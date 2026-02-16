#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_bare_repo_with_worktree
repo="$REPO"
main_worktree="$BARE_WORKTREE"

echo "*.env" > "$main_worktree/.gitignore"
git -C "$main_worktree" add .gitignore
git -C "$main_worktree" commit -m "add gitignore" >/dev/null
echo "secret" > "$main_worktree/.env"
echo "payload" > "$main_worktree/untracked.txt"

cd "$repo"
path=$("$WT_BIN" switch feat-1 --from main --copy-all)
[ -f "$path/.env" ] || fail ".env not copied from primary worktree"
[ -f "$path/untracked.txt" ] || fail "untracked.txt not copied from primary worktree"
assert_match "secret" "$(cat "$path/.env")"
assert_match "payload" "$(cat "$path/untracked.txt")"
