#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"

echo "build/" > .gitignore
git add .gitignore
git commit -m "ignore build dir" >/dev/null

mkdir -p build/sub
echo "root" > build/root.txt
echo "nested" > build/sub/nested.txt

path=$("$WT_BIN" switch feat-sync-dir-recursive --from main)

cd "$path"
"$WT_BIN" sync --copy-ignored

[ -f "$path/build/root.txt" ] || fail "build/root.txt not copied"
[ -f "$path/build/sub/nested.txt" ] || fail "build/sub/nested.txt not copied"
assert_match "root" "$(cat "$path/build/root.txt")"
assert_match "nested" "$(cat "$path/build/sub/nested.txt")"
