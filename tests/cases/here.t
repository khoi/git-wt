#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

repo=$(new_repo)
trap 'cleanup_repo "$repo"' EXIT

cd "$repo"
path=$("$WT_BIN" open feat-1 --from main)

cd "$path"
branch=$("$WT_BIN" here)
assert_eq "feat-1" "$branch"

cd "$repo"
if "$WT_BIN" here >/dev/null 2>&1; then
  fail "expected here to fail in main worktree"
fi
