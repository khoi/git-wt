#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

repo=$(new_repo)
trap 'cleanup_repo "$repo"' EXIT

cd "$repo"

git checkout -b develop >/dev/null
echo "develop content" >> README.md
git add README.md
git commit -m "develop commit" >/dev/null

path=$("$WT_BIN" switch feat-from-develop)
[ -d "$path" ] || fail "worktree path missing"

content=$(cat "$path/README.md")
assert_match "develop content" "$content"
