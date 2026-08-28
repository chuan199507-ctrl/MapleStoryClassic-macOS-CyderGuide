# macOS Apple Silicon 玩台灣《新楓之谷：經典版》教學

這篇教學紀錄如何在 macOS Apple Silicon 上，使用免費社群工具 Cyder + CitrusGate / Beanfun OTP 啟動台灣遊戲橘子《新楓之谷：經典版》。

實測環境：

- MacBook Air，Apple M5
- 24GB unified memory
- macOS 26.5
- Cyder `v0.13.2`
- CitrusGate / Beanfun OTP `v0.8.2`

本教學不需要 Parallels、CrossOver 或 VMware Fusion。但這不是官方支援玩法，可能因遊戲更新、Beanfun 登入流程變更、macOS 更新或工具版本變動而失效。

## 目前測試結果

本次實測已成功：

- 在 macOS 直接啟動《新楓之谷：經典版》
- 使用 Beanfun / Gamania 登入流程啟動遊戲
- 登入角色並進入遊戲地圖
- 在高刷怪地圖測試約 30 分鐘
- 快速進出地圖後仍可正常遊玩
- 測試期間沒有 crash

M1 到 M5 的 Apple Silicon Mac 理論上都可以測。16GB 以上較建議；8GB 可以嘗試，但要特別注意記憶體壓力與 swap。

## 你需要準備什麼

建議條件：

- Apple Silicon Mac：M1 / M2 / M3 / M4 / M5
- macOS 13 以上
- Rosetta 2
- 至少 8GB RAM，建議 16GB 以上
- 約 5GB 以上可用硬碟空間
- 可以正常登入 Beanfun 的帳號

請注意：

- 不要把 Beanfun 帳號、密碼、2FA、完整 `NexonPlug://` 網址或啟動參數貼給別人。
- 不要下載來源不明的第三方包。
- 不需要停用 SIP。
- 不需要降低 macOS 安全性。

## 工具分工

### Cyder

Cyder 是用來在 macOS 上執行 Windows `.exe` 的啟動器。它會準備 Wine engine、Wine bottle / prefix，並啟動 `Maplestory_Classic.exe`。

官方來源：

- https://github.com/dspp779/CyderBits
- https://github.com/dspp779/cyder-wine-engine

### CitrusGate / Beanfun OTP

CitrusGate 的 macOS app 名稱是 Beanfun OTP。它負責處理 Beanfun 網頁登入後的啟動流程，接收 `NexonPlug://`，再交給 Cyder 啟動遊戲。

官方來源：

- https://github.com/dspp779/CitrusGate

### nxdl

nxdl 是用來下載《新楓之谷：經典版》客戶端的工具。

官方來源：

- https://github.com/HikariCalyx/nxdl

## 第 1 步：檢查 Mac 環境

打開 Terminal，先確認目前環境：

```bash
sw_vers
uname -m
sysctl -n machdep.cpu.brand_string
sysctl -n hw.memsize
arch -x86_64 /usr/bin/true && echo "Rosetta available"
```

如果最後一行顯示 `Rosetta available`，代表 Rosetta 可以使用。

也可以使用本 repo 的檢查腳本：

```bash
./scripts/check-environment.sh
```

## 第 2 步：建立資料夾

以下教學使用這幾個位置：

```text
$HOME/Downloads/CyderLab
$HOME/Applications/CyderLab
$HOME/Games/MapleStoryClassic
```

建立資料夾：

```bash
mkdir -p "$HOME/Downloads/CyderLab" "$HOME/Applications/CyderLab" "$HOME/Games"
```

## 第 3 步：下載 Cyder 與 Beanfun OTP

請到官方 GitHub release 下載：

- Cyder: https://github.com/dspp779/CyderBits/releases
- Beanfun OTP: https://github.com/dspp779/CitrusGate/releases

本次實測版本：

