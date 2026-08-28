# macOS Apple Silicon 執行台灣遊戲橘子《新楓之谷：經典版》測試紀錄

測試日期：2026-08-28  
測試設備：Apple Silicon M5 MacBook Air，24GB unified memory，macOS 26.5  
測試目標：盡量不使用 VMware Fusion + Windows VM，改用 macOS 原生環境下的免費相容層方案啟動並遊玩《新楓之谷：經典版》。

## 結論摘要

本次在 M5 / 24GB / macOS 26.5 上，使用 Cyder + CitrusGate / Beanfun OTP 已成功：

- 從 macOS 啟動台灣遊戲橘子《新楓之谷：經典版》
- 完成 Beanfun / NexonPlug 啟動流程
- 登入角色並進入遊戲地圖
- 在高刷怪地圖中測試約 30 分鐘，體感穩定
- 快速進出地圖後，RAM 有回落，沒有出現 VMware 測試時那種明顯逐漸 Lag
- 監測期間沒有 macOS crash report

目前可判定：在本測試設備上，Cyder + CitrusGate 方案已通過第一輪可用性測試，可以作為 VMware Fusion 之外的主要測試方案。

但這不是官方支援路線，仍可能因遊戲更新、Beanfun / Gamania 啟動流程變更、macOS 更新、Cyder / CitrusGate 版本變動而失效。

## 工具分工

### Cyder

Cyder 是 Windows `.exe` 啟動器，負責在 macOS 上透過 Wine / CrossOver FOSS-based engine 執行 Windows 遊戲主程式。

本次用途：

- 建立 Wine runtime
- 建立 shared Wine prefix / bottle
- 啟動 `Maplestory_Classic.exe`
- 套用圖形後端，本次實際使用 `DXMT`

官方來源：

- https://github.com/dspp779/CyderBits
- https://github.com/dspp779/cyder-wine-engine

### CitrusGate / Beanfun OTP

CitrusGate 的 release app 名稱是 Beanfun OTP。它負責 Beanfun / Gamania 登入與啟動流程，特別是接收 `NexonPlug://` URL，解析經典版啟動參數，再交給 Cyder 啟動遊戲。

本次用途：

- 處理 Beanfun / 官方網頁登入後的 `NexonPlug://`
- 將經典版啟動參數傳給 Cyder
- 預先記住 `Maplestory_Classic.exe` 路徑

官方來源：

- https://github.com/dspp779/CitrusGate

### nxdl

nxdl 是 CitrusGate 文件中用來下載經典版客戶端的命令列工具。本次使用官方 GitHub release 的釘選版本下載遊戲檔。

官方來源：

- https://github.com/HikariCalyx/nxdl

## 官方來源與版本確認

本次只使用 GitHub 官方 release，不使用第三方下載站。

### Cyder

- Repository: `dspp779/CyderBits`
- Release: `v0.13.2`
- Asset: `Cyder-0.13.2.zip`
- SHA-256: `609e1bc8bee4a7e966c48025134a2007f210198bcfd974885d4235a0ab9f7cd3`
- Bundle ID: `local.cyder.app`
- App version: `0.13.2`
- Wine engine: `CX26.3.0-W11-Cyder012`
- Wine version observed: `wine-11.0`

### CitrusGate / Beanfun OTP

- Repository: `dspp779/CitrusGate`
- Release: `v0.8.2`
- Asset: `Beanfun.OTP.zip`
- SHA-256: `d8ed9866b7da870ba47f30be76f38da8d8830e60d5338a2d09cca8a9fbad1441`
- Bundle ID: `local.ogom.beanfunotp`
- App version: `0.8.2`
- Minimum macOS: `13.0`

### nxdl

- Repository: `HikariCalyx/nxdl`
- Release: `v0.1.2-prerelease2`
- Asset: `nxdl_darwin`
- SHA-256: `a0cf22ae06f94268a33d3bed847619f70842fbd3b0ee758cd0c607782d31a1f7`

## 本機環境

