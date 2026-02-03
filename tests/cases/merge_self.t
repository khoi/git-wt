#!/bin/bash
set -euo pipefail
source "$ROOT/tests/lib/common.sh"

setup_repo
cd "$REPO"

run_cmd "$WT_BIN" merge main
assert_ne "$RUN_RC" "0"
assert_match "cannot merge branch into itself" "$RUN_ERR"
