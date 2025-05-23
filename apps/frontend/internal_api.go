// internal_api.go (或 jobdone.go)
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings" // <--- 加入這一行
	// 需要引入 ReturnMessage 的定義，如果它在別的 package
)


// HandleJobUpdate 處理來自 Worker 的狀態更新通知
func HandleJobUpdate(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		return
	}

	var msg ReturnMessage
	// 從請求 Body 解析 JSON 資料
	decoder := json.NewDecoder(r.Body)
	if err := decoder.Decode(&msg); err != nil {
		log.Printf("ERROR decoding job update message: %v", err)
		http.Error(w, "Bad Request: Invalid JSON payload", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	// 驗證收到的資料 (可選但推薦)
	if msg.TaskID == "" {
		http.Error(w, "Bad Request: Missing taskID", http.StatusBadRequest)
		return
	}
	// 可以加入更多驗證，例如檢查 Status code 是否有效

	log.Printf("INFO: Received internal job update notification for TaskID: %s, Status: %d", msg.TaskID, msg.Status)

	// *** 呼叫現有的函數來更新記憶體狀態 ***
	err := UpdateJobsViaTaskID(msg) // 這個函數在 jobs.go 中定義

	if err != nil {
		// 如果 UpdateJobsViaTaskID 返回錯誤 (例如找不到 TaskID)
		log.Printf("ERROR updating job status via internal notification (TaskID: %s): %v", msg.TaskID, err)
		// 根據錯誤類型返回不同的狀態碼
		if strings.Contains(err.Error(), "No job id") {
			http.Error(w, "Not Found: "+err.Error(), http.StatusNotFound)
		} else {
			http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		}
		return
	}

	// 更新成功，返回成功訊息
	w.WriteHeader(http.StatusOK)
	fmt.Fprintln(w, "Job status updated successfully for TaskID:", msg.TaskID)
	log.Printf("INFO: Successfully updated status in memory for TaskID: %s via internal notification", msg.TaskID)

    // 觸發保存 (如果 SaveJobs 不是自動的)
    // if NeedSave {
    //     go func() { // 異步保存避免阻塞請求
    //         if err := SaveJobs(Joblistz); err != nil {
    //              log.Printf("ERROR saving jobs after internal update (TaskID: %s): %v", msg.TaskID, err)
    //         } else {
    //              log.Printf("INFO: Jobs saved to file after internal update (TaskID: %s)", msg.TaskID)
    //         }
    //     }()
    // }
}

// 你需要在 router.go (或設定路由的地方) 添加這個 Handler
// 例如: mux.HandleFunc("POST /internal/job-update", HandleJobUpdate)