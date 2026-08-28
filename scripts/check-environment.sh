#!/usr/bin/env bash
set -euo pipefail

echo "== macOS =="
sw_vers

echo
echo "== Hardware =="
sysctl -n machdep.cpu.brand_string 2>/dev/null || true
printf 'Memory: %.1f GB\n' "$(awk "BEGIN {print $(sysctl -n hw.memsize) / 1024 / 1024 / 1024}")"
printf 'Architecture: %s\n' "$(uname -m)"

echo
echo "== Apple Silicon / Rosetta =="
sysctl hw.optional.arm64 2>/dev/null || true
if arch -x86_64 /usr/bin/true 2>/dev/null; then
  echo "Rosetta: available"
else
  echo "Rosetta: not available or not installed"
fi

echo
echo "== Tools =="
command -v brew >/dev/null && echo "Homebrew: $(command -v brew)" || echo "Homebrew: not found"
command -v git >/dev/null && git --version || echo "Git: not found"
