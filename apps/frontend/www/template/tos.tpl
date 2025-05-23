<!DOCTYPE html>
<html lang="zh_tw">
   <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
      <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
      <link rel="stylesheet" href="/css/xx.css">
      <title>Job Queue File Upload</title>
      <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
           font-family: Arial, sans-serif;
        }

        /* 側邊欄樣式 */
        .sidebar {
            width: 250px;
            height: 100vh;
            background: #f8f9fa;
            position: fixed;
            left: 0;
            top: 0;
            transition: 0.3s;
            border-right: 1px solid #ddd;
            padding-top: 20px;
        }

        .sidebar.collapsed {
            width: 60px;
        }

        .sidebar-header {
            padding: 0 20px 20px 20px;
            border-bottom: 1px solid #ddd;
            display: flex;
            align-items: center;
        }

        .sidebar-header h1 {
            font-size: 20px;
            color: #333;
        }

        .toggle-btn {
            position: absolute;
            right: -12px;
            top: 50px;
            background: white;
            border: 1px solid #ddd;
            width: 24px;
            height: 24px;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
        }

        .nav-menu {
            list-style: none;
            padding: 20px 0;
        }

        .nav-item {
            padding: 10px 20px;
            display: flex;
            align-items: center;
            cursor: pointer;
            color: #666;
            text-decoration: none;
        }

        .nav-item:hover {
            background: #e9ecef;
        }

        .nav-item.active {
            color: #ff69b4;
        }

        .nav-item i {
            margin-right: 15px;
            width: 20px;
            text-align: center;
        }

        .nav-text {
            white-space: nowrap;
            overflow: hidden;
        }
        .right-align {
            margin-left: auto;
            margin-right: 0;
            width: fit-content;
        }

        /* 主內容區域樣式 */
        .main-content {
            margin-left: 250px;
            padding: 20px;
            transition: 0.3s;
        }

        .main-content.expanded {
            margin-left: 60px;
        }
        .highlight {
           background-color: yellow;
           transition: background-color 2s ease-out;
        }

        /* RWD 調整 */
        @media screen and (max-width: 768px) {
            .sidebar {
                width: 60px;
            }

            .sidebar.expanded {
                width: 250px;
            }

            .main-content {
                margin-left: 60px;
            }

            .main-content.collapsed {
                margin-left: 250px;
            }

            .nav-text {
                opacity: 0;
                display: none;
            }

            .sidebar.expanded .nav-text {
                opacity: 1;
                display: inline;
            }
        }

        /* 原有的表格和表單樣式 */
        .container {
            width: 100%;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .responsive-table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
            max-width: 1200px;
        }
        
        .responsive-table th,
        .responsive-table td {
            padding: 12px;
            text-align: left;
            border: 1px solid #ddd;
        }
        
        .responsive-table th {
            background-color: #3682f6;
            color: white;
            font-weight: bold;
        }
        
        .responsive-table tr:nth-child(even) {
            background-color: #fafafa;
        }
        
        .upload-form {
           width: 100%;
           max-width: 650px;
           margin: 20px auto;
           padding: 20px;
           border: 1px solid #ddd;
           border-radius: 4px;
        }

        .file-format {
            color: #666;
            font-size: 0.9em;
            margin-bottom: 15px;
        }

        .file-input-container {
            margin-bottom: 15px;
        }

        .radio-group {
            margin-bottom: 15px;
        }

        .upload-btn {
            padding: 8px 16px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }

        .download-btn {
            display: inline-block;
            padding: 6px 12px;
            background-color: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 4px;
        }

        .version {
           color: #666;
           font-size: clamp(0.9rem, 2vw, 1rem);
           margin: 1rem 0;
        }

        .department {
           color: #555;
           font-size: clamp(0.9rem, 2vw, 1rem);
           margin-top: 1rem;
        }

        @media screen and (max-width: 600px) {
           .sideBarTxt {
              display: none;
           }
           .right-align .name {
              display: none;
           }
           .responsive-table {
               border: 0;
           }
            
            .responsive-table thead {
                display: none;
            }
            
            .responsive-table tr {
                margin-bottom: 20px;
                display: block;
                border: 1px solid #ddd;
            }
            
            .responsive-table td {
                display: block;
                text-align: right;
                padding: 6px;
                border-bottom: 1px solid #ddd;
            }
            
            .responsive-table td:before {
                content: attr(data-label);
                float: left;
                font-weight: bold;
            }

            .upload-form {
               padding: 5px;
               margin: 0px;
            }
        }
        @media screen and (max-width: 480px) {
          .headerx {
             padding: 0.2rem;
          }
        }
    </style>
</head>
<body>
   {{template "sidebar" .}}
   <!-- 主內容區域 -->
   <main class="main-content">
      <div class="right-align">
         <span class="name">您好，{{ .Userinfo.ChName }}（{{ .Userinfo.Email }}） |  </span>
         <a href="/www/en/tos">English</a>
      </div>
      <div class="container">
         
         <div class="headerx">
            <h1>XXXX AI 服務平台—逐字稿使用條款</h1>
            <div class="version">版本：2025.2.7</div>
            <div class="department">智發會</div>
         </div>
         <div>
            <h2>一、適用範圍</h2>
            <p>本條款適用於使用 AI 服務平台—逐字稿（以下簡稱"本服務"）的所有用戶。使用本服務即表示用戶已閱讀、理解並同意遵守本條款。</p>

            <h2>二、服務內容</h2>
            <p>本服務提供將錄音檔案內容轉換為逐字稿的功能，用戶可將資料上傳至本會指定平台，系統將自動產生文字檔案。本服務旨在提高工作效率，僅供合
法及
內部業務用途。</p>

            <h2>三、用戶責任</h2>
            <ol>
               <li>用戶應確保上傳的錄音檔案不涉及任何侵害第三方權益或違反法律之行為。</li>
               <li>用戶須自行負責上傳錄音檔案的真實性與合法性，如有任何法律糾紛，概由用戶自行承擔責任。</li>
            </ol>

            <h2>四、保密與隱私</h2>
            <ol>
               <li>本會對用戶上傳的資料將採取嚴格保密措施，僅用於提供本服務所需，不會另作他用。</li>
               <li>本會承諾未經用戶許可，不會將資料分享給第三方，法律另有規定者除外。</li>
               <li>用戶上傳的錄音檔案轉出為逐字稿後將立刻刪除，轉出的逐字稿將保留1個月後刪除。</li>
            </ol>

            <h2>五、逐字稿準確性</h2>
            <p>本服務所產生的逐字稿為系統自動生成，其準確性可能受錄音檔案內容的音質、錄製速度等因素影響，並可能無法正確識別領域專有名詞。本會不對
逐字
稿的完整性或正確性作出保證，用戶應自行核對並確認內容。</p>

            <h2>六、智慧財產權</h2>
            <ol>
               <li>本服務所涉及的軟體、技術及相關內容之所有權與智慧財產權均屬本會所有。</li>
               <li>用戶僅享有本服務授予的有限使用權，不得以任何形式擅自複製、修改、散佈或衍生使用。</li>
            </ol>

            <h2>七、服務限制與終止</h2>
            <ol>
               <li>本會保留在必要時限制或暫停用戶訪問本服務的權利，無需事先通知。</li>
               <li>用戶違反本條款或法律規定時，本會有權立即終止其使用資格。</li>
            </ol>

            <h2>八、責任限制</h2>
            <ol>
               <li>本服務按"現狀"提供，本會不對服務的不中斷性或無誤性作任何保證。</li>
               <li>對於因使用本服務而產生的任何直接、間接或後果性損失，本會概不承擔責任。</li>
            </ol>

            <h2>九、條款修改</h2>
            <p>本會保留隨時修改本條款的權利，修訂後的條款將通過本服務平台公告，用戶繼續使用本服務即視為同意修訂內容。</p>

            <h2>十、法律適用與爭議解決</h2>
            <p>本條款受中華民國法律管轄，因本條款引起之任何爭議，應以台灣台北地方法院為第一審管轄法院。</p>

            <h2>十一、聯繫方式</h2>
            <div class="contact">
               <p>如有任何問題，請聯繫：<br>
               XXXXXX<br>
               <a href="mailto:its@sinica.edu.tw">XXXX@mail.tycg.gov.tw</a></p>
            </div>
            <h2>十二、原始碼提供</h2>
               <a href="https://github.com/AS-AIGC/TranscriptHub">https://github.com/AS-AIGC/TranscriptHub</a></p>
         </div>
      </div>
   </main>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.3/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