```text
Hardware: Apple M5
Memory: 24GB unified memory
Architecture: arm64
macOS: 26.5
Rosetta: available
Homebrew: /opt/homebrew/bin/brew
```

原本可用備援方案：

- VMware Fusion + Windows VM

注意：本次流程沒有修改、刪除或破壞 VMware Fusion Windows VM。

## 安裝與設定位置

本次全部放在使用者目錄，不安裝到系統 `/Applications`：

```text
Cyder:
  /Users/ctc/Applications/CyderLab/Cyder.app

Beanfun OTP:
  /Users/ctc/Applications/CyderLab/Beanfun OTP.app

Cyder engine:
  /Users/ctc/.cyder/runtime/Engines/wine-x86_64

Cyder shared bottle:
  /Users/ctc/Library/Application Support/Cyder/bottles/shared

MapleStory Classic client:
  /Users/ctc/Games/MapleStoryClassic/Maplestory_Classic.exe

Performance CSV:
  /Users/ctc/Library/Application Support/Cyder/Logs/perf/maplestory-classic-highspawn-20260828-224848.csv
```

## 下載與驗證流程

### 1. 下載 Cyder 與 Beanfun OTP

```bash
mkdir -p "$HOME/Downloads/CyderLab" "$HOME/Applications/CyderLab" "$HOME/Games"

curl -fL --retry 3 \
  --output "$HOME/Downloads/CyderLab/Cyder-0.13.2.zip" \
  "https://github.com/dspp779/CyderBits/releases/download/v0.13.2/Cyder-0.13.2.zip"

curl -fL --retry 3 \
  --output "$HOME/Downloads/CyderLab/Beanfun.OTP-v0.8.2.zip" \
  "https://github.com/dspp779/CitrusGate/releases/download/v0.8.2/Beanfun.OTP.zip"

shasum -a 256 \
  "$HOME/Downloads/CyderLab/Cyder-0.13.2.zip" \
  "$HOME/Downloads/CyderLab/Beanfun.OTP-v0.8.2.zip"
```

實測 SHA-256 與 GitHub release API 公布值相符。

### 2. 解壓到使用者 Applications

```bash
ditto -x -k "$HOME/Downloads/CyderLab/Cyder-0.13.2.zip" "$HOME/Applications/CyderLab"
ditto -x -k "$HOME/Downloads/CyderLab/Beanfun.OTP-v0.8.2.zip" "$HOME/Applications/CyderLab"
```

### 3. 驗證簽章與 Gatekeeper

```bash
codesign --verify --deep --strict --verbose=2 "$HOME/Applications/CyderLab/Cyder.app"
codesign --verify --deep --strict --verbose=2 "$HOME/Applications/CyderLab/Beanfun OTP.app"

spctl -a -vv --type execute "$HOME/Applications/CyderLab/Cyder.app"
spctl -a -vv --type execute "$HOME/Applications/CyderLab/Beanfun OTP.app"
```

實測結果：

```text
Cyder.app: valid on disk
Beanfun OTP.app: valid on disk
spctl: accepted
source: Notarized Developer ID
```

### 4. 初始化 Cyder engine / graphics / bottle

```bash
"$HOME/Applications/CyderLab/Cyder.app/Contents/Resources/ogom-scripts/cyder_launcher.sh" --ensure-rosetta-only
"$HOME/Applications/CyderLab/Cyder.app/Contents/Resources/ogom-scripts/cyder_launcher.sh" --ensure-engine-only
"$HOME/Applications/CyderLab/Cyder.app/Contents/Resources/ogom-scripts/cyder_launcher.sh" --ensure-graphics-only
"$HOME/Applications/CyderLab/Cyder.app/Contents/Resources/ogom-scripts/cyder_launcher.sh" --bootstrap-only
"$HOME/Applications/CyderLab/Cyder.app/Contents/Resources/ogom-scripts/cyder_launcher.sh" --health-check
```

實測結果：

