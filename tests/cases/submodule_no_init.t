#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo_with_submodule
repo="$REPO"

cd "$repo"

git -C "$repo" submodule deinit -f sub >/dev/null
rm -rf "$repo/.git/modules/sub"
rm -rf "$repo/sub"
git -C "$repo" config protocol.file.allow never

path1=$("$WT_BIN" switch feat-sub --from main)
run_cmd git -C "$path1" submodule status
assert_rc 0
assert_match "^-" "$RUN_OUT"
[ ! -e "$path1/sub/.git" ] || fail "expected submodule to be uninitialized"

git -C "$repo" branch feat-exist
path2=$("$WT_BIN" switch feat-exist --path .worktrees/feat-exist)
run_cmd git -C "$path2" submodule status
assert_rc 0
assert_match "^-" "$RUN_OUT"
[ ! -e "$path2/sub/.git" ] || fail "expected submodule to be uninitialized"
