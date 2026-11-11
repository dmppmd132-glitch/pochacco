# P0 主角動畫與資產規格

## 狀態與範圍

P0 核心角色動畫已接入 `snackisle_game.gd`：嘟嘟與帕恰狗各有待機及跑步循環；嘟嘟另有屁屁坐擊下墜、撞地、回復姿勢；關卡完成時兩位角色切換為各自的勝利 pose。跳躍、嘟嘟滾動、帕恰狗迴旋鏢及受傷維持首輪 P0 關鍵姿勢。兩名角色的碰撞、移動速度、平台判定、攻擊判定及關卡完成條件均未由美術素材控制。

## 素材規格

- 參考圖：`assets/snackisle/dudu.png`、`assets/snackisle/pochacco.png`，以及首輪關鍵姿勢。
- 遊戲圖檔：`assets/snackisle/animation_p0/`；全為 512×512 RGBA、透明背景的獨立精靈圖，角色腳底在共用的 y≈495 基線。
- 新生成的原圖以 Manus GPT Image 生成，轉檔流程為 alpha > 64 取主體、加 28 px 留白、等比例 Lanczos 縮至 452×466 內，置入 512×512 透明畫布；未覆寫專案原圖。
- 新增 17 張循環／坐擊／勝利遊戲影格；來源、參考輸入、轉換步驟、SHA-256、用途與公開權限審閱標記均已加入 `asset-provenance.json`。公開發佈前仍需由專案負責人確認 Sanrio／第三方角色權利與素材發佈授權；來源紀錄不代表取得授權。

## 動畫行為與程式接線

| 角色／狀態 | 影格 | 播放方式與觸發 |
|---|---|---|
| 嘟嘟待機 | `dudu_idle.png`, `_01`–`_03` | 4 格循環，5 fps；非移動且未進入更高優先級狀態 |
| 嘟嘟跑步 | `dudu_run.png`, `_01`–`_03` | 4 格循環，10 fps；水平速度超過既有門檻 |
| 帕恰狗待機 | `pochacco_idle.png`, `_01`–`_03` | 4 格循環，5 fps |
| 帕恰狗跑步 | `pochacco_run.png`, `_01`–`_03` | 4 格循環，10 fps |
| 嘟嘟坐擊下墜 | `dudu_pound_01.png` | `ground_pounding` 時固定下墜姿勢 |
| 嘟嘟坐擊撞地／回復 | `dudu_pound_02.png`, `_03` | 落地後兩格單次播放，8 fps；既有回復計時到期後回到一般移動狀態 |
| 兩角色勝利 | `dudu_victory.png`, `pochacco_victory.png` | `finish_level()` 設定 pose，結算畫面期間保持 |
| 既有關鍵姿勢 | jump、roll、boomerang、hurt PNG | 沿用原始遊戲狀態／既有短暫計時 |

姿勢優先順序為勝利、受傷、嘟嘟滾動、攻擊、坐擊下墜／回復、空中、跑步、待機。`Sprite2D.flip_h` 負責左右朝向；動畫影格只設定 Sprite 貼圖，`CapsuleShape2D` 及物理錨點保持不變。

## 自動化驗收

`test/animation_p0.gd` 覆蓋兩角色 idle/run 各四格、循環影格推進、jump／能力／hurt 姿勢、嘟嘟坐擊下墜與落地回復，以及呼叫 `finish_level()` 後兩位角色進入勝利 pose。另檢查所有 27 張 P0 PNG 均為 512×512 RGBA 且有透明像素。

建議在具備完整專案資產的環境執行：

```sh
godot --headless --audio-driver Dummy --path . --script test/animation_p0.gd
npm run test:checks
```

## 本工作副本測試紀錄與限制

- [x] 17 張新增 PNG 已生成、裁切、縮放及登記 provenance；總計 27 張 P0 PNG 均為 512×512 RGBA，alpha 通道含透明像素。
- [x] `gdparse` 對 `scripts/snackisle_game.gd` 及 `test/animation_p0.gd` 靜態解析通過。
- [x] `npm run test:checks`：7 項 Node 測試全部通過。
- [x] 新增 17 個 provenance 記錄的路徑、SHA-256、位元組數及 manifest 檔案摘要已核對。
- [ ] Godot headless 場景測試：尚未通過。本 shallow clone 缺少原專案引用的 `assets/template/fonts/Nunito-VF.subset.woff2`、`NotoSansSC-VF.subset.woff2` 和 `assets/template/audio/*.ogg` 等既有來源素材，場景 preload／首次匯入因此無法完整完成；不得將阻塞或逾時記為通過。
- [ ] Web／手機實機、動畫滑動與匯出後畫質仍須由完整專案環境驗收。

以上限制只表示本次無法在不完整 clone 進行 Godot runtime 驗證；並不表示新增 GDScript 或美術影格已在完整專案環境通過執行期測試。
