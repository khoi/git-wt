#!/bin/bash
set -euo pipefail
source "$ROOT/tests/lib/common.sh"

setup_repo
cd "$REPO"

"$WT_BIN" switch feat --from main >/dev/null
cd "$REPO/.worktrees/feat"

run_cmd "$WT_BIN" merge nonexistent
assert_ne "$RUN_RC" "0"
assert_match "not found" "$RUN_ERR"
