#!/bin/bash
set -euo pipefail
source "$ROOT/tests/lib/common.sh"

setup_repo
cd "$REPO"

"$WT_BIN" switch feat --from main >/dev/null
cd "$REPO/.worktrees/feat"
echo "change1" >> README.md
git add -A && git commit -m "feat: change 1" >/dev/null
echo "change2" >> README.md
git add -A && git commit -m "feat: change 2" >/dev/null

"$WT_BIN" merge main

cd "$REPO"
commit_count=$(git rev-list --count HEAD)
assert_eq "$commit_count" "2"

[ -d "$REPO/.worktrees/feat" ] || fail "worktree should still exist"
