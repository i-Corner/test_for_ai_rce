#!/usr/bin/env bash
collect_disk() {
    local out="${1:-/dev/stdout}" dev reads rmerge rsectors rtime writes wmerge wsectors wtime io_in_progress io_time io_weight
    while read -r dev reads rmerge rsectors rtime writes wmerge wsectors wtime io_in_progress io_time io_weight _; do
        [[ "$dev" =~ ^(sd|vd|nvme|xvd|hd) ]] || continue
        { printf "disk.dev=%s\n" "$dev"; printf "disk.reads=%s\n" "$reads"; printf "disk.writes=%s\n" "$writes"; printf "disk.read_sectors=%s\n" "$rsectors"; printf "disk.write_sectors=%s\n" "$wsectors"; printf "disk.io_in_progress=%s\n" "$io_in_progress"; printf "disk.io_time_ms=%s\n" "$io_time"; } >> "$out"; break
    done < <(awk 'NR>2' /proc/diskstats 2>/dev/null)
    local root_used root_avail root_total root_pct
    read -r root_total root_used root_avail root_pct < <(df -k / 2>/dev/null | awk 'NR==2{print $2,$3,$4,$5}')
    { printf "disk.root_total_kb=%s\n" "${root_total:-0}"; printf "disk.root_used_kb=%s\n" "${root_used:-0}"; printf "disk.root_avail_kb=%s\n" "${root_avail:-0}"; printf "disk.root_use_pct=%s\n" "${root_pct%%%}"; } >> "$out"
}
