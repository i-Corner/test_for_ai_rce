#!/usr/bin/env bash
parse_meminfo() { awk "/^${1}:/{print \$2}" /proc/meminfo 2>/dev/null || echo "0"; }
parse_vmstat()  { awk "/^${1} /{print \$2}" /proc/vmstat 2>/dev/null || echo "0"; }
parse_loadavg() { awk '{print $1,$2,$3}' /proc/loadavg 2>/dev/null || echo "0 0 0"; }
parse_stat()    { awk '/^cpu /{for(i=2;i<=NF;i++)s+=$i;print s}' /proc/stat 2>/dev/null || echo "0"; }
parse_uptime()  { awk '{printf "%.0f",$1}' /proc/uptime 2>/dev/null || echo "0"; }
