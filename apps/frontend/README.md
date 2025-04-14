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

本系統採用現代前端技術堆疊：
The system utilizes a modern frontend technology stack:

1. **Framework**: React.js 18 with Next.js 13
2. **UI Library**: Material-UI v5
3. **State Management**: Redux Toolkit
4. **API Communication**: Axios with React-Query
5. **Build Tools**: Webpack 5, Babel
6. **Testing**: Jest, React Testing Library

## 安裝指南 | Installation Guide

### 環境需求 | Prerequisites
- Node.js v18.20.3+
- npm v9.0.0+ 或 Yarn v1.22.0+ | npm v9.0.0+ or Yarn v1.22.0+
- 現代瀏覽器支援 (Chrome, Firefox, Safari, Edge) | Modern browser support (Chrome, Firefox, Safari, Edge)

### 安裝步驟 | Installation Steps

1. **複製專案 | Clone Repository**
```bash
git clone https://github.com/AS-AIGC/TranscriptHub.git
cd TranscriptHub/apps/frontend/
```

2. **安裝依賴套件 | Install Dependencies**
```bash
npm install
# 或使用 Yarn | or using Yarn
yarn install
```

3. **配置環境變數 | Configure Environment Variables**
```bash
cp .env.example .env.local
# 編輯 .env.local 設定 API 端點與其他環境變數 | Edit .env.local with API endpoints and other environment variables
```

4. **開發模式啟動 | Start Development Server**
```bash
npm run dev
# 或使用 Yarn | or using Yarn
yarn dev
```

5. **建置生產版本 | Build Production Version**
```bash
npm run build
npm run start
# 或使用 Yarn | or using Yarn
yarn build
yarn start
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

本專案遵循 Airbnb JavaScript Style Guide，並使用 ESLint 與 Prettier 確保代碼一致性：
This project follows the Airbnb JavaScript Style Guide and uses ESLint and Prettier for code consistency:

```bash
# 檢查代碼風格 | Check code style
npm run lint

# 自動修復代碼風格問題 | Auto-fix code style issues
npm run lint:fix

# 格式化代碼 | Format code
npm run format
```

### 開發模式 | Development Mode

```bash
# 使用熱重載開發模式 | Run development server with hot-reloading
npm run dev

# 使用指定 port | Use specific port
npm run dev -- -p 3001
```

### 測試 | Testing

```bash
# 執行單元測試 | Run unit tests
npm run test

# 執行覆蓋率測試 | Run coverage tests
npm run test:coverage

# 執行 E2E 測試 | Run E2E tests
npm run test:e2e
```

### 建置與部署 | Building and Deployment

```bash
# 生產環境建置 | Production build
npm run build

# 本地預覽生產版本 | Local preview of production build
npm run start

# 靜態輸出 (如需部署到靜態託管服務) | Static export (for deployment to static hosting)
npm run export
```

## 專案結構 | Project Structure
```
apps/frontend/
├── public/              # 靜態資源 | Static assets
├── src/
│   ├── api/             # API 請求封裝 | API request wrappers
│   ├── components/      # UI 組件 | UI components
│   │   ├── common/      # 通用組件 | Common components
│   │   ├── forms/       # 表單組件 | Form components
│   │   ├── layout/      # 佈局組件 | Layout components
│   │   └── ...
│   ├── context/         # React Context
│   ├── hooks/           # 自定義 Hooks | Custom Hooks
│   ├── pages/           # 頁面組件 | Page components
│   ├── redux/           # Redux 狀態管理 | Redux state management
│   ├── styles/          # 全局樣式 | Global styles
│   ├── types/           # TypeScript 類型定義 | TypeScript type definitions
│   └── utils/           # 工具函數 | Utility functions
├── .env.example         # 環境變數範例 | Environment variables example
├── next.config.js       # Next.js 配置 | Next.js configuration
├── package.json         # 專案描述檔 | Project descriptor
└── tsconfig.json        # TypeScript 配置 | TypeScript configuration
```

## 授權條款 | License

本專案採用 MIT 授權條款。

This project is licensed under the MIT License.