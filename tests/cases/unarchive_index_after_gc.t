#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
path=$("$WT_BIN" switch feat-index-gc --from main)
printf 'staged-only-line\n' >> "$path/README.md"
git -C "$path" add README.md
printf 'unstaged-line\n' >> "$path/README.md"

"$WT_BIN" archive feat-index-gc >/dev/null
git -C "$repo" branch -D feat-index-gc >/dev/null
git -C "$repo" reflog expire --expire=now --all >/dev/null
git -C "$repo" gc --prune=now >/dev/null

restored=$("$WT_BIN" unarchive feat-index-gc)
[ -d "$restored" ] || fail "restored worktree missing"

status=$(git -C "$restored" status --porcelain)
assert_match "MM README.md" "$status"

run_cmd git -C "$restored" diff --cached -- README.md
assert_rc 0
assert_match "staged-only-line" "$RUN_OUT"
