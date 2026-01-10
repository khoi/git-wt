#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

repo=$(new_repo)
trap 'cleanup_repo "$repo"' EXIT

cd "$repo"
path=$("$WT_BIN" open feat-1 --from main)
[ -d "$path" ] || fail "worktree path missing"

git -C "$repo" show-ref --verify --quiet refs/heads/feat-1 || fail "branch missing"
