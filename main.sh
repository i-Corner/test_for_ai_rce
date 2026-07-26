#!/usr/bin/env bash
# main.sh — server-perf-kit v2.3.0
# Lightweight server performance monitoring and kernel tuning toolkit.
# Usage: ./main.sh

set -o pipefail

SPK_HOME="$(cd "$(dirname "$0")" && pwd)"
export SPK_HOME

SPK_CONFIG_DIR="$SPK_HOME/config"
SPK_SCRIPT_DIR="$SPK_HOME/scripts"
SPK_COLLECTOR_DIR="$SPK_HOME/collector"
SPK_UTILS_DIR="$SPK_HOME/utils"
SPK_DATA_DIR="$SPK_HOME/data"
SPK_STATE_DIR="$SPK_HOME/logs"
SPK_LOG_DIR="$SPK_HOME/logs"
export SPK_CONFIG_DIR SPK_SCRIPT_DIR SPK_COLLECTOR_DIR SPK_UTILS_DIR SPK_DATA_DIR SPK_STATE_DIR SPK_LOG_DIR

# ---- Phase 1: Bootstrap ----
source "$SPK_UTILS_DIR/logger.sh" || { echo "FATAL: cannot source logger.sh"; exit 1; }
[[ -f "$SPK_CONFIG_DIR/kit.conf" ]] && source "$SPK_CONFIG_DIR/kit.conf"
log_info "============================================"
log_info "server-perf-kit v${SPK_VERSION:-unknown} starting"
log_info "============================================"
source "$SPK_UTILS_DIR/parser.sh"  || { log_error "Cannot source parser.sh"; exit 1; }
source "$SPK_UTILS_DIR/sysinfo.sh" || { log_error "Cannot source sysinfo.sh"; exit 1; }

mkdir -p "$SPK_STATE_DIR" "$SPK_LOG_DIR"

detect_hw_profile
detect_os_info
log_info "Detected HW: $SPK_DETECTED_HW, OS: $SPK_OS_ID $SPK_OS_VER"

# ---- Phase 2: Metric Collection ----
log_info "--- Phase 2: Collecting metrics ---"
METRICS_FILE="$SPK_STATE_DIR/metrics.current"
:> "$METRICS_FILE"

for collector in "$SPK_COLLECTOR_DIR"/*.sh; do
    [[ -f "$collector" ]] || continue
    collector_name="$(basename "$collector" .sh)"
    source "$collector" 2>/dev/null || continue
    case "$collector_name" in
        cpu)  collect_cpu  "$METRICS_FILE" && log_debug "CPU metrics collected" ;;
        mem)  collect_mem  "$METRICS_FILE" && log_debug "Memory metrics collected" ;;
        disk) collect_disk "$METRICS_FILE" && log_debug "Disk metrics collected" ;;
        net)  collect_net  "$METRICS_FILE" && log_debug "Network metrics collected" ;;
    esac
done
log_info "Metrics: $(wc -l < "$METRICS_FILE" 2>/dev/null || echo 0) data points"

# ---- Phase 3: Profile Loading ----
log_info "--- Phase 3: Loading kernel tuning profiles ---"
source "$SPK_SCRIPT_DIR/profile_loader.sh" 2>/dev/null || true
load_all_profiles "$SPK_DATA_DIR/profiles"

# ---- Phase 4: Remote Agent ----
log_info "--- Phase 4: Remote monitoring agent ---"
if [[ -f "$SPK_SCRIPT_DIR/remote_agent.sh" ]]; then
    source "$SPK_SCRIPT_DIR/remote_agent.sh" 2>/dev/null || true
    _spk_remote_agent_run 2>/dev/null || log_debug "Remote agent returned"
fi

# ---- Phase 5: Report Generation ----
log_info "--- Phase 5: Generating report ---"
source "$SPK_SCRIPT_DIR/report_gen.sh" 2>/dev/null || { log_error "Cannot source report_gen.sh"; exit 1; }
generate_report "$METRICS_FILE" "$SPK_STATE_DIR/report.txt"

log_info "============================================"
log_info "server-perf-kit completed successfully"
log_info "Report: $SPK_STATE_DIR/report.txt"
log_info "============================================"