<script>
   var needReload = false;  // 是否需要重新更新表格
   // 側邊欄縮放功能
   const sidebar = document.querySelector('.sidebar');
   const mainContent = document.querySelector('.main-content');

   function insertRow(item) {
      if (!item || item.length === 0) {  return; }
      const table = document.getElementById('files-list');
      if(!table) self.location.reload();

      const row = document.createElement("tr");
      var nameCell = document.createElement("td");
      nameCell.textContent = item.fileName || ' ';
      row.appendChild(nameCell);

      var ageCell = document.createElement("td");
      ageCell.textContent = item.action || " ";
      row.appendChild(ageCell);

      var ageCell = document.createElement('td');
      ageCell.textContent = item.status || " ";
      row.appendChild(ageCell);

      var ageCell = document.createElement('td');
      ageCell.textContent = item.uploadTime || " ";
      row.appendChild(ageCell);

      // finish time
      var ageCell = document.createElement('td');
      ageCell.textContent = item.finishTime || " ";
      row.appendChild(ageCell);

      var ageCell = document.createElement('td');
      var s = "";
      if(item.results && item.results.length > 0) {
         item.results.forEach(function(link) {
            let l = link.split("/");
            s += "<li><a href='/result/" + item.taskID + "/" + l[l.length-2] + "'>" + l[l.length-2] + "</a></li>\n";
         });
      } else {
         s = " ";
      }
      ageCell.innerHTML = s;
      row.appendChild(ageCell);
      // delete
      var ageCell = document.createElement('td');
      var deleteLink = document.createElement('a');
      deleteLink.href = "javascript:del('" + item.taskID + "');";
      var fontElement = document.createElement('font');
      fontElement.color = "red";
      var iconElement = document.createElement('i');
      iconElement.className = 'bx bxs-message-rounded-x';
      fontElement.appendChild(iconElement);
      deleteLink.appendChild(fontElement);

       ageCell.appendChild(deleteLink);
       row.appendChild(ageCell);
       row.classList.add('highlight');
       if(!table.rows || table.rows.length === 0) {
          table.appendChild(row);
       } else {
          table.insertBefore(row, table.rows[0]); // 插入到第一行位置
       }
       // 五秒后移除高亮颜色
       setTimeout(function() {
          row.classList.remove('highlight');
       }, 10000);
   }

   function generateTable(data) {
      if (!data || data.length === 0) {  return; }
      const table = document.getElementById('files-list');
      table.innerHTML = '';

      data.forEach(function(item) {
          const row = document.createElement("tr");
          var nameCell = document.createElement("td");
          nameCell.textContent = item.fileName || ' ';
          row.appendChild(nameCell);

          var ageCell = document.createElement("td");
          ageCell.textContent = item.action || " ";
          row.appendChild(ageCell);

          var ageCell = document.createElement('td');
          ageCell.textContent = item.status || " ";
          row.appendChild(ageCell);

          var ageCell = document.createElement('td');
          ageCell.textContent = item.uploadTime || " ";
          row.appendChild(ageCell);

          // finish time
          var ageCell = document.createElement('td');
          ageCell.textContent = item.finishTime || " ";
          row.appendChild(ageCell);

          var ageCell = document.createElement('td');
          var s = "";
          if(item.results && item.results.length > 0) {
             item.results.forEach(function(link) {
                let l = link.split("/"); 
                s += "<li><a href='/result/" + item.taskID + "/" + l[l.length-2] + "'>" + l[l.length-2] + "</a></li>\n";
             });
          } else { 
             s = " ";
          }
          ageCell.innerHTML = s;
          row.appendChild(ageCell);
          // delete 
          var ageCell = document.createElement('td');
          var deleteLink = document.createElement('a');
          deleteLink.href = "javascript:del('" + item.taskID + "');";
          var fontElement = document.createElement('font');
          fontElement.color = "red";
          var iconElement = document.createElement('i');
          iconElement.className = 'bx bxs-message-rounded-x';
          fontElement.appendChild(iconElement);
          deleteLink.appendChild(fontElement);
 
          ageCell.appendChild(deleteLink);
          row.appendChild(ageCell);
          if (table.rows.length === 0) {
             table.appendChild(row);
          } else {
             table.insertBefore(row, table.rows[0]); // 插入到第一行位置
          }
      });
   }

   function generateList(data) {
      var listContainer = document.getElementById('jobLists');
      if(!listContainer)  return;
      listContainer.innerHTML = '';
      data.forEach(function(item) {
         var listItem = document.createElement('li');
         listItem.textContent = item.name; // 假設JSON資料中有一個名為'name'的屬性
         listContainer.appendChild(listItem); // 將li元素添加到列表容器中
      });
   }
   
   // Function to get the value of the 'multiplespeaker' radio buttons
   function getMultiplespeakerValue() {
       const radios = document.getElementsByName('multiplespeaker');
       for(let i = 0; i < radios.length; i++) {
           if(radios[i].checked) {
              return radios[i].value;
           }
       }
       return 0;
   }

   function del(id) {
      if(!id || !confirm("是否確定要刪除此筆資料？")) return;
      var xhr = new XMLHttpRequest();
      xhr.open('GET', '/del/' + id, true);
      xhr.onload = function(evt) {
         if(xhr.status === 200) {
            console.log(xhr.responseText);
            self.location.reload();
         } else {
            alert('Delete failed');
         }
      };
      xhr.onerror = function () {
         alert("delete error");
      };
      xhr.send();
   }

   function uploadFile() {
      var button = document.getElementById("myButton");
      button.disabled = true; // 禁用按钮
      var fileInput = document.getElementById('file');
      var file = fileInput.files[0];
      var formData = new FormData();
      const multiplespeaker = getMultiplespeakerValue();
      formData.append('file', file);
      formData.append('multiplespeaker', multiplespeaker);
      var xhr = new XMLHttpRequest();
      xhr.open('POST', '/upload', true);
      xhr.upload.onprogress = function (e) {
         if(e.lengthComputable) {
            var progress = (e.loaded / e.total) * 100;
            document.getElementById('progressBar').style.width = progress + '%';
            document.getElementById('progressBar').innerText = Math.round(progress) + '%';
         }
      };
      xhr.onload = function () {
         if(xhr.status === 200) {
            var responseData = JSON.parse(xhr.responseText);
            if(responseData)  {
               insertRow(responseData);
               alert("上傳成功");
            } else {
               alert("上傳失敗");
            } 
         } else {
            document.getElementById('uploadStatus').innerText = 'Upload failed';
         }
         document.getElementById('progressBar').style.width = '0%';
         document.getElementById('progressBar').innerText = '0%';
         button.disabled = false;
         document.getElementById('uploadForm').reset();
       };
       xhr.onerror = function () {
          document.getElementById('uploadStatus').innerText = 'Upload failed';
          document.getElementById('progressBar').style.width = '0%';
          document.getElementById('progressBar').innerText = '0%';
          button.disabled = false;
          document.getElementById('uploadForm').reset();
       };
       xhr.send(formData);
   }

   function validateForm() {
      var fileInput = document.getElementById('file');
      var filePath = fileInput.value;
      var allowedExtensions = /(\.wav)|(\.mp3)$/i;

      if(!allowedExtensions.exec(filePath)) {
          alert('Please upload an MP3 file.');
          fileInput.value = '';
          return false;
      }
      return true;
   }

   function cycleEvents() {
      $.ajax({ url: "/query/jobs", method: "GET",
         success:function(res){
            if(!res) { console.log(res); return; }
            var events = JSON.parse(res);
            if(needReload) {
               generateTable(events);
               return;
            }
            if(events && events.length > 0) {
               for(var i = 0; i < events.length; i++)  {
                  let event = events[i]; 
                  var s = "";
                  if(!event.results || event.results.length == 0)   continue;
                  event.results.forEach(function(link) {
                     let l = link.split("/");
                     s += "<li><a href='/result/" + event.taskID + "/" + l[l.length-2] + "'>" + l[l.length-2] + "</a></li>\n";
                  });
                  var elem = document.querySelector("#Job" + event.taskID);
                  if(!elem)  { needReload = true; return; }
                  elem.innerHTML = s;
               }
            } else {
            }
         },
         error:function(err) {
            console.log(err)
         }
      });
   }
   
   function moveRowUp(row) {
      const prevRow = row.previousElementSibling;
      if(prevRow) {
         row.classList.add('moving-up');
         prevRow.classList.add('moving-down');

         setTimeout(() => {
            row.parentNode.insertBefore(row, prevRow);
            row.classList.remove('moving-up');
            prevRow.classList.remove('moving-down');
         }, 300);
      }
   }

   function moveRowDown(row) {
      const nextRow = row.nextElementSibling;
      if(nextRow) {
         row.classList.add('moving-down');
         nextRow.classList.add('moving-up');

         setTimeout(() => {
            row.parentNode.insertBefore(nextRow, row);
            row.classList.remove('moving-down');
            nextRow.classList.remove('moving-up');
         }, 400);
      }
   }
   
   var timeoutID;
   $(document).ready(function() {
      timeoutID = window.setInterval(cycleEvents, 30000);
   });
        
   // 移動設備上的側邊欄處理
   if(window.innerWidth <= 768) {
      sidebar.classList.add('collapsed');
      mainContent.classList.add('expanded');
   }
</script>
</body>
</html>
