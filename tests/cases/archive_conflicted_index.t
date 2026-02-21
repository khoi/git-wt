#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
printf 'base\n' > conflict.txt
git add conflict.txt
git commit -m "add conflict fixture" >/dev/null

path=$("$WT_BIN" switch feat-conflict-index --from main)

printf 'main change\n' > conflict.txt
git add conflict.txt
git commit -m "main conflict change" >/dev/null

printf 'feature change\n' > "$path/conflict.txt"
git -C "$path" add conflict.txt
git -C "$path" commit -m "feature conflict change" >/dev/null

set +e
git -C "$path" merge --no-ff main >/dev/null 2>&1
merge_rc=$?
set -e
[ "$merge_rc" -ne 0 ] || fail "expected merge conflict"

status_before=$(git -C "$path" status --porcelain)
assert_match "UU conflict.txt" "$status_before"

index_before=$(git -C "$path" ls-files -u)
[ -n "$index_before" ] || fail "expected conflicted index entries before archive"

"$WT_BIN" archive feat-conflict-index >/dev/null
restored=$("$WT_BIN" unarchive feat-conflict-index)

status_after=$(git -C "$restored" status --porcelain)
assert_match "UU conflict.txt" "$status_after"

index_after=$(git -C "$restored" ls-files -u)
[ -n "$index_after" ] || fail "expected conflicted index entries after unarchive"
assert_eq "$index_before" "$index_after"

conflict_file=$(cat "$restored/conflict.txt")
assert_match "<<<<<<<" "$conflict_file"
