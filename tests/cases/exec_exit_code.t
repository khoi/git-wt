#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
"$WT_BIN" switch feat-1 --from main >/dev/null

run_cmd "$WT_BIN" exec feat-1 -- sh -c "exit 0"
assert_rc 0

run_cmd "$WT_BIN" exec feat-1 -- sh -c "exit 42"
assert_rc 42

run_cmd "$WT_BIN" exec feat-1 -- sh -c "echo hello && exit 7"
assert_rc 7
assert_eq "hello" "$RUN_OUT"
