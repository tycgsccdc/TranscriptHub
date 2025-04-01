/*
   檔案上傳後執行的動作
*/
package main

import (
  "os"
  "io"
  "fmt"
  "bytes"
  "net/http"
  "io/ioutil"
  "crypto/tls"
  "encoding/json"
  "path/filepath"
  "mime/multipart"
)

// 科長那邊回傳的訊息
type ReturnMessage struct {
   Message	string		`json:"message"`
   TaskID	string		`json:"task_objid"`
   Status	int		`json:"status"`  // 0)Error, 1)Canceled 5)pending 建好objid後，就傳這個status 10)finish
   Results	[]string	`json:"results"`
}

func GetDataViaUrl(method, url, contentType string, payload *bytes.Buffer) ([]byte, error) {
  // 去除 SSL 驗證
  transport := http.DefaultTransport
  transport.(*http.Transport).Proxy = nil
  http.DefaultTransport.(*http.Transport).TLSClientConfig = &tls.Config{InsecureSkipVerify: true}

  client := &http.Client {
    Transport: transport,
  }
  req, err := http.NewRequest(method, url, payload)
  if err != nil {
     fmt.Println(err)
     return nil, err
  }
  req.Header.Set("Content-Type", contentType)
  res, err := client.Do(req)
  if err != nil {
     fmt.Println(err)
     return nil, err
  }
  defer res.Body.Close()

  body, err := ioutil.ReadAll(res.Body)
  if err != nil {
     fmt.Println(err)
     return nil, err
  }
  return body, nil
}

func AfterUpload(dstPath, label, sso, token, uuid, multipleTag string) {
  url := os.Getenv("TranslateUrl")   // "https://10.16.10.231:8080/api/v1/rest/CreateTranscribeTask"
  if url == "" {
     fmt.Println("TranslateUrl is empty")
     return
  }
  method := "POST"

  payload := &bytes.Buffer{}
  writer := multipart.NewWriter(payload)
  file, errFile1 := os.Open(dstPath)
  defer file.Close()
  fileName := filepath.Base(dstPath)
  part1, errFile1 := writer.CreateFormFile("audiofile", fileName)
  _, errFile1 = io.Copy(part1, file)
  if errFile1 != nil {
   fmt.Printf("上傳檔案錯誤:%v", errFile1)
    return
  }
  _ = writer.WriteField("label", label)
  _ = writer.WriteField("sso_account", sso)
  _ = writer.WriteField("token", token)
  _ = writer.WriteField("multiplespeaker", multipleTag)
  err := writer.Close()
  if err != nil {
     fmt.Println(err.Error())
     return
  }

  // {"message":"Task created successfully","task_objid":"278435572", "status": 0}
  body, err := GetDataViaUrl(method, url, writer.FormDataContentType(), payload)
  if err != nil {
     fmt.Println(err.Error())
     return
  }
  var msg ReturnMessage
  if err = json.Unmarshal(body, &msg); err != nil {
     fmt.Println(err.Error())
     return
  }
  if msg.Status == 0 {  // Error
     // 刪除已上傳之檔案
     fmt.Println(msg.Message)
     return
  }
  go UpdateJobs(sso, fileName, uuid, msg)
  fmt.Println(string(body))
}
