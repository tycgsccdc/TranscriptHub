# Academia Sinica Transcription Platform - Backend Service

Academia Sinica AI 語音轉錄平台後端服務，基於 Node.js 與 WhisperX 引擎提供高效能語音轉文字處理能力。

Enterprise-grade audio transcription backend service powered by Node.js and WhisperX engine, developed for Academia Sinica.

## 目錄 | Table of Contents
- [核心功能 | Core Features](#核心功能--core-features)
- [系統架構 | System Architecture](#系統架構--system-architecture)
- [安裝指南 | Installation Guide](#安裝指南--installation-guide)
- [API 文件 | API Documentation](#api-文件--api-documentation)
- [部署方式 | Deployment](#部署方式--deployment)
- [專案結構 | Project Structure](#專案結構--project-structure)
- [授權條款 | License](#授權條款--license)

## 核心功能 | Core Features

### 高效能處理引擎 | High-Performance Processing Engine
- 基於 WhisperX 的最新語音識別技術
- Node.js cluster 多核心並行處理架構
- 任務隊列管理與負載平衡機制

- State-of-the-art speech recognition with WhisperX
- Multi-core parallel processing with Node.js cluster
- Task queue management and load balancing

### 企業級系統設計 | Enterprise System Design
- 完整的錯誤處理與日誌記錄機制
- 資料庫持久化儲存與備份機制
- 服務健康監控與自動恢復功能

- Comprehensive error handling and logging
- Database persistence and backup mechanisms
- Service health monitoring and auto-recovery

### 多樣化輸出格式 | Diverse Output Formats
- 標準文字檔案 (TXT)
- 時間碼字幕檔案 (SRT, VTT)
- JSON/TSV 結構化資料
- 多人對話分離標註

- Standard text files (TXT)
- Timestamped subtitle files (SRT, VTT)
- Structured data in JSON/TSV format
- Speaker diarization support

## 系統架構 | System Architecture

本系統採用多層架構設計：
The system employs a multi-layered architecture:

1. **API 層 | API Layer**：處理 HTTP 請求及回應，提供 RESTful API
   Handles HTTP requests and responses via RESTful endpoints
   
2. **服務層 | Service Layer**：實現核心業務邏輯，處理轉錄任務流程
   Implements core business logic and transcription workflow
   
3. **資料層 | Data Layer**：與 SQL Server 資料庫交互，儲存系統數據
   Interacts with SQL Server database for data persistence
   
4. **轉錄引擎層 | Transcription Engine Layer**：整合 WhisperX Python 處理引擎
   Integrates with WhisperX Python processing engine

## 安裝指南 | Installation Guide

### 環境需求 | Prerequisites
- Node.js v18.20.3+
- Python 3.8+ 與 Anaconda/Miniconda | Python 3.8+ with Anaconda/Miniconda
- SQL Server 2019+
- CUDA 支援的 NVIDIA GPU (建議 RTX 系列) | CUDA-compatible NVIDIA GPU (RTX series recommended)

### 安裝步驟 | Installation Steps

1. **設定 Python 環境 | Set up Python Environment**
```bash
# 建立獨立環境 | Create isolated environment
conda create -n whisperx python=3.8
conda activate whisperx

# 安裝 WhisperX | Install WhisperX
pip install git+https://github.com/m-bain/whisperx.git
```

2. **設定資料庫 | Set up Database**
```bash
# 使用 Docker 快速部署 SQL Server | Quick deployment with Docker
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=YourStrongPassword' \
  -p 1433:1433 --name as-sqlserver \
  -d mcr.microsoft.com/mssql/server:2019-latest

# 或使用現有的 SQL Server 實例 | Or use existing SQL Server instance
```

3. **複製並配置專案 | Clone and Configure Project**
```bash
# 複製專案 | Clone repository
git clone https://github.com/AS-AIGC/TranscriptHub.git
cd TranscriptHub/apps/backend/

# 配置環境變數 | Configure environment variables
cp .env.example .env
# 編輯 .env 設定資料庫連接與系統參數 | Edit .env file with database connection and system parameters

# 配置系統設定 | Configure system settings
cp config.json.example config.json
# 編輯 config.json 設定系統路徑與轉錄參數 | Edit config.json with system paths and transcription parameters


# 安裝專案 scripts 的相關套件 | Install dependencies for project scripts
pip install -r scripts/requirements.txt
```

4. **安裝 Node.js 套件 | Install Node.js Packages**
```bash
npm ci
```

5. **初始化資料庫 | Initialize Database**
```bash
# 執行資料庫初始化腳本 | Run database initialization script
node db-init.js
# 或執行下列 SQL 腳本 (請依照實際資料庫設定修改連線資訊) | Or execute SQL scripts (modify connection settings accordingly)
cd sql
sqlcmd -S localhost -U sa -P YourStrongPassword -i createdb.sql
sqlcmd -S localhost -U sa -P YourStrongPassword -i initial.sql
sqlcmd -S localhost -U sa -P YourStrongPassword -i access_operation.sql
sqlcmd -S localhost -U sa -P YourStrongPassword -i access_operation_error.sql
sqlcmd -S localhost -U sa -P YourStrongPassword -i task.sql
```

6. **啟動服務 | Start Service**
```bash
# 使用控制腳本啟動服務 | Use control script to start service
./run.sh start

# 其他指令 | Other commands
./run.sh stop    # 停止服務 | Stop service
./run.sh status  # 檢查狀態 | Check status
./run.sh restart # 重新啟動 | Restart service
```

## API 文件 | API Documentation

### 認證機制 | Authentication
系統使用 API Key 認證，需在請求標頭中包含 `X-API-Key` 欄位。

The system uses API Key authentication. Include `X-API-Key` header in your requests.

### 任務管理 API | Task Management API

#### 建立轉錄任務 | Create Transcription Task
```
POST /api/v1/rest/CreateTranscribeTask
Content-Type: multipart/form-data

Parameters:
- file: 音訊檔案 (必須) | Audio file (required)
- language: 語言代碼 (選填，預設為 "zh") | Language code (optional, default "zh")
- formats: 輸出格式，以逗號分隔 (選填，預設為 "txt,srt") | Output formats, comma-separated (optional, default "txt,srt")
- diarize: 是否進行說話者分離 (選填，預設為 false) | Enable speaker diarization (optional, default false)
- callback_url: 任務完成後的回調 URL (選填) | Callback URL when task completes (optional)
```

#### 查詢任務狀態 | Query Task Status
```
POST /api/v1/rest/ViewAllTask
Content-Type: application/json

Body:
{
  "task_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" (選填，若不提供則返回所有任務 | optional, returns all tasks if omitted)
}
```

#### 取消任務 | Cancel Task
```
POST /api/v1/rest/CancelTask
Content-Type: application/json

Body:
{
  "task_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" (必須 | required)
}
```

#### 下載轉錄結果 | Download Transcription Results
```
GET /api/v1/rest/RetrieveTranscribe/{FORMAT}/{filename}

Parameters:
- FORMAT: 輸出格式 (txt, srt, vtt, json, tsv) | Output format (txt, srt, vtt, json, tsv)
- filename: 檔案名稱 (不含副檔名) | File name (without extension)
```

### 錯誤代碼 | Error Codes

| 代碼 Code | 說明 Description |
|------|-------------|
| 400  | 請求參數錯誤 Bad Request |
| 401  | 未授權存取 Unauthorized |
| 404  | 資源不存在 Resource Not Found |
| 500  | 伺服器內部錯誤 Internal Server Error |

## 部署方式 | Deployment

### 生產環境建議 | Production Recommendations

1. **使用 PM2 管理進程 | Process Management with PM2**
```bash
npm install -g pm2
pm2 start main.js -i max --name "as-transcribe"
```

2. **設定 Nginx 反向代理 | Nginx Reverse Proxy Configuration**
```nginx
server {
    listen 443 ssl;
    server_name transcribe.yourdomain.com;

    # SSL 設定 | SSL configuration
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

3. **配置防火牆與資安設定 | Security Configuration**
   - 限制訪問 IP | Restrict access by IP
   - 設定請求速率限制 | Set up request rate limiting
   - 啟用 HTTPS 強制跳轉 | Enable HTTPS redirect

## 專案結構 | Project Structure
```
apps/backend/
├── controller/           # API 控制器目錄 | API controllers directory
│   ├── auth.js           # 認證控制器 | Authentication controller
│   ├── task.js           # 任務控制器 | Task controller
│   └── transcribe.js     # 轉錄控制器 | Transcription controller
├── middlewares/          # 中間件目錄 | Middleware directory
│   ├── auth.js           # 認證中間件 | Authentication middleware
│   ├── error.js          # 錯誤處理中間件 | Error handling middleware
│   ├── logger.js         # 日誌中間件 | Logging middleware
│   └── validator.js      # 請求驗證中間件 | Request validation middleware
├── scripts/              # 腳本目錄 | Scripts directory
│   ├── transcribe.py     # 轉錄處理主腳本 | Main transcription script
│   ├── db-init.js        # 資料庫初始化腳本 | Database initialization script
│   └── utils/            # 工具腳本目錄 | Utility scripts directory
├── services/             # 服務層目錄 | Services directory
│   ├── db.js             # 資料庫服務 | Database service
│   ├── task.js           # 任務服務 | Task service
│   └── transcribe.js     # 轉錄服務 | Transcription service
├── sql/                  # SQL 腳本目錄 | SQL scripts directory
├── .env.example          # 環境變數範例 | Environment variables example
├── config.js             # 系統配置 | System configuration
├── constants.js          # 常數定義 | Constants definition
├── logger.js             # 日誌模組 | Logging module
├── main.js               # 應用程式入口 | Application entry point
├── package.json          # 專案描述檔 | Project descriptor
└── run.sh                # 服務控制腳本 | Service control script
```

## 授權條款 | License

本專案採用 MIT 授權條款。

This project is licensed under the MIT License.
