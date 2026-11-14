# 網頁版手機觸控與效能測試

**日期：2026-11-14**
**已部署版本：**commit [`271d999`](https://github.com/dmppmd132-glitch/pochacco/commit/271d999)；[GitHub Pages workflow #43577835231](https://github.com/dmppmd132-glitch/pochacco/actions/runs/43577835231) 成功。

A/B 對照僅更改 Godot 的 2D Stretch Mode；其餘遊戲來源、素材、瀏覽器與觸控腳本相同。

## 測試條件與方法

以 Chromium 131 的 Android 14／Pixel 7 裝置模擬測試公開頁與本機 Web 匯出版。視窗為 915×412 CSS 像素、DPR 2.625；網路模擬為 50 Mbps、40 ms RTT，執行期間沒有額外 CPU 節流。先讓遊戲載入並暖機 30 秒，再在第一關操作虛擬搖桿及跳躍鍵，量測 15 秒穩態畫格間隔及觸控事件後第一、第二個 `requestAnimationFrame` 回呼的時間。兩種本機匯出版使用相同來源碼、素材、瀏覽器與測試腳本，僅 2D Stretch Mode 不同。

此雲端 Chromium 使用軟體渲染器，測得的是瀏覽器事件到下一個畫面回呼的延遲，不是手機觸控面板的硬體延遲。因此數據適合比較兩種渲染設定，不應當作實體 Android／iPhone 的 FPS 保證。

## A/B 結果

原本的 `canvas_items` 模式，在此模擬條件下穩態畫格間隔中位數為 **100 ms**、P95 為 **116.6 ms**，約等於 10 FPS。虛擬搖桿按下至第一個畫面回呼為 **93.2 ms**；跳躍按下為 **107.9 ms**。

候選 `viewport` 模式改為先繪製至 Godot 的內部 logical viewport，再縮放到相同的高 DPR 手機畫布；本專案的 `ViewportPolicy` 會依視窗大小調整該 logical size。測得畫格間隔中位數為 **83.3 ms**、P95 為 **100 ms**，約等於 12 FPS。搖桿按下至第一個畫面回呼降至 **72.1 ms**，跳躍降至 **78.4 ms**。兩種設定都維持 915×412 的遊戲畫布顯示尺寸；候選版本的搖桿拖曳及跳躍均有觸發，瀏覽器記錄沒有載入或腳本錯誤。

依此結果，正式專案已採用 `window/stretch/mode="viewport"`，保留自適應 Web 畫布與原有橫向版面，降低高 DPR 下 2D 場景的繪製解析度。Godot 文件說明，`viewport` Stretch Mode 會先以專案基準尺寸繪製再縮放；降低 viewport 的內部解析度可減少繪製負載，但會影響輸出清晰度。[1] [2]

## Pages 上線後公開頁驗收

部署完成後重新測試 `https://dmppmd132-glitch.github.io/pochacco/`：HTTP **200**，canvas 為 2401×1081 backing pixels／914×411 CSS pixels，Chromium 記錄沒有 console/page error 或失敗請求。暖機 30 秒並遊玩 15 秒後，公開頁畫格間隔中位數 **83.3 ms**、P95 **116.7 ms**；搖桿及跳躍輸入到第一個畫面回呼分別為 **75.1 ms** 與 **75.8 ms**。觸控後截圖確認角色移動且繁中地標對話已顯示。這是 Pixel 7 規格的 Chromium 模擬器／軟體渲染器上線 smoke，不是實體手機測量。

## 回歸測試

在這次變更後通過：`npm test`、`npm run test:dialogue`、`npm run test:chapter-three`（7/7）、`npm run test:platform-route` 與 `npm run test:cloud-gust`。`npm test` 結束時 Godot 印出一則資源仍在使用的清理訊息，但測試程序 exit code 為 0，煙霧測試標示通過。

`npm run check` 在此 repo 目前無法執行：命令轉交 `scripts/manus/runtime-command.cjs` 後要求設定 `GAME_RUNTIME`，本工作階段沒有該 Game runtime 路徑。這是執行環境設定阻礙，不能視為來源檢查成功；對應的 Godot 與章節測試已另外通過。

## 尚待實體手機驗收

目前尚未在實際 iPhone 或 Android 裝置上取得 FPS、耗電、觸控硬體延遲或長時間發熱數據。仍需在 Safari／Chrome 的直向與橫向切換、PWA 安裝／離線重開、雙指操作，以及對話氣泡遮擋程度上進行實機驗收。Viewport 模式在高 DPI 螢幕上的邊緣清晰度也應由實機確認；若模糊程度不可接受，再比較較高的基準 viewport 或自適應品質設定。

## 參考資料

[1]: https://docs.godotengine.org/en/latest/tutorials/rendering/multiple_resolutions.html "Godot 多解析度與 Stretch Mode 官方指南"
[2]: https://docs.godotengine.org/en/latest/classes/class_editorexportplatformweb.html "Godot Web 匯出與 Canvas Resize Policy 官方參考"