- Engine 解壓成功
- Shared engine signatures intact
- Shared bottle 建立成功
- Health check `cmd /c exit 0` 回傳 0
- DXVK payload: `1.10.3`
- DXMT payload: `0.80`

## 經典版客戶端下載

先檢查 manifest：

```bash
"$HOME/Library/Application Support/local.ogom.beanfunotp/nxdl/nxdl_darwin" tms_cw --check --json
```

實測結果：

```json
{
  "appid": "2982@2141",
  "game_name": "新楓之谷：經典版",
  "files_in_manifest": 167,
  "files_to_download": 167,
  "total_size": 3045294200
}
```

下載：

```bash
mkdir -p "$HOME/Games/MapleStoryClassic"

"$HOME/Library/Application Support/local.ogom.beanfunotp/nxdl/nxdl_darwin" \
  tms_cw --download "$HOME/Games/MapleStoryClassic"
```

實測結果：

```text
Done: 167 downloaded, 0 directories, 0 filtered out, 0 failed (0 path errors).
```

### 重要：修正反斜線檔名

本次直接用 `nxdl` CLI 下載後，出現 CitrusGate 文件提到的問題：部分 Windows path 被寫成單一 macOS 檔名，例如：

```text
Maplestory_Classic_Data\Plugins\x86_64\VuplexWebViewChromium\locales\...
```

這些需要還原成真正目錄，否則 Unity 客戶端可能找不到檔案。

本次修正前：

```text
反斜線檔名數量：162
```

修正後：

```text
反斜線檔名數量：0
總檔案數：167
```

修正腳本：

```bash
root="$HOME/Games/MapleStoryClassic"

conflicts=0
while IFS= read -r -d '' src; do
  rel=${src#$root/}
  target=$root/${rel//\\/\/}
  if [[ -e "$target" ]]; then
    printf 'conflict: %s -> %s\n' "$src" "$target"
    conflicts=$((conflicts+1))
  fi
done < <(/usr/bin/find "$root" -name '*\*' -type f -print0)

if [[ "$conflicts" -eq 0 ]]; then
  moved=0
  while IFS= read -r -d '' src; do
    rel=${src#$root/}
    target=$root/${rel//\\/\/}
    /bin/mkdir -p "$(/usr/bin/dirname "$target")"
    /bin/mv -n "$src" "$target"
    moved=$((moved+1))
  done < <(/usr/bin/find "$root" -name '*\*' -type f -print0)
  printf 'moved=%s\n' "$moved"
fi
```

注意：不要把 shell 變數命名成 `path`。在 zsh 裡 `path` 是特殊陣列，會影響 `$PATH`，導致 `mkdir`、`mv`、`find` 等指令找不到。

## Beanfun OTP 設定

經典版遊戲 ID：

```text
maplestory-classic
```

預填 exe 路徑：

```bash
defaults write local.ogom.beanfunotp \
  ExecutablePath.maplestory-classic \
  "$HOME/Games/MapleStoryClassic/Maplestory_Classic.exe"
```

確認：

```bash
defaults read local.ogom.beanfunotp ExecutablePath.maplestory-classic
```

本次 `NexonPlug://` handler 已是：

```text
local.ogom.beanfunotp
```

用 AppKit 查詢：

```bash
swift -e 'import Foundation; import AppKit; let url = URL(string: "NexonPlug://test")!; if let app = NSWorkspace.shared.urlForApplication(toOpen: url) { print(app.path) } else { print("<none>") }'
```

實測：

```text
/Users/ctc/Applications/CyderLab/Beanfun OTP.app
```

## 啟動流程

玩家操作：

1. 開啟 `Beanfun OTP.app`
2. 選擇「新楓之谷：經典版」或 App 內顯示的「楓之谷：經典版」
3. 確認主程式是 `Maplestory_Classic.exe`
4. 開啟官方登入網頁
5. 自行登入 Beanfun / 完成 2FA
6. 網頁呼叫 `NexonPlug://`
7. Beanfun OTP 接收參數後交給 Cyder
8. Cyder 啟動 `Maplestory_Classic.exe`

