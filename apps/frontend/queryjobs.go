package main

import(
   "fmt"
   "net/http"
   "encoding/json"
)

func QueryAllJobs(w http.ResponseWriter, r *http.Request) {
   _, err := GetUserInfoViaBearer(w.Header().Get("Authorization"))
   if err != nil {
      fmt.Println("Parse Authorization Bearer error at query all jobs:(" + err.Error() + ")")
      http.Error(w, "Unauthorized(" + err.Error() + ")", http.StatusUnauthorized)
      return
   }
   jobs, err := GetAllJobs()
   if err != nil {
      fmt.Print("Error reading file:%s", err.Error())
      w.WriteHeader(http.StatusInternalServerError)
      return
   }
   w.Header().Set("Content-Type", "application/json")
   json.NewEncoder(w).Encode(jobs)
}

func QueryJobs(w http.ResponseWriter, r *http.Request) {
   userinfo, err := GetUserInfoViaBearer(w.Header().Get("Authorization"))
   if err != nil {
      fmt.Println("Parse Authorization Bearer error at Query jobs:(" + err.Error() + ")")
      http.Error(w, "Unauthorized", http.StatusUnauthorized)
      return
   }
   // 找出自己的Job lists 輸出到 client 端
   jobs, err := ReadJobsViaEmail(userinfo.Email)
   if err != nil {
      fmt.Print("Error reading file:%s", err.Error())
      w.WriteHeader(http.StatusInternalServerError)
      return
   }
   // 建立臨時的資料
   w.Header().Set("Content-Type", "application/json")
   json.NewEncoder(w).Encode(jobs)
}
