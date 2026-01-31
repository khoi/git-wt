#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_bare_repo_with_worktree
repo="$REPO"
wt_path="$BARE_WORKTREE"
repo_real=$(cd "$repo" && pwd -P)

cd "$repo"
out=$("$WT_BIN" ls)
assert_match "(bare)" "$out"
assert_match "$wt_path" "$out"

json=$("$WT_BIN" ls --json)
assert_match "\"branch\":\"(bare)\"" "$json"
assert_match "\"path\":\"$repo_real\"" "$json"
assert_match "\"is_bare\":true" "$json"
