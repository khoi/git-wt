#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"

run_cmd "$WT_BIN"
assert_rc 1
assert_match "Usage:" "$RUN_OUT"

run_cmd "$WT_BIN" --help
assert_rc 0
assert_match "--base-dir" "$RUN_OUT"

run_cmd "$WT_BIN" --base-dir
assert_rc 1
assert_match "missing value for --base-dir" "$RUN_ERR"

run_cmd "$WT_BIN" --nope
assert_rc 1
assert_match "unknown flag" "$RUN_ERR"

run_cmd "$WT_BIN" no-such
assert_rc 1
assert_match "unknown command" "$RUN_ERR"

run_cmd "$WT_BIN" help
assert_rc 0
assert_match "Commands:" "$RUN_OUT"

run_cmd "$WT_BIN" help switch
assert_rc 0
assert_match "wt switch" "$RUN_OUT"

run_cmd "$WT_BIN" help no-such
assert_rc 1
assert_match "unknown command" "$RUN_ERR"

run_cmd "$WT_BIN" completion
assert_rc 1
assert_match "wt completion" "$RUN_OUT"

run_cmd "$WT_BIN" completion nope
assert_rc 1
assert_match "unknown shell" "$RUN_ERR"