- `Cyder-0.13.2.zip`
- `Beanfun.OTP.zip` from CitrusGate `v0.8.2`

也可以用 Terminal 下載：

```bash
curl -fL --retry 3 \
  --output "$HOME/Downloads/CyderLab/Cyder-0.13.2.zip" \
  "https://github.com/dspp779/CyderBits/releases/download/v0.13.2/Cyder-0.13.2.zip"

curl -fL --retry 3 \
  --output "$HOME/Downloads/CyderLab/Beanfun.OTP-v0.8.2.zip" \
  "https://github.com/dspp779/CitrusGate/releases/download/v0.8.2/Beanfun.OTP.zip"
```

檢查 SHA-256：

```bash
shasum -a 256 \
  "$HOME/Downloads/CyderLab/Cyder-0.13.2.zip" \
  "$HOME/Downloads/CyderLab/Beanfun.OTP-v0.8.2.zip"
```

本次實測 SHA-256：

```text
Cyder-0.13.2.zip
609e1bc8bee4a7e966c48025134a2007f210198bcfd974885d4235a0ab9f7cd3

Beanfun.OTP-v0.8.2.zip
d8ed9866b7da870ba47f30be76f38da8d8830e60d5338a2d09cca8a9fbad1441
```

如果 SHA 不同，請先不要繼續。

## 第 4 步：解壓縮 App

```bash
ditto -x -k "$HOME/Downloads/CyderLab/Cyder-0.13.2.zip" "$HOME/Applications/CyderLab"
ditto -x -k "$HOME/Downloads/CyderLab/Beanfun.OTP-v0.8.2.zip" "$HOME/Applications/CyderLab"
```

確認 app 存在：

```bash
ls -la "$HOME/Applications/CyderLab"
```

應該會看到：

```text
Cyder.app
Beanfun OTP.app
```

## 第 5 步：檢查簽章與 Gatekeeper

```bash
codesign --verify --deep --strict --verbose=2 "$HOME/Applications/CyderLab/Cyder.app"
codesign --verify --deep --strict --verbose=2 "$HOME/Applications/CyderLab/Beanfun OTP.app"

spctl -a -vv --type execute "$HOME/Applications/CyderLab/Cyder.app"
spctl -a -vv --type execute "$HOME/Applications/CyderLab/Beanfun OTP.app"
```

正常情況會看到 `valid on disk` 與 `accepted`。

如果 macOS 跳出安全性確認，請自行判斷並手動處理。不要把管理員密碼或帳號密碼交給任何人。

## 第 6 步：初始化 Cyder

依序執行：

```bash
"$HOME/Applications/CyderLab/Cyder.app/Contents/Resources/ogom-scripts/cyder_launcher.sh" --ensure-rosetta-only
"$HOME/Applications/CyderLab/Cyder.app/Contents/Resources/ogom-scripts/cyder_launcher.sh" --ensure-engine-only
"$HOME/Applications/CyderLab/Cyder.app/Contents/Resources/ogom-scripts/cyder_launcher.sh" --ensure-graphics-only
"$HOME/Applications/CyderLab/Cyder.app/Contents/Resources/ogom-scripts/cyder_launcher.sh" --bootstrap-only
"$HOME/Applications/CyderLab/Cyder.app/Contents/Resources/ogom-scripts/cyder_launcher.sh" --health-check
```

本次實測：

- Wine engine：`CX26.3.0-W11-Cyder012`
- Wine version：`wine-11.0`
- DXMT：`0.80`
- DXVK：`1.10.3`
- health check 成功

若 health check 失敗，先不要進下一步。

## 第 7 步：下載 nxdl

請從官方 GitHub release 下載 nxdl：

- https://github.com/HikariCalyx/nxdl/releases

本次實測版本：

- `v0.1.2-prerelease2`
- asset：`nxdl_darwin`

放到 CitrusGate 預期位置：

