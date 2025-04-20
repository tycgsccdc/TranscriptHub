# TranscriptHub 
[![Academia Sinica](https://img.shields.io/badge/Academia%20Sinica-%23006E99.svg?style=for-the-badge)](https://www.sinica.edu.tw)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![React](https://img.shields.io/badge/React-v18-blue.svg)](https://reactjs.org/)
[![Node.js](https://img.shields.io/badge/Node.js-v18-green.svg)](https://nodejs.org/)
[![Go](https://img.shields.io/badge/Go-v1.20-00ADD8.svg)](https://golang.org/)
[![WhisperX](https://img.shields.io/badge/WhisperX-AI-orange.svg)](https://github.com/m-bain/whisperX)

![TranscriptHub Intro](image/TranscriptHub-zhtw.png)

一個 AI 語音轉錄平台，採用 React + Go 作為前端技術，並以 Node.js 作為後端基礎，提供高品質的語音轉錄服務。

An AI audio transcription platform built with React + Go for the frontend and Node.js for the backend, providing high-quality transcription services.

---

## 📋 目錄 | Contents
- [✨ 特色功能 | Key Features](#-特色功能--key-features)
- [🏗 系統架構 | Architecture](#-系統架構--architecture)
- [📁 專案結構 | Project Structure](#-專案結構--project-structure)
- [🚀 快速開始 | Quick Start](#-快速開始--quick-start)
- [📄 授權條款 | License](#-授權條款--license)

---

## ✨ 特色功能 | Key Features

### 🎨 前端應用 (apps/frontend/) | Frontend (apps/frontend/)
#### React 應用 | React Application
- 使用 TypeScript 的現代化 React 架構  
  Modern React architecture with TypeScript.
- 響應式 Material-UI 設計  
  Responsive Material-UI design.
- 即時任務進度追蹤  
  Real-time task progress tracking.
- 互動式轉錄檢視器  
  Interactive transcript viewer.
- 拖放式檔案上傳  
  Drag-and-drop file upload.

### 🛠 後端服務 (apps/backend/) | Backend Service (apps/backend/)
- WhisperX AI 轉錄引擎  
  WhisperX AI transcription engine.
- Node.js cluster 多核心處理  
  Multi-core processing with Node.js cluster.
- HTTPS 安全連線  
  HTTPS secure connections.
- TASK 排程管理  
  Task scheduling management.
- 可自定義多種 TASK  
  Customizable task types.
- 多種音訊格式支援  
  Support for multiple audio formats.
- 多種輸出格式支援  
  Support for multiple output formats.

---

## 🏗 系統架構 | Architecture
```
前端 (React + Go) ←→ API 閘道器 ←→ 後端服務 (Node.js)
    ↓                  ↓               ↓
UI 元件           負載平衡         工作程序
    ↓                  ↓               ↓
Go 檔案處理      API 路由         任務處理
    ↓                  ↓               ↓
Material-UI      認證服務        SQL 資料庫

Frontend (React + Go) ←→ API Gateway ←→ Backend (Node.js)
       ↓                    ↓                ↓
  UI Components        Load Balancer     Worker Processes
       ↓                    ↓                ↓
  Go File Handler      API Routes        Task Processing
       ↓                    ↓                ↓
   Material-UI        Auth Service      SQL Database
```

---

## 📁 專案結構 | Project Structure
```
TranscriptHub/
├── apps/
│   ├── frontend/                 # 前端應用 | Frontend application
│   │   ├── web/                 # React 應用 | React application
│   │   │   ├── public/          # 靜態資源 | Static assets
│   │   │   ├── src/             # React 源碼 | React source
│   │   │   │   ├── components/  # UI 元件 | UI components
│   │   │   │   ├── hooks/       # React Hooks
│   │   │   │   ├── pages/       # 頁面元件 | Page components
│   │   │   │   ├── services/    # API 服務 | API services
│   │   │   │   └── utils/       # 工具函數 | Utilities
│   │   │   └── package.json     # 前端相依套件 | Frontend dependencies
│   │   │
│   │   └── server/              # Go 應用 | Go application
│   │       ├── cmd/             # 主程式進入點 | Entry points
│   │       ├── internal/        # 內部套件 | Private packages
│   │       ├── pkg/             # 公用套件 | Public packages
│   │       └── go.mod           # Go 相依套件 | Go dependencies
│   │
│   └── backend/                 # 後端服務 | Backend service
       ├── controller/           # 控制器 | Controllers
       ├── middlewares/         # 中介軟體 | Middlewares
       ├── scripts/             # 轉錄腳本 | Transcription scripts
       ├── services/            # 服務層 | Services
       ├── sql/                 # 資料庫腳本 | Database scripts
       └── package.json         # 後端相依套件 | Backend dependencies
```

---

## 🚀 快速開始 | Quick Start

### 前端設定 | Frontend Setup
詳見 [前端說明文件](apps/frontend/README.md)  
See [Frontend Documentation](apps/frontend/README.md)

### 後端設定 | Backend Setup
詳見 [後端說明文件](apps/backend/README.md)  
See [Backend Documentation](apps/backend/README.md)

---

## 📄 授權條款 | License
本專案採用 MIT 授權條款，詳見 [LICENSE](LICENSE) 檔案。  
This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
