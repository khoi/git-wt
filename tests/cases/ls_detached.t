#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"

commit=$(git rev-parse HEAD)
git worktree add .worktrees/detached "$commit" --detach >/dev/null

out=$("$WT_BIN" ls --json)
assert_match '"branch":""' "$out"
repo_real=$(cd "$repo" && pwd -P)
assert_match "\"path\":\"$repo_real/.worktrees/detached\"" "$out"
assert_match "\"head\":\"$commit\"" "$out"

out_plain=$("$WT_BIN" ls --plain)
assert_match 'detached' "$out_plain"
