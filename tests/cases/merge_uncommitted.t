#!/bin/bash
set -euo pipefail
source "$ROOT/tests/lib/common.sh"

setup_repo
cd "$REPO"

"$WT_BIN" switch feat --from main >/dev/null
cd "$REPO/.worktrees/feat"
echo "committed" >> README.md
git add -A && git commit -m "committed change" >/dev/null
echo "uncommitted" >> README.md

"$WT_BIN" merge main

git show main:README.md | grep -q "uncommitted" || fail "uncommitted changes should be merged"
