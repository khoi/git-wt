#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"

path=$("$WT_BIN" switch feat-1 --from main)

echo "modified main" >> README.md

echo "modified in worktree" >> "$path/README.md"

run_cmd "$WT_BIN" sync main feat-1 --copy-modified
assert_rc 0
assert_match "modified main" "$(cat "$path/README.md")"
