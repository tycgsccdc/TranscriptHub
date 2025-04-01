# TranscriptHub
A comprehensive full-stack platform for AI-driven audio transcription services. / 一個完整的 AI 語音轉錄全端平台。

Featuring a modern React frontend and Node.js backend, this platform provides enterprise-grade transcription services powered by WhisperX. / 採用 React 前端與 Node.js 後端，本平台提供企業級的 WhisperX 驅動語音轉錄服務。

---

## ✨ Key Features / 特色功能

### Frontend / 前端
- 🎨 Modern React with TypeScript / 使用 TypeScript 的現代 React
- 📱 Responsive Material-UI design / 響應式 Material-UI 設計
- 🔄 Real-time task progress tracking / 即時任務進度追蹤
- 📊 Interactive transcription viewer / 互動式轉錄檢視器
- 🎯 Drag-and-drop file upload / 拖放式檔案上傳

### Backend / 後端
- 🧒 WhisperX AI transcription engine / WhisperX AI 轉錄引擎
- 🧵 Multi-core processing with Node.js cluster / Node.js cluster 多核心處理
- 🔐 JWT authentication & HTTPS / JWT 認證與 HTTPS 安全連線
- 🎷 Multiple audio format support / 多種音訊格式支援
- 📤 Multiple output formats / 多種輸出格式支援

---

## 🏗 Architecture / 系統架構

```
Frontend (React) ←→ API Gateway ←→ Backend Services
  ↓                  ↓               ↓
UI Components     Load Balancer    Worker Processes
  ↓                  ↓               ↓
State Management   API Routes      Task Processing
  ↓                  ↓               ↓
Material-UI       Auth Service     SQL Database
```

## 🚀 Quick Start / 快速開始

### Frontend Setup / 前端設定

```bash
# Install dependencies / 安裝相依套件
cd frontend
npm install

# Start development server / 啟動開發伺服器
npm run dev

# Build for production / 建置正式版本
npm run build
```

### Backend Setup / 後端設定

```bash
# Install backend dependencies / 安裝後端相依套件
cd backend
npm install

# Configure environment / 設定環境
cp .env.example .env

# Start server / 啟動伺服器
npm run start
```

### Database Setup / 資料庫設定

```bash
# Start SQL Server container / 啟動 SQL Server 容器
docker compose up -d

# Initialize database / 初始化資料庫
npm run db:init
```

---

## 📁 Project Structure / 專案結構

```
.
├── frontend/                # React frontend application
│   ├── src/
│   │   ├── components/     # React components
│   │   ├── pages/         # Page components
│   │   ├── services/      # API services
│   │   └── styles/        # CSS & theme files
│   └── package.json
├── backend/                # Node.js backend server
│   ├── src/
│   │   ├── controllers/   # Request handlers
│   │   ├── models/       # Database models
│   │   ├── routes/       # API routes
│   │   └── services/     # Business logic
│   └── package.json
├── scripts/               # Utility scripts
└── docker-compose.yml     # Container configuration
```

## 📚 Documentation / 文件

- [API Documentation](./docs/api.md)
- [Frontend Guide](./docs/frontend.md)
- [Backend Guide](./docs/backend.md)
- [Deployment Guide](./docs/deploy.md)

## 🔒 Security / 安全性

- HTTPS encryption / HTTPS 加密
- JWT authentication / JWT 認證
- SQL injection prevention / SQL 注入防護
- Rate limiting / 請求限制
- CORS protection / CORS 防護

## 📄 License / 授權條款

MIT License

## 🤝 Contributing / 貢獻

1. Fork the Project / 複製專案
2. Create Feature Branch / 建立功能分支
3. Commit Changes / 提交變更
4. Push to Branch / 推送分支
5. Open Pull Request / 發送合併請求

