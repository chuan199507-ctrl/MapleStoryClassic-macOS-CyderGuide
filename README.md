# MapleStory Classic macOS Cyder Guide

這個 repository 紀錄在 macOS Apple Silicon 上，使用免費社群工具 Cyder + CitrusGate / Beanfun OTP 執行台灣遊戲橘子《新楓之谷：經典版》的實測流程。

測試日期：2026-08-28  
測試機器：Apple Silicon M5 MacBook Air / 24GB unified memory / macOS 26.5  
測試結果：成功從 macOS 啟動、登入角色、進入遊戲地圖，並完成高刷怪與快速切換地圖初步壓力測試。

## 重要聲明

這不是遊戲橘子、Beanfun、Nexon、Apple、CodeWeavers 或 Cyder / CitrusGate 作者提供的官方支援路線。遊戲更新、Beanfun 登入流程、macOS 更新、Cyder / CitrusGate 版本變動，都可能讓流程失效。

請不要分享帳號密碼、2FA、登入 token、`NexonPlug://` 完整啟動網址或 `passarg` 參數。這些內容可能包含個人登入資訊。

## 結論

本次 M5 / 24GB / macOS 26.5 實測可用：

- Cyder `v0.13.2`
- CitrusGate / Beanfun OTP `v0.8.2`
- nxdl `v0.1.2-prerelease2`
- Cyder engine `CX26.3.0-W11-Cyder012`
- 實際圖形後端：DXMT

約 30 分鐘高刷怪與快速進出地圖測試期間：

- 遊戲沒有 crash
- macOS 沒有產生相關 crash report
- 遊戲 RSS 記憶體有上下波動，沒有觀察到單調持續上升的 leak
- 切換地圖後仍維持可操作，沒有重現 VMware Fusion + Windows VM 中逐漸 Lag 到 crash 的狀況

## M1 到 M5、8GB 到 24GB 可以用嗎？

目前可以合理判斷：

- M5 / 24GB：本 repo 的實測環境，已確認可用。
- M1 到 M4：Cyder 與 CitrusGate 都支援 Apple Silicon / Rosetta 方向，理論上可以測，但本 repo 沒有逐台驗證。
- 16GB：建議可測，請關閉大型背景程式並觀察 swap。
- 8GB：可以嘗試，但不建議期待長時間高刷怪穩定性；請特別觀察 Activity Monitor 的 Memory Pressure 與 swap。

若你要回報測試結果，建議至少提供：

- Mac 型號與晶片
- RAM
- macOS 版本
- Cyder / CitrusGate 版本
- 是否成功登入角色
- 是否可進入高刷怪地圖
- 遊玩多久後是否 Lag 或 crash
- 遊戲、wineserver、grap 的 RSS 變化

## 工具分工

Cyder 負責：

- Wine runtime
- Wine bottle / prefix
- 啟動 `Maplestory_Classic.exe`
- DXVK / DXMT 等圖形層

CitrusGate / Beanfun OTP 負責：

- Beanfun / Gamania 登入後的 `NexonPlug://` 啟動流程
- 解析並轉交經典版啟動參數
- 呼叫 Cyder 啟動遊戲

nxdl 負責：

- 從官方 manifest 下載《新楓之谷：經典版》客戶端

## 官方來源

- CyderBits: https://github.com/dspp779/CyderBits
- Cyder Wine Engine: https://github.com/dspp779/cyder-wine-engine
- CitrusGate: https://github.com/dspp779/CitrusGate
- nxdl: https://github.com/HikariCalyx/nxdl

本次流程只使用官方 GitHub release，不使用第三方下載站。

## 快速開始

一般玩家請先閱讀逐步教學：

- [docs/player-guide.md](docs/player-guide.md)

想看完整測試紀錄、版本驗證、監測數據與設計過程，再閱讀：

- [docs/test-report.md](docs/test-report.md)

此 repo 另外提供幾個輔助腳本：

- [scripts/check-environment.sh](scripts/check-environment.sh)：檢查 Apple Silicon、macOS、Rosetta、Homebrew、Git。
- [scripts/monitor-maplestory-classic.sh](scripts/monitor-maplestory-classic.sh)：監測遊戲、wineserver、grap 的 CPU/RAM。
- [scripts/fix-nxdl-backslash-paths.sh](scripts/fix-nxdl-backslash-paths.sh)：修正 nxdl 下載後檔名含反斜線的情況。

腳本預設不會刪除檔案、不會碰 VMware VM、不會輸入帳密，也不會停用 SIP 或降低 macOS 安全性。

## Repo 內容

```text
.
├── README.md
├── LICENSE
├── docs/
│   ├── player-guide.md
│   └── test-report.md
├── scripts/
│   ├── check-environment.sh
│   ├── fix-nxdl-backslash-paths.sh
│   └── monitor-maplestory-classic.sh
└── data/
    └── highspawn-monitor-20260828.csv
```

## 授權

本 repo 內容以 MIT License 釋出。遊戲、商標、Cyder、CitrusGate、nxdl 與各上游專案仍屬各自權利人與原授權。
