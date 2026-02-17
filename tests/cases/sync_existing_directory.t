#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
echo "cache/" > .gitignore
git add .gitignore
git commit -m "ignore cache dir" >/dev/null

mkdir -p cache/sub
echo "source-keep" > cache/sub/keep.txt
echo "source-new" > cache/sub/new.txt
ln -s keep.txt cache/sub/link.txt

path=$("$WT_BIN" switch feat-sync-existing-dir --from main)

cd "$path"
mkdir -p cache/sub
echo "dest-keep" > cache/sub/keep.txt
echo "dest-only" > cache/sub/dest-only.txt
ln -s dest-only.txt cache/sub/link.txt

run_cmd "$WT_BIN" sync --copy-ignored
assert_rc 0

assert_eq "dest-keep" "$(cat "$path/cache/sub/keep.txt")"
assert_eq "dest-only.txt" "$(readlink "$path/cache/sub/link.txt")"
assert_eq "source-new" "$(cat "$path/cache/sub/new.txt")"
assert_eq "dest-only" "$(cat "$path/cache/sub/dest-only.txt")"

run_cmd "$WT_BIN" sync --copy-ignored --force
assert_rc 0

assert_eq "source-keep" "$(cat "$path/cache/sub/keep.txt")"
assert_eq "keep.txt" "$(readlink "$path/cache/sub/link.txt")"
assert_eq "source-new" "$(cat "$path/cache/sub/new.txt")"
assert_eq "dest-only" "$(cat "$path/cache/sub/dest-only.txt")"