Cyder 實際 dry-run 顯示：

```text
WINEPREFIX=/Users/ctc/Library/Application Support/Cyder/bottles/shared
wine=/Users/ctc/.cyder/runtime/Engines/wine-x86_64/bin/wine
exe=/Users/ctc/Games/MapleStoryClassic/Maplestory_Classic.exe
cwd=/Users/ctc/Games/MapleStoryClassic
```

實際圖形後端：

```text
Graphics preference: dxmt
Graphics backend: dxmt
DXMT_CONFIG=d3d11.preferredMaxFrameRate=60;
```

也就是本次跑的是 DXMT，並有 60 FPS 限幀設定。

## 效能與穩定性監測

監測方式：每 30 秒取樣一次遊戲本體、wineserver、grap 防護/外掛相關程序的 CPU 與 RSS RAM。

監測指令：

```bash
log_dir="$HOME/Library/Application Support/Cyder/Logs/perf"
/bin/mkdir -p "$log_dir"
log_file="$log_dir/maplestory-classic-highspawn-$(/bin/date +%Y%m%d-%H%M%S).csv"

/usr/bin/printf 'timestamp,seconds,role,pid,pcpu,rss_mb,vsz_mb,etime\n' > "$log_file"
start=$(/bin/date +%s)

for i in {1..60}; do
  now=$(/bin/date +%s)
  ts=$(/bin/date '+%Y-%m-%d %H:%M:%S')
  seconds=$((now-start))

  game_pid=$(ps -axo pid,command | awk '/\/Users\/ctc\/Games\/MapleStoryClassic\/Maplestory_Classic\.exe / && $0 !~ /--launch-exe/ {print $1; exit}')
  wine_pid=$(ps -axo pid,command | awk '/\.cyder\/runtime\/Engines\/wine-x86_64.*wineserver/ {print $1; exit}')
  grap_pid=$(ps -axo pid,command | awk '/grap-core64\.aes/ {print $1; exit}')

  for item in "game:$game_pid" "wineserver:$wine_pid" "grap:$grap_pid"; do
    role=${item%%:*}
    pid=${item#*:}
    if [[ -n "$pid" ]]; then
      ps -p "$pid" -o pid=,pcpu=,rss=,vsz=,etime= |
        awk -v ts="$ts" -v seconds="$seconds" -v role="$role" \
          '{printf "%s,%s,%s,%s,%s,%.1f,%.1f,%s\n", ts, seconds, role, $1, $2, $3/1024, $4/1024, $5}' >> "$log_file"
    else
      /usr/bin/printf '%s,%s,%s,not-running,,,,\n' "$ts" "$seconds" "$role" >> "$log_file"
    fi
  done

  /bin/sleep 30
done
```

### 監測結果

測試條件：

- 已進入遊戲地圖
- 高刷怪地區
- 隊友協助快速刷怪
- 中途刻意快速進出地圖

截至 2026-08-28 23:18:25，長測已完成約 29 分 37 秒，遊戲程序已存活約 40 分 36 秒。

摘要：

```text
game:
  samples: 60
  RSS first: 1330.1 MB
  RSS min:   1330.1 MB
  RSS max:   1933.4 MB
  RSS last:  1438.8 MB
  RSS avg:   1626.4 MB
  delta:     +108.7 MB
  last CPU:  77.6%

wineserver:
  samples: 60
  RSS first: 222.7 MB
  RSS min:   104.6 MB
  RSS max:   337.0 MB
  RSS last:  294.6 MB
  RSS avg:   216.5 MB
  delta:     +71.9 MB
  last CPU:  9.9%

grap-core64.aes:
  samples: 60
  RSS first: 322.7 MB
  RSS min:   322.6 MB
  RSS max:   412.1 MB
  RSS last:  402.9 MB
  RSS avg:   370.5 MB
  delta:     +80.2 MB
  last CPU:  25.5%
```

觀察：

