#!/usr/bin/env bash
set -euo pipefail

interval="${INTERVAL_SECONDS:-30}"
samples="${SAMPLES:-60}"
log_dir="${LOG_DIR:-$HOME/Library/Application Support/Cyder/Logs/perf}"
mkdir -p "$log_dir"

log_file="$log_dir/maplestory-classic-monitor-$(date +%Y%m%d-%H%M%S).csv"
printf 'timestamp,seconds,role,pid,pcpu,rss_mb,vsz_mb,etime\n' > "$log_file"
echo "log_file=$log_file"

start="$(date +%s)"
for ((i = 1; i <= samples; i++)); do
  now="$(date +%s)"
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  seconds=$((now - start))

  game_pid="$(ps -axo pid,command | awk '/\/MapleStoryClassic\/Maplestory_Classic\.exe / && $0 !~ /--launch-exe/ && pid == "" {pid=$1} END {if (pid != "") print pid}')"
  wine_pid="$(ps -axo pid,command | awk '/\.cyder\/runtime\/Engines\/wine-x86_64.*wineserver/ && pid == "" {pid=$1} END {if (pid != "") print pid}')"
  grap_pid="$(ps -axo pid,command | awk '/grap-core64\.aes/ && pid == "" {pid=$1} END {if (pid != "") print pid}')"

  for item in "game:$game_pid" "wineserver:$wine_pid" "grap:$grap_pid"; do
    role="${item%%:*}"
    pid="${item#*:}"
    if [[ -n "$pid" ]]; then
      ps -p "$pid" -o pid=,pcpu=,rss=,vsz=,etime= |
        awk -v ts="$ts" -v seconds="$seconds" -v role="$role" \
          '{printf "%s,%s,%s,%s,%s,%.1f,%.1f,%s\n", ts, seconds, role, $1, $2, $3/1024, $4/1024, $5}' >> "$log_file"
    else
      printf '%s,%s,%s,not-running,,,,\n' "$ts" "$seconds" "$role" >> "$log_file"
    fi
  done

  tail -3 "$log_file"
  sleep "$interval"
done
