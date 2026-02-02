#!/bin/bash
set -euo pipefail
source "$ROOT/tests/lib/common.sh"

setup_repo
cd "$REPO"

"$WT_BIN" switch feat --from main >/dev/null
cd "$REPO/.worktrees/feat"
echo "change" >> README.md
git add -A && git commit -m "feat: change" >/dev/null

"$WT_BIN" merge

cd "$REPO"
log_out=$(git log main --oneline)
echo "$log_out" | grep -q "feat: change" || fail "main should have feat commit"
