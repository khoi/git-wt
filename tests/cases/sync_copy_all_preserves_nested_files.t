#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
echo "cache/" > .gitignore
mkdir -p cache/sub
echo "tracked" > cache/sub/tracked.txt
echo "ignored" > cache/sub/ignored.txt
git add .gitignore
git add -f cache/sub/tracked.txt
git commit -m "seed ignored dir with tracked child" >/dev/null

path=$("$WT_BIN" switch feat-sync-copy-all-preserve --from main)

cd "$path"
"$WT_BIN" sync --copy-all

[ -f "$path/cache/sub/tracked.txt" ] || fail "tracked child not copied"
[ -f "$path/cache/sub/ignored.txt" ] || fail "ignored child not copied"
assert_eq "tracked" "$(cat "$path/cache/sub/tracked.txt")"
assert_eq "ignored" "$(cat "$path/cache/sub/ignored.txt")"
