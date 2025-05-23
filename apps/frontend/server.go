package main

import (
   "os"
   "fmt"
   "github.com/joho/godotenv"
   "github.com/asccclass/sherryserver"
)

var (
   Joblistz []Job
   NeedSave bool
)

func mkSlice(args ...interface{}) []interface{} {
   return args
}

func main() {
   if err := godotenv.Load("envfile"); err != nil {
      fmt.Println("Error loading .env file")
      return
   }
   port := os.Getenv("PORT")
   if port == "" {
      port = "80"
   }
   documentRoot := os.Getenv("DocumentRoot")
   if documentRoot == "" {
      documentRoot = "www"
   }
   templateRoot := os.Getenv("TemplateRoot")
   if templateRoot == "" {
      templateRoot = "www/html"
   }

   server, err := SherryServer.NewServer(":" + port, documentRoot, templateRoot)
   if err != nil {
      panic(err)
   }
   router := NewRouter(server, documentRoot)
   if router == nil {
      fmt.Println("router return nil")
      return
   }
   server.Server.Handler = router 
   NeedSave = false
   Joblistz, _ = GetAllJobs()
   defer func() {
      if err := SaveJobs(Joblistz); err != nil {
         fmt.Println(err.Error())
      }
   }()
   server.Start()
}
