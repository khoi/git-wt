#!/bin/bash
set -euo pipefail
source "$ROOT/tests/lib/common.sh"

setup_repo
cd "$REPO"

run_cmd "$WT_BIN" merge --help
assert_eq "$RUN_RC" "0"
assert_match "no-squash" "$RUN_OUT"

run_cmd "$WT_BIN" merge --unknown
assert_ne "$RUN_RC" "0"
assert_match "unknown flag" "$RUN_ERR"
