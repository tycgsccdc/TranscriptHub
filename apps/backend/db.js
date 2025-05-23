// db.js - Database connection module
const sql = require('mssql');
const cfg = require('./config.js');
const { LOG_LEVEL, TASK_STATUS, NOTIFY_STATUS } = require('./constants.js');
const { TASK_QUERIES } = require('./query_constants.js');


// Create and export the connection pool
const pool_promise = new sql.ConnectionPool(cfg.sql_config)
  .connect()
  .then(pool => {
    console.log('Database connected successfully');
    // logger(LOG_LEVEL.INFO, 'Database connected successfully');
    // console.log(generate_timestamp() + ` - INFO - [${process.pid}] Database connected successfully.`);
    return pool;
  })
  .catch(err => {
    console.error('Database connection failed:', err);
    // logger(LOG_LEVEL.ERROR, `Database connection failed: ${err}`);
    // console.error(generate_timestamp() + ` - ERROR - [${process.pid}] Database connection failed: ${err}`);
    throw err;
  });

async function log_operation_to_db(data) {
  /* Query syntax */
  const query_log_operation = TASK_QUERIES.ACCESS_OPERTION.LOG_OPERATION;
  const query_log_operation_error = TASK_QUERIES.ACCESS_OPERTION.LOG_OPERATION_ERROR;

  try {
    const pool = await pool_promise;
    await pool.request()
      .input('token', sql.NVarChar, data.token || '')
      .input('ip_address', sql.NVarChar, data.ip_address || '')
      .input('sso_account', sql.NVarChar, data.sso_account || '')
      .input('query_time', sql.NVarChar, data.query_time || '')
      .input('process_id', sql.NVarChar, data.process_id || '')
      .input('code', sql.NVarChar, data.code || '')
      .input('route', sql.NVarChar, data.route || '')
      .input('ref', sql.BigInt, data.ref)
      .input('log', sql.NVarChar, data.log || '')
      .query(query_log_operation);
    } catch (err) { // err 是數據庫操作失敗的 Error 對象
      console.error(`[${process.pid}] Error in primary log operation. Attempting to log error to DB:`, err); // 先打印原始錯誤
  
      // 將 Error 對象轉換為字串，優先使用 stack，其次 message
      let errorString = 'Unknown DB logging error'; // 預設值
      if (err instanceof Error) { // 確保 err 真的是 Error 對象
        errorString = err.stack || err.message; // 獲取堆棧或消息
      } else if (typeof err === 'string') {
        errorString = err; // 如果 err 本身就是字串
      } else {
        try {
           errorString = JSON.stringify(err); // 最後嘗試序列化
        } catch (stringifyError) {
           errorString = 'Failed to stringify error object';
        }
      }
  
      // 確保錯誤字串不會太長，如果資料庫欄位有限制的話
      const maxErrorLength = 4000; // 假設 NVarChar(4000) 或 MAX
      if (errorString.length > maxErrorLength) {
        errorString = errorString.substring(0, maxErrorLength - 3) + '...';
      }

  
      try { // 再加一個 try...catch 以防記錄錯誤的操作本身又失敗
          const pool = await pool_promise; // 再次獲取 pool (或確保它在外部可用)
          await pool.request()
            .input('token', sql.NVarChar, data.token || '')
            .input('ip_address', sql.NVarChar, data.ip_address || '')
            .input('sso_account', sql.NVarChar, data.sso_account || '')
            .input('query_time', sql.NVarChar, data.query_time || '')
            .input('process_id', sql.NVarChar, data.process_id || '')
            .input('code', sql.NVarChar, data.code || '-1') // 保留原 code 或用特定錯誤碼
            .input('route', sql.NVarChar, data.route || '')
            .input('ref', sql.BigInt, data.ref)
            // <<< 使用轉換後的 errorString >>>
            .input('err', sql.NVarChar, errorString) // <<< 主要修改處
            .query(query_log_operation_error);
          console.error(`[${process.pid}] Successfully logged primary log operation error to DB.`);
      } catch (logErrErr) {
          // 如果連記錄錯誤都失敗了，只能打印到控制台
          console.error(`[${process.pid}] CRITICAL: Failed to log logging error to DB:`, logErrErr);
          console.error(`[${process.pid}] Original error that failed primary logging was:`, err); // 打印原始錯誤
      }
    }
  }

module.exports = {
  // sql_db,
  pool_promise,
  log_operation_to_db
};

