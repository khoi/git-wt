#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
path=$("$WT_BIN" switch feat-1 --from main)
[ -d "$path" ] || fail "worktree path missing"

git -C "$repo" show-ref --verify --quiet refs/heads/feat-1 || fail "branch missing"