```bash
mkdir -p "$HOME/Library/Application Support/local.ogom.beanfunotp/nxdl"

curl -fL --retry 3 \
  --output "$HOME/Library/Application Support/local.ogom.beanfunotp/nxdl/nxdl_darwin" \
  "https://github.com/HikariCalyx/nxdl/releases/download/v0.1.2-prerelease2/nxdl_darwin"

chmod +x "$HOME/Library/Application Support/local.ogom.beanfunotp/nxdl/nxdl_darwin"
```

檢查 SHA-256：

```bash
shasum -a 256 "$HOME/Library/Application Support/local.ogom.beanfunotp/nxdl/nxdl_darwin"
```

本次實測 SHA-256：

```text
a0cf22ae06f94268a33d3bed847619f70842fbd3b0ee758cd0c607782d31a1f7
```

## 第 8 步：檢查並下載遊戲客戶端

先檢查 manifest：

```bash
"$HOME/Library/Application Support/local.ogom.beanfunotp/nxdl/nxdl_darwin" tms_cw --check --json
```

本次實測顯示：

```text
game_name: 新楓之谷：經典版
files_in_manifest: 167
total_size: 約 2.84 GiB
```

下載遊戲：

```bash
mkdir -p "$HOME/Games/MapleStoryClassic"

"$HOME/Library/Application Support/local.ogom.beanfunotp/nxdl/nxdl_darwin" \
  tms_cw --download "$HOME/Games/MapleStoryClassic"
```

下載完成後，確認主程式存在：

```bash
ls -la "$HOME/Games/MapleStoryClassic/Maplestory_Classic.exe"
```

## 第 9 步：修正 nxdl 反斜線路徑問題

如果下載後出現檔名包含 `\` 的情況，需要修正路徑。

可以用本 repo 的腳本：

```bash
./scripts/fix-nxdl-backslash-paths.sh "$HOME/Games/MapleStoryClassic"
```

修正後確認：

```bash
find "$HOME/Games/MapleStoryClassic" -name '*\*' -print
```

如果沒有輸出，代表沒有殘留反斜線檔名。

也可以確認這些資料夾存在：

```bash
ls -la "$HOME/Games/MapleStoryClassic/Maplestory_Classic_Data"
ls -la "$HOME/Games/MapleStoryClassic/Maplestory_Classic_Data/Plugins/x86_64"
```

## 第 10 步：設定 Beanfun OTP 的遊戲路徑

讓 Beanfun OTP 記住經典版主程式位置：

```bash
defaults write local.ogom.beanfunotp \
  ExecutablePath.maplestory-classic \
  "$HOME/Games/MapleStoryClassic/Maplestory_Classic.exe"
```

確認設定：

```bash
defaults read local.ogom.beanfunotp ExecutablePath.maplestory-classic
```

應該會顯示：

```text
$HOME/Games/MapleStoryClassic/Maplestory_Classic.exe
```

實際輸出可能會是完整絕對路徑，這是正常的。

## 第 11 步：確認 NexonPlug handler

讓系統知道 `NexonPlug://` 要交給 Beanfun OTP：

```bash
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
  -f "$HOME/Applications/CyderLab/Beanfun OTP.app"
```

檢查：

```bash
swift -e 'import Foundation; import AppKit; let url = URL(string: "NexonPlug://test")!; if let app = NSWorkspace.shared.urlForApplication(toOpen: url) { print(app.path) } else { print("<none>") }'
```

正常情況會指向：

```text
$HOME/Applications/CyderLab/Beanfun OTP.app
```

## 第 12 步：啟動遊戲

用 Finder 打開：

```text
$HOME/Applications/CyderLab/Beanfun OTP.app
```

或用 Terminal：

```bash
open "$HOME/Applications/CyderLab/Beanfun OTP.app"
```

接下來在 Beanfun OTP / 官方頁面中自行登入 Beanfun，完成 2FA，並啟動《新楓之谷：經典版》。

