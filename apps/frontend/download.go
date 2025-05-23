// download.go (完整修改版 - 基於記憶體 Joblistz)
package main

import (
	// "crypto/tls" // 考慮移除 InsecureSkipVerify
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"
	// "database/sql" // 使用記憶體版本，不需要
	// _ "github.com/denisenkom/go-mssqldb" // 使用記憶體版本，不需要
	// 不需要 "path" 了
)

// --- 移除 GetRealName 函數 ---
// func GetRealName(results []string, ftype string)(string) { ... }

// --- 移除 getFileName 函數 ---
// func getFileName(fileURL string, contentDisposition string) string { ... }

// ResultDownload 處理 /result/{taskID}/{fileType} 的下載請求
// 從記憶體 Joblistz 讀取 Job 資訊，並代理到外部 DownloadServer
func ResultDownload(w http.ResponseWriter, r *http.Request) {
	// 1. 身份驗證
	userinfo, err := GetUserInfoViaBearer(w.Header().Get("Authorization"))
	if err != nil {
		log.Printf("WARN: Unauthorized attempt to download result: %v", err)
		http.Error(w, "Unauthorized: Invalid credentials", http.StatusUnauthorized)
		return
	}

	// 2. 獲取路徑參數
	taskID := r.PathValue("taskID") // 這是 OBJID 的字串形式
	ftype := r.PathValue("fileType") // 例如 "TXT", "SRT"

	if taskID == "" || ftype == "" {
		log.Printf("WARN: Missing taskID or fileType in result download request")
		http.Error(w, "Bad Request: Missing taskID or fileType", http.StatusBadRequest)
		return
	}

	// 3. 從記憶體 Joblistz 讀取 Job 資訊
	// 依賴同 package 下的 ReadJobsViaTaskID(taskID string) (Job, error) 函數
	job, err := ReadJobsViaTaskID(taskID) // <--- 從記憶體讀取
	if err != nil {
		log.Printf("ERROR reading job for result download (TaskID: %s) from memory: %v", taskID, err)
		if strings.Contains(err.Error(), "not found") {
			http.Error(w, "Not Found: Job "+taskID+" not found.", http.StatusNotFound)
		} else {
			http.Error(w, "Internal Server Error retrieving job details", http.StatusInternalServerError)
		}
		return
	}

	// 4. 權限檢查
	if job.Owner != userinfo.Email {
		log.Printf("WARN: Forbidden attempt to download result by wrong user (Owner: %s, Requester: %s, TaskID: %s)", job.Owner, userinfo.Email, taskID)
		http.Error(w, "Forbidden: You do not own this job.", http.StatusForbidden)
		return
	}

	// 5. 狀態檢查 (確保與 UpdateJobsViaTaskID 中設置的完成狀態字串一致)
	if job.Status != "Done" { // *** 如果 UpdateJobsViaTaskID 設為 "完成", 這裡也要檢查 "完成" ***
		log.Printf("INFO: Download denied because job status is not Done (TaskID: %s, Status: %s)", taskID, job.Status)
		http.Error(w, "Forbidden: Job is not yet complete or encountered an error.", http.StatusForbidden)
		return
	}

	// 6. 獲取必要的標識符
	// taskID := job.TaskID     // 已經從路徑參數獲取
	systemFileName := job.FileName // <-- 使用儲存在 Job 結構中的系統檔名 (例如 audiofile-...)

	if taskID == "" || systemFileName == "" {
		log.Printf("ERROR: TaskID or FileName is empty for completed job (TaskID: %s, FileName: %s)", taskID, systemFileName)
		http.Error(w, "Internal Server Error: Missing necessary job identifiers", http.StatusInternalServerError)
		return
	}


	// 7. 構建外部下載 URL
	downloadServerURL := os.Getenv("DownloadServer")
	if downloadServerURL == "" {
		log.Printf("ERROR: DownloadServer environment variable not set.")
		http.Error(w, "Internal Server Error: Server configuration missing", http.StatusInternalServerError)
		return
	}
	if !strings.HasSuffix(downloadServerURL, "/") {
		downloadServerURL += "/"
	}

	// *** 關鍵修改：URL 路徑中使用 systemFileName，查詢參數中包含 owner 和 taskID ***
	fileURL := fmt.Sprintf("%s%s/%s?sso_account=%s&task_objid=%s",
		downloadServerURL,
		url.PathEscape(ftype),            // 格式類型
		url.PathEscape(systemFileName),   // <-- 在路徑中使用系統檔名
		url.QueryEscape(job.Owner),       // SSO 帳號
		url.QueryEscape(taskID),          // 任務 OBJID
	)
	log.Printf("INFO: Attempting to proxy download from URL: %s", fileURL)

	// 8. 代理下載
	client := &http.Client{Timeout: 60 * time.Second} // 使用預設 Transport
	resp, err := client.Get(fileURL)
	if err != nil {
		log.Printf("ERROR fetching file from remote server (%s): %v", fileURL, err)
		http.Error(w, "Internal Server Error: Could not retrieve file from remote server.", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		bodyBytes, _ := io.ReadAll(resp.Body) // 嘗試讀取錯誤回應
		log.Printf("ERROR: Remote download server returned status %s for URL %s. Response Body: %s", resp.Status, fileURL, string(bodyBytes))
		// 向客戶端返回更通用的網關錯誤
		http.Error(w, "Bad Gateway: Error retrieving file from storage.", http.StatusBadGateway)
		return
	}

	// 9. 設置下載回應頭
	// **** 使用 systemFileName (去除副檔名) + ftype 作為下載檔名 ****
	originalBase := systemFileName // <-- 使用 systemFileName
	if idx := strings.LastIndex(originalBase, "."); idx != -1 {
		originalBase = originalBase[:idx] // 去除副檔名 (如果 systemFileName 包含)
	}
	downloadFilename := fmt.Sprintf("%s.%s", originalBase, strings.ToLower(ftype))
	// 清理檔名
	downloadFilename = strings.ReplaceAll(downloadFilename, "/", "_")
	downloadFilename = strings.ReplaceAll(downloadFilename, "\\", "_")
	downloadFilename = strings.ReplaceAll(downloadFilename, "\"", "'")

	w.Header().Set("Content-Disposition", "attachment; filename=\""+downloadFilename+"\"") // 使用雙引號包裹檔名
	contentType := "application/octet-stream" // 預設類型
	switch strings.ToUpper(ftype) {
	case "TXT", "SRT":
		contentType = "text/plain; charset=utf-8"
	case "VTT":
		contentType = "text/vtt; charset=utf-8"
	case "JSON":
		contentType = "application/json; charset=utf-8"
	case "TSV":
		contentType = "text/tab-separated-values; charset=utf-8"
	}
	w.Header().Set("Content-Type", contentType)
	// 從遠端伺服器回應獲取 Content-Length
	if cl := resp.Header.Get("Content-Length"); cl != "" {
		w.Header().Set("Content-Length", cl)
	}
	w.Header().Set("Cache-Control", "no-cache") // 防止客戶端快取

	// 10. 將檔案內容流式傳輸給客戶端
	bytesCopied, err := io.Copy(w, resp.Body)
	if err != nil {
		log.Printf("WARN: Error copying response body to client (TaskID: %s, likely client closed connection): %v", taskID, err)
		return
	}
	log.Printf("INFO: Successfully streamed %d bytes for TaskID %s, Type %s", bytesCopied, taskID, ftype)
}

// Download 函數 - 處理 /download/{fileName}
// !!! 警告：此函數從本地伺服器讀取 .txt 檔案，並依賴記憶體 Joblistz。請確認是否需要此功能。!!!
func Download(w http.ResponseWriter, r *http.Request) {
	// 1. 身份驗證
	userinfo, err := GetUserInfoViaBearer(w.Header().Get("Authorization"))
	if err != nil {
		log.Printf("WARN: Unauthorized attempt to download local file: %v", err)
		http.Error(w, "Unauthorized: Invalid credentials", http.StatusUnauthorized)
		return
	}

	// 2. 獲取檔名
	// !!! 注意：這裡的 fileName 是 URL 路徑中的 {fileName}，它很可能是系統檔名 (audiofile-...) !!!
	fileName := r.PathValue("fileName")
	if fileName == "" {
		log.Printf("WARN: Missing fileName in local download request")
		http.Error(w, "Bad Request: Missing fileName", http.StatusBadRequest)
		return
	}

	// 3. 從記憶體 Joblistz 查找 Job 並驗證 Owner 和 Status
	// !!! 假設 Joblistz 可訪問且包含最新數據 (需要考慮線程安全) !!!
	var foundJob *Job
	jobFound := false
	// 需要一種安全的方式訪問 Joblistz
	for i := range Joblistz {
		// *** 使用 Joblistz 中的 FileName (系統檔名) 與 URL 傳入的 fileName 比較 ***
		if Joblistz[i].Owner == userinfo.Email && Joblistz[i].FileName == fileName {
			tempJob := Joblistz[i]
			foundJob = &tempJob
			jobFound = true
			break
		}
	}

	if !jobFound {
		log.Printf("WARN: Local download request for non-existent or unauthorized file (User: %s, File: %s)", userinfo.Email, fileName)
		http.Error(w, "Not Found: File not found or you do not have permission.", http.StatusNotFound)
		return
	}

	// 4. 檢查狀態 (確保與 UpdateJobsViaTaskID 中設置的完成狀態字串一致)
	if foundJob.Status != "Done" { // *** 如果 UpdateJobsViaTaskID 設為 "完成", 這裡也要檢查 "完成" ***
		log.Printf("INFO: Local download denied because job status is not Done (User: %s, File: %s, Status: %s)", userinfo.Email, fileName, foundJob.Status)
		http.Error(w, "Forbidden: Job is not yet complete.", http.StatusForbidden)
		return
	}

	// 5. 構建本地檔案路徑 (假設下載的是 .txt 檔案，且檔名基於系統檔名)
	uploadFolder := os.Getenv("UploadFolder")
	if uploadFolder == "" {
		log.Printf("ERROR: UploadFolder environment variable not set for local download.")
		http.Error(w, "Internal Server Error: Server configuration missing", http.StatusInternalServerError)
		return
	}
	// 使用系統檔名 (fileName) 來構建路徑
	localFilePath := fmt.Sprintf("%s/files/%s.txt", strings.TrimRight(uploadFolder, "/"), fileName)

	log.Printf("INFO: Attempting to serve local file: %s", localFilePath)

	// 6. 打開本地檔案
	file, err := os.Open(localFilePath)
	if err != nil {
		if os.IsNotExist(err) {
			log.Printf("ERROR: Local result file not found at path: %s", localFilePath)
			http.Error(w, "Not Found: Result file not found on server.", http.StatusNotFound)
		} else {
			log.Printf("ERROR opening local file %s: %v", localFilePath, err)
			http.Error(w, "Internal Server Error: Could not read file.", http.StatusInternalServerError)
		}
		return
	}
	defer file.Close()

	// 7. 獲取檔案資訊
	fileStat, err := file.Stat()
	if err != nil {
		log.Printf("ERROR getting file stat for %s: %v", localFilePath, err)
		http.Error(w, "Internal Server Error: Could not read file information.", http.StatusInternalServerError)
		return
	}

	// 8. 設置下載回應頭
	// 下載時顯示的檔名仍然基於系統檔名 + .txt
	downloadFilename := fmt.Sprintf("%s.txt", fileName)
	downloadFilename = strings.ReplaceAll(downloadFilename, "/", "_")
	downloadFilename = strings.ReplaceAll(downloadFilename, "\\", "_")
	downloadFilename = strings.ReplaceAll(downloadFilename, "\"", "'")

	w.Header().Set("Content-Disposition", "attachment; filename=\""+downloadFilename+"\"")
	w.Header().Set("Content-Type", "text/plain; charset=utf-8") // 假設是 TXT
	w.Header().Set("Content-Length", fmt.Sprint(fileStat.Size()))
	w.Header().Set("Cache-Control", "no-cache")

	// 9. 將檔案內容流式傳輸給客戶端
	bytesCopied, err := io.Copy(w, file)
	if err != nil {
		log.Printf("WARN: Error copying local file %s to response: %v", localFilePath, err)
		return
	}
	log.Printf("INFO: Successfully served %d bytes from local file %s", bytesCopied, localFilePath)
}