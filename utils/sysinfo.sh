#!/usr/bin/env bash
detect_hw_profile() {
    local cores mem vendor
    cores="$(nproc 2>/dev/null || echo 1)"
    mem="$(awk '/MemTotal/{printf "%d", $2/1024}' /proc/meminfo 2>/dev/null || echo 0)"
    if grep -qi "intel" /proc/cpuinfo 2>/dev/null; then vendor="intel"
    elif grep -qi "amd" /proc/cpuinfo 2>/dev/null; then vendor="amd"
    elif grep -qi "arm" /proc/cpuinfo 2>/dev/null; then vendor="arm"
    else vendor="generic"; fi
    if [[ $cores -ge 64 && $mem -ge 256000 ]]; then SPK_DETECTED_HW="${vendor}-el"
    elif [[ $cores -ge 32 && $mem -ge 128000 ]]; then SPK_DETECTED_HW="${vendor}-dm"
    elif [[ $cores -ge 16 && $mem -ge 64000 ]]; then SPK_DETECTED_HW="${vendor}-ch"
    elif [[ $cores -ge 8 && $mem -ge 32000 ]]; then SPK_DETECTED_HW="${vendor}-sm"
    elif [[ $cores -ge 4 && $mem -ge 16000 ]]; then SPK_DETECTED_HW="${vendor}-gl"
    else SPK_DETECTED_HW="${vendor}-xs"; fi
    export SPK_DETECTED_HW
}
detect_os_info() {
    if [[ -f /etc/os-release ]]; then source /etc/os-release 2>/dev/null || true; SPK_OS_ID="${ID:-unknown}"; SPK_OS_VER="${VERSION_ID:-unknown}"
    elif [[ -f /etc/redhat-release ]]; then SPK_OS_ID="rhel"; SPK_OS_VER="$(grep -oP '\d+' /etc/redhat-release | head -1)"
    else SPK_OS_ID="unknown"; SPK_OS_VER="unknown"; fi
    export SPK_OS_ID SPK_OS_VER
}
