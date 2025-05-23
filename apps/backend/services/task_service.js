const sql = require('mssql');
const { exec } = require('child_process');
const fs = require('fs')
const path = require('path');
const axios = require('axios'); // <--- 加入這一行

const cfg = require('../config.js');
const { logger } = require('../logger.js');
const { pool_promise } = require('../db.js');

const { 
  get_worker_pids, 
  set_worker_pids, 
  add_worker_pid, 
  remove_worker_pid,
  operation_memo
} = require('../shared.js');

const { LOG_LEVEL, NOTIFY_STATUS, TASK_STATUS } = require('../constants.js');
const { TASK_QUERIES } = require('../query_constants.js');

const { __MSSQL_TEST__ } = require('../env.js');

/**
 * @brief Create new transcription task in database
 *
 * @param data [in] Task creation parameters:
 *   - label:            Task label/name
 *   - original_filename Original uploaded filename
 *   - new_filename     System assigned filename
 *   - status          Initial task status
 *   - route           API endpoint route
 *   - pid            Process ID handling task
 *   - sso_account    User account
 *   - file_size      File size in bytes
 *   - diarize        Speaker diarization flag
 *   - duration       Media duration in seconds
 *
 * @return Task OBJID if successful
 * @throws Error if creation fails or no record found
 *
 * Operation Flow:
 * 1. Insert task record
 * 2. Query inserted record by filename
 * 3. Log creation with task details
 *
 * @note Creates ISO string timestamp for logging
 * @note Throws error if inserted record not found
 */
async function create_task(data) {
  const query_insert_task = TASK_QUERIES.CREATE_TASK.INSERT_TASK;
  const query_get_task_by_filename = TASK_QUERIES.CREATE_TASK.GET_TASK_BY_FILENAME;
  try {
    const pool = await pool_promise;
    await pool.request()
      .input('label', sql.NVarChar, data.label)
      .input('original_filename',sql.NVarChar, data.original_filename)
      .input('new_filename', sql.NVarChar, data.new_filename)
      .input('status', sql.INT, data.status)
      .input('route', sql.NVarChar, data.route)
      .input('pid', sql.INT, data.pid)
      .input('sso_account', sql.NVarChar, data.sso_account)
      .input('file_size', sql.INT, data.file_size)
      .input('diarize', sql.INT, data.diarize)
      .input('duration', sql.FLOAT, data.duration)
      .query(query_insert_task);

    // Get created task
    const result = await pool.request()
      .input('filename', sql.NVarChar, data.new_filename)
      .query(query_get_task_by_filename);
      // .query(`SELECT * FROM TASK WHERE FILENAME=@filename`);

      // Validate query result
      if (!result || !result.recordset) {
        throw new Error('Invalid query result structure');
      }

      if (result.recordset.length === 0) {
        throw new Error('No record found after insert');
      }
      
      if (result.recordset.length > 1) {
        throw new Error(`Duplicate records found for filename ${data.new_filename}`);
      }
  
      // Log success and return task ID
      const task = result.recordset[0];
      task.CREATE_AT = new Date(task.CREATE_AT).toISOString();
      
      logger(LOG_LEVEL.INFO, `Task ${task.OBJID} created successfully`);
      logger(LOG_LEVEL.INFO_TABLE, task);
      
      return task.OBJID;  
  } catch (err) {
    logger(LOG_LEVEL.ERROR, `create_task failed ${err}.`);
    throw err;
  }
}

/**
 * @brief Select next available task for processing
 * 
 * @return Task record or null if no task available
 * 
 * Selection Logic:
 * 1. No running tasks (STATUS=1) in system
 * 2. Task status is NEW(0) or RETRY(-2,-3)
 * 3. Task not finished and has content
 * 4. Prioritize NEW tasks over RETRY
 * 
 * @note Ensures single task execution across processes
 */
