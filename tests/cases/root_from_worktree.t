#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

repo=$(new_repo)
repo_real=$(cd "$repo" && pwd -P)
trap 'cleanup_repo "$repo"' EXIT

cd "$repo"
path=$("$WT_BIN" switch feat-1 --from main)

cd "$path"
root=$("$WT_BIN" root)
assert_eq "$repo_real" "$root"

base=$("$WT_BIN" base)
assert_match ".worktrees" "$base"
