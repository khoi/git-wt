#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

repo=$(new_repo)
trap 'cleanup_repo "$repo"' EXIT

cd "$repo"

commit=$(git rev-parse HEAD)
git worktree add .worktrees/detached "$commit" --detach >/dev/null

out=$("$WT_BIN" ls --json)
assert_match 'detached' "$out"

out_plain=$("$WT_BIN" ls --plain)
assert_match 'detached' "$out_plain"
