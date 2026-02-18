#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
echo "payload" > untracked.txt

path=$("$WT_BIN" switch feat-verbose --from main)

cd "$path"
run_cmd "$WT_BIN" sync --copy-untracked --dry-run --verbose
assert_rc 0
assert_match "untracked.txt" "$RUN_OUT"
assert_match "untracked.txt" "$RUN_ERR"

run_cmd "$WT_BIN" sync --copy-untracked --dry-run -v
assert_rc 0
assert_match "untracked.txt" "$RUN_OUT"
assert_match "untracked.txt" "$RUN_ERR"
