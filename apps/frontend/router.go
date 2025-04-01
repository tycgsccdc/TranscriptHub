// router.go
package main

import(
   "net/http"
   "github.com/asccclass/sherryserver"
)

func NewRouter(srv *SherryServer.Server, documentRoot string)(*http.ServeMux) {
   router := http.NewServeMux()

   // Static File server
   staticfileserver := SherryServer.StaticFileServer{documentRoot, "index.html"}
   staticfileserver.AddRouter(router)

   // App router
   router.Handle("/homepage", http.HandlerFunc(Home))
   router.Handle("/homepage/{lang}", http.HandlerFunc(Home))
   router.Handle("/www/{pageName}",http.HandlerFunc(page))
   router.Handle("/www/{lang}/{pageName}", http.HandlerFunc(page))
   router.Handle("/upload", http.HandlerFunc(Upload))
   router.Handle("/jobdone", http.HandlerFunc(JobDone))
   router.Handle("/updatejob", http.HandlerFunc(JobDone))
   router.Handle("/download/{fileName}", http.HandlerFunc(Download))
   router.Handle("/result/{taskID}/{fileType}", http.HandlerFunc(ResultDownload))
   router.Handle("/del/{taskID}", http.HandlerFunc(DelJob))
   router.Handle("/logout", http.HandlerFunc(Logout))
   router.Handle("/query/jobs", http.HandlerFunc(QueryJobs))
   router.Handle("/listall/jobs", http.HandlerFunc(QueryAllJobs))
   router.Handle("/hand/save/jobs", http.HandlerFunc(SaveJobsByHand))   // 手動將記憶體工作寫入檔案
   return router
}
