#!/usr/bin/env bash
# profile_loader.sh — Kernel tuning profile loader for server-perf-kit v2.3.0

load_all_profiles() {
    local profile_dir="${1:-$SPK_DATA_DIR/profiles}"
    local loaded=0 skipped=0
    log_info "Scanning profile directory: $profile_dir"
    [[ ! -d "$profile_dir" ]] && { log_warn "Profile directory not found: $profile_dir"; return 1; }
    for pf in "$profile_dir"/*.conf; do
        [[ -f "$pf" ]] || continue
        if _apply_profile "$pf"; then ((loaded++)); else ((skipped++)); fi
    done
    log_info "Profiles: $loaded loaded, $skipped skipped"
}

_apply_profile() {
    local pf="$1"
    while IFS='=' read -r key val || [[ -n "$key" ]]; do
        [[ -z "$key" ]] && continue
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        key="${key## }"; key="${key%% }"; val="${val## }"; val="${val%% }"
        [[ -z "$key" ]] && continue
        case "$key" in vm.*|kernel.*|fs.*|net.*|user.*) _sysctl_apply "$key" "$val" ;; esac
    done < "$pf"
    return 0
}

_sysctl_apply() {
    local key="$1" val="$2" sys_path
    sys_path="/proc/sys/${key//./\/}"
    [[ -w "$sys_path" ]] && echo "$val" > "$sys_path" 2>/dev/null && return 0
    return 1
}
