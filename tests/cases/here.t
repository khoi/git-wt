#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
path=$("$WT_BIN" switch feat-1 --from main)

cd "$path"
branch=$("$WT_BIN" here)
assert_eq "feat-1" "$branch"

cd "$repo"
if "$WT_BIN" here >/dev/null 2>&1; then
  fail "expected here to fail in main worktree"
fi
