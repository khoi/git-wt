#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
path=$("$WT_BIN" switch feat-path-override --from main)
printf 'saved\n' > "$path/saved.txt"
"$WT_BIN" archive feat-path-override >/dev/null

mkdir -p "$repo/custom"
expected_path="$(cd "$repo" && pwd -P)/custom"

run_cmd "$WT_BIN" unarchive feat-path-override --path custom
assert_rc 1
assert_match "worktree path already in use: '$expected_path'" "$RUN_ERR"

if git -C "$repo" show-ref --verify --quiet refs/heads/feat-path-override-restored; then
  fail "restored branch should not be created on path conflict"
fi

archive_key=$(printf 'feat-path-override' | git -C "$repo" hash-object --stdin)
archive_prefix="refs/wt/archive/$archive_key"
if ! git -C "$repo" show-ref --verify --quiet "$archive_prefix/meta"; then
  fail "archive metadata ref missing after failed unarchive"
fi
