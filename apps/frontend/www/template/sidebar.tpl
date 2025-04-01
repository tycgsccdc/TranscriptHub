{{ define "sidebar" }}
   <!-- Sidebar -->
   <div class="sidebar">
      <span class="logo">
         <img src="/images/suitemain.svg" onClick="self.location.replace('/homepage');" style="cursor:pointer"/>
      </span>
      <ul class="side-menu">
          <li><a href="/homepage" style="color:#EA609E"><i class='bx bx-home-alt-2'></i><span class="sideBarTxt">首頁</span></a></li>
          <li class="{{ if eq .PageName "translate.tpl" }}active{{ else }}{{ end }}">
             <a href="/www/translate" style="color:#6CBA42"><i class='bx bx-analyse'></i><span class="sideBarTxt">逐字稿</span></a></li>
          <li class="{{ if eq .PageName "tos.tpl" }}active{{ else }}{{ end }}">
             <a href="/www/tos" style="color:#49C0EE"><i class='bx bxs-hand-right'></i><span class="sideBarTxt">使用條款</span></a></li>
          <li><a href="/transcription.pdf" target=_blank><i class='bx bxs-book-alt' style="color:#7E7AB8"></i><span class="sideBarTxt">操作指引</span></a></li>
      </ul>
      <ul class="side-menu">
         <li title="登出">
            <a href="/logout" class="logout" style="color:#F18C2E">
               <i class='bx bx-log-out-circle'></i>
               <span class="sideBarTxt">登出</span>
            </a>
         </li>
      </ul>
   </div>
   <!-- End of Sidebar -->
{{ end }}

{{ define "sidebar_en" }}
   <!-- Sidebar -->
   <div class="sidebar">
      <span class="logo">
         <img src="/images/suitemain.svg" onClick="self.location.replace('/homepage');" style="cursor:pointer"/>
      </span>
      <ul class="side-menu">
         <li><a href="/homepage/en" style="color:#EA609E"><i class='bx bx-home-alt-2'></i><span class="sideBarTxt">Home</span></a></li>
         <li class="{{ if eq .PageName "translate_en.tpl" }}active{{ else }}{{ end }}">
            <a href="/www/en/translate" style="color:#6CBA42"><i class='bx bx-analyse'></i>
            <span class="sideBarTxt">AI Transcription</span></a></li>
         <li class="{{ if eq .PageName "tos_en.tpl" }}active{{ else }}{{ end }}">
            <a href="/www/en/tos" style="color:#49C0EE"><i class='bx bxs-hand-right'></i><span class="sideBarTxt">Terms of Use</span></a></li>
         <li><a href="/transcription_en.pdf" target=_blank><i class='bx bxs-book-alt' style="color:#7E7AB8"></i><span class="sideBarTxt">User Manual</span></a></li>
      </ul>
      <ul class="side-menu">
          <li>
              <a href="/logout" class="logout" style="color:#F18C2E"><i class='bx bx-log-out-circle'></i><span class="sideBarTxt">Logout</span></a>
          </li>
      </ul>
   </div>
   <!-- End of Sidebar -->
{{ end }}
