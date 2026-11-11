# 嘟嘟與帕恰狗：點心島的奇幻野餐

一款繁體中文 2D 平台冒險遊戲原型，以 Godot 4 Web 匯出，支援可安裝 PWA。第一章「草莓蛋糕村」聚焦即時切換嘟嘟與帕恰狗、AI 隨行、甜點平台探索、協力機關及 Boss 戰。

## 遊玩

GitHub Pages 部署完成後，遊戲網址為：

`https://dmppmd132-glitch.github.io/pochacco/`

iPhone 請以 Safari 開啟網址，按「分享」→「加入主畫面」，開啟「以網頁 App 開啟」後按「加入」。遊戲採橫向操作，首次載入需要下載約 54 MB 遊戲資源；請先連網並等到標題畫面出現。離線快取已由 PWA 匯出設定提供，但尚未以實體 iPhone 斷網驗證。

## 操作

- 移動：`←`／`→` 或 `A`／`D`
- 跳躍：`Space` 或 `↑`
- 切換角色：`L` 或 `Tab`
- 主要能力：`J` 或 `X`
- 嘟嘟屁屁坐擊：跳起後按 `K`
- 帕恰狗偵探嗅嗅：`E`
- 帕恰狗放香蕉皮：`C`
- 集合／雙重重量機關：嘟嘟站上粉紅大福按鈕後按 `F`
- 暫停：`Esc`

## 專案與部署

遊戲原始碼位於專案根目錄。GitHub Pages 部署 `github-pages/` 中的自包含 PWA（含 `index.wasm`、`index.pck`、manifest、Service Worker 與離線頁）；`.github/workflows/pages.yml` 會在 `main` 分支更新時發佈此目錄。Webdev 管理的 `site/` 是另一份預覽輸出，不是 GitHub Pages 的部署來源。

更新遊戲後，先執行 `npm run build` 產生 `dist/standalone/`，再執行 `npm run pages:sync` 更新 `github-pages/`，提交並推送到 `main` 後即可觸發 Pages 部署。同步腳本會排除本機 build fingerprint，並確認 PWA 包含 WASM/PCK 且沒有 Manus Storage 絕對路徑。

### 本機 Godot runtime 測試

部分模板字型與音效來源檔依 `.gitignore` 規則不納入 Git；在全新 clone 執行 Godot 前，先執行 `npm run assets:restore`。此命令只還原 `assets.lock.json` 中標記為使用中的字型與音效，並逐檔核對大小及 SHA-256；媒體本體仍保持 ignored，不會被加入 Git。首次還原後先執行 `godot --headless --editor --path . --quit` 建立 Godot 匯入快取，再執行各項 runtime 測試。`npm run assets:restore -- --check` 可離線確認本機檔案是否齊全且符合 lock。

## 注意事項

本 repo 與 Pages 網站均為公開。請勿加入密鑰、個人資料或未授權素材。角色及品牌相關素材依專案權利聲明使用；Godot 匯出檔內含第三方元件，授權資訊見 `github-pages/THIRD_PARTY_NOTICES.txt` 與 `github-pages/open-source-licenses.html`。
