#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
nxdl_path="${NXDL_PATH:-$HOME/Library/Application Support/local.ogom.beanfunotp/nxdl/nxdl_darwin}"
game_dir="${GAME_DIR:-$HOME/Games/MapleStoryClassic}"
fix_script="${FIX_SCRIPT:-$repo_root/scripts/fix-nxdl-backslash-paths.sh}"

echo "== MapleStory Classic client update =="
echo "nxdl: $nxdl_path"
echo "game_dir: $game_dir"
echo

if [[ ! -x "$nxdl_path" ]]; then
  echo "nxdl not found or not executable: $nxdl_path" >&2
  echo "Install nxdl_darwin first, then run this script again." >&2
  exit 2
fi

if [[ ! -x "$fix_script" ]]; then
  echo "path fix script not found or not executable: $fix_script" >&2
  exit 2
fi

echo "== Checking official manifest =="
"$nxdl_path" tms_cw --check --json
echo

echo "== Downloading/updating client =="
mkdir -p "$game_dir"
"$nxdl_path" tms_cw --download "$game_dir"
echo

echo "== Normalizing nxdl backslash paths =="
"$fix_script" "$game_dir"
echo

echo "== Verifying client layout =="
required_paths=(
  "$game_dir/Maplestory_Classic.exe"
  "$game_dir/Maplestory_Classic_Data"
  "$game_dir/Maplestory_Classic_Data/Plugins/x86_64"
)

missing=0
for path in "${required_paths[@]}"; do
  if [[ -e "$path" ]]; then
    echo "ok: $path"
  else
    echo "missing: $path" >&2
    missing=$((missing + 1))
  fi
done

if find "$game_dir" -name '*\*' -print | grep . >/dev/null; then
  echo "Some filenames still contain backslashes. Review the output above." >&2
  exit 1
fi

if [[ "$missing" -ne 0 ]]; then
  echo "Client verification failed." >&2
  exit 1
fi

echo
echo "Update completed."
echo "Next: open Beanfun OTP and launch the game normally."
