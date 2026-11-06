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

遊戲原始碼位於專案根目錄。已建置的 PWA 靜態檔案放在 `site/`；`.github/workflows/pages.yml` 會在 `main` 分支更新時把 `site/` 部署至 GitHub Pages。Godot 預覽匯出曾由專案工作流程完成；若要更新遊戲內容，應重新匯出 Web/PWA、替換 `site/` 並確認子目錄 `/pochacco/` 下的相對資源與 Service Worker 路徑。

## 注意事項

本 repo 與 Pages 網站均為公開。請勿加入密鑰、個人資料或未授權素材。角色及品牌相關素材依專案權利聲明使用；Godot 匯出檔內含第三方元件，授權資訊見 `site/THIRD_PARTY_NOTICES.txt` 與 `site/open-source-licenses.html`。
