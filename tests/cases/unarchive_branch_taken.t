#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
path=$("$WT_BIN" switch feat-taken --from main)
printf 'saved\n' > "$path/saved.txt"
"$WT_BIN" archive feat-taken >/dev/null

taken_path="$repo/.worktrees/taken-path"
git -C "$repo" worktree add "$taken_path" feat-taken >/dev/null

restored=$("$WT_BIN" unarchive feat-taken)
restored_branch=$(git -C "$restored" symbolic-ref --short HEAD)
taken_branch=$(git -C "$taken_path" symbolic-ref --short HEAD)

assert_eq "feat-taken-restored" "$restored_branch"
assert_eq "feat-taken" "$taken_branch"
assert_ne "$taken_path" "$restored"
[ -f "$restored/saved.txt" ] || fail "saved file missing after unarchive"