async function select_task() {
  const query_select_task = TASK_QUERIES.SELECT_TASK;
  // IMPORTANT!!!!  The NOT EXISTS line ensures that even if there are multiple processes, 
  // only one process is executing at any given time, meaning if a task is in status=1, 
  // other processes will not proceed to process other tasks with status=0.  
  // SQL statment:
  // WITH T AS (
  //   SELECT * 
  //     FROM TASK
  //    WHERE (STATUS=0 AND PID = ${process.pid})
  //       OR STATUS=-2
  //       OR STATUS=-3
  // )
  // SELECT TOP 1 *
  //   FROM T
  //  WHERE NOT EXISTS (SELECT 1 FROM TASK WHERE STATUS=1)
  //    AND FINISH_AT IS NULL
  //    AND FILE_SIZE > 0
  //    AND IS_DELETE IS NULL
  //  ORDER BY 
  //   CASE WHEN STATUS=0 THEN 0 ELSE 1 END,
  //   CASE WHEN STATUS=0 THEN CREATE_AT END,
  //   CASE WHEN STATUS=-2 OR STATUS=-3 THEN RETRY END;
  // 

  try {
    const pool = await pool_promise;
    const result = await pool.request()
      .input('pid', sql.Int, process.pid)
      .query(query_select_task);

    // Currently no unexecuted tasks
    if (!result.recordset.length) {
      return null;
    }

    const task = result.recordset[0];
    const memo = operation_memo({ ref: task.OBJID });
    
    task.CREATE_AT = new Date(task.CREATE_AT).toISOString();
    
    logger(LOG_LEVEL.INFO, `Task ${task.OBJID} selected for execution`, memo);
    logger(LOG_LEVEL.INFO_TABLE, task);

    return task;
  } catch (err) {
    logger(LOG_LEVEL.ERROR, `select_task ${err}.`, operation_memo({}));

    // No need to throw err, just return null or an empty array if preferred
    return null; 
  }
}    

/**
 * @brief Cancel a transcription task by ID
 *
 * @param data [in] Task cancellation parameters:
 *   - objid [BigInt] Task identifier to cancel
 *
 * @return SQL result object containing:
 *   - rowsAffected: Number of tasks cancelled
 *   - recordset: Updated task record
 *
 * @throws Error if cancellation fails
 * 
 * Operation Flow:
 * 1. Update task status to cancelled
 * 2. Set finish time to current timestamp
 * 3. Clear assigned PID
 *
 * @note Task files are not automatically deleted
 * @note Only cancels tasks that aren't completed
 */
async function cancel_task(data) {
  const query_cancel_task = TASK_QUERIES.CANCEL_TASK;
  try {
    const pool = await pool_promise;
    const result = await pool.request()
      .input('objid', sql.BigInt, data.objid)
      .query(query_cancel_task);

    return result
  } catch (err) {
    logger(LOG_LEVEL.ERROR, `cancel_task ${err}.`);
    throw err;
  }
}

/**
 * @brief Clean up abandoned or stale tasks in the system
 * 
 * @note No input parameters - uses global worker PIDs
 * @return void - Logs results or errors
 * 
 * Operation Flow:
 * 1. Get active worker PIDs
 * 2. Build SQL query with PID filter
 * 3. Clean tasks that are:
 *    - Not finished (FINISH_AT IS NULL)
 *    - Not owned by active workers
 *    - In status NEW(0), RUNNING(1), or RETRY(-3)
 * 
 * SQL Table Parameter:
 * - In test mode: Uses table-valued parameter for PIDs
 * - In prod mode: Uses comma-separated PID list
 * 
 * @note Requires worker PIDs to be initialized
 * @note Different behavior in test vs production mode
 * @note Logs cleanup count on success
 */
/**
 * @brief Clean up abandoned or stale tasks in the system
 *
 * @note No input parameters - uses global worker PIDs
 * @return void - Logs results or errors
 *
 * Operation Flow:
 * 1. Get active worker PIDs
 * 2. Build SQL query with PID filter
 * 3. Clean tasks that are:
 *    - Not finished (FINISH_AT IS NULL)
 *    - Not owned by active workers (unless no PIDs provided)
 *    - In status NEW(0), RUNNING(1), or RETRY(-3)
 *
 * SQL Table Parameter:
 * - In test mode: Uses table-valued parameter for PIDs
 * - In prod mode: Uses comma-separated PID list
 *
 * @note Requires worker PIDs to be initialized
 * @note Different behavior in test vs production mode
 * @note Logs cleanup count on success
 */
