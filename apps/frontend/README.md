# Academia Sinica Transcription Platform - Frontend Application

Academia Sinica AI 語音轉錄平台前端應用，提供直覺的使用者介面，讓研究人員與一般使用者能便捷地處理語音轉錄任務。

A modern, intuitive frontend interface for the Academia Sinica AI Transcription Platform, enabling researchers and general users to efficiently process audio transcription tasks.

## 目錄 | Table of Contents
- [核心功能 | Core Features](#核心功能--core-features)
- [技術架構 | Technical Architecture](#技術架構--technical-architecture)
- [安裝指南 | Installation Guide](#安裝指南--installation-guide)
- [使用說明 | Usage Guide](#使用說明--usage-guide)
- [開發指引 | Development Guidelines](#開發指引--development-guidelines)
- [專案結構 | Project Structure](#專案結構--project-structure)
- [授權條款 | License](#授權條款--license)

## 核心功能 | Core Features

### 直覺化使用介面 | Intuitive User Interface
- 簡潔的檔案上傳與任務管理
- 即時的任務狀態監控與通知
- 響應式設計支援各種裝置與螢幕尺寸

- Streamlined file upload and task management
- Real-time task status monitoring and notifications
- Responsive design supporting various devices and screen sizes

### 完整的轉錄工作流程 | Complete Transcription Workflow
- 批次檔案上傳與處理
- 多樣化轉錄參數設定
- 多種格式轉錄結果預覽與下載

- Batch file upload and processing
- Diverse transcription parameter settings
- Multi-format result preview and download

### 豐富的進階功能 | Rich Advanced Features
- 說話者分離視覺化呈現
- 轉錄文字線上編輯與修正
- 轉錄歷史紀錄與資料管理

- Speaker diarization visualization
- Online transcription text editing and correction
- Transcription history records and data management

## 技術架構 | Technical Architecture

本系統採用以下技術堆疊：
The system utilizes the following technology stack:

1. **Framework**: Go with custom web server implementation
2. **Web Server**: sherryserver (custom Go library)
3. **Templating Engine**: Go templates
4. **Environment Management**: godotenv
5. **Audio Processing**: faiface/beep

## 安裝指南 | Installation Guide

### 環境需求 | Prerequisites
- Go 1.24.0+
- GNU Make (for Makefile usage)
- 現代瀏覽器支援 (Chrome, Firefox, Safari, Edge) | Modern browser support (Chrome, Firefox, Safari, Edge)

### 安裝步驟 | Installation Steps

1. **複製專案 | Clone Repository**
```bash
git clone https://github.com/AS-AIGC/TranscriptHub.git
cd TranscriptHub/apps/frontend/
```

2. **安裝依賴套件 | Install Dependencies**
```bash
go mod download
```

3. **配置環境變數 | Configure Environment Variables**
```bash
cp envfile.example envfile
# 編輯 envfile 設定 API 端點與其他環境變數 | Edit envfile with API endpoints and other environment variables
```

4. **使用 Makefile 建置與運行 | Build and Run using Makefile**
```bash
# 建置專案 | Build the project
make build

# 運行專案 | Run the project
make run
```

> [!IMPORTANT]  
> If you host your frontend and backend on the same server, start the server by `make run-same-host`, and set your backend host as `host.docker.internal`

5. **直接使用 Go 命令 | Directly using Go commands**
```bash
# 建置專案 | Build the project
go build -o frontend

# 運行專案 | Run the project
./frontend
```

## 使用說明 | Usage Guide

### 上傳音訊檔案 | Upload Audio Files

1. 登入系統後，點選首頁的「上傳檔案」按鈕
   After logging in, click the "Upload File" button on the homepage
   
2. 選擇音訊檔案（支援 .mp3, .wav, .m4a, .flac 等常見格式）
   Select audio files (supporting .mp3, .wav, .m4a, .flac, and other common formats)
   
3. 設定轉錄參數，如語言、輸出格式、是否進行說話者分離等
   Configure transcription parameters such as language, output formats, and speaker diarization
   
4. 點選「開始轉錄」按鈕提交任務
   Click "Start Transcription" to submit the task

### 管理任務 | Manage Tasks

1. 在「任務列表」頁面查看所有轉錄任務及其狀態
   View all transcription tasks and their statuses on the "Task List" page
   
2. 使用搜尋與篩選功能快速找到特定任務
   Use search and filter functions to quickly locate specific tasks
   
3. 點選任務卡片查看詳細資訊與進度
   Click on a task card to view detailed information and progress

### 查看與下載結果 | View and Download Results

1. 任務完成後，系統會發送通知
   The system will send a notification when a task is completed
   
2. 在任務詳細頁面可預覽轉錄結果
   Preview transcription results on the task detail page
   
3. 下載所需格式的轉錄檔案（TXT, SRT, VTT, JSON, TSV）
   Download transcription files in desired formats (TXT, SRT, VTT, JSON, TSV)
   
4. 也可使用線上編輯器修正轉錄內容後再下載
   Use the online editor to correct transcription content before downloading

## 開發指引 | Development Guidelines

### 代碼風格與規範 | Code Style and Standards

本專案遵循標準 Go 代碼風格，建議使用 gofmt 與 golint 確保代碼一致性：
This project follows standard Go code style and recommends using gofmt and golint for code consistency:

```bash
# 格式化代碼 | Format code
gofmt -w .

# 檢查代碼風格 | Check code style
golint ./...
```

### 開發模式 | Development Mode

```bash
# 直接運行 | Run directly
go run *.go

# 使用熱重載工具如 Air 進行開發 | Use hot-reload tools like Air for development
air
```

### 建置與部署 | Building and Deployment

```bash
# 在本機建置 | Local build
go build -o frontend

# 使用 Makefile | Using Makefile
make build

# Docker 建置與運行 | Docker build and run
docker build -t transcripthub-frontend .
docker run -p 8080:80 transcripthub-frontend
```

## 專案結構 | Project Structure
```
apps/frontend/
├── Dockerfile           # Docker 配置 | Docker configuration
├── README.md            # 專案說明文檔 | Project documentation
├── afterupload.go       # 上傳後處理邏輯 | Post-upload processing logic
├── countlength.go       # 文件長度計算功能 | File length calculation
├── download.go          # 下載功能處理 | Download handling
├── envfile.example      # 環境變數配置範例 | Environment variable configuration example
├── go.mod               # Go 模組定義 | Go module definition
├── go.sum               # Go 依賴版本鎖定 | Go dependency version lock
├── homepage.go          # 首頁處理邏輯 | Homepage handling logic
├── jobdone.go           # 任務完成相關功能 | Task completion functionality
├── jobs.go              # 任務管理相關功能 | Job management functionality
├── makefile             # 自動化建置腳本 | Build automation scripts
├── page.go              # 頁面處理共用邏輯 | Common page handling logic
├── queryjobs.go         # 任務查詢功能 | Job query functionality
├── router.go            # 路由處理 | Routing handler
├── sendmail.go          # 郵件發送功能 | Email sending functionality
├── server.go            # 伺服器主程式 | Server main program
├── upload.go            # 檔案上傳處理 | File upload handling
├── userinf.go           # 使用者資訊相關 | User information related
├── writefile.go         # 檔案寫入功能 | File writing functionality
├── tmp/                 # 臨時檔案目錄 | Temporary files directory
│   └── joblists         # 任務列表存儲 | Job list storage
└── www/                 # 靜態資源與模板 | Static assets and templates
    ├── html/            # HTML 靜態資源 | HTML static assets
    │   ├── css/         # CSS 樣式表 | CSS stylesheets
    │   ├── images/      # 圖片資源 | Image resources
    │   └── ...
    └── template/        # Go HTML 模板 | Go HTML templates
        ├── index.tpl    # 主頁模板 | Homepage template
        ├── sidebar.tpl  # 側邊欄模板 | Sidebar template
        └── ...
```

## 授權條款 | License

本專案採用 MIT 授權條款。

This project is licensed under the MIT License.