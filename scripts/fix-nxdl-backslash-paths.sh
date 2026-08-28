#!/usr/bin/env bash
set -euo pipefail

root="${1:-}"
if [[ -z "$root" || ! -d "$root" ]]; then
  echo "Usage: $0 /path/to/MapleStoryClassic" >&2
  exit 2
fi

conflicts=0
moved=0

while IFS= read -r -d '' src; do
  rel="${src#$root/}"
  dst="$root/${rel//\\//}"
  if [[ "$src" == "$dst" ]]; then
    continue
  fi
  if [[ -e "$dst" ]]; then
    echo "Conflict: $dst already exists" >&2
    conflicts=$((conflicts + 1))
    continue
  fi
  mkdir -p "$(dirname "$dst")"
  mv "$src" "$dst"
  moved=$((moved + 1))
done < <(find "$root" -type f -name '*\\*' -print0)

echo "moved=$moved"
echo "conflicts=$conflicts"

if [[ "$conflicts" -ne 0 ]]; then
  exit 1
fi
