#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
path=$("$WT_BIN" switch feat-gc --from main)
printf 'gc restore\n' > "$path/gc.txt"
git -C "$path" add gc.txt
git -C "$path" commit -m "gc fixture" >/dev/null
archived_head=$(git -C "$path" rev-parse HEAD)

"$WT_BIN" archive feat-gc >/dev/null
git -C "$repo" branch -D feat-gc >/dev/null
git -C "$repo" reflog expire --expire=now --all >/dev/null
git -C "$repo" gc --prune=now >/dev/null

restored=$("$WT_BIN" unarchive feat-gc)
[ -d "$restored" ] || fail "restored worktree missing"
restored_head=$(git -C "$restored" rev-parse HEAD)
assert_eq "$archived_head" "$restored_head"
