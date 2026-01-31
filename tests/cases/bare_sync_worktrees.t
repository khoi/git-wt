#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_bare_repo_with_worktree
repo="$REPO"
main_worktree="$BARE_WORKTREE"
other_worktree=$(mktemp -d)
git -C "$repo" worktree add -b feat-sync "$other_worktree" main >/dev/null
trap "cleanup_repo '$other_worktree'; cleanup_repo '$BARE_WORKTREE'; cleanup_repo '$BARE_REPO'; cleanup_repo '$BARE_SOURCE_REPO'" EXIT

echo "payload" > "$main_worktree/untracked.txt"

cd "$repo"
"$WT_BIN" sync main feat-sync --copy-untracked

[ -f "$other_worktree/untracked.txt" ] || fail "untracked.txt not copied"
assert_match "payload" "$(cat "$other_worktree/untracked.txt")"
