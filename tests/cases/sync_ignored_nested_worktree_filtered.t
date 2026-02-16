#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"

echo ".worktrees/" > .gitignore
git add .gitignore
git commit -m "ignore worktrees dir" >/dev/null

path_a=$("$WT_BIN" switch feat-sync-nested-a --from main)
path_b=$("$WT_BIN" switch feat-sync-nested-b --from main)

cd "$path_b"
run_cmd "$WT_BIN" sync --copy-ignored --dry-run
assert_rc 0

if printf '%s\n' "$RUN_OUT" | grep -q '^\.worktrees/'; then
  fail "nested worktrees should be filtered from ignored copy set"
fi

[ -d "$path_a" ] || fail "path_a missing"
