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
index_ref="$archive_prefix/index"
index_ref_path=$(git -C "$repo" rev-parse --git-path "$index_ref")
mkdir -p "$(dirname "$index_ref_path")"
: > "$index_ref_path.lock"

run_cmd "$WT_BIN" unarchive feat-ref-cleanup
assert_rc 1
assert_match "failed to clear archive refs for 'feat-ref-cleanup'" "$RUN_ERR"

if [ -d "$repo/.worktrees/feat-ref-cleanup" ]; then
  fail "restored worktree leaked after archive ref cleanup failure"
fi

for ref in "$archive_prefix/meta" "$archive_prefix/index" "$archive_prefix/index-keepalive" "$archive_prefix/worktree" "$archive_prefix/head"; do
  if ! git -C "$repo" show-ref --verify --quiet "$ref"; then
    fail "archive ref missing after cleanup failure: $ref"
  fi
done

if git -C "$repo" show-ref --verify --quiet refs/heads/feat-ref-cleanup-restored; then
  fail "restored branch leaked after archive ref cleanup failure"
fi

rm -f "$index_ref_path.lock"
restored=$("$WT_BIN" unarchive feat-ref-cleanup)
[ -d "$restored" ] || fail "restored worktree missing"
[ -f "$restored/saved.txt" ] || fail "saved file missing after successful retry"
