#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"

echo "out/" > .gitignore
git add .gitignore
git commit -m "add gitignore" >/dev/null

mkdir -p out/a/b/c
echo "level0" > out/root.txt
echo "level1" > out/a/one.txt
echo "level2" > out/a/b/two.txt
echo "level3" > out/a/b/c/three.txt

path=$("$WT_BIN" switch feat-parallel-nested --from main --copy-ignored)

[ -f "$path/out/root.txt" ] || fail "out/root.txt missing"
[ -f "$path/out/a/one.txt" ] || fail "out/a/one.txt missing"
[ -f "$path/out/a/b/two.txt" ] || fail "out/a/b/two.txt missing"
[ -f "$path/out/a/b/c/three.txt" ] || fail "out/a/b/c/three.txt missing"

assert_eq "level0" "$(cat "$path/out/root.txt")"
assert_eq "level1" "$(cat "$path/out/a/one.txt")"
assert_eq "level2" "$(cat "$path/out/a/b/two.txt")"
assert_eq "level3" "$(cat "$path/out/a/b/c/three.txt")"
