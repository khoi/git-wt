#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
path=$("$WT_BIN" switch feat-mkdir-fail --from main)
printf 'saved\n' > "$path/saved.txt"
"$WT_BIN" archive feat-mkdir-fail >/dev/null
git -C "$repo" branch -D feat-mkdir-fail >/dev/null

printf 'blocker\n' > "$repo/blocked"

run_cmd "$WT_BIN" unarchive feat-mkdir-fail --path blocked/worktree
assert_rc 1
assert_match "failed to prepare workspace path for 'feat-mkdir-fail'" "$RUN_ERR"

if git -C "$repo" show-ref --verify --quiet refs/heads/feat-mkdir-fail; then
  fail "branch leaked after unarchive mkdir failure"
fi

archive_key=$(printf 'feat-mkdir-fail' | git -C "$repo" hash-object --stdin)
archive_prefix="refs/wt/archive/$archive_key"
if ! git -C "$repo" show-ref --verify --quiet "$archive_prefix/meta"; then
  fail "archive metadata ref missing after unarchive failure"
fi
