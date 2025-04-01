package main

import(
   "os"
   "fmt"
   "path"
   "bytes"
   "net/http"
   "html/template"
)

func printPage(w http.ResponseWriter, filename string, userinfo *User) {
   jobs, err := ReadJobsViaEmail(userinfo.Email) 
   if err != nil {
      fmt.Println("Read job error", err.Error())
      return
   }
   // 反轉 job 內容
   reversed := make([]Job, len(jobs))
   for i, job := range jobs {
      reversed[len(jobs)-1-i] = job
   }
   xName := path.Base(filename)
   data := TFO {
      Userinfo: *userinfo,
      Jobs: reversed,
      PageName: xName,
   }

   funcMap := map[string]interface{}{"mkSlice": mkSlice}
   tmpl := template.New(xName).Funcs(template.FuncMap(funcMap))
   if xName[0:5] == "index" {
      tmpl, err = tmpl.ParseFiles(filename)
   } else {
      tmpl, err = tmpl.ParseFiles(filename, os.Getenv("TemplateRoot") + "sidebar.tpl")
   }
   if err != nil {
      fmt.Fprint(w, "Parse template error: ", err.Error())
      return
   }
   var s bytes.Buffer
   if err := tmpl.Execute(&s, data); err != nil {
      fmt.Fprint(w, "Parse template error: ", err.Error())
      return
   }
   fmt.Fprint(w, s.String())
}

// 直接讀取頁面
func page(w http.ResponseWriter, r *http.Request) {
   userinfo, err := GetUserInfoViaBearer("")
   if err != nil {
      http.Error(w, err.Error(), http.StatusUnauthorized)
      return
   }
   lang := r.PathValue("lang")
   pageName := r.PathValue("pageName")
   if pageName == "" {
      fmt.Fprint(w, "Empty page name")
      return
   }
   filename := os.Getenv("TemplateRoot")
   if lang != "" { // 有語言識別
      pageName = pageName + "_" + lang 
   }
   filename += pageName + ".tpl" 
   printPage(w, filename, userinfo)
}
