#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
path=$("$WT_BIN" switch feat-locked --from main)
printf 'saved\n' > "$path/saved.txt"
git -C "$path" add saved.txt

archive_key=$(printf 'feat-locked' | git -C "$repo" hash-object --stdin)
archive_prefix="refs/wt/archive/$archive_key"

git -C "$repo" worktree lock "$path"

run_cmd "$WT_BIN" archive feat-locked
assert_rc 1
assert_match "failed to remove workspace for archive" "$RUN_ERR"

[ -d "$path" ] || fail "locked worktree path missing"

if ! git -C "$repo" show-ref --verify --quiet "$archive_prefix/meta"; then
  fail "archive metadata ref missing after failed archive"
fi
if ! git -C "$repo" show-ref --verify --quiet "$archive_prefix/index"; then
  fail "archive index ref missing after failed archive"
fi
if ! git -C "$repo" show-ref --verify --quiet "$archive_prefix/index-keepalive"; then
  fail "archive index keepalive ref missing after failed archive"
fi
if ! git -C "$repo" show-ref --verify --quiet "$archive_prefix/worktree"; then
  fail "archive worktree ref missing after failed archive"
fi
if ! git -C "$repo" show-ref --verify --quiet "$archive_prefix/head"; then
  fail "archive head ref missing after failed archive"
fi