啟動流程大致是：

```text
Beanfun 網頁登入
-> 呼叫 NexonPlug://
-> Beanfun OTP 接收
-> Cyder 啟動 Maplestory_Classic.exe
-> 進入遊戲
```

不要把完整 `NexonPlug://` 網址、啟動參數、帳密或驗證碼貼給別人。

## 第 13 步：確認遊戲是否真的成功

建議檢查：

- 是否出現遊戲視窗
- 是否能到登入後角色選單
- 是否能進入遊戲地圖
- 畫面是否正常
- 鍵盤滑鼠操作是否正常
- 切換地圖是否正常
- 是否會 crash

本次實測實際使用圖形後端是 DXMT。

可以查看 Cyder log：

```bash
grep -R "Graphics backend" "$HOME/Library/Application Support/Cyder/Logs" | tail
```

## 第 14 步：測試效能與穩定性

開啟遊戲後，可以用本 repo 的監測腳本：

```bash
./scripts/monitor-maplestory-classic.sh
```

預設會每 30 秒記錄一次，共 60 次，大約 30 分鐘。

監測內容包含：

- `game`：遊戲本體
- `wineserver`：Wine server
- `grap`：遊戲保護相關程序

建議測試方式：

- 在一般地圖待 10 分鐘
- 在高刷怪地圖待 20 到 30 分鐘
- 中途快速進出地圖
- 觀察是否越來越 Lag
- 觀察切圖後是否恢復
- 觀察是否 crash

本次實測 30 分鐘高刷怪結果：

```text
game:
  RSS first: 1330.1 MB
  RSS max:   1933.4 MB
  RSS last:  1438.8 MB

wineserver:
  RSS first: 222.7 MB
  RSS max:   337.0 MB
  RSS last:  294.6 MB

grap-core64.aes:
  RSS first: 322.7 MB
  RSS max:   412.1 MB
  RSS last:  402.9 MB
```

遊戲記憶體有上下波動，沒有觀察到一路增加到 crash 的情況。

## 常見問題

### 一定要買 CrossOver 或 Parallels 嗎？

本次實測不需要。使用的是 Cyder + CitrusGate / Beanfun OTP。

### 可以保留 VMware Fusion 嗎？

可以。本教學不需要修改或刪除 VMware Fusion Windows VM。

### M1 / M2 / M3 / M4 可以用嗎？

理論上可以測，因為這條路線是 Apple Silicon + Rosetta + Wine engine。但本次只實測 M5 / 24GB / macOS 26.5。

### 8GB RAM 可以用嗎？

可以嘗試，但不保證長時間高刷怪穩定。建議關閉瀏覽器、大型通訊軟體、直播錄影工具等背景程式，並觀察 Activity Monitor 的 Memory Pressure。

### 安裝時 macOS 要求安全性確認怎麼辦？

請自行判斷是否信任官方 GitHub release 與簽章檢查結果，再手動處理。不要停用 SIP，也不要下載第三方來源。

### 遊戲更新後不能開怎麼辦？

先重新檢查：

- Cyder 是否有新版
- CitrusGate / Beanfun OTP 是否有新版
- nxdl manifest 是否更新
- Beanfun 登入流程是否改變
- Cyder log 裡是否有新的錯誤

## 回報測試結果建議格式

```text
Mac 型號：
晶片：
RAM：
macOS 版本：
Cyder 版本：
CitrusGate / Beanfun OTP 版本：
是否可啟動：
是否可登入角色：
是否可進入地圖：
測試地圖類型：
測試時間：
是否越玩越 Lag：
切換地圖是否恢復：
是否 crash：
Activity Monitor memory pressure：
補充：
```

## 最後提醒

這是一條社群測試路線，不是官方保證支援。請保留原本可用的 Windows / VM 方案作為備用，並避免把任何帳號資料、啟動參數或驗證資訊公開。
