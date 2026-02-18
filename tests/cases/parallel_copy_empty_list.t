#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"

run_cmd "$WT_BIN" switch feat-parallel-empty --from main --copy-ignored
assert_rc 0

path="$RUN_OUT"
[ -d "$path" ] || fail "worktree not created"
[ -f "$path/README.md" ] || fail "README.md missing in worktree"
