# Academia Sinica AI Suite (AISuite)

AISuite 是一個專為中央研究院設計的 AI 工具套件，主要提供錄音檔案轉逐字稿的功能，並支援多種格式的檔案上傳與處理。此專案包含前端頁面與後端服務。

---

## 功能特色

- 支援 MP3、WAV 等音訊格式的逐字稿轉換。
- 提供多語言的前端頁面模板。
- 支援 Docker 部署及 Windows 系統的安裝，可快速啟動服務。
- 提供 RESTful API，方便整合其他系統或與 AI 整合。
- 自動化 Email 通知功能，提醒用戶處理結果。

---

## 系統需求

- **Go** 1.22 或以上版本
- **Docker** (可選)
- **ffmpeg** (音訊處理工具)
- **SMTP Server** (用於 Email 通知)
- **AI Whisper** （需自行準備）

---

## 安裝方式

### 方法一：使用原始碼進行安裝

1. **Clone 專案**
   ```sh
   git clone https://github.com/AS-AIGC/TranscriptHub.git
   cd TranscriptHub/apps/frontend/
   ```

2. **安裝依賴套件**
   ```sh
   go mod tidy
   ```

3. **編譯專案**
   - Linux:
     ```sh
     make build
     ```
   - Windows:
     ```sh
     make build-win
     ```

4. **啟動服務**
   ```sh
   ./app
   ```

5. **開啟瀏覽器**
   預設服務運行於 `http://localhost:80` （其中 port 80設定，可於 makefile 及 envfile 中設定）。

---

### 方法二：使用 Docker 部署（推薦）
使用 Docker 前，請先確定您已經安裝好可以運行的 Docker 環境。

1. **建置 Docker 映像檔**
   ```sh
   make docker
   ```

2. **啟動容器**
   ```sh
   make run
   ```

3. **檢查日誌**
   ```sh
   make log
   ```

4. **停止容器**
   ```sh
   make stop
   ```

---

## 環境變數設定

請在專案根目錄下的 envfile（可參考.env說明，或 rename .env to envfile 後進行修改）中設定以下參數：

| 參數名稱              | 說明                                   | 預設值                       |
|-----------------------|----------------------------------------|----------------------------|
| `SystemName`          | 系統名稱                              | `Open AI Suite`              |
| `PORT`                | 服務埠號                              | `80`                       |
| `ContainerName`       | Docker 容器名稱                       | `openaisuite`                  |
| `DocumentRoot`        | 靜態檔案根目錄                        | html                 |
| `TemplateRoot`        | 模板檔案根目錄                        | template            |
| `UploadFolder`        | 上傳檔案存放目錄                      | tmp                     |
| `JobsFile`            | 工作列表檔案名稱                      | joblists                 |
| `mailHost`            | SMTP 主機                             | `smtp.yourdomain.com`       |
| `smtpPort`            | SMTP 埠號                             | `25`                       |
| `smtpEmail`           | SMTP 發送者 Email                     | `notify@yourdomain.com`        |
| `TranslateUrl`        | 翻譯服務 API URL                      | `https://10.0.0.1:8080/api/v1/rest/CreateTranscribeTask` |
| `TranslateQueryUrl`   | 翻譯服務查詢 API URL                  | `https://10.0.0.1:8080/api/v1/rest/ViewAllTask` |
| `DownloadServer`      | 下載服務 URL                          | `https://10.0.0.2:8080/api/v1/rest/RetrieveTranscribe/` |
| `MaxUploadSize`       | 最大上傳檔案大小（MB）                | `290`                      |

---

## API 路由

| 路由                     | 方法  | 說明                                   |
|--------------------------|-------|----------------------------------------|
| `/upload`                | POST  | 上傳音訊檔案                          |
| `/query/jobs`            | GET   | 查詢用戶的工作列表                    |
| `/listall/jobs`          | GET   | 查詢所有工作列表                      |
| `/result/{taskID}/{type}`| GET   | 下載處理結果                          |
| `/del/{taskID}`          | DELETE| 刪除指定工作                          |

