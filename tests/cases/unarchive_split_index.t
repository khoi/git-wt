#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
path=$("$WT_BIN" switch feat-split-index --from main)
git -C "$path" config core.splitIndex true
git -C "$path" update-index --split-index
printf 'staged-line\n' >> "$path/README.md"
git -C "$path" add README.md
printf 'unstaged-line\n' >> "$path/README.md"

"$WT_BIN" archive feat-split-index >/dev/null
git -C "$repo" branch -D feat-split-index >/dev/null

restored=$("$WT_BIN" unarchive feat-split-index)
[ -d "$restored" ] || fail "restored worktree missing"

status=$(git -C "$restored" status --porcelain)
assert_match "MM README.md" "$status"

run_cmd git -C "$restored" diff --cached -- README.md
assert_rc 0
assert_match "staged-line" "$RUN_OUT"
