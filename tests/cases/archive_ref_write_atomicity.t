#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
path=$("$WT_BIN" switch feat-archive-atomic --from main)
printf 'saved\n' > "$path/saved.txt"
git -C "$path" add saved.txt

archive_key=$(printf 'feat-archive-atomic' | git -C "$repo" hash-object --stdin)
archive_prefix="refs/wt/archive/$archive_key"
keepalive_ref="$archive_prefix/index-keepalive"
keepalive_ref_path=$(git -C "$repo" rev-parse --git-path "$keepalive_ref")
mkdir -p "$(dirname "$keepalive_ref_path")"
: > "$keepalive_ref_path.lock"

run_cmd "$WT_BIN" archive feat-archive-atomic
assert_rc 1
assert_match "failed to write archive refs for 'feat-archive-atomic'" "$RUN_ERR"

[ -d "$path" ] || fail "workspace removed after failed archive ref write"
for ref in "$archive_prefix/meta" "$archive_prefix/index" "$archive_prefix/index-keepalive" "$archive_prefix/worktree" "$archive_prefix/head"; do
  if git -C "$repo" show-ref --verify --quiet "$ref"; then
    fail "archive ref unexpectedly created after failed archive write: $ref"
  fi
done

rm -f "$keepalive_ref_path.lock"
archived_path=$("$WT_BIN" archive feat-archive-atomic)
assert_eq "$path" "$archived_path"
[ ! -d "$path" ] || fail "workspace path still exists after successful archive"