---

## 授權

本專案採用 MIT 授權條款，詳見 LICENSE。

```

### 英文版本

```markdown
# Academia Sinica AI Suite (AISuite)

AISuite is an AI toolkit designed specifically for Academia Sinica, mainly providing transcription services for audio files and supporting multiple file formats for upload and processing. This project includes both frontend pages and backend services.

---

## Features

- Supports transcription for audio formats such as MP3 and WAV.
- Provides multilingual front-end page templates.
- Supports Docker deployment and Windows installation for quick service startup.
- Offers RESTful API for easy integration with other systems or AI.
- Automated email notification feature to notify users of processing results.

---

## System Requirements

- **Go** version 1.22 or above
- **Docker** (optional)
- **ffmpeg** (audio processing tool)
- **SMTP Server** (for email notifications)
- **AI Whisper** (to be prepared by the user)

---

## Installation

### Method 1: Install from Source Code

1. **Clone the Project**
   ```sh
   git clone https://github.com/AS-AIGC/TranscriptHub.git
   cd TranscriptHub
   ```

2. **Install Dependencies**
   ```sh
   go mod tidy
   ```

3. **Build the Project**
   - Linux:
     ```sh
     make build
     ```
   - Windows:
     ```sh
     make build-win
     ```

4. **Start the Service**
   ```sh
   ./app
   ```

5. **Open Browser**
   The default service runs at `http://localhost:80` (port 80 can be configured in makefile and envfile).

---

### Method 2: Deploy with Docker (Recommended)
Before using Docker, make sure you have a working Docker environment installed.

1. **Build Docker Image**
   ```sh
   make docker
   ```

2. **Start the Container**
   ```sh
   make run
   ```

3. **Check Logs**
   ```sh
   make log
   ```

4. **Stop the Container**
   ```sh
   make stop
   ```

---

## Environment Variables Configuration

Set the following parameters in the envfile located in the project's root directory (refer to .env for instructions, or rename .env to envfile and modify):

| Parameter Name         | Description                            | Default Value               |
|------------------------|----------------------------------------|-----------------------------|
| `SystemName`           | System Name                            | `Open AI Suite`             |
| `PORT`                 | Service Port                           | `80`                        |
| `ContainerName`        | Docker Container Name                  | `openaisuite`               |
| `DocumentRoot`         | Static File Root Directory             | html                        |
| `TemplateRoot`         | Template File Root Directory           | template                    |
| `UploadFolder`         | Upload File Storage Directory          | tmp                         |
| `JobsFile`             | Job List File Name                     | joblists                    |
| `mailHost`             | SMTP Host                              | `smtp.yourdomain.com`       |
| `smtpPort`             | SMTP Port                              | `25`                        |
| `smtpEmail`            | SMTP Sender Email                      | `notify@yourdomain.com`     |
| `TranslateUrl`         | Translation Service API URL            | `https://10.0.0.1:8080/api/v1/rest/CreateTranscribeTask` |
| `TranslateQueryUrl`    | Translation Service Query API URL      | `https://10.0.0.1:8080/api/v1/rest/ViewAllTask` |
| `DownloadServer`       | Download Service URL                   | `https://10.0.0.2:8080/api/v1/rest/RetrieveTranscribe/` |
| `MaxUploadSize`        | Maximum Upload File Size (MB)          | `290`                       |

---

## API Routes

| Route                     | Method | Description                            |
|---------------------------|--------|----------------------------------------|
| `/upload`                 | POST   | Upload Audio File                      |
| `/query/jobs`             | GET    | Query User's Job List                  |
| `/listall/jobs`           | GET    | Query All Job Lists                    |
| `/result/{taskID}/{type}` | GET    | Download Processing Result             |
| `/del/{taskID}`           | DELETE | Delete Specified Job                   |

---

## License

This project is licensed under the MIT License. See LICENSE for more information.

```