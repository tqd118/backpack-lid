# shared helpers for backpack-lid
: "${XDG_RUNTIME_DIR:=/tmp}"
STATE_DIR="${XDG_RUNTIME_DIR}/backpack-lid"
STATE_FILE="${STATE_DIR}/state"
WATCHER_PID_FILE="${STATE_DIR}/watcher.pid"
INHIBIT_PID_FILE="${STATE_DIR}/inhibit.pid"

ensure_state_dir() {
  mkdir -p "$STATE_DIR"
  chmod 700 "$STATE_DIR" 2>/dev/null || true
}

read_state() {
  if [[ -f "$STATE_FILE" ]]; then
    cat "$STATE_FILE"
  else
    echo "idle"
  fi
}

write_state() {
  ensure_state_dir
  printf '%s\n' "$1" >"$STATE_FILE"
}

lid_state_file() {
  local f
  for f in /proc/acpi/button/lid/*/state; do
    [[ -r "$f" ]] && { echo "$f"; return 0; }
  done
  return 1
}

read_lid() {
  local f s
  f="$(lid_state_file)" || { echo "unknown"; return 1; }
  s="$(awk '{print $2}' "$f" 2>/dev/null || true)"
  case "$s" in
    open|closed) echo "$s" ;;
    *) echo "unknown" ;;
  esac
}

pid_alive() {
  local pid="${1:-}"
  [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
}

read_pid_file() {
  local f="$1"
  [[ -f "$f" ]] || { echo ""; return 0; }
  tr -d ' \n' <"$f"
}

kill_pid_file() {
  local f="$1" pid
  pid="$(read_pid_file "$f")"
  if pid_alive "$pid"; then
    kill "$pid" 2>/dev/null || true
    sleep 0.15
    kill -9 "$pid" 2>/dev/null || true
  fi
  rm -f "$f"
}

dpms_off() {
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl dispatch dpms off >/dev/null 2>&1 || true
  fi
}

dpms_on() {
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl dispatch dpms on >/dev/null 2>&1 || true
  fi
}
