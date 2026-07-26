#!/usr/bin/env bash
SPK_LOG_LEVEL="${SPK_LOG_LEVEL:-INFO}"
SPK_LOG_FILE="${SPK_LOG_DIR:-/tmp}/spk-runtime.log"
_log_level_num() { case "${1:-INFO}" in DEBUG) echo 0 ;; INFO) echo 1 ;; WARN) echo 2 ;; ERROR) echo 3 ;; esac; }
_log_write() { local level="$1" msg="$2" ts; ts="$(date '+%H:%M:%S')"; if [[ $(_log_level_num "$level") -ge $(_log_level_num "$SPK_LOG_LEVEL") ]]; then printf '[%s] [%-5s] %s\n' "$ts" "$level" "$msg" | tee -a "$SPK_LOG_FILE" 2>/dev/null || printf '[%s] [%-5s] %s\n' "$ts" "$level" "$msg"; fi; }
log_debug() { _log_write DEBUG "$*"; }
log_info()  { _log_write INFO  "$*"; }
log_warn()  { _log_write WARN  "$*"; }
log_error() { _log_write ERROR "$*"; }
