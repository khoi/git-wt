#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

dir=$(mktemp -d)
trap 'rm -rf "$dir"' EXIT

cd "$dir"

run_cmd "$WT_BIN" switch feat-1 --from main
assert_rc 1
assert_match "not a git repository" "$RUN_ERR"

run_cmd "$WT_BIN" ls
assert_rc 1
assert_match "not a git repository" "$RUN_ERR"

run_cmd "$WT_BIN" here
assert_rc 1
assert_match "not a git repository" "$RUN_ERR"

run_cmd "$WT_BIN" base
assert_rc 1
assert_match "not a git repository" "$RUN_ERR"

run_cmd "$WT_BIN" root
assert_rc 1
assert_match "not a git repository" "$RUN_ERR"

run_cmd "$WT_BIN" rm feat-1
assert_rc 1
assert_match "not a git repository" "$RUN_ERR"

run_cmd "$WT_BIN" sync --copy-all
assert_rc 1
assert_match "not a git repository" "$RUN_ERR"
