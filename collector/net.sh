#!/usr/bin/env bash
collect_net() {
    local out="${1:-/dev/stdout}" iface rx_bytes rx_packets tx_bytes tx_packets rx_errs tx_errs rx_drop tx_drop
    while read -r iface rx_bytes rx_packets rx_errs rx_drop _ _ _ tx_bytes tx_packets tx_errs tx_drop _; do
        [[ "$iface" == "lo:" || "$iface" == "lo" ]] && continue
        [[ "$iface" =~ ^(eth|ens|enp|wlan|bond|br|tun|tap|veth|docker) ]] || continue
        { printf "net.iface=%s\n" "${iface%:}"; printf "net.rx_bytes=%s\n" "$rx_bytes"; printf "net.tx_bytes=%s\n" "$tx_bytes"; printf "net.rx_packets=%s\n" "$rx_packets"; printf "net.tx_packets=%s\n" "$tx_packets"; printf "net.rx_errors=%s\n" "$rx_errs"; printf "net.tx_errors=%s\n" "$tx_errs"; printf "net.rx_dropped=%s\n" "$rx_drop"; printf "net.tx_dropped=%s\n" "$tx_drop"; } >> "$out"; break
    done < /proc/net/dev 2>/dev/null
    { printf "net.tcp_established=%d\n" "$(ss -t state established 2>/dev/null | wc -l)"; printf "net.tcp_timewait=%d\n" "$(ss -t state time-wait 2>/dev/null | wc -l)"; printf "net.tcp_listen=%d\n" "$(ss -tln 2>/dev/null | wc -l)"; } >> "$out"
}
