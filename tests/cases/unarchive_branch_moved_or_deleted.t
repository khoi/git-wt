#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
moved_path=$("$WT_BIN" switch feat-moved --from main)
printf 'moved state\n' > "$moved_path/moved.txt"
"$WT_BIN" archive feat-moved >/dev/null

printf 'advance main\n' >> README.md
git add README.md
git commit -m "advance main" >/dev/null
git -C "$repo" branch -f feat-moved HEAD

restored_moved=$("$WT_BIN" unarchive feat-moved)
moved_branch=$(git -C "$restored_moved" symbolic-ref --short HEAD)
assert_eq "feat-moved-restored" "$moved_branch"
[ -f "$restored_moved/moved.txt" ] || fail "moved archive file missing"

deleted_path=$("$WT_BIN" switch feat-deleted --from main)
printf 'deleted state\n' > "$deleted_path/deleted.txt"
"$WT_BIN" archive feat-deleted >/dev/null
git -C "$repo" branch -D feat-deleted >/dev/null

restored_deleted=$("$WT_BIN" unarchive feat-deleted)
deleted_branch=$(git -C "$restored_deleted" symbolic-ref --short HEAD)
assert_eq "feat-deleted" "$deleted_branch"
[ -f "$restored_deleted/deleted.txt" ] || fail "deleted archive file missing"
