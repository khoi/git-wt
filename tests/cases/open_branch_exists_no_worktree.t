#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
git -C "$repo" branch feat-2

if "$WT_BIN" switch feat-2 >/dev/null 2>&1; then
  fail "expected failure when branch exists without worktree"
fi
