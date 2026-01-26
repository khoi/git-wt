#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
"$WT_BIN" switch feat-1 --from main >/dev/null

run_cmd "$WT_BIN" sync nonexistent feat-1 --copy-all
assert_rc 1
assert_match "workspace not found: 'nonexistent'" "$RUN_ERR"

run_cmd "$WT_BIN" sync feat-1 nonexistent --copy-all
assert_rc 1
assert_match "workspace not found: 'nonexistent'" "$RUN_ERR"
