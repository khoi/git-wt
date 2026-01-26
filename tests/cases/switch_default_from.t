#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"

git checkout -b develop >/dev/null
echo "develop content" >> README.md
git add README.md
git commit -m "develop commit" >/dev/null

path=$("$WT_BIN" switch feat-from-develop)
[ -d "$path" ] || fail "worktree path missing"

content=$(cat "$path/README.md")
assert_match "develop content" "$content"