async function cleanup_task() {
  // 獲取基礎的 UPDATE 查詢語句
  let query_cleanup_task = TASK_QUERIES.CLEANUP_TASK; // Example: "UPDATE TASK SET STATUS = -2, PID = @pid, RETRY = RETRY - 1 WHERE STATUS IN (0, 1, -3) AND FINISH_AT IS NULL"

  // 獲取當前活躍的 worker PIDs，並轉換為逗號分隔的字串
  let pids_for_query_string = get_worker_pids().join(',');
  const memo = operation_memo({}); // 初始化 memo 對象

  let table; // 用於測試模式的 table-valued parameter

  // 檢查是否有活躍的 worker PIDs
  let has_active_pids = false;

  if (__MSSQL_TEST__) {
    // --- 測試模式處理 ---
    const pids_array = get_worker_pids()
      .map(id => parseInt(id, 10)) // 確保是數字
      .filter(Number.isFinite); // 過濾掉非數字

    logger(LOG_LEVEL.INFO, 'cleanup_task pids (test mode): ' + pids_array.join(','));

    table = new sql.Table(); // 假設 IntList 類型已在 SQL Server 中定義
    table.columns.add('value', sql.Int);
    if (pids_array.length > 0) {
        pids_array.forEach(pid => table.rows.add(pid));
        query_cleanup_task += ' AND (PID IS NULL OR PID NOT IN (SELECT value FROM @pids))';
        has_active_pids = true;
    } else {
        // 測試模式下如果沒有 PID，可以選擇不添加 NOT IN 條件，清理所有符合狀態的任務
        // 或者添加一個永遠為真的條件？ 這裡選擇不添加，讓基礎查詢執行
        logger(LOG_LEVEL.WARN, 'cleanup_task (test mode): No active PIDs found. Cleanup might affect all eligible tasks.');
    }
    // --- 測試模式結束 ---
  } else {
    // --- 生產模式處理 ---
    if (pids_for_query_string.length > 0) {
      // 這裡需要確保 pids_for_query_string 是安全的，只包含數字和逗號
      // 實際生產中可能需要更嚴格的驗證來防止 SQL Injection
      // 假設 get_worker_pids() 返回的是可靠的數字 PID 陣列
      query_cleanup_task += ` AND (PID IS NULL OR PID NOT IN (${pids_for_query_string}))`;
      has_active_pids = true;
    } else {
      // 生產模式下如果沒有 PID，通常意味著沒有活躍的 worker，可能不需要執行清理
      // 或者執行基礎查詢清理所有未完成的？ 這裡選擇記錄警告並可能跳過
      logger(LOG_LEVEL.WARN, `cleanup_task: No active worker PIDs found (pids_for_query is empty). Skipping PID-based exclusion.`);
      // 如果確定沒 PID 就完全不清理，可以在這裡 return
      // return;
    }
    // --- 生產模式結束 ---
  }

  // 執行資料庫操作
  try {
    const pool = await pool_promise;
    const request = pool.request();

    // --- 關鍵：為 SET PID = @pid 提供參數值 ---
    // 使用當前執行 cleanup_task 的這個進程的 PID
    request.input('pid', sql.Int, process.pid);
    // -----------------------------------------

    // 如果是測試模式且有 PIDs，綁定 table-valued 參數
    if (__MSSQL_TEST__ && has_active_pids) {
      request.input('pids', table);
    }

    // Log the final query for debugging
    //logger(LOG_LEVEL.DEBUG, `Executing cleanup query: ${query_cleanup_task}`);
    const result = await request.query(query_cleanup_task);

    // 記錄清理結果
    if (result.rowsAffected && result.rowsAffected.length > 0 && result.rowsAffected[0] > 0) {
      logger(LOG_LEVEL.INFO, `cleanup_task clean up ${result.rowsAffected[0]} records.`, memo);
    } else {
      // logger(LOG_LEVEL.INFO, `cleanup_task: No records needed cleaning based on current criteria.`, memo);
    }
  } catch (err) {
    // 記錄執行清理查詢時發生的錯誤
    logger(LOG_LEVEL.ERROR, `cleanup_task execution failed: ${err}. Query attempted: ${query_cleanup_task}`, memo);
    // 這裡不需要再嘗試記錄到數據庫，避免循環錯誤
  }
}



