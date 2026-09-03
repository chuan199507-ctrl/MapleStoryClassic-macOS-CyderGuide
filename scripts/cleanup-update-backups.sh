#!/usr/bin/env bash
set -euo pipefail

game_parent="${GAME_PARENT:-$HOME/Games}"

echo "== MapleStory Classic update backups =="
if ! compgen -G "$game_parent/MapleStoryClassic-conflict-backup-*" >/dev/null; then
  echo "No update backup folders found under: $game_parent"
  exit 0
fi

du -sh "$game_parent"/MapleStoryClassic-conflict-backup-* 2>/dev/null || true

if [[ "${1:-}" != "--delete" ]]; then
  echo
  echo "Dry run only. To delete these backup folders after the game is confirmed working, run:"
  echo "$0 --delete"
  exit 0
fi

echo
echo "Deleting backup folders..."
rm -rf "$game_parent"/MapleStoryClassic-conflict-backup-*
echo "Backup cleanup completed."
