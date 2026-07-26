#!/usr/bin/env bash
set -o pipefail
TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
SPK_HOME="$(cd "$TEST_DIR/.." && pwd)"
TESTS_PASSED=0; TESTS_FAILED=0
assert_file() { [[ -f "$1" ]] && { ((TESTS_PASSED++)); return 0; }; echo "FAIL: file not found: $1"; ((TESTS_FAILED++)); return 1; }
assert_dir()  { [[ -d "$1" ]] && { ((TESTS_PASSED++)); return 0; }; echo "FAIL: dir not found: $1";  ((TESTS_FAILED++)); return 1; }
assert_cmd()  { command -v "$1" >/dev/null 2>&1 && { ((TESTS_PASSED++)); return 0; }; echo "FAIL: cmd not found: $1"; ((TESTS_FAILED++)); return 1; }
echo "=== server-perf-kit Smoke Tests ==="
assert_dir "$SPK_HOME/config"; assert_dir "$SPK_HOME/scripts"; assert_dir "$SPK_HOME/collector"
assert_dir "$SPK_HOME/utils"; assert_dir "$SPK_HOME/data/profiles"
for f in main.sh config/kit.conf scripts/profile_loader.sh scripts/report_gen.sh scripts/remote_agent.sh collector/cpu.sh collector/mem.sh collector/disk.sh collector/net.sh utils/logger.sh utils/parser.sh utils/sysinfo.sh; do assert_file "$SPK_HOME/$f"; done
assert_cmd bash; assert_cmd awk; assert_cmd sed
PROFILE_COUNT=$(find "$SPK_HOME/data/profiles" -name "*.conf" 2>/dev/null | wc -l)
echo "  Profiles found: $PROFILE_COUNT"
(( PROFILE_COUNT >= 200 )) && { ((TESTS_PASSED++)); } || { echo "FAIL: expected >=200 profiles, got $PROFILE_COUNT"; ((TESTS_FAILED++)); }
echo "=== Results: $TESTS_PASSED passed, $TESTS_FAILED failed ==="
exit $TESTS_FAILED
