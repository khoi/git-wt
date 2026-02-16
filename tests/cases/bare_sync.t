#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_bare_repo_with_worktree
repo="$REPO"

cd "$repo"
run_cmd "$WT_BIN" sync --copy-all
assert_rc 0
