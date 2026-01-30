#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_bare_repo_with_worktree
repo="$REPO"

cd "$repo"
run_cmd "$WT_BIN" switch feat-1 --from main --copy-all
assert_rc 1
assert_match "copy flags are not supported in bare repositories" "$RUN_ERR"
