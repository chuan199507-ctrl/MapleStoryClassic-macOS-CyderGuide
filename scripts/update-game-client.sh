#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
nxdl_path="${NXDL_PATH:-$HOME/Library/Application Support/local.ogom.beanfunotp/nxdl/nxdl_darwin}"
game_dir="${GAME_DIR:-$HOME/Games/MapleStoryClassic}"
fix_script="${FIX_SCRIPT:-$repo_root/scripts/fix-nxdl-backslash-paths.sh}"
backup_root="${BACKUP_ROOT:-$(dirname "$game_dir")}"
timestamp="$(date +%Y%m%d-%H%M%S)"

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
if "$fix_script" "$game_dir"; then
  echo "Backslash paths normalized without conflicts."
else
  echo
  echo "Conflicting normalized paths found. Backing up old files, then applying downloaded files."
  conflict_backup="$backup_root/MapleStoryClassic-conflict-backup-$timestamp"
  mkdir -p "$conflict_backup"

  conflicts_backed_up=0
  downloaded_files_moved=0
  while IFS= read -r -d '' src; do
    rel="${src#$game_dir/}"
    dst="$game_dir/${rel//\\//}"
    if [[ "$src" == "$dst" ]]; then
      continue
    fi

    if [[ -e "$dst" ]]; then
      backup_dst="$conflict_backup/${dst#$game_dir/}"
      mkdir -p "$(dirname "$backup_dst")"
      if [[ -e "$backup_dst" ]]; then
        backup_dst="$backup_dst.$(date +%s).bak"
      fi
      mv "$dst" "$backup_dst"
      conflicts_backed_up=$((conflicts_backed_up + 1))
    fi

    mkdir -p "$(dirname "$dst")"
    mv "$src" "$dst"
    downloaded_files_moved=$((downloaded_files_moved + 1))
  done < <(find "$game_dir" -type f -name '*\\*' -print0)

  echo "conflict_backup=$conflict_backup"
  echo "conflicts_backed_up=$conflicts_backed_up"
  echo "downloaded_files_moved=$downloaded_files_moved"
fi
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

if find "$game_dir" -name '*\\*' -print | grep . >/dev/null; then
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
