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

        @media screen and (max-width: 600px) {
           .sideBarTxt {
              display: none;
           }
           .right-align {
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
    </style>
</head>
<body>
   {{template "sidebar" .}}
   <!-- 主內容區域 -->
   <main class="main-content">
      <div class="right-align">
         您好，{{ .Userinfo.ChName }}（{{ .Userinfo.Email }}） |
         <a href="/www/en/translate">English</a>
      </div>
      <div class="container">
         <!-- 上傳表單 -->
         <form id="uploadForm" enctype="multipart/form-data" class="upload-form">
            <h2>請選擇聲音檔上傳</h2>
            <div class="file-format">格式限制：mp3、wav</div>
            <div class="file-input-container">
               <input type="file" class="form-control-file" id="file" name="file" accept=".mp3,.wav" required>
               <small id="fileHelp" class="form-text text-muted">Please upload an MP3 file.</small>
            </div>
            <div class="radio-group">
               <div>是否標註不同人發言？</div>
               <label>
                  <input type="radio" style="margin:0;min-width:0;" name="multiplespeaker" value="0" checked> 關閉
               </label>
               <label>
                  <input type="radio" style="margin-left:15px;min-width:0;" name="multiplespeaker"value="1" > 開啟
               </label>
            </div>
            <button type="button" class="upload-btn" id="myButton" onclick="uploadFile()">Upload</button>
            <div class="progress">
               <div id="progressBar" class="progress-bar" role="progressbar" style="width:0%;" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100">0%<span>上傳成功</span></div>
            </div>
         </form>
         {{ $length := len .Jobs }}
         {{ if gt $length 0 }}
         <!-- 檔案列表表格 -->
         <table class="responsive-table">
            <thead>
               <tr>
                  <th>檔案名稱</th>
                  <th>工作型態</th>
                  <th>目前狀態</th>
                  <th>上傳時間</th>
                  <th>結束時間</th>
                  <th>檔案下載</th>
                  <th></th>
               </tr>
            </thead>
            <tbody id="files-list">
               {{range $i, $val := .Jobs}}
                  {{ $taskID := $val.TaskID }}
                  <tr id="row{{$i}}">
                     <td data-label="檔案名稱" title="{{ $taskID }}">{{ $val.FileName }}</td>
                     <td data-label="工作型態">{{ $val.Action }}</td>
                     <!-- **** 建議修改下面這行的 data-label="工作型態" 為 data-label="目前狀態" **** -->
                     <td data-label="工作型態">{{ $val.Status }}</td>
                     <td data-label="上傳時間">{{ $val.UploadTime }}</td>
                     <td data-label="結束時間">{{ $val.FinishTime }} </td>
                     <td data-label="檔案下載" id="Job{{ $taskID }}">
                        {{ $length := len $val.Results }}
                        {{ if gt $length 0 }}
                           <ul>
                           {{/* 假設 $val.Results 包含可用的格式名稱，例如 ["TXT", "SRT"] */}}
                           {{ range $val.Results }}
                              <li><a href="/result/{{ $taskID }}/{{ . }}" target=_blank>{{ . }}</a></li>
                           {{ end }}
                           </ul>
                        {{ else }}
                             
                        {{ end }}
                     </td>
                     <td data-label="刪除檔案">
                        <a href="javascript:del('{{ $taskID }}');" title="刪除檔案">
                           <font color="red"><i class='bx bxs-message-rounded-x'></i></font></a>
                     </td>
                  </tr>
                  {{end}}
            </tbody>
         </table>
         {{ end }}
      </div>
   </main>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.3/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
<script>
   var needReload = false;  // 是否需要重新更新表格
   // 側邊欄縮放功能 (保留你原有的邏輯)
   const sidebar = document.querySelector('.sidebar');
   const mainContent = document.querySelector('.main-content');
   // ... (你可能還有其他的側邊欄相關 JS) ...

   function insertRow(item) {
       // **** 重要: 請確保這個函數內部給「檔案下載」的 <td> 添加了 id="Job" + item.taskID ****
       // (你提供的 insertRow 程式碼片段中沒有包含這個 TD 的創建，請檢查你的完整程式碼)
       if (!item || item.length === 0) { return; }
       const table = document.getElementById('files-list');
       if (!table) { self.location.reload(); return; } // 如果找不到表格，重新載入頁面

       const row = document.createElement("tr");
       row.id = "row" + Date.now(); // 給新行一個唯一的 ID (或者用其他方式)

       // 檔案名稱
       var nameCell = document.createElement("td");
       nameCell.setAttribute("data-label", "檔案名稱");
       nameCell.setAttribute("title", item.taskID || '');
       nameCell.textContent = item.fileName || '\u00A0';
       row.appendChild(nameCell);

       // 工作型態
       var actionCell = document.createElement("td");
       actionCell.setAttribute("data-label", "工作型態");
       actionCell.textContent = item.action || '\u00A0';
       row.appendChild(actionCell);

       // 目前狀態
       var statusCell = document.createElement('td');
       statusCell.setAttribute("data-label", "目前狀態"); // *** 確保 data-label 正確 ***
       // --- 同樣需要進行狀態碼轉換 ---
       let statusText = item.status || "pending"; // 假設新上傳的默認是 pending
       if (item.status === 2 || item.status === "2") { statusText = "完成"; }
       else if (item.status === 1 || item.status === "1") { statusText = "處理中"; }
       else if (item.status === 0 || item.status === "0" || item.status === "pending") { statusText = "pending"; }
       statusCell.textContent = statusText;
       row.appendChild(statusCell);

       // 上傳時間
       var uploadTimeCell = document.createElement('td');
       uploadTimeCell.setAttribute("data-label", "上傳時間");
       uploadTimeCell.textContent = item.uploadTime || '\u00A0';
       row.appendChild(uploadTimeCell);

       // 結束時間
       var finishTimeCell = document.createElement('td');
       finishTimeCell.setAttribute("data-label", "結束時間");
       finishTimeCell.textContent = item.finishTime || '\u00A0';
       row.appendChild(finishTimeCell);

       // 檔案下載
       var downloadCell = document.createElement('td');
       downloadCell.setAttribute('data-label', '檔案下載');
       downloadCell.id = "Job" + item.taskID; // *** 關鍵: 設置 ID ***
       var downloadLinksHtml = '\u00A0';
       if (item.results && item.results.length > 0) {
           downloadLinksHtml = "<ul>";
           // 假設 item.results 是格式名稱陣列
            item.results.forEach(function(formatName) {
                let downloadUrl = '/result/' + item.taskID + '/' + formatName;
                downloadLinksHtml += "<li><a href='" + downloadUrl + "' target='_blank'>" + formatName + "</a></li>";
            });
           downloadLinksHtml += "</ul>";
       }
       downloadCell.innerHTML = downloadLinksHtml;
       row.appendChild(downloadCell);

       // 刪除按鈕
       var deleteCell = document.createElement('td');
       deleteCell.setAttribute("data-label", "刪除檔案");
       var deleteLink = document.createElement('a');
       deleteLink.href = "javascript:del('" + item.taskID + "');";
       deleteLink.title = "刪除檔案";
       var fontElement = document.createElement('font');
       fontElement.color = "red";
       var iconElement = document.createElement('i');
       iconElement.className = 'bx bxs-message-rounded-x';
       fontElement.appendChild(iconElement);
       deleteLink.appendChild(fontElement);
       deleteCell.appendChild(deleteLink);
       row.appendChild(deleteCell);

       // 添加高亮效果並插入表格
       row.classList.add('highlight');
       if (!table.rows || table.rows.length === 0) {
           table.appendChild(row);
       } else {
           table.insertBefore(row, table.firstChild); // 插入到第一行位置
       }

       // 一段時間後移除高亮
       setTimeout(function () {
           row.classList.remove('highlight');
       }, 10000); // 10 秒
   }


   function generateTable(data) {
       if (!data || data.length === 0) {
           // 如果沒有資料，可以選擇清空表格或顯示提示訊息
           const table = document.getElementById('files-list');
           if(table) table.innerHTML = '<tr><td colspan="7" style="text-align:center;">目前沒有工作記錄</td></tr>';
           return;
       }
       const table = document.getElementById('files-list');
       table.innerHTML = ''; // 清空現有內容

       data.forEach(function (item, index) { // 添加 index 用於 row ID
           const row = document.createElement("tr");
           row.id = "row" + index; // 使用索引作為行 ID

           // 檔案名稱
           var nameCell = document.createElement("td");
           nameCell.setAttribute("data-label", "檔案名稱");
           nameCell.setAttribute("title", item.taskID || '');
           nameCell.textContent = item.fileName || '\u00A0';
           row.appendChild(nameCell);

           // 工作型態
           var actionCell = document.createElement("td");
           actionCell.setAttribute("data-label", "工作型態");
           actionCell.textContent = item.action || '\u00A0';
           row.appendChild(actionCell);

           // 目前狀態
           var statusCell = document.createElement('td');
           statusCell.setAttribute("data-label", "目前狀態"); // *** 確保 data-label 正確 ***
           // --- 同樣需要進行狀態碼轉換 ---
           let statusText = "未知狀態";
           if (item.status === 2 || item.status === "2") { statusText = "完成"; }
           else if (item.status === 1 || item.status === "1") { statusText = "處理中"; }
           else if (item.status === 0 || item.status === "0" || item.status === "pending") { statusText = "pending"; }
           else if (item.status) { statusText = item.status; }
           statusCell.textContent = statusText;
           row.appendChild(statusCell);

           // 上傳時間
           var uploadTimeCell = document.createElement('td');
           uploadTimeCell.setAttribute("data-label", "上傳時間");
           uploadTimeCell.textContent = item.uploadTime || '\u00A0';
           row.appendChild(uploadTimeCell);

           // 結束時間
           var finishTimeCell = document.createElement('td');
           finishTimeCell.setAttribute("data-label", "結束時間");
           finishTimeCell.textContent = item.finishTime || '\u00A0';
           row.appendChild(finishTimeCell);

           // 檔案下載
           var downloadCell = document.createElement('td');
           downloadCell.setAttribute('data-label', '檔案下載');
           downloadCell.id = "Job" + item.taskID; // *** 關鍵: 設置 ID ***
           var downloadLinksHtml = '\u00A0';
           if (item.results && item.results.length > 0) {
               downloadLinksHtml = "<ul>";
                // 假設 item.results 是格式名稱陣列
                item.results.forEach(function(formatName) {
                    let downloadUrl = '/result/' + item.taskID + '/' + formatName;
                    downloadLinksHtml += "<li><a href='" + downloadUrl + "' target='_blank'>" + formatName + "</a></li>";
                });
               downloadLinksHtml += "</ul>";
           }
           downloadCell.innerHTML = downloadLinksHtml;
           row.appendChild(downloadCell);

           // 刪除按鈕
           var deleteCell = document.createElement('td');
           deleteCell.setAttribute("data-label", "刪除檔案");
           var deleteLink = document.createElement('a');
           deleteLink.href = "javascript:del('" + item.taskID + "');";
           deleteLink.title = "刪除檔案";
           var fontElement = document.createElement('font');
           fontElement.color = "red";
           var iconElement = document.createElement('i');
           iconElement.className = 'bx bxs-message-rounded-x';
           fontElement.appendChild(iconElement);
           deleteLink.appendChild(fontElement);
           deleteCell.appendChild(deleteLink);
           row.appendChild(deleteCell);

           // 將行添加到表格體
           table.appendChild(row);
       });
   }


   function generateList(data) {
      var listContainer = document.getElementById('jobLists'); // 檢查你的 HTML 是否有這個 ID
      if(!listContainer)  return;
      listContainer.innerHTML = '';
      data.forEach(function(item) {
         var listItem = document.createElement('li');
         listItem.textContent = item.name || item.fileName || item.taskID; // 嘗試找到一個可顯示的名稱
         listContainer.appendChild(listItem);
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
       return "0"; // 返回字串 "0" 可能更安全
   }

   function del(id) {
      if(!id || !confirm("是否確定要刪除此筆資料？")) return;
      var xhr = new XMLHttpRequest();
      // 考慮使用 DELETE 方法 (如果後端支持)
      // xhr.open('DELETE', '/del/' + id, true);
      xhr.open('GET', '/del/' + id, true); // 保持 GET 如果後端是這樣實現的
      // 可以考慮添加 Authorization 頭部，如果刪除需要權限
      // xhr.setRequestHeader('Authorization', 'Bearer ' + your_token_variable);
      xhr.onload = function(evt) {
         if(xhr.status === 200 || xhr.status === 204) { // 200 OK 或 204 No Content 都表示成功
            console.log("Delete successful for:", id, xhr.responseText);
            // 從表格中移除行，而不是重新載入整個頁面，體驗更好
            var rowToRemove = document.querySelector("#Job" + id)?.closest('tr');
            if (rowToRemove) {
                rowToRemove.remove();
                console.log("Removed row for taskID:", id);
            } else {
                // 如果找不到行，可能需要重新載入以同步狀態
                console.warn("Could not find row to remove for taskID:", id, "- reloading page.");
                self.location.reload();
            }
         } else {
            console.error('Delete failed for:', id, 'Status:', xhr.status, xhr.responseText);
            alert('刪除失敗 (Status: ' + xhr.status + ')');
         }
      };
      xhr.onerror = function () {
         console.error("Network error during delete request for:", id);
         alert("刪除請求時發生網路錯誤");
      };
      xhr.send();
   }

   function uploadFile() {
      var fileInput = document.getElementById('file');
      if(fileInput.files.length <= 0) {
         alert("請先選擇上傳檔案");
         return;
      }
      var file = fileInput.files[0];
      // 基本的文件類型和大小檢查 (可選但推薦)
      var allowedTypes = ['audio/mpeg', 'audio/wav', 'audio/mp3']; // MP3 可能有多種 MIME type
      if (!allowedTypes.includes(file.type)) {
          alert('檔案格式不支援，請上傳 mp3 或 wav 檔案。\n偵測到的類型: ' + file.type);
          return;
      }
      // var maxSize = 100 * 1024 * 1024; // 例如: 限制 100MB
      // if (file.size > maxSize) {
      //     alert('檔案大小超過限制 (例如 100MB)');
      //     return;
      // }

      var button = document.getElementById("myButton");
      var progressBar = document.getElementById('progressBar');
      var progressSpan = progressBar.querySelector('span'); // 獲取進度條內的 span

      button.textContent = '檔案上傳中.....';
      button.disabled = true;
      progressBar.style.width = '0%';
      progressBar.setAttribute('aria-valuenow', '0');
      progressBar.textContent = '0%'; // 清空文字
      if (progressSpan) progressSpan.style.display = 'none'; // 隱藏“上傳成功”

      var formData = new FormData();
      const multiplespeaker = getMultiplespeakerValue();
      formData.append('file', file);
      formData.append('multiplespeaker', multiplespeaker);

      var xhr = new XMLHttpRequest();
      xhr.open('POST', '/upload', true);
      // 可以考慮添加 Authorization 頭部，如果上傳需要權限
      // xhr.setRequestHeader('Authorization', 'Bearer ' + your_token_variable);

      xhr.upload.onprogress = function (e) {
         if(e.lengthComputable) {
            var progress = (e.loaded / e.total) * 100;
            progressBar.style.width = progress + '%';
            progressBar.setAttribute('aria-valuenow', progress);
            progressBar.textContent = Math.round(progress) + '%';
         }
      };

      xhr.onload = function () {
         if(xhr.status === 200 || xhr.status === 201) { // 200 OK 或 201 Created
            try {
               var responseData = JSON.parse(xhr.responseText);
               console.log("Upload successful, response:", responseData);
               if(responseData && responseData.taskID) { // 確保回應中有 taskID
                  insertRow(responseData); // 使用 insertRow 添加新行
                  // alert("上傳成功"); // insertRow 視覺上已經提示，這裡可以考慮移除或改為非阻塞提示
                  if (progressSpan) {
                      progressBar.style.width = '100%'; // 確保進度條滿
                      progressBar.textContent = '100%';
                      // 不再顯示“上傳成功”文字，因為 insertRow 已經更新列表
                      // progressSpan.style.display = 'inline';
                      // setTimeout(() => { // 短暫顯示後隱藏進度條
                      //    progressBar.style.width = '0%';
                      //    progressBar.textContent = '0%';
                      // }, 3000);
                  }
               } else {
                   console.error("Upload succeeded but response data is invalid:", responseData);
                   alert("上傳成功，但伺服器回應資料格式錯誤，無法更新列表。");
               }
            } catch (e) {
                console.error("Error parsing upload response JSON:", e, xhr.responseText);
                alert("上傳成功，但解析伺服器回應時出錯。");
            }
         } else {
            console.error('Upload failed. Status:', xhr.status, xhr.responseText);
            // 嘗試解析錯誤訊息
            let errorMsg = '上傳失敗 (Status: ' + xhr.status + ')';
            try {
                let errorData = JSON.parse(xhr.responseText);
                if (errorData && errorData.error) {
                    errorMsg += "\n錯誤訊息: " + errorData.error;
                } else if(xhr.responseText) {
                     errorMsg += "\n" + xhr.responseText.substring(0, 100); // 顯示部分原始錯誤
                }
            } catch (e) {
                // 解析失敗，顯示原始文字
                 if(xhr.responseText) {
                     errorMsg += "\n" + xhr.responseText.substring(0, 100);
                }
            }
            alert(errorMsg);
            progressBar.style.width = '0%'; // 重設進度條
            progressBar.textContent = '0%';
         }
         // 無論成功或失敗，都恢復按鈕和表單
         button.disabled = false;
         button.textContent = 'Upload';
         document.getElementById('uploadForm').reset(); // 清空文件選擇
         // 延遲一點時間重設進度條視覺效果
         setTimeout(() => {
             progressBar.style.width = '0%';
             progressBar.textContent = '0%';
         }, 2000);
       };

       xhr.onerror = function () {
          console.error("Network error during upload.");
          alert('檔案上傳時發生網路錯誤');
          progressBar.style.width = '0%';
          progressBar.textContent = '0%';
          button.disabled = false;
          button.textContent = 'Upload';
          document.getElementById('uploadForm').reset();
       };
       xhr.send(formData);
   }

   function validateForm() {
       // 這個函數目前沒有被直接使用，可以在選擇檔案時觸發 (onchange) 或上傳前調用
      var fileInput = document.getElementById('file');
      if (fileInput.files.length > 0) {
         var filePath = fileInput.value;
         var allowedExtensions = /(\.wav|\.mp3)$/i;
         if(!allowedExtensions.exec(filePath)) {
             alert('檔案格式不正確，請選擇 .mp3 或 .wav 檔案。');
             fileInput.value = ''; // 清空選擇
             return false;
         }
      }
      return true;
   }


   // ======================================================
   // ==========   修正後的 cycleEvents 函數   ==========
   // ======================================================
   function cycleEvents() {
       $.ajax({
           url: "/query/jobs?_t=" + new Date().getTime(), // 添加 cache busting 參數
           method: "GET",
           // dataType: 'json', // 你可以明確指定 dataType，但通常 jQuery 會自動偵測
           success: function (res) { // 'res' 已經是解析後的 JS 物件/陣列
               console.log("Received data from /query/jobs:", res); // 直接打印收到的數據結構

               // **** 主要修改：移除 JSON.parse() ****
               // 不再需要: var events = JSON.parse(res);
               var events = res; // 直接使用 res

               if (!events) { // 檢查 events 是否有效 (可能為 null 或 undefined)
                   console.log("Received null or undefined data from /query/jobs");
                   // 可以考慮清空表格或顯示提示
                   const table = document.getElementById('files-list');
                   if(table) table.innerHTML = '<tr><td colspan="7" style="text-align:center;">無法獲取工作狀態</td></tr>';
                   return;
               }

               // 後續的邏輯保持不變，直接使用 'events' 變數
               if (needReload) {
                   console.log("Need reload is true, regenerating table.");
                   generateTable(events); // 使用 generateTable 重建整個表格
                   needReload = false; // 重設標記
                   return;
               }

               // 判斷 events 是否為陣列且有內容
               if (Array.isArray(events) && events.length > 0) {
                   let updatedTaskIDs = new Set();

                   for (var i = 0; i < events.length; i++) {
                       let event = events[i];
                       if (!event || !event.taskID) {
                           console.warn("Skipping invalid event data:", event);
                           continue;
                       }
                       updatedTaskIDs.add(event.taskID.toString());
                       console.log("Processing event:", event.taskID, "Status:", event.status);

                       var resultsCell = document.querySelector("#Job" + event.taskID);

                       if (!resultsCell) {
                           console.warn("Results cell #Job" + event.taskID + " not found. Setting needReload = true.");
                           needReload = true;
                           continue;
                       }

                       var tableRow = resultsCell.closest('tr');
                       if (!tableRow) {
                          console.error("Could not find parent TR for cell:", resultsCell);
                          continue;
                       }

                       var statusCell = tableRow.querySelector('td[data-label="目前狀態"]') || tableRow.querySelector('td[data-label="工作型態"]:nth-of-type(3)'); // 包含備選查詢
                       var finishTimeCell = tableRow.querySelector('td[data-label="結束時間"]');

                       // 更新狀態
                       if (statusCell) {
                           let statusText = "未知狀態";
                           // **** (重要) 根據後端狀態碼調整 ****
                           if (event.status === 2 || event.status === "2") { statusText = "完成"; }
                           else if (event.status === 1 || event.status === "1") { statusText = "處理中"; }
                           else if (event.status === 0 || event.status === "0" || event.status === "pending") { statusText = "pending"; }
                           else if (event.status != null) { statusText = event.status; } // 顯示非空狀態

                           if (statusCell.textContent !== statusText) {
                               statusCell.textContent = statusText;
                               console.log("Updated status for", event.taskID, "to", statusText);
                           }
                       } else {
                           console.warn("Status cell could not be found for taskID:", event.taskID);
                       }

                       // 更新結束時間
                       if (finishTimeCell) {
                           let finishTimeText = event.finishTime || '\u00A0';
                           if (finishTimeCell.textContent !== finishTimeText) {
                               finishTimeCell.textContent = finishTimeText;
                               console.log("Updated finish time for", event.taskID, "to", event.finishTime || 'N/A');
                           }
                       } else {
                           console.warn("Finish time cell not found for taskID:", event.taskID);
                       }

                       // 更新下載連結
                       var currentDownloadHTML = resultsCell.innerHTML.trim();
                       var downloadLinksHtml = '\u00A0';
                       if (Array.isArray(event.results) && event.results.length > 0) {
                           downloadLinksHtml = "<ul>";
                            event.results.forEach(function(formatName) {
                                if (typeof formatName === 'string' && formatName.trim() !== '') {
                                    let downloadUrl = '/result/' + event.taskID + '/' + encodeURIComponent(formatName.trim());
                                    downloadLinksHtml += "<li><a href='" + downloadUrl + "' target='_blank'>" + formatName.trim() + "</a></li>";
                                }
                            });
                           downloadLinksHtml += "</ul>";
                       }
                       if (resultsCell.innerHTML.trim() !== downloadLinksHtml.trim()) {
                           resultsCell.innerHTML = downloadLinksHtml;
                           console.log("Updated download links for", event.taskID);
                       }
                   } // End of for loop

                   // 移除陳舊行邏輯 (保持不變)
                   const table = document.getElementById('files-list');
                   if(table) {
                        const rows = table.querySelectorAll('tr');
                        rows.forEach(row => {
                            let rowTaskIDElement = row.querySelector('td[id^="Job"]');
                            if (rowTaskIDElement) {
                                let rowTaskID = rowTaskIDElement.id.substring(3);
                                if (!updatedTaskIDs.has(rowTaskID)) {
                                    console.log("Removing stale row for taskID:", rowTaskID);
                                    row.remove();
                                }
                            } else {
                                 console.warn("Could not determine taskID for row:", row.id, " - cannot check for staleness.");
                            }
                        });
                   }

               } else {
                   console.log("Received data is not an array or is empty. Clearing table.");
                   const table = document.getElementById('files-list');
                   if(table) table.innerHTML = '<tr><td colspan="7" style="text-align:center;">目前沒有工作記錄</td></tr>';
               }

               // 不再需要 try...catch 來捕獲 JSON.parse 錯誤了
           }, // success callback 結束
           error: function (jqXHR, textStatus, errorThrown) {
               console.error("AJAX error querying /query/jobs. Status:", jqXHR.status, textStatus, errorThrown);
               console.error("Response Text:", jqXHR.responseText);
               if (jqXHR.status === 401 || jqXHR.status === 403) {
                   alert("您可能需要重新登入。");
                   // window.location.href = '/login';
               } else {
                   // 可以考慮顯示一個通用的錯誤提示
                   // alert("查詢工作狀態時發生錯誤，請稍後再試。");
               }
           }
       });
   }
   // ======================================================
   // ==========   cycleEvents 函數結束       ==========
   // ======================================================



   // 下面是你原有的 moveRowUp, moveRowDown 函數 (保持不變)
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
      // 頁面載入完成後，立即執行一次 cycleEvents 以獲取初始狀態
      cycleEvents();
      // 然後設定定時器，定期更新
      timeoutID = window.setInterval(cycleEvents, 30000); // 保持 30 秒間隔

      // 移動設備上的側邊欄處理 (保持不變)
      if(window.innerWidth <= 768) {
          if (sidebar) sidebar.classList.add('collapsed');
          if (mainContent) mainContent.classList.add('expanded');
      }

      // 可以添加對側邊欄切換按鈕的事件監聽 (如果需要)
      const toggleButton = document.querySelector('.toggle-btn'); // 假設你有這個按鈕
       if (toggleButton && sidebar && mainContent) {
           toggleButton.addEventListener('click', () => {
               sidebar.classList.toggle('collapsed');
               sidebar.classList.toggle('expanded'); // 如果需要 expanded class
               mainContent.classList.toggle('expanded');
               mainContent.classList.toggle('collapsed'); // 如果需要 collapsed class
           });
       }
   });

</script>
</body>
</html>