package main

import(
   "os"
   "fmt"
   "bytes"
   "net/http"
   "io/ioutil"
   "encoding/json"
   "mime/multipart"
)

// 儲存資料
func SaveJobsByHand(w http.ResponseWriter, r *http.Request) {
   w.Header().Set("Content-Type", "application/json")
   if err := SaveJobs(Joblistz); err != nil {
      fmt.Fprintf(w, "{\"status\":\"0\", \"message\":\"%s\"}", err.Error())
      fmt.Println(err.Error())
      return
   }
   fmt.Fprintf(w, "{\"status\":\"1\", \"message\":\"save job files ok.\"}")
}

// 刪除遠端資料及成果
func delRemoteResult(label, sso, token, taskID string) {
   payload := &bytes.Buffer{}
   writer := multipart.NewWriter(payload)
    _ = writer.WriteField("label", label)
    _ = writer.WriteField("sso_account", sso)
    _ = writer.WriteField("token", token)
   _ = writer.WriteField("task_objid", taskID)
   err := writer.Close()
   if err != nil {
      fmt.Println(err.Error())
      return
   }
   url := os.Getenv("TranslateEndpoint")
   if url == "" {
      fmt.Println("envfile's TranslateEndpoint is not set")
      return
   }
   url += "CancelTask"
  body, err := GetDataViaUrl("POST", url, writer.FormDataContentType(), payload)
  if err != nil {
     fmt.Println(err.Error() + payload.String())
     return
  }
  fmt.Println(string(body))
}

func DelJob(w http.ResponseWriter, r *http.Request) {
   userinfo, err := GetUserInfoViaBearer(w.Header().Get("Authorization"))
   if err != nil {
      fmt.Fprintf(w, "{\"status\":\"0\", \"message\":\"" + err.Error() + "\"}")
      return
   }
   taskID := r.PathValue("taskID") 
   if taskID == "" {
      fmt.Fprintf(w, "{\"status\":\"0\", \"message\":\"job ID is empty\"}")
      return
   }
   jobs, err := GetAllJobs()
   if err != nil {
      fmt.Fprintf(w, "{\"status\":\"0\", \"message\":\"" + err.Error() + "\"}")
      return
   }
   for i, job := range jobs {
      if job.TaskID == taskID {
         if job.Owner != userinfo.Email {
            fmt.Fprintf(w, "{\"status\":\"0\", \"message\":\"Not your Job\"}")
            return
         }
	 if err := os.Remove(os.Getenv("UploadFolder") + "files/" + job.FileName); err != nil {
            if os.IsNotExist(err) {  // 檔案已經移除
	       go delRemoteResult(userinfo.Sysid, userinfo.Email, "IamToken", taskID)  // 同步刪除whisper資料及成果)label, sso, token, taskID
	       Joblistz = append(jobs[:i], jobs[i+1:]...)  // 刪除資料
               fmt.Println("File does not exist, remove memory record ok.")
	    }
            fmt.Fprintf(w, "{\"status\":\"0\", \"message\":\"" + err.Error() + "\"}")
            return
	 }
	 Joblistz = append(jobs[:i], jobs[i+1:]...)  // 刪除資料
	 go delRemoteResult(userinfo.Sysid, userinfo.Email, "IamToken", taskID)  // 同步刪除whisper資料及成果)label, sso, token, taskID
         fmt.Fprintf(w, "{\"status\":\"1\", \"message\":\"Job deleted\"}")
         return
      }
   }
   fmt.Fprintf(w, "{\"status\":\"0\", \"message\":\"Job ID not Found\"}")
}

func JobDone(w http.ResponseWriter, r *http.Request) {
   w.Header().Set("Content-Type", "application/json")
   if err := r.ParseForm(); err != nil {
      fmt.Fprintf(w, "{\"status\":\"0\", \"message\":\"%s\"}", err.Error())
      return
   }
   b, err := ioutil.ReadAll(r.Body)
   defer r.Body.Close()
   if err != nil {
      fmt.Fprintf(w, "{\"status\":\"0\", \"message\":\"%s\"}", err.Error())
      return
   }
   var resp ReturnMessage
   if err := json.Unmarshal(b, &resp); err != nil {
      fmt.Fprintf(w, "{\"status\":\"0\", \"message\":\"%s\"}", err.Error())
      return
   }
   // 更新狀態
   if resp.Status != 0 {
      if err := UpdateJobsViaTaskID(resp); err != nil {   // see jobs.go
         fmt.Fprintf(w, "{\"status\":\"%d\", \"message\":\"%s\"}", resp.Status, err.Error())
         return
      }
   } else {
      fmt.Fprintf(w, "{\"status\":\"0\", \"message\":\"job status is not ok\"}")
      return
   }
   fmt.Fprintf(w, "{\"status\":\"1\", \"message\":\"update job done\"}")
}
