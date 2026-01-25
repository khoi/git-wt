#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

repo=$(new_repo_with_submodule)
sub="$SUBMODULE_REPO"
trap 'cleanup_repo "$repo"; cleanup_repo "$sub"' EXIT

cd "$repo"

sub_head=$(git -C "$sub" rev-parse HEAD)

path1=$("$WT_BIN" switch feat-sub --from main)
run_cmd git -C "$path1/sub" rev-parse HEAD
assert_rc 0
assert_eq "$sub_head" "$RUN_OUT"

git -C "$repo" branch feat-exist
path2=$("$WT_BIN" switch feat-exist --path .worktrees/feat-exist)
run_cmd git -C "$path2/sub" rev-parse HEAD
assert_rc 0
assert_eq "$sub_head" "$RUN_OUT"
