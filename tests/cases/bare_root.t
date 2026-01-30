#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_bare_repo_with_worktree
repo="$REPO"
repo_real=$(cd "$repo" && pwd -P)

cd "$repo"
root=$("$WT_BIN" root)
assert_eq "$repo_real" "$root"
