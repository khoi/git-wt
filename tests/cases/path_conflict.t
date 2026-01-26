#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"

"$WT_BIN" switch feat-1 --from main --path .wt/custom >/dev/null

git branch feat-2

run_cmd "$WT_BIN" switch feat-2 --path .wt/custom
assert_rc 1
assert_match "worktree path already in use" "$RUN_ERR"