/**
 * @brief Query current status of a transcription task
 *
 * @param data [in] Task query parameters:
 *   - objid [BigInt] Task identifier to check
 *
 * @return SQL result object containing:
 *   - recordset: Task record with current status
 *   - rowsAffected: Number of records found
 * @throws Error if query fails
 *
 * @note Returns all task fields from database
 * @note Throws error instead of returning null
 */
async function check_task_status(data) {
  const query_task_status = TASK_QUERIES.CHECK_TASK_STATUS;
  try {
    const pool = await pool_promise;
    const result = await pool.request()
      .input('objid', sql.BigInt, data.objid)
      .query(query_task_status);
      return result;
  } catch (err) {
    logger(LOG_LEVEL.ERROR, `check_task_status ${err}.`);
    throw err;
  }
}


/**
 * @brief List all transcription tasks with optional filters
 *
 * @param data [in] Query filter parameters:
 *   - label       [string] Task label filter or 'all'
 *   - sso_account [string] User account filter or 'all'
 *   - status      [number] Task status filter (-3 to 2) or undefined
 *
 * @return SQL result object containing:
 *   - recordset: Array of task records
 *   - rowsAffected: Number of tasks found
 * @return null if query fails
 *
 * Filters:
 * - Tasks created within configured days limit
 * - Optional label match
 * - Optional user account match
 * - Optional status match
 * 
 * @note Results ordered by CREATE_AT descending
 * @note Returns null instead of throwing errors
 */
async function view_all_tasks(data) {
  const { label, sso_account, status } = data;
  let query = TASK_QUERIES.VIEW_ALL_TASK;
  // Build dynamic WHERE clause
  const conditions = [];
  if (label !== 'all') conditions.push('LABEL = @LABEL');
  if (sso_account !== 'all') conditions.push('SSO_ACCOUNT = @SSO_ACCOUNT');
  if ([-3, -2, -1, 0, 1, 2].includes(status)) conditions.push('STATUS = @STATUS');
  conditions.push(`datediff(day, CREATE_AT, getdate()) < ${cfg.tasks.days_limit}`);  // Only show tasks created within the last 30 days

  // Append WHERE clause if conditions exist
  if (conditions.length > 0) query += ' WHERE ' + conditions.join(' AND ');
  query += ' ORDER BY CREATE_AT desc';

  try {
    // Get pool connection from pool_promise
    const pool = await pool_promise;
    const request = pool.request();

    // Conditionally bind parameters
    if (label !== 'all') request.input('LABEL', sql.NVarChar, label);
    if (sso_account !== 'all') request.input('SSO_ACCOUNT', sql.NVarChar, sso_account);
    if ([-3, -2, -1, 0, 1, 2].includes(status)) request.input('STATUS', sql.Int, status);

    // Execute the query and return results
    return await request.query(query);
  } catch (err) {
    logger(LOG_LEVEL.ERROR, `view_all_tasks: ${err}`);
    return null;  // No need to throw, just return null or an empty array if preferred
  }
}

 
async function cleanup_task_() {
  //const worker_pids_array = Array.from(worker_pids);  // convert Set to Array
  
  //const pids_for_query = process_sync_worker_pids.join(','); 
  const pids_for_query = get_worker_pids().join(','); // note
  //logger(LOG_LEVEL.INFO, `PIDs: ${process_sync_worker_pids}`);


  let where_pid_clause = '';

  if (pids_for_query.length > 0) {
    where_pid_clause = `AND (PID IS NULL OR PID NOT IN (${pids_for_query}))`;
  } else {
    // where_pid_clause = `AND PID IS NULL`;
    return logger(LOG_LEVEL.ERROR, `cleanup_task pids_for_query is empty.`, memo);
  }

  // set status = UPDATE_STATUS.TERMINATED
  const query = `
    UPDATE TASK
        SET STATUS = -2,
            PID = ${process.pid},
            RETRY = RETRY - 1
      WHERE STATUS IN (0, 1, -3)
        AND FINISH_AT IS NULL
        ${where_pid_clause};
    `;
    // AND (PID IS NULL OR PID NOT IN (${pids_for_query}));
  const memo = operation_memo({});
  try {
    const pool = await pool_promise;
    const result = await pool.request().query(query);
      
    if (result.rowsAffected[0] > 0) {
      logger(LOG_LEVEL.INFO, `cleanup_task clean up ${result.rowsAffected[0]} records.`, memo);
    } 
  } catch (err) {
    logger(LOG_LEVEL.ERROR, `cleanup_task ${err}.`, memo);
  }
}      

