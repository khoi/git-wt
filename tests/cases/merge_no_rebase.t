#!/bin/bash
set -euo pipefail
source "$ROOT/tests/lib/common.sh"

setup_repo
cd "$REPO"

"$WT_BIN" switch feat --from main >/dev/null
cd "$REPO/.worktrees/feat"
echo "feat" >> README.md
git add -A && git commit -m "feat" >/dev/null

cd "$REPO"
echo "main change" >> other.txt
git add -A && git commit -m "main diverge" >/dev/null

cd "$REPO/.worktrees/feat"
run_cmd "$WT_BIN" merge --no-rebase main
assert_ne "$RUN_RC" "0"
assert_match "not rebased" "$RUN_ERR"
