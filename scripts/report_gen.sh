#!/usr/bin/env bash
# report_gen.sh — Performance report generator for server-perf-kit v2.3.0

generate_report() {
    local metrics_file="${1:-$SPK_STATE_DIR/metrics.current}"
    local report_file="${2:-$SPK_STATE_DIR/report.txt}"
    local ts="$(date -Iseconds)"
    [[ -f "$metrics_file" ]] || { log_warn "No metrics file at $metrics_file"; return 1; }
    {
        echo "=========================================="
        echo " server-perf-kit v${SPK_VERSION}"
        echo " Report generated: $ts"
        echo " HW Profile: ${SPK_DETECTED_HW:-unknown}"
        echo " OS: ${SPK_OS_ID:-unknown} ${SPK_OS_VER:-unknown}"
        echo "=========================================="
        echo ""
        echo "--- CPU ---"
        grep -E '^cpu\.' "$metrics_file" 2>/dev/null | while IFS='=' read -r k v; do printf "  %-18s %s\n" "${k#cpu.}" "$v"; done
        echo ""
        echo "--- Memory ---"
        grep -E '^mem\.(total|used|free|avail|usage)' "$metrics_file" 2>/dev/null | while IFS='=' read -r k v; do printf "  %-18s %s\n" "${k#mem.}" "$v"; done
        echo ""
        echo "--- Disk ---"
        grep -E '^disk\.(dev|root)' "$metrics_file" 2>/dev/null | while IFS='=' read -r k v; do printf "  %-18s %s\n" "${k#disk.}" "$v"; done
        echo ""
        echo "--- Network ---"
        grep -E '^net\.(iface|rx_bytes|tx_bytes|tcp_)' "$metrics_file" 2>/dev/null | while IFS='=' read -r k v; do printf "  %-18s %s\n" "${k#net.}" "$v"; done
        echo ""
        echo "--- Alerts ---"
        _generate_alerts "$metrics_file"
    } > "$report_file"
    log_info "Report written to $report_file ($(wc -c < "$report_file") bytes)"
    return 0
}

_generate_alerts() {
    local mf="$1" cpu_usage mem_usage disk_usage
    cpu_usage="$(grep '^cpu\.idle=' "$mf" 2>/dev/null | head -1 | awk -F= '{print 100-$2}')"
    mem_usage="$(grep '^mem\.usage_pct=' "$mf" 2>/dev/null | head -1 | awk -F= '{print $2}')"
    disk_usage="$(grep '^disk\.root_use_pct=' "$mf" 2>/dev/null | head -1 | awk -F= '{print $2}')"
    [[ -n "$cpu_usage" && "$cpu_usage" -gt "${SPK_CPU_THRESHOLD_WARN:-80}" ]] && echo "  WARNING: CPU usage ${cpu_usage}% exceeds ${SPK_CPU_THRESHOLD_WARN:-80}%"
    [[ -n "$mem_usage" && "$mem_usage" -gt "${SPK_MEM_THRESHOLD_WARN:-85}" ]] && echo "  WARNING: Memory usage ${mem_usage}% exceeds ${SPK_MEM_THRESHOLD_WARN:-85}%"
    [[ -n "$disk_usage" && "$disk_usage" -gt "${SPK_DISK_THRESHOLD_WARN:-90}" ]] && echo "  WARNING: Disk usage ${disk_usage}% exceeds ${SPK_DISK_THRESHOLD_WARN:-90}%"
    grep -c '^cpu\.' "$mf" /dev/null 2>/dev/null | awk -F: '{print "  Total metrics: " $2}'
}