/**
 * @brief Update transcription task status and details
 *
 * @param data [in] Task update parameters:
 *   - objid          [BigInt] Task identifier
 *   - status         [Int] New task status (IN_PROGRESS/COMPLETED/TERMINATED/FILE_IO_ERROR)
 *   - transcribe     [Int] Transcription result flag
 *   - content_length [Int] Content size in bytes
 *   - pid           [Int] Process ID handling task
 *
 * @return void - Logs update result
 *
 * Status Updates:
 * - IN_PROGRESS:  Task being processed
 * - COMPLETED:    Task finished successfully
 * - TERMINATED:   Task cancelled or failed
 * - FILE_IO_ERROR: File operation failed
 *
 * @note Uses different SQL queries based on status
 * @note Logs status change with task ID
 */
async function update_task(data) {
  var query = ``;
  let isCompletionUpdate = false; // 標記是否是完成狀態的更新

  // 根據傳入的 status 選擇對應的 SQL 更新語句
  if (data.status == TASK_STATUS.IN_PROGRESS)
    query = TASK_QUERIES.UPDATE_TASK_STATUS.IN_PROGRESS;

  if (data.status == TASK_STATUS.COMPLETED) {
    query = TASK_QUERIES.UPDATE_TASK_STATUS.COMPLETED;
    isCompletionUpdate = true; // 標記為完成更新
  }

  if (data.status == TASK_STATUS.TERMINATED)
    query = TASK_QUERIES.UPDATE_TASK_STATUS.TERMINATED;

  if (data.status == TASK_STATUS.FILE_IO_ERROR)
    query = TASK_QUERIES.UPDATE_TASK_STATUS.FILE_IO_ERROR;

  // 如果 query 仍然是空的，表示傳入了未知的 status，記錄錯誤並返回
  if (query === ``) {
    logger(LOG_LEVEL.ERROR, `update_task called with unknown status: ${data.status} for objid: ${data.objid}`);
    return; // 或者可以考慮 throw new Error(...) 向上層報告錯誤
  }

  try {
    const pool = await pool_promise;

    // --- 執行資料庫狀態更新 ---
    const dbResult = await pool.request() // 使用 await 確保操作完成
      .input('objid', sql.BigInt, data.objid)
      .input('transcribe', sql.INT, data.transcribe)       // 傳遞 transcribe 參數
      .input('content_length', sql.INT, data.content_length) // 傳遞 content_length 參數
      .input('pid', sql.INT, data.pid)                   // 傳遞 pid 參數
      .query(query);

    // --- 資料庫更新成功後的日誌 ---
    const status_name = Object.keys(TASK_STATUS).find(key => TASK_STATUS[key] == data.status);
    // 確保 status_name 找到了對應的名稱，否則使用原始數字
    const statusNameToLog = status_name ? status_name : `Unknown(${data.status})`;
    logger(LOG_LEVEL.INFO, `Update the status of task ${data.objid} to ${statusNameToLog}.`);

    // --- 如果是完成狀態，嘗試發送通知給 Go 後端 ---
    if (isCompletionUpdate) {
      // 從環境變數或設定檔獲取 Go 後端的內部 API URL
      const goBackendNotifyUrl = process.env.GO_BACKEND_NOTIFY_URL || cfg.go_backend_notify_url;
      logger(LOG_LEVEL.INFO, `DEBUG: GO_BACKEND_NOTIFY_URL value is: '${goBackendNotifyUrl}' (Type: ${typeof goBackendNotifyUrl})`);

      if (!goBackendNotifyUrl) {
        logger(LOG_LEVEL.ERROR, `Go backend notification URL (GO_BACKEND_NOTIFY_URL or cfg.go_backend_notify_url) is not configured. Cannot notify frontend for task ${data.objid}.`);
      } else {
        // 為了包含 FileName，需要再次查詢資料庫獲取
        let systemFileName = "";
        try {
          const taskInfoResult = await pool.request()
            .input('objid', sql.BigInt, data.objid)
            .query('SELECT FILENAME FROM [AI_AP].[dbo].[TASK] WHERE OBJID = @objid');
          if (taskInfoResult.recordset && taskInfoResult.recordset.length > 0) {
            systemFileName = taskInfoResult.recordset[0].FILENAME;
          } else {
            logger(LOG_LEVEL.WARN, `Could not find FILENAME for task ${data.objid} when preparing notification.`);
            // 即使找不到檔名，也可能需要繼續嘗試通知（如果 Go 不需要檔名也能工作）
            // 但如果 Go 端需要 FileName，這裡應該記錄更嚴重的錯誤或跳過通知
          }
        } catch (dbError) {
          logger(LOG_LEVEL.ERROR, `Error fetching FILENAME for notification (TaskID: ${data.objid}): ${dbError}`);
          // 獲取檔名失敗，可能無法發送包含檔名的完整通知
          // 根據需求決定是否繼續發送不含檔名的通知
        }

        const taskIDStr = data.objid.toString(); // 將 BigInt OBJID 轉為字串
        // **重要**: 再次確認這個列表是否與 Go 後端期望的一致
        const resultsList = ["TXT", "SRT", "VTT", "TSV", "JSON"];
        // **重要**: 再次確認 TASK_STATUS.COMPLETED 的值 (假設是 2)
        const finalStatusCodeInt = parseInt(TASK_STATUS.COMPLETED, 10);

        if (isNaN(finalStatusCodeInt)) {
          logger(LOG_LEVEL.ERROR, `Invalid TASK_STATUS.COMPLETED value: ${TASK_STATUS.COMPLETED}. Cannot format notification payload.`);
        } else {
          // 構建 payload，鍵名嚴格匹配 Go ReturnMessage 的 JSON 標籤
          const payload = {
            message: "Task completed", // Go struct 有此欄位
            task_objid: taskIDStr,       // 匹配 `json:"task_objid"`
            status: finalStatusCodeInt, // 匹配 `json:"status"` (傳遞數字 2)
            results: resultsList,       // 匹配 `json:"results"`
            filename: systemFileName    // 匹配 `json:"filename"`
          };
          logger(LOG_LEVEL.INFO, `Attempting to notify Go backend at ${goBackendNotifyUrl} for completed task ${taskIDStr} with payload: ${JSON.stringify(payload)}`);

          // --- 使用 axios 發送 POST 請求 ---
          try {
            const response = await axios.post(goBackendNotifyUrl, payload, {
              headers: { 'Content-Type': 'application/json' },
              timeout: 5000 // 5 秒超時
            });

            // 檢查 Go 後端的回應
            if (response.status === 200) {
              logger(LOG_LEVEL.INFO, `Successfully notified Go backend for task ${taskIDStr}. Response: ${response.data}`);
            } else {
              // Go 後端返回了非 200 的狀態碼
              logger(LOG_LEVEL.WARN, `Go backend notification for task ${taskIDStr} returned status ${response.status}: ${response.data}`);
            }
          } catch (notifyError) {
            // axios 請求本身出錯 (網路、超時、Go服務器錯誤等)
            logger(LOG_LEVEL.ERROR, `Failed to notify Go backend for task ${taskIDStr}: ${notifyError.message}`);
            if (notifyError.response) {
              // 如果錯誤包含來自 Go 的回應，記錄下來
              logger(LOG_LEVEL.ERROR, `Go backend notification error details: Status ${notifyError.response.status}, Data: ${JSON.stringify(notifyError.response.data)}`);
            } else if (notifyError.request) {
              // 請求已發出但沒有收到回應
              logger(LOG_LEVEL.ERROR, `Go backend notification error: No response received for task ${taskIDStr}. Request details: ${notifyError.request}`);
            } else {
              // 設置請求時出錯
              logger(LOG_LEVEL.ERROR, `Go backend notification error: Error setting up request for task ${taskIDStr}: ${notifyError.message}`);
            }
            // 即使通知失敗，也不向上拋出錯誤，因為資料庫更新可能已成功
          }
          // --- 通知邏輯結束 ---
        } // end if (!isNaN(finalStatusCodeInt))
      } // end if (!goBackendNotifyUrl)
    } // end if (isCompletionUpdate)

    // 函數正常結束
    return;

  } catch (err) {
    // 捕獲資料庫更新或其他在 try 塊中發生的錯誤
    logger(LOG_LEVEL.ERROR, `update_task failed for objid ${data.objid}: ${err}.`);
    // 根據需要，可以選擇在這裡向上拋出錯誤
    // throw err;
  }
}
/**
 * @brief Get file path for task transcription result
 *
 * @param filename  [in] Base filename without extension
 * @param file_type [in] Output format (TXT/SRT/VTT/TSV/JSON)
 * @return Full path to result file
 * @throws Error if file does not exist
 *
 * Supported Types:
 * - TXT: Plain text transcript
 * - SRT: SubRip subtitle format
 * - VTT: WebVTT subtitle format
 * - TSV: Tab-separated values
 * - JSON: Structured data format
 *
 * @note Uses paths defined in config.js
 * @note Extensions are forced to lowercase
 */
