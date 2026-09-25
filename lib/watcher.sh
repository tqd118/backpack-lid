#!/usr/bin/env bash
# Background lid watcher for backpack-lid (one session).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT/lib/common.sh"

ensure_state_dir
POLL_SEC="${BACKPACK_LID_POLL:-0.6}"

start_inhibit() {
  if pid_alive "$(read_pid_file "$INHIBIT_PID_FILE")"; then
    return 0
  fi
  # Keep sleep / lid-switch handling blocked while active.
  systemd-inhibit \
    --what=sleep:idle:handle-lid-switch \
    --who=backpack-lid \
    --why="Backpack lid-awake session (one lid-close)" \
    --mode=block \
    sleep infinity &
  echo $! >"$INHIBIT_PID_FILE"
}

stop_inhibit() {
  kill_pid_file "$INHIBIT_PID_FILE"
}

cleanup_and_exit() {
  stop_inhibit
  dpms_on
  write_state "idle"
  rm -f "$WATCHER_PID_FILE"
  exit 0
}

trap cleanup_and_exit TERM INT HUP

echo $$ >"$WATCHER_PID_FILE"
write_state "armed"

prev="$(read_lid || true)"
# If already closed when arming, treat as immediate activate.
if [[ "$prev" == "closed" ]]; then
  write_state "active"
  start_inhibit
  dpms_off
fi

while true; do
  sleep "$POLL_SEC"
  cur="$(read_lid || true)"
  state="$(read_state)"

  if [[ "$cur" == "closed" && "$prev" != "closed" ]]; then
    if [[ "$state" == "armed" || "$state" == "active" ]]; then
      write_state "active"
      start_inhibit
      dpms_off
    fi
  fi

  # Lid opened → end session (even if still only armed).
  if [[ "$cur" == "open" && "$prev" == "closed" ]]; then
    cleanup_and_exit
  fi

  # If state was externally set to idle, exit.
  if [[ "$(read_state)" == "idle" ]]; then
    cleanup_and_exit
  fi

  prev="$cur"
done
