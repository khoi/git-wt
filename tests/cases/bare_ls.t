#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_bare_repo_with_worktree
repo="$REPO"
wt_path="$BARE_WORKTREE"

cd "$repo"
out=$("$WT_BIN" ls)
assert_match "(bare)" "$out"
assert_match "$wt_path" "$out"
