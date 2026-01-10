#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

repo=$(new_repo)
trap 'cleanup_repo "$repo"' EXIT

cd "$repo"
git -C "$repo" branch feat-2
path=$("$WT_BIN" open feat-2 --path .wt/custom)
[ -d "$path" ] || fail "worktree path missing"
