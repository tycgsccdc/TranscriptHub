# Sparrow AI 語音轉錄平台 - 後端服務

基於 Node.js 與 WhisperX 的企業級語音轉錄系統後端服務。

## Table of Contents
- [主要功能](#主要功能)
- [快速開始](#快速開始)
- [API 文件](#API-文件)
- [專案目錄結構](#專案目錄結構)
- [License](#License)

## 🌟 主要功能

- 🎯 高效能多工處理架構
  - Node.js cluster 多核心運算
  - 自動工作程序管理
  - 任務狀態即時追蹤

- 🔐 企業級安全性
  - HTTPS 安全連線
  - SSO 單一登入整合
  - 檔案存取權限控制

- 🎛 彈性輸出格式
  - 純文字腳本 (TXT)
  - 字幕檔案 (SRT, VTT)
  - 結構化資料 (JSON, TSV)
  - 說話者分離標註

## 🚀 快速開始

### 系統需求
- Node.js v18.20.3+
- Anaconda/Miniconda
- SQL Server 2019+
- CUDA 支援的 GPU (建議)

### 安裝步驟

1. **設定 Conda 環境**
```bash
# 建立 conda 環境
conda create -n whisperx python=3.8

# 啟動環境
conda activate whisperx

# 安裝 WhisperX
pip install git+https://github.com/m-bain/whisperx.git

# 安裝相依套件
pip install -r requirements.txt
```

2. **安裝資料庫**
```bash
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=YourStrong!Passw0rd' \
   -p 1433:1433 --name sqlserver \
   -d mcr.microsoft.com/mssql/server:2022-latest
```

3. **Clone 專案**
   ```sh
   git clone https://github.com/AS-AIGC/TranscriptHub.git
   cd TranscriptHub/apps/backend/
   ```

4. **初始化資料庫**
執行 SQL 腳本：
- sql/initial.sql
- sql/task.sql
- sql/access_operation.sql
- sql/access_operation_error.sql

5. **設定環境變數**
```bash
cp .env.example .env
cp config.json.example config.json
# 編輯設定檔內容
```

6. **安裝 Node.js 相依套件**
```bash
npm ci
```

7. **啟動服務**
```bash
./run.sh {start|stop|status|restart}
```

### 注意事項
- 轉錄任務腳本名稱需同步更新：
  - `scripts/transcribe.py`
  - `config.js` 中的 `TASK_SCRIPT` 設定
  - `run.sh` 中的腳本路徑

## 📚 API 文件

### 任務管理
| 方法 | 路徑 | 說明 |
|------|------|------|
| POST | `/api/v1/rest/CreateTranscribeTask` | 建立轉錄任務 |
| POST | `/api/v1/rest/CancelTask` | 取消執行任務 |
| POST | `/api/v1/rest/ViewAllTask` | 查看任務狀態 |
| GET  | `/api/v1/rest/RetrieveTranscribe/{FORMAT}/{filename}` | 下載轉錄結果 |


## 🗂 專案目錄結構
```
apps/backend/
├── controller/               # 控制器目錄
├── middlewares/              # 中介軟體目錄
├── scripts/                  # 腳本目錄
│   ├── transcribe.py         # 轉錄任務腳本
├── services/                 # 服務目錄
├── sql/                      # SQL 腳本目錄
│   ├── initial.sql           # 初始化資料庫腳本
│   ├── task.sql              # 任務相關資料庫腳本
│   ├── access_operation.sql  # 存取操作資料庫腳本
│   ├── access_operation_error.sql  # 存取操作錯誤資料庫腳本
├── .env.example              # 環境變數範例檔案
├── README.md                 # 專案說明文件
├── config.js                 # 主要設定檔
├── constants.js              # 常量定義檔
├── db.js                     # 資料庫設定檔
├── env.js                    # 環境設定檔
├── logger-writer.js          # 日誌寫入模組
├── logger.js                 # 日誌模組
├── main.js                   # 主程式入口
├── package-lock.json         # Node.js 鎖定檔案
├── package.json              # Node.js 專案設定檔
├── query_constants.js        # 查詢常量定義檔
├── requirements.txt          # Python 相依套件列表
├── run.sh                    # 啟動服務腳本
├── shared.js                 # 共享模組
├── utils.js                  # 工具函數模組
```
---

# Sparrow AI Transcription Platform - Backend Service

Enterprise-grade audio transcription backend service based on Node.js and WhisperX.

## 🌟 Key Features

- 🎯 High-Performance Architecture
  - Multi-core processing with Node.js cluster
  - Automatic worker process management
  - Real-time task status tracking

- 🔐 Enterprise Security
  - HTTPS support
  - SSO integration
  - File access control

- 🎛 Flexible Output Formats
  - Plain text transcripts (TXT)
  - Subtitle files (SRT, VTT)
  - Structured data (JSON, TSV)
  - Speaker diarization

## 🚀 Getting Started

### Prerequisites
- Node.js v18.20.3+
- Anaconda/Miniconda
- SQL Server 2019+
- CUDA-capable GPU (recommended)

### Installation Steps

1. **Setup Conda Environment**
```bash
# Create conda environment
conda create -n whisperx python=3.8

# Activate environment
conda activate whisperx

# Install WhisperX
pip install git+https://github.com/m-bain/whisperx.git

# Install dependencies
pip install -r requirements.txt
```

2. **Setup Database**
```bash
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=YourStrong!Passw0rd' \
   -p 1433:1433 --name sqlserver \
   -d mcr.microsoft.com/mssql/server:2022-latest
```

3. **Clone the Project**
   ```sh
   git clone https://github.com/AS-AIGC/TranscriptHub.git
   cd TranscriptHub
   ```

4. **Initialize Database**
Execute SQL scripts:
- sql/initial.sql
- sql/task.sql
- sql/access_operation.sql
- sql/access_operation_error.sql

5. **Configure Environment**
```bash
cp .env.example .env
cp config.json.example config.json
# Edit configuration files
```

6. **Install Node.js Dependencies**
```bash
npm ci
```

7. **Start Service**
```bash
./run.sh {start|stop|status|restart}
```

### Important Notes
- Transcription script name must be synchronized in:
  - `scripts/transcribe.py`
  - `TASK_SCRIPT` setting in `config.js`
  - Script path in `run.sh`

## 📚 API Documentation

### Task Management
| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/rest/CreateTranscribeTask` | Create transcription task |
| POST | `/api/v1/rest/CancelTask` | Cancel running task |
| POST | `/api/v1/rest/ViewAllTask` | View task status |
| GET  | `/api/v1/rest/RetrieveTranscribe/{FORMAT}/{filename}` | Download results |

## 🗂 Project Directory Architecture
```
apps/backend/
├── controller/               # Controllers directory
├── middlewares/              # Middlewares directory
├── scripts/                  # Scripts directory
│   ├── transcribe.py         # Transcription task script
├── services/                 # Services directory
├── sql/                      # SQL scripts directory
│   ├── initial.sql           # Initialize database script
│   ├── task.sql              # Task-related database script
│   ├── access_operation.sql  # Access operation database script
│   ├── access_operation_error.sql  # Access operation error database script
├── .env.example              # Example environment variable file
├── README.md                 # Project documentation file
├── config.js                 # Main configuration file
├── constants.js              # Constants definition file
├── db.js                     # Database configuration file
├── env.js                    # Environment configuration file
├── logger-writer.js          # Logger writer module
├── logger.js                 # Logger module
├── main.js                   # Main application entry point
├── package-lock.json         # Node.js lock file
├── package.json              # Node.js project configuration file
├── query_constants.js        # Query constants definition file
├── requirements.txt          # Python dependencies list
├── run.sh                    # Service start script
├── shared.js                 # Shared functions module
├── utils.js                  # Utilities functions module
```
## 📄 License
MIT License
