package main

import(
   "io"
   "os"
   "fmt"
   "strconv"
   "strings"
   "net/http"
   "path/filepath"
   "encoding/json"
   "github.com/asccclass/sherrytime"
)

func Upload(w http.ResponseWriter, r *http.Request) {
   userinfo, err := GetUserInfoViaBearer(w.Header().Get("Authorization"))
   if err != nil {
      fmt.Println("Parse Authorization Bearer error at Uupload function")
      http.Error(w, "Unauthorized", http.StatusUnauthorized)
      return
   }
   us := os.Getenv("MaxUploadSize")
   if us == "" {
      fmt.Println("params: Max upload size is not set")
      w.WriteHeader(http.StatusBadRequest)
      return
   }
   MaxuploadSize, err := strconv.Atoi(us)
   if err != nil {
      fmt.Println("strconv error:", err.Error())
      w.WriteHeader(http.StatusBadRequest)
      return
   }

   r.ParseMultipartForm(int64(MaxuploadSize << 20)) // 限制最大上传文件大小为 290 MB
   file, handler, err := r.FormFile("file")
   if err != nil {
      fmt.Println("Error reading upload file:%s", err.Error())
      w.WriteHeader(http.StatusBadRequest)
      return
   }

   defer file.Close()
   path := os.Getenv("UploadFolder")
   dstPath := filepath.Join(path + "files/", handler.Filename)
   dstFile, err := os.Create(dstPath)
   if err != nil {
      fmt.Println("Error creating upload directory:", err)
      w.WriteHeader(http.StatusInternalServerError)
      return
   }
   defer dstFile.Close()

   if _, err = io.Copy(dstFile, file); err != nil {
      fmt.Print("Error reading file:%s", err.Error())
      w.WriteHeader(http.StatusInternalServerError)
      return
   }
   multipleTag := r.FormValue("multiplespeaker")  // 0)關閉  1)開啟
   if multipleTag == "" {
      multipleTag = "0"
   }
   st := sherrytime.NewSherryTime("Asia/Taipei", "-")  // Initial
   uuid := st.NewUUID()
   job := &Job{
      Owner: userinfo.Email,
      FileName: handler.Filename,
      Action: "mp32text",
      Status: "sending",   // sending)待傳過去翻譯 pending)翻譯中 finish)翻譯完畢可下載
      UploadTime: st.Now(),
      TaskID: uuid,
      MultipleTag: multipleTag,
   }

   Joblistz = append(Joblistz, *job)  // 寫入記憶體

   // 找出自己的Job lists 輸出到 client 端
   jobs, err := ReadJobsViaEmail(userinfo.Email)
   if err != nil {
      fmt.Print("Error reading file:%s", err.Error())
      w.WriteHeader(http.StatusInternalServerError)
      return
   }
   // 建立臨時的資料
   fmt.Println(r.Header.Get("HX-Request"))
   if r.Header.Get("HX-Request") == "true" {
      ext := strings.ToLower(filepath.Ext(handler.Filename))
      w.Header().Set("Content-Type", "text/html")
      html := fmt.Sprintf(`
            <tr title="%s">
                <td>%s</td>
                <td>%s</td>
                <td>%s</td>
                <td>%s</td>
                <td>%s</td>
                <td></td>
            </tr>
        `, jobs[0].MultipleTag, jobs[0].FileName, ext,
           jobs[0].UploadTime, jobs[0].FinishTime,
           jobs[0].Status)
      w.Write([]byte(html))
      fmt.Println(html)
   } else {
      w.Header().Set("Content-Type", "application/json")
      json.NewEncoder(w).Encode(job)
   }
   // 執行傳送檔案: AfterUpload(dstPath, label, sso, token, multipleTag string)
   go AfterUpload(dstPath, userinfo.Sysid, userinfo.Email, "IamToken", uuid, multipleTag) 
}
