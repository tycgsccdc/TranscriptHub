# Sparrow AI Transcription Platform / Sparrow 語音轉錄平台

A comprehensive HTTP server and RESTful API platform designed for AI-driven audio transcription services. / 一個為 AI 語音轉錄設計的完整 HTTP 伺服器與 RESTful API 平台。

This application leverages the WhisperX speech recognition engine, supports multiple languages and audio formats, and is optimized for concurrent task execution using Node.js cluster. It includes robust task management, database persistence, speaker diarization, and secure output retrieval. / 本應用使用 WhisperX 語音辨識引擎，支援多語言與多種音訊格式，並透過 Node.js cluster 模組實現多工任務處理，具備任務管理、資料庫保存、說話者分離以及安全下載功能。

---

## ✨ Key Features / 特色功能

- 🧒 AI transcription using WhisperX / 使用 WhisperX 進行 AI 語音轉錄
- 🧵 Multi-core processing via Node.js cluster / 透過 Node.js cluster 進行多核心處理
- 🔄 Automatic worker process recovery / 自動重啟失敗的工作程序
- 🔐 HTTPS support / 支援 HTTPS 安全連線
- 🎷 Upload and transcribe MP3, WAV, MPEG, and more / 支援多種音訊格式上傳與轉錄（如 MP3、WAV、MPEG）
- 📊 Task tracking and status management / 任務狀態追蹤與管理
- 🗃️ SQL Server database integration / 整合 SQL Server 資料庫
- 📤 Multiple output formats: TXT, SRT, VTT, TSV, JSON / 多種輸出格式：TXT、SRT、VTT、TSV、JSON
- 🢑 Speaker diarization support / 支援說話者分離

---

## 📦 API Endpoints / API 接口

| Method | Endpoint                                                             | Description / 描述                 |
|--------|----------------------------------------------------------------------|------------------------------------|
| POST   | `/api/v1/rest/CreateTranscribeTask`                                  | Create a new transcription task / 建立新轉錄任務 |
| POST   | `/api/v1/rest/CancelTask`                                            | Cancel a running task / 取消執行中任務 |
| POST   | `/api/v1/rest/ViewAllTask`                                           | View all task statuses / 查看所有任務狀態 |
| GET    | `/api/v1/rest/RetrieveTranscribe/{FORMAT}/{filename}`                | Retrieve results by format / 下載指定格式的結果 |

---

## 🚀 Quick Start Guide / 快速開始指南

### 1️⃣ Install WhisperX / 安裝 WhisperX  
Follow the official [WhisperX GitHub](https://github.com/m-bain/whisperx) guide. / 請依官方 GitHub 指引安裝 WhisperX。

### 2️⃣ Install SQL Server (via Docker) / 使用 Docker 安裝 SQL Server

```bash
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=YourStrong!Passw0rd' \
   -p 1433:1433 --name sqlserver \
   -d mcr.microsoft.com/mssql/server:2022-latest
```

### 3️⃣ Clone this project / 下載本專案

```bash
git clone https://github.com/your-org/sparrow-transcriber.git
cd sparrow-transcriber
```

### 4️⃣ Initialize the database / 初始化資料庫

Execute SQL files in order: / 依序執行下列 SQL 檔案：

```sql
sql/initial.sql
sql/task.sql
sql/access_operation.sql
sql/access_operation_error.sql
```

### 5️⃣ Install Node.js & Dependencies / 安裝 Node.js 與套件

```bash
npm install
```

### 6️⃣ Configure settings / 設定環境檔案

- Copy and modify `scripts/config.json.example` → `scripts/config.json`
- Copy and modify `.env.example` → `.env`

### 7️⃣ Edit `run.sh`

Set the following variables: / 設定以下變數：

```bash
NODEJS_APP="./main.js"
WHISPERX_TASK="exec_whisperx_task_v1.0.py"
```

### 8️⃣ Install Python dependencies / 安裝 Python 套件

```bash
cd scripts/
pip install -r requirements.txt
```

> You may need to generate `requirements.txt` manually. / 如尚未產生，請依照程式引入自行建立 `requirements.txt`

### 9️⃣ Generate required certificates / 建立憑證供 `config.js` 使用

If using HTTPS, reference your certs in `config.js`. / 若需啟用 HTTPS，請在 `config.js` 中設定憑證路徑。

---

## 📁 Project Structure / 專案結構

```bash
.
├── backend/                 # Backend API server code and core logic
│   ├── controllers/        # Request handlers and business logic
│   ├── models/            # Database models and data structures
│   ├── routes/            # API route definitions
│   └── services/          # Business service implementations
├── scripts/                # Python processing scripts
│   ├── whisperx/         # WhisperX integration scripts
│   ├── config.json       # Configuration settings
│   └── requirements.txt  # Python dependencies
├── sql/                    # Database initialization scripts
│   ├── initial.sql       # Database schema
│   ├── task.sql         # Task management tables
│   └── access.sql       # Access control tables
├── .env.example           # Environment variables template
├── config.js              # Application configuration
├── run.sh                 # Main execution script
└── README.md              # Project documentation
```
```

---

## 📄 License / 授權條款

MIT or your preferred license here. / 本專案使用 MIT 或你自定的授權條款。

---

## 🧑‍💻 Maintainers / 專案維護者

- [Your Name](https://github.com/your-name)
- [Team or Organization](https://your-org.github.io)

---

## ✨ Contributions / 貢獻

Pull requests are welcome. For major changes, please open an issue first. / 歡迎提交 Pull Request，若為重大修改請先開 issue 討論。

