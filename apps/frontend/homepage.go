package main

import(
   "os"
   "net/http"
)

type TFO struct {
   Userinfo	interface{}
   Jobs		[]Job
   PageName	string
}

func Home(w http.ResponseWriter, r *http.Request) {
   userinfo, err := GetUserInfoViaBearer("")  
   if err != nil {
      http.Error(w, err.Error(), http.StatusUnauthorized)
      return
   }
   filename := os.Getenv("TemplateRoot") + "index.tpl" 
   lang := r.PathValue("lang")
   if lang != "" {
      filename = os.Getenv("TemplateRoot") + "index_" + lang + ".tpl" 
   }
   printPage(w, filename, userinfo)
}
