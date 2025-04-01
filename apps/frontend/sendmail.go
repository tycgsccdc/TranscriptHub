/*
   傳送Email通知
*/
package main

import (
  "fmt"
  "bytes"
  "mime"
  "strconv"
  "net/http"
  "github.com/asccclass/sherryserver/libs/mail"
)

// 0) Error 1)Canceled  10)job done
// 請自行修改信件內容
func SendEmailNotify(taskID string, state int) {
   job, err := ReadJobsViaTaskID(taskID)
   if err != nil {
      fmt.Println(err.Error())
      return
   }
   status := "執行完成"
   if state == 0 {
      status = "因錯誤中斷"
   } else if state == 1 {
      status = "因故被取消執行"
   }

   app, err := MailService.NewSMTPMail()
   if err != nil {
      fmt.Println("Send email notify error:" + err.Error())
      return
   }

   subject := "【ITS】AI Suite 系統通知"
   body := fmt.Sprintf(`
      <!DOCTYPE html>
      <html>
         <body>
	 <p>敬啟者，<br /><br />感謝您使用中央研究院 AI 錄音轉逐字稿服務。您於 %s 上傳的檔案 %s 已於%s %s。請點擊以下連結進入系統查詢您的逐字稿內
容。<br><br>提醒您，轉檔文件僅保留 30 天，請盡速保存資料。<br><br><br>查詢逐字稿連結：<br>https://....its.sinica.edu.tw<br><br>使用意見回饋表
單：<a href="https://forms.gle/...">請點擊此處填寫表單</a><br><br>
         資訊服務處 敬啟
         </p>
         <p>
線上服務台 (上班時間)：https://its.sinica.edu.tw/online<br>
電話(上班時間)：02-27898855<br>
信箱：its@sinica.edu.tw
         </p>
         <p>Dear User,<br><br>
         Thank you for using Academia Sinica’s AI Audio-to-Text Service. The file %s that you uploaded on %s has been successfully processed at %s. Please click the link below to access your transcript.<br>
Kindly note that the transcribed file will only be retained for 30 days, so please save your data promptly.<br><br><br>
         Transcript Access Link:<br> https://aisuite.its.sinica.edu.tw
         Feedback Form: [<a href="https://forms.gle/...">Click here to fill out the form</a>]<br><br>
	 Department of Information Technology Services<br>
         Online Helpdesk (Office Hours): https://its.sinica.edu.tw/online<br>
         Tel (Office Hours): +886-2-2789-8855<br>
         E-mail: its@sinica.edu.tw
         </body>
      </html>
   `, job.UploadTime, job.FileName, job.FinishTime, status, job.FileName, job.UploadTime, job.FinishTime)


   // 完整的 MIME 訊息
   var msg bytes.Buffer
   msg.WriteString(fmt.Sprintf("From: 資訊處 <%s>\r\n", mime.QEncoding.Encode("utf-8", app.From)))
   msg.WriteString(fmt.Sprintf("To: %s\r\n", job.Owner))
   msg.WriteString(fmt.Sprintf("Subject: %s\r\n", mime.QEncoding.Encode("utf-8", subject)))
   msg.WriteString("MIME-Version: 1.0\r\n")
   msg.WriteString("Content-Type: text/html; charset=UTF-8\r\n")
   msg.WriteString("\r\n")
   msg.WriteString(fmt.Sprintf("--\r\n"))
   msg.WriteString(body)
   msg.WriteString("\r\n")
   msg.WriteString(fmt.Sprintf("--\r\n"))
   if err := app.Send(job.Owner, msg, false); err != nil {
      fmt.Println("send err:", err.Error())
      return
   }
   fmt.Println("send ok")
}

func SendTestEmailFromWeb(w http.ResponseWriter, r *http.Request) {
   taskID := r.PathValue("taskID")
   status := r.PathValue("state")
   if taskID == "" || status == "" {
      fmt.Println("taskID or state is empey")
      http.Error(w, "TaskID or state is empty", http.StatusUnauthorized)
      return
   }
   num, err := strconv.Atoi(status)
   if err != nil {
      http.Error(w, err.Error(), http.StatusUnauthorized)
      return
   }
   SendEmailNotify(taskID, num)
}