// task_service.js (修改 get_task_result_path)

async function get_task_result_path(filenameWithExt, file_type) { // 修改參數名以示區分
  // Define paths for each file type in the configuration
  const download_paths = {
    TXT: 'transcribe_txt_path',
    SRT: 'transcribe_srt_path',
    VTT: 'transcribe_vtt_path',
    TSV: 'transcribe_tsv_path',
    JSON: 'transcribe_json_path'
  };

  // 檢查 file_type 是否有效
  if (!download_paths[file_type]) {
      throw new Error(`Unsupported file type requested: ${file_type}`);
  }

  // *** 新增：去除原始檔名中的副檔名 ***
  const filenameBase = path.parse(filenameWithExt).name; // 使用 path.parse().name 获取不含扩展名的部分
  // 例如 "audiofile-123.mp3" -> "audiofile-123"

  // 使用去除副檔名的基礎名稱來拼接最終路徑
  const file_path = path.join(cfg.paths[download_paths[file_type]], `${filenameBase}.${file_type.toLowerCase()}`);
  // 現在會拼接成 C:\...\txt\audiofile-1745894216569.txt

  logger(LOG_LEVEL.DEBUG, `[get_task_result_path] Trying to access file at path: ${file_path}`); // 增加調試日誌

  if (!fs.existsSync(file_path)) {
    // 如果檔案仍然不存在，記錄更詳細的信息
    logger(LOG_LEVEL.ERROR, `[get_task_result_path] File does not exist at calculated path: ${file_path}. Original filename input: ${filenameWithExt}, type: ${file_type}`);
    throw new Error(`The file ${file_path} does not exist.`);
  }

  return file_path;
}

module.exports = {
  create_task,
  select_task,
  cancel_task,
  view_all_tasks,
  cleanup_task,
  check_task_status,
  update_task,
  get_task_result_path
};