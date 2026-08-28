#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
script="$repo_root/scripts/update-game-client.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local needle="$1"
  local file="$2"
  grep -F -- "$needle" "$file" >/dev/null || fail "Expected '$needle' in $file"
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "test: missing nxdl reports clear error"
if NXDL_PATH="$tmp/missing-nxdl" GAME_DIR="$tmp/game" "$script" >"$tmp/missing.out" 2>&1; then
  fail "script should fail when nxdl is missing"
fi
assert_contains "nxdl not found" "$tmp/missing.out"

echo "test: update downloads, fixes backslash paths, and verifies client"
fake_nxdl="$tmp/nxdl_darwin"
cat >"$fake_nxdl" <<'FAKE_NXDL'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "$NXDL_CALL_LOG"
if [[ "$*" == "tms_cw --check --json" ]]; then
  printf '{"game_name":"新楓之谷：經典版","files_in_manifest":167,"files_to_download":1,"total_size":1}\n'
  exit 0
fi
if [[ "$1" == "tms_cw" && "$2" == "--download" ]]; then
  game_dir="$3"
  mkdir -p "$game_dir"
  printf 'exe\n' > "$game_dir/Maplestory_Classic.exe"
  mkdir -p "$game_dir/Maplestory_Classic_Data"
  printf 'plugin\n' > "$game_dir/Maplestory_Classic_Data\\Plugins\\x86_64\\grap-core64.aes"
  exit 0
fi
exit 9
FAKE_NXDL
chmod +x "$fake_nxdl"

game_dir="$tmp/MapleStoryClassic"
export NXDL_CALL_LOG="$tmp/nxdl-calls.log"
NXDL_PATH="$fake_nxdl" GAME_DIR="$game_dir" "$script" >"$tmp/update.out" 2>&1

assert_contains "tms_cw --check --json" "$NXDL_CALL_LOG"
assert_contains "tms_cw --download $game_dir" "$NXDL_CALL_LOG"
[[ -f "$game_dir/Maplestory_Classic.exe" ]] || fail "missing Maplestory_Classic.exe"
[[ -d "$game_dir/Maplestory_Classic_Data/Plugins/x86_64" ]] || fail "missing normalized Plugins/x86_64 directory"
if find "$game_dir" -name '*\*' -print | grep . >/dev/null; then
  fail "backslash paths were not normalized"
fi
assert_contains "Update completed" "$tmp/update.out"

echo "all update-game-client tests passed"
