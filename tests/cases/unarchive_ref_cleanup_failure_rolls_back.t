#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
path=$("$WT_BIN" switch feat-ref-cleanup --from main)
printf 'saved\n' > "$path/saved.txt"
"$WT_BIN" archive feat-ref-cleanup >/dev/null

archive_key=$(printf 'feat-ref-cleanup' | git -C "$repo" hash-object --stdin)
archive_prefix="refs/wt/archive/$archive_key"
meta_ref="$archive_prefix/meta"
meta_ref_path=$(git -C "$repo" rev-parse --git-path "$meta_ref")
mkdir -p "$(dirname "$meta_ref_path")"
: > "$meta_ref_path.lock"

run_cmd "$WT_BIN" unarchive feat-ref-cleanup
assert_rc 1
assert_match "failed to clear archive refs for 'feat-ref-cleanup'" "$RUN_ERR"

if [ -d "$repo/.worktrees/feat-ref-cleanup" ]; then
  fail "restored worktree leaked after archive ref cleanup failure"
fi

if ! git -C "$repo" show-ref --verify --quiet "$meta_ref"; then
  fail "archive metadata ref missing after cleanup failure"
fi

rm -f "$meta_ref_path.lock"
restored=$("$WT_BIN" unarchive feat-ref-cleanup)
[ -d "$restored" ] || fail "restored worktree missing"
[ -f "$restored/saved.txt" ] || fail "saved file missing after successful retry"
