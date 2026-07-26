#!/usr/bin/env bash
collect_mem() {
    local out="${1:-/dev/stdout}" total free avail buffers cached swap_total swap_free
    total="$(awk '/^MemTotal:/{print $2}' /proc/meminfo 2>/dev/null || echo 0)"
    free="$(awk '/^MemFree:/{print $2}' /proc/meminfo 2>/dev/null || echo 0)"
    avail="$(awk '/^MemAvailable:/{print $2}' /proc/meminfo 2>/dev/null || echo 0)"
    buffers="$(awk '/^Buffers:/{print $2}' /proc/meminfo 2>/dev/null || echo 0)"
    cached="$(awk '/^Cached:/{print $2}' /proc/meminfo 2>/dev/null || echo 0)"
    swap_total="$(awk '/^SwapTotal:/{print $2}' /proc/meminfo 2>/dev/null || echo 0)"
    swap_free="$(awk '/^SwapFree:/{print $2}' /proc/meminfo 2>/dev/null || echo 0)"
    local used=$(( total - free - buffers - cached )); [[ $total -eq 0 ]] && total=1
    { printf "mem.total_kb=%d\n" "$total"; printf "mem.used_kb=%d\n" "$used"; printf "mem.free_kb=%d\n" "$free"; printf "mem.avail_kb=%d\n" "$avail"; printf "mem.buffers_kb=%d\n" "$buffers"; printf "mem.cached_kb=%d\n" "$cached"; printf "mem.usage_pct=%d\n" "$(( (total - avail) * 100 / total ))"; printf "mem.swap_total_kb=%d\n" "$swap_total"; printf "mem.swap_free_kb=%d\n" "$swap_free"; } >> "$out"
}
