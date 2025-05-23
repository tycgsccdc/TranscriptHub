// router.go
package main

import (
	"net/http"

	// 使用 SherryServer 庫，假設它提供了 Server 結構和 StaticFileServer 功能
	// 具體路徑可能需要根據你的專案結構調整
	"github.com/asccclass/sherryserver"
   
)

// NewRouter 創建並配置 HTTP 路由器
// srv: 指向 SherryServer.Server 的指針 (可能包含配置或依賴)
// documentRoot: 靜態檔案的根目錄
func NewRouter(srv *SherryServer.Server, documentRoot string) *http.ServeMux {
	router := http.NewServeMux() // 使用 Go 內建的 ServeMux

	// --- 靜態檔案服務 ---
	// 假設 SherryServer.StaticFileServer 能正確處理靜態檔案路由
	// staticfileserver := SherryServer.StaticFileServer{Root: documentRoot, IndexFile: "index.html"}
	// staticfileserver.AddRouter(router) // 將靜態檔案路由添加到 mux
   // 使用 Go 內建的 http.FileServer 提供 documentRoot 目錄下的靜態檔案
   fs := http.FileServer(http.Dir(documentRoot))
   // 將 / 路徑下的請求（除去特定 API 路徑外的所有請求）交給檔案伺服器處理
   // 注意：這個會攔截所有未被前面更精確路徑匹配的請求
   // 可能需要更精密的路由（例如使用 ServeMux 的 Handle 而不是 HandleFunc，或使用第三方庫）
   // 一個簡單的做法是將靜態檔案放在特定前綴下，例如 /static/
   // http.Handle("/static/", http.StripPrefix("/static/", fs))
   // 或者如果你的 API 路徑都有特定前綴，這個也能工作：
   router.Handle("/", fs) // 將根路徑交給檔案伺服器
	// --- 應用程式 API 和頁面路由 ---

	// 頁面路由 (假設 Home 和 page 函數處理頁面渲染)
	router.HandleFunc("/homepage", Home)           // 注意: HandleFunc 比 Handle 更常用於函數
	router.HandleFunc("/homepage/{lang}", Home)    // Go 1.22+ 支持路徑參數
	router.HandleFunc("/www/{pageName}", page)     // Go 1.22+ 支持路徑參數
	router.HandleFunc("/www/{lang}/{pageName}", page) // Go 1.22+ 支持路徑參數

	// 文件上傳路由
	router.HandleFunc("POST /upload", Upload) // 上傳通常使用 POST 方法

	// 工作完成/更新路由 (舊的，可能需要檢查 JobDone 的用途)
	// 如果 JobDone 也是一個接收外部通知的端點，需要確認其方法和功能
	router.HandleFunc("/jobdone", JobDone)   // 需要確認方法 (GET/POST?) 和功能
	router.HandleFunc("/updatejob", JobDone) // 同上，可能與 /jobdone 重複？

	// 文件下載路由
	router.HandleFunc("GET /download/{fileName}", Download) // 下載通常使用 GET
	router.HandleFunc("GET /result/{taskID}/{fileType}", ResultDownload) // 結果下載也用 GET

	// 刪除工作路由
	router.HandleFunc("GET /del/{taskID}", DelJob) // 刪除操作用 GET 可能不太符合 RESTful 風格，但按現狀保留

	// 登出路由
	router.HandleFunc("/logout", Logout) // 方法可能是 GET 或 POST

	// 查詢工作列表路由
	router.HandleFunc("GET /query/jobs", QueryJobs)     // 查詢自己的 jobs，用 GET
	router.HandleFunc("GET /listall/jobs", QueryAllJobs) // 查詢所有 jobs (管理員？)，用 GET

	// 手動保存 Jobs 到檔案 (管理/調試功能)
	router.HandleFunc("/hand/save/jobs", SaveJobsByHand) // 方法可能是 GET 或 POST

	// --- 新增：處理來自 Worker 的內部狀態更新通知 ---
	// 使用 POST 方法，路徑為 /internal/job-update
	// 指向 internal_api.go 中定義的 HandleJobUpdate 函數
	router.HandleFunc("POST /internal/job-update", HandleJobUpdate)

	return router // 返回配置好的路由器
}

// 注意：
// 1. 上面的程式碼假設你的 Go 版本支持 http.HandleFunc 中的路徑參數 (Go 1.22+)。
//    如果你的 Go 版本較舊，你需要使用其他路由庫 (如 gorilla/mux) 或不同的方式來處理路徑參數。
// 2. 我將大部分路由的方法明確標註為 GET 或 POST (基於常見用法)。你需要根據實際情況調整，
//    特別是 /jobdone, /updatejob, /logout, /hand/save/jobs 這些路由的方法。
// 3. 確保所有被呼叫的 Handler 函數 (Home, page, Upload, JobDone, Download, ...)
//    都已經在你的專案中定義了。