# TranscriptHub 
一個完整的 AI 語音轉錄全端平台，採用 React + Go 前端與 Node.js 後端，讓您可自行建立一個共用性的語音轉錄服務。

## 📋 目錄
- [特色功能](#特色功能)
- [系統架構](#系統架構)
- [專案結構](#專案結構)
- [快速開始](#快速開始)
- [授權條款](#授權條款)

## ✨ 特色功能

### 🎨 前端應用 (apps/frontend/)
#### React 應用
- 使用 TypeScript 的現代 React 架構
- 響應式 Material-UI 設計
- 即時任務進度追蹤
- 互動式轉錄檢視器
- 拖放式檔案上傳

#### Go 應用
- 高效能檔案上傳處理
- 檔案格式驗證與轉換
- 檔案分塊上傳
- 資源使用監控
- 前端快取管理

### 🛠 後端服務 (apps/backend/)
- WhisperX AI 轉錄引擎
- Node.js cluster 多核心處理
- HTTPS 安全連線
- TASK 排程管理
- 可自定義多種 TASK
- 多種音訊格式支援
- 多種輸出格式支援

## 🏗 系統架構
```
前端 (React + Go) ←→ API 閘道器 ←→ 後端服務 (Node.js)
    ↓                  ↓               ↓
UI 元件           負載平衡         工作程序
    ↓                  ↓               ↓
Go 檔案處理      API 路由         任務處理
    ↓                  ↓               ↓
Material-UI      認證服務        SQL 資料庫
```

## 📁 專案結構
```
TranscriptHub/
├── apps/
│   ├── frontend/                 # 前端應用
│   │   ├── web/                 # React 應用
│   │   │   ├── public/          # 靜態資源
│   │   │   ├── src/             # React 源碼
│   │   │   │   ├── components/  # UI 元件
│   │   │   │   ├── hooks/       # React Hooks
│   │   │   │   ├── pages/       # 頁面元件
│   │   │   │   ├── services/    # API 服務
│   │   │   │   └── utils/       # 工具函數
│   │   │   └── package.json     # 前端相依套件
│   │   │
│   │   └── server/              # Go 應用
│   │       ├── cmd/             # 主程式進入點
│   │       ├── internal/        # 內部套件
│   │       ├── pkg/             # 公用套件
│   │       └── go.mod           # Go 相依套件
│   │
│   └── backend/                 # Node.js 後端服務
       ├── controller/           # 控制器
       ├── middlewares/         # 中介軟體
       ├── scripts/             # 轉錄腳本
       ├── services/            # 服務層
       ├── sql/                 # 資料庫腳本
       └── package.json         # 後端相依套件
```

## 🚀 快速開始

### 前端設定 
詳見 [前端說明文件](apps/frontend/README.md)

### 後端設定
詳見 [後端說明文件](apps/backend/README.md)

## 📄 授權條款
MIT License

---

# TranscriptHub

An enterprise-grade AI audio transcription platform built with React+Go frontend and Node.js backend.

## 📋 Contents
- [Key Features](#key-features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [License](#license)

## ✨ Key Features

### 🎨 Frontend (apps/frontend/)
#### React Application
- Modern React with TypeScript
- Responsive Material-UI design
- Real-time task progress tracking
- Interactive transcript viewer
- Drag-and-drop file upload

#### Go Application
- High-performance file upload
- File format validation
- Chunked file uploads
- Resource monitoring
- Frontend caching

### 🛠 Backend Service (apps/backend/)
- WhisperX AI transcription engine
- Multi-core processing with Node.js cluster
- HTTPS security
- Task scheduling management
- Customizable task types
- Multiple audio format support
- Multiple output formats

## 🏗 Architecture
```
Frontend (React + Go) ←→ API Gateway ←→ Backend (Node.js)
       ↓                    ↓                ↓
  UI Components        Load Balancer     Worker Processes
       ↓                    ↓                ↓
  Go File Handler      API Routes        Task Processing
       ↓                    ↓                ↓
   Material-UI        Auth Service      SQL Database
```

## 📁 Project Structure
```
TranscriptHub/
├── apps/
│   ├── frontend/                 # Frontend application
│   │   ├── web/                 # React application
│   │   │   ├── public/          # Static assets
│   │   │   ├── src/             # React source
│   │   │   │   ├── components/  # UI components
│   │   │   │   ├── hooks/       # React hooks
│   │   │   │   ├── pages/       # Page components
│   │   │   │   ├── services/    # API services
│   │   │   │   └── utils/       # Utilities
│   │   │   └── package.json     # Frontend dependencies
│   │   │
│   │   └── server/              # Go application
│   │       ├── cmd/             # Entry points
│   │       ├── internal/        # Private packages
│   │       ├── pkg/             # Public packages
│   │       └── go.mod           # Go dependencies
│   │
│   └── backend/                 # Node.js backend
       ├── controller/           # Controllers
       ├── middlewares/         # Middlewares
       ├── scripts/             # Transcription scripts
       ├── services/            # Services
       ├── sql/                 # Database scripts
       └── package.json         # Backend dependencies
```

## 🚀 Quick Start

### Frontend Setup
See [Frontend Documentation](apps/frontend/README.md)

### Backend Setup
See [Backend Documentation](apps/backend/README.md)

## 📄 License
MIT License