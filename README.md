# 嘟嘟與帕恰狗：點心島的奇幻野餐

一款繁體中文 Godot 4 2D 平台冒險遊戲，匯出為可安裝的 PWA。目前提供四個可直接遊玩的章節：前兩章為完整流程，第三章與第四章以灰盒公開試玩提供；玩家可以即時切換嘟嘟與帕恰狗，未操控角色會由 AI 隨行。

## 遊玩

GitHub Pages 公開遊戲：[https://dmppmd132-glitch.github.io/pochacco/](https://dmppmd132-glitch.github.io/pochacco/)。標題頁可選擇第一至第四章；第三章「糖霜齒輪城」及第四章「月潮玻璃海」為灰盒公開試玩。第四章包含四段主線、可選三顆星星糖暗礁、水母王三階段戰、Boss 門前檢查點，以及觸碰月光珍珠後的結算與 run ID 去重存檔。灰盒狀態不代表視覺 polish 或實體手機／離線驗收已完成。完整安裝與操作指南見 [PLAYING.md](PLAYING.md)。

iPhone／iPad 請以 Safari 開啟網址，選「分享」→「加入主畫面」，再從主畫面圖示啟動並橫向遊玩。首次載入需下載約 54 MB 遊戲資源，請先連接穩定網路並等到標題畫面出現。Service Worker 會在首次完整載入時快取遊戲本體；離線重啟及手機觸控手感尚待實體裝置驗證。

## 章節內容

- **第一章｜草莓蛋糕村**：探索甜點平台、收集星星糖與草莓食材；用帕恰狗嗅聞找出隱藏巧克力牆，再切換嘟嘟滾撞破牆。果醬河需要兩位角色合作，最後以香蕉皮和屁屁坐擊擊敗哼哼奶油怪，走到草莓噴泉閥門完成本章。起點戚風彈跳台已降低，沿地面靠近後起跳即可接上彈跳路線。
- **第二章｜棉花糖雲朵森林**：帕恰狗嗅出雲朵風車的風鈴線索，再以香蕉迴旋鏢敲響風鈴開啟雲門。利用彈跳雲朵與上升氣流前進，穿越週期性側風走廊（風起時會推回，等候平靜空檔或持續向前移動）；在雲朵橋讓帕恰狗守住踏板、由嘟嘟打開通路；最後先敲出棉花糖風靈的月光鈴心，再用嘟嘟屁屁坐擊，走到月光蜂蜜鈴完成本章。
- **第三章｜糖霜齒輪城（灰盒）**：包含低位安全路線與高位高風險星星糖分支（多 3 顆），並在高風險路線配置三座錯相蒸汽噴口；噴口具 0.8 秒預熱、0.9 秒噴發、約 1.9 秒冷卻，失誤會把角色彈回安全平台。移動齒輪在自動換向前 0.5 秒以閃爍箭頭與「即將換向」文字預告，並播放短音提示；嘟嘟第一次煞車停靠有 6.5 秒教學窗口，後續維持 5 秒。`npm run test:chapter-three` 含真實關卡路線 smoke，驗證低／高位齒輪載人、邊緣支撐、煞車及高位檢查點回復。帕恰狗嗅嗅可預告附近蒸汽噴口狀態，嘟嘟坐擊可壓閥 2.4 秒；分支在鐘樓檢查點前匯合。章末發條糖果守衛會施放可跳躲的齒輪波紋與慢速擺錘；帕恰狗敲中黃銅卡榫後，嘟嘟須在 3.5 秒內坐擊露出的鐘芯，累積三次命中，打開閘門後觸碰星星糖鐘芯通關。Boss 現有六組原創 WAV cue，命中加入模型反衝、爆光、相機震動及短暫打擊停頓；雙齒輪組合謎題與互動高亮仍待擴充，詳見 [TODO.md](TODO.md)。
- **第四章｜月潮玻璃海（灰盒公開試玩）**：從入口潮池沿地面安全路線前進；回音珊瑚廊先聽三拍、再切換帕恰狗以香蕉迴旋鏢重現；折光玻璃礁使用 `F`／手把或觸控 `Y` 旋轉鏡面，把月光接到接收器。月潮分流可不進入可選暗礁支線（額外 3 顆星星糖）直走主線；Boss 門前設檢查點。潮汐水母王會預告波環／推流，三階段需完成音序與鏡面機關並以嘟嘟坐擊命中三次；擊敗後還須觸碰月光珍珠才結算，獎勵以 run ID 去重保存。完整流程及灰盒範圍見 [CHAPTER_4_PLAN.md](CHAPTER_4_PLAN.md) 與 [PLAYING.md](PLAYING.md)。

各章皆有星星糖與章節食材可收集。標題頁衣櫃、服裝資料與購買／保存已接線；章節獎勵可由 `SaveStore` 依 run ID 去重入帳，角色實際服裝外觀套用仍列於 [TODO.md](TODO.md)。

新增七組三章地標雙角色繁中短對話，對話不暫停遊戲、依角色／路線條件只觸發一次；靠近隊友切換角色可觸發有冷卻的擊掌反應。PWA 端補上觸控回歸驗收，確認搖桿主指標捕捉與失焦時釋放跳躍輸入，並調整窄螢幕對話字級／文字區。程式層級效能改善包含背景繪製節流至 30Hz、靜態收集品取消每幀重繪、角色裝飾層降至 10Hz；另將 2D Stretch Mode 改為 `viewport`。同源手機模擬 A/B 的畫格中位間隔由 100ms 降至 83.3ms，觸控後首個畫面回呼約改善 23–27%；這是軟體渲染器數據，不等同實體手機 FPS，詳見 [MOBILE_WEB_TEST.md](MOBILE_WEB_TEST.md)。

第四章已完成可通關灰盒流程；本輪版本部署狀態須以本次 `main` push 後的 Pages workflow 結果為準。上一輪互動、觸控與效能更新已由 commit [`271d999`](https://github.com/dmppmd132-glitch/pochacco/commit/271d999) 推送並部署至 [GitHub Pages](https://github.com/dmppmd132-glitch/pochacco/actions/runs/43577835231)，公開頁手機模擬驗收記錄於 [MOBILE_WEB_TEST.md](MOBILE_WEB_TEST.md)。

第一章開場跳台路線已調整並加入 smoke regression；第二章測試檢查側風區域、推力與風歇窗口。`npm run test:chapter-three` 驗收第三章 Boss；`npm run test:chapter-four` 涵蓋第四章入口、音序與鏡面、Boss 三階段、真實場景安全主線／支線糖果／門鎖／檢查點／珍珠結算及獎勵去重；`npm run test:costume-store` 涵蓋 schema v4、run ID 去重、持久化與保存失敗回滾。其餘回歸以本輪驗證結果為準。

## 操作

### 鍵盤

- 移動：`←`／`→` 或 `A`／`D`
- 跳躍：`Space` 或 `↑`
- 切換角色：`L` 或 `Tab`
- 主要能力：`J` 或 `X`（嘟嘟滾滾衝刺／帕恰狗香蕉迴旋鏢）
- 嘟嘟屁屁坐擊：跳起後按 `K`
- 帕恰狗偵探嗅嗅：`E`
- 帕恰狗放香蕉皮：`C`
- 集合／雙重重量機關：`F`
- 攻略／帕恰狗香蕉皮：`R`（嘟嘟顯示本章攻略；帕恰狗放香蕉皮）
- 暫停：`Esc`

### 手把與手機觸控

| 按鍵 | 動作 |
| --- | --- |
| `A` | 跳躍 |
| `B` | 嘟嘟滾滾衝刺／帕恰狗香蕉迴旋鏢 |
| `X` | 嘟嘟屁屁坐擊／帕恰狗偵探嗅嗅 |
| `Y` | 集合抱抱 |
| `L`（左肩鍵） | 切換角色 |
| `R`（右肩鍵） | 嘟嘟攻略說明／帕恰狗放香蕉皮 |
| `Start` | 暫停 |

手機請橫向持握。左側虛擬搖桿負責左右移動，上推可跳躍；右側使用仿手把的 `A`／`B`／`X`／`Y` 按鍵及 `L`／`R` 肩鍵。

## 專案與部署

遊戲原始碼位於專案根目錄。GitHub Pages 部署 `github-pages/` 中的自包含 PWA（含 `index.wasm`、`index.pck`、manifest、Service Worker 與離線頁）；`.github/workflows/pages.yml` 會在 `main` 分支更新時，依 `assets.lock.json` 還原並驗證素材、安裝 Godot 4.7.2 與 Web 匯出模板、執行平台／陣風／第三至四章／SaveStore／故事對話與來源契約測試、匯出及檢查 PWA，再同步並部署 GitHub Pages。也可從 Actions 頁面手動執行 workflow。Webdev 管理的 `site/` 是另一份預覽輸出，不是 GitHub Pages 的部署來源。

更新遊戲並推送到 `main` 後，GitHub Actions 會自動完成建置與部署；本機也可用 `npm run ci:hydrate-assets` 還原鎖定素材、`npm run ci:export` 匯出 `dist/standalone/`，再用 `npm run pages:sync` 更新 Pages 目錄。同步腳本會排除本機 build fingerprint，並確認 PWA 包含 WASM/PCK 且沒有 Manus Storage 絕對路徑。

驗證第一章開場平台可達、彈跳、落到下一平台並取得糖果：`npm run test:platform-route`。驗證第二章週期陣風的區域邊界、活動／平靜週期與角色實際受側推：`npm run test:cloud-gust`。第三章噴口相位、錯相配置、嗅嗅提示與坐擊壓閥：`npm run test:chapter-three`。第四章全章機制／Boss／路線與存檔測試由 `npm run test:chapter-four` 及 `npm run test:costume-store` 執行；Pages workflow 在來源環境執行後，匯出並檢查實際 PCK。

## 注意事項

本 repo 與 Pages 網站均為公開。請勿加入密鑰、個人資料或未授權素材。角色及品牌相關素材依專案權利聲明使用；Godot 匯出檔內含第三方元件，授權資訊見 `github-pages/THIRD_PARTY_NOTICES.txt` 與 `github-pages/open-source-licenses.html`。
