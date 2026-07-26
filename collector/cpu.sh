#!/usr/bin/env bash
collect_cpu() {
    local out="${1:-/dev/stdout}" idle iowait system user steal softirq
    read -r user nice system idle iowait irq softirq steal _ < <(awk '/^cpu /{print $2,$3,$4,$5,$6,$7,$8,$9}' /proc/stat 2>/dev/null)
    local total=$(( ${user:-0} + ${nice:-0} + ${system:-0} + ${idle:-0} + ${iowait:-0} + ${irq:-0} + ${softirq:-0} + ${steal:-0} ))
    [[ $total -eq 0 ]] && total=1
    { printf "cpu.user=%d\n" "$(( ${user:-0} * 100 / total ))"; printf "cpu.system=%d\n" "$(( ${system:-0} * 100 / total ))"; printf "cpu.iowait=%d\n" "$(( ${iowait:-0} * 100 / total ))"; printf "cpu.steal=%d\n" "$(( ${steal:-0} * 100 / total ))"; printf "cpu.softirq=%d\n" "$(( ${softirq:-0} * 100 / total ))"; printf "cpu.idle=%d\n" "$(( ${idle:-0} * 100 / total ))"; printf "cpu.cores=%s\n" "$(nproc 2>/dev/null || echo 1)"; } >> "$out"
}
