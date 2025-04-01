package main

import(
   "fmt"
   "io/ioutil"
   "encoding/json"
)

func ReadJobs(filename string)([]Job, error) {
   var jobs []Job
   file, err := ioutil.ReadFile(filename)
   if err != nil {
      return jobs, err
   }
   // 解碼 JSON 資料為結構
   if err := json.Unmarshal(file, &jobs); err != nil {
      return jobs, err
   }
   return jobs, nil
}

// 將工作寫入檔案
func WriteJob(filename string, job *Job)([]Job, error) {
   jobs, err := ReadJobs(filename)
   if err != nil {
      fmt.Println("job file:" + filename + ", " + err.Error())
      return jobs, err
   }
   jobs = append(jobs, *job)
   updatedJSON, err := json.MarshalIndent(jobs, "", "    ")
   if err != nil {
      return jobs, err
   }
   if err := ioutil.WriteFile(filename, updatedJSON, 0644); err != nil {
      return jobs, err
   }
   return jobs, nil
}
