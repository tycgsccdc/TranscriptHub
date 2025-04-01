package main

import(
   "io"
   "os"
   "fmt"
   "path"
   "time"
   "strings"
   "net/url"
   "net/http"
   "crypto/tls"
)

// 從網址取得資料 https://...../api/v1/rest/RetrieveTranscribe/TXT/audiofile-1730258994869
func GetRealName(results []string, ftype string)(string) {
   for _, url := range results {
      parts := strings.Split(url, "/")
      if parts[len(parts)-2] == ftype {
         return parts[len(parts)-1]
      }
   }
   return ""
}

// 從 URL 或 Content-Disposition 中獲取檔案名
func getFileName(fileURL string, contentDisposition string) string {
   // 首先嘗試從 Content-Disposition 獲取檔案名
   if contentDisposition != "" {
      if strings.Contains(contentDisposition, "filename=") {
         parts := strings.Split(contentDisposition, "filename=")
         if len(parts) > 1 {
            fileName := strings.Trim(parts[1], `"'`)
            if fileName != "" {
               return fileName
            }
         }
      }
   }
   // 從 URL 路徑中獲取檔案名
   parsedURL, err := url.Parse(fileURL)
   if err != nil {
      return "download.file"
   }

   fileName := path.Base(parsedURL.Path)
   if fileName == "." || fileName == "/" {
      return "download.file"
   }
   return fileName
}

func ResultDownload(w http.ResponseWriter, r *http.Request) {
   if _, err := GetUserInfoViaBearer(w.Header().Get("Authorization")); err != nil {
      fmt.Println("Parse Authorization Bearer error at result download function")
      http.Error(w, "Unauthorized(" + err.Error() + ")", http.StatusUnauthorized)
      return
   }
   // /result/{taskID}/{fileType}
   taskID := r.PathValue("taskID")
   ftype := r.PathValue("fileType")
   job, err := ReadJobsViaTaskID(taskID) 
   if err != nil {
      http.Error(w, err.Error(), http.StatusInternalServerError)
      return
   }
   realName := GetRealName(job.Results, ftype)
   if realName == "" {
      http.Error(w, "no realName: Error downloading file", http.StatusInternalServerError)
      return
   }
   // https://....../api/v1/rest/RetrieveTranscribe/TXT/audiofile-1730258994869
   fileURL := os.Getenv("DownloadServer") + ftype + "/" + realName + "?sso_account=" + job.Owner + "&task_objid=" + taskID
   // 建立忽略 SSL 驗證的 HTTP client
   tr := &http.Transport{
      TLSClientConfig: &tls.Config{
         InsecureSkipVerify: true,
      },
   }
   client := &http.Client{
      Transport: tr,
      Timeout:   30 * time.Second,
   }
   resp, err := client.Get(fileURL)
   if err != nil {
      http.Error(w, err.Error(), http.StatusInternalServerError)
      return
   }
   defer resp.Body.Close()
   // 檢查回應狀態
   if resp.StatusCode != http.StatusOK {
      fmt.Printf("Bad status: %s", resp.Status)
      http.Error(w, "Remote server error", http.StatusInternalServerError)
      return
   }
   // fileName := getFileName(fileURL, resp.Header.Get("Content-Disposition"))

   w.Header().Set("Content-Disposition", "attachment; filename=" + realName + "." + strings.ToLower(ftype))
   w.Header().Set("Content-Type", "application/octet-stream")
   w.Header().Set("Content-Length", resp.Header.Get("Content-Length"))
   w.Header().Set("Cache-Control", "no-cache")

   io.Copy(w, resp.Body)
}

func Download(w http.ResponseWriter, r *http.Request) {
   userinfo, err := GetUserInfoViaBearer(w.Header().Get("Authorization"))
   if err != nil {
      fmt.Println("Parse Authorization Bearer error at Uupload function")
      http.Error(w, "Unauthorized", http.StatusUnauthorized)
      return
   }
   fileName := r.PathValue("fileName")
   job, err := ReadJobsViaEmailandFile(userinfo.Email, fileName) 
   if err != nil {
      http.Error(w, err.Error(), http.StatusInternalServerError)
      return
   }
   if job.Status != "done" {
      http.Error(w, "Job not done", http.StatusInternalServerError)
      return
   }
   // path := os.Getenv("UploadFolder") + "files/" + webVars["fileName"] + ".txt"
   path := os.Getenv("UploadFolder") + "files/" + fileName + ".txt"
   file, err := os.Open(path)
   if err != nil {
      fmt.Println("Error reading upload file:%s", err.Error())
      http.Error(w, "File " + path + " not found", http.StatusInternalServerError)
      return
   }
   defer file.Close()
   fileStat, err := file.Stat()
   if err != nil {
      http.Error(w, "Can not read file information", http.StatusInternalServerError)
      return
   }
   w.Header().Set("Content-Disposition", "attachment; filename=" + fileName + ".txt")
   w.Header().Set("Content-Type", "application/octet-stream")
   w.Header().Set("Content-Length", fmt.Sprint(fileStat.Size()))
   _, err = file.Seek(0, 0)
   if err != nil {
      fmt.Println("Error creating upload directory:", err)
      w.WriteHeader(http.StatusInternalServerError)
      return
   }

   _, err = file.WriteTo(w)
   // if _, err = io.Copy(w, file); err != nil {
   if err != nil {
      fmt.Print("Error reading file:%s", err.Error())
      http.Error(w, "Can not send file", http.StatusInternalServerError)
      return
   }
}
