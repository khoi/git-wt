#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
git -C "$repo" branch feat-2
path=$("$WT_BIN" switch feat-2 --path .wt/custom)
[ -d "$path" ] || fail "worktree path missing"