- 遊戲 RAM 曾升到約 1.89GB，但收尾回落到約 1.41GB。
- `wineserver` RAM 有明顯上下波動，沒有一路上升。
- `grap-core64.aes` 在本次測試中最高約 412MB，收尾約 403MB。
- 高刷怪與快速切圖後，玩家回報體感仍穩定。
- 近 30 分鐘未出現相關 macOS crash report。

目前沒有看到 VMware 測試中描述的「長時間同地圖逐漸 Lag，切圖暫時恢復，反覆後 crash」現象。

## M1 到 M5、8GB 到 24GB 是否可用？

以下是根據官方文件需求與本次 M5 / 24GB 實測推論，不是每台機器保證。

### Apple Silicon M1 / M2 / M3 / M4 / M5

理論上可測，因為 Cyder 的 Apple Silicon 路線是透過 Rosetta 執行 x86_64 Wine engine，CitrusGate / Beanfun OTP 是 Universal app。

本次只實測 M5。M1-M4 應該也可以嘗試，但效能、散熱、長時間穩定性需要各自驗證。

### RAM 24GB

本次實測可用。高刷怪下遊戲本體約 1.3-1.9GB，整組 Wine / grap 相關程序額外約數百 MB，系統仍有餘裕。

### RAM 16GB

推測可用，而且是比較合理的建議門檻。若同時開瀏覽器、Discord、直播、錄影、其他遊戲工具，仍要注意記憶體壓力。

### RAM 8GB

可以嘗試，但不建議期待長時間穩定高壓遊玩。

理由：

- macOS 本身、瀏覽器、Beanfun OTP、Cyder/Wine、遊戲、grap 會一起吃 RAM。
- 本次遊戲本體最高已到約 1.87GB，整體相關程序加總大約可到 2.5GB 左右或更高。
- 8GB 機器一旦進入 swap，可能出現卡頓；長時間高刷怪尤其需要觀察。

8GB 玩家建議：

- 關閉大型瀏覽器分頁
- 關閉錄影/直播/不必要背景 App
- 遊戲內畫質與特效先保守設定
- 先測 20-30 分鐘同地圖高刷怪
- 若出現 swap 或越玩越卡，仍建議回 VM/雲端/Windows PC

## 建議玩家測試清單

1. 能否啟動 Beanfun OTP
2. 能否開官方登入網頁
3. 能否接收 `NexonPlug://`
4. 能否啟動 `Maplestory_Classic.exe`
5. 能否登入角色
6. 能否進入地圖
7. 畫面是否正常
8. 鍵盤/滑鼠輸入是否正常
9. 高刷怪地圖待 20-30 分鐘是否越來越 Lag
10. 快速切圖 5-10 次是否恢復或 crash
11. 觀察 Activity Monitor 是否 memory pressure 變黃/紅
12. 檢查是否出現 crash report

## 風險與免責

- 這不是遊戲橘子、Beanfun、Nexon 官方支援方式。
- 使用相容層啟動線上遊戲可能有帳號風險或服務條款風險。
- Beanfun / Gamania / NexonPlug 啟動流程可能隨時變更。
- 遊戲更新後可能需要重新下載客戶端或等待 CitrusGate / Cyder 更新。
- 不建議停用 SIP、降低 macOS 安全性、安裝來源不明工具、或從第三方下載站抓安裝包。

## 本次測試判定

本次 M5 / 24GB / macOS 26.5：

```text
啟動：成功
登入：成功
進入地圖：成功
高刷怪短中程測試：穩定
快速切圖：穩定
RAM：有波動，沒有單向失控
CPU：可接受
Crash：未觀察到
推薦狀態：可作為 Apple Silicon Mac 玩家優先嘗試的免費方案
```

對其他設備的建議：

```text
M1-M5 / 16GB 以上：建議可測
M1-M5 / 8GB：可測但要保守，不保證長時間穩定
Intel Mac：文件表示工具可支援，但本次未測
macOS 13+：Beanfun OTP Modern 版需求符合
macOS 15+：DXMT 可用條件符合
macOS 26.5：本次實測可用
```
