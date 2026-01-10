#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

repo=$(new_repo)
trap 'cleanup_repo "$repo"' EXIT

cd "$repo"
git -C "$repo" branch feat-2

if "$WT_BIN" open feat-2 >/dev/null 2>&1; then
  fail "expected failure when branch exists without worktree"
fi
