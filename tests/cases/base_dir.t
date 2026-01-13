#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

repo=$(new_repo)
trap 'cleanup_repo "$repo"' EXIT

cd "$repo"
path=$("$WT_BIN" switch feat-1 --from main)
assert_match ".worktrees/feat-1" "$path"
[ -d "$path" ] || fail "worktree dir not created"
[ -f "$path/README.md" ] || fail "worktree missing README.md"

base=$("$WT_BIN" base)
assert_match ".worktrees" "$base"
