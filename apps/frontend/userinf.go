/* 
   取得登入者資訊，請修改成自己需要的方式取得使用者資訊
   1. 取得 Bearer Token
   2. 取得使用者資訊
   3. 取得使用者的工作列表
*/
package main

import(
   "net/http"
)

// 登出
func Logout(w http.ResponseWriter, r *http.Request) {
   url := "/"
   w.Header().Del("Authorization")
   http.Redirect(w, r, url, http.StatusTemporaryRedirect)
}

type User struct {
   Cn       string `json:"cn"`
   ChName   string `json:"chName"`
   Phone    string `json:"phone"`
   Email    string `json:"email"`
   InstCode string `json:"instCode"`
   Sysid    string `json:"sysid"`
}

// GetUserInfoViaBearer 取得登入者資訊，請修改成自己需要的方式取得使用者資訊
func GetUserInfoViaBearer(str string)(*User, error) {
   return &User{
      Cn:       "OO單位",
      ChName:   "劉智漢",
      Phone:    "0921.....",
      Email:    "andyliu@as.edu.tw",
      InstCode: "MI6",
      Sysid:    "007",
  }, nil
}
