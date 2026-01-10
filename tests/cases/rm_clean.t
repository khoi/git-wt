#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

repo=$(new_repo)
trap 'cleanup_repo "$repo"' EXIT

cd "$repo"
path=$("$WT_BIN" switch feat-1 --from main)
"$WT_BIN" rm feat-1 >/dev/null
[ ! -d "$path" ] || fail "worktree path still exists"
if git -C "$repo" show-ref --verify --quiet refs/heads/feat-1; then
  fail "branch still exists"
fi
