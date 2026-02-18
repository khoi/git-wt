#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"

echo "build/" > .gitignore
git add .gitignore
git commit -m "add gitignore" >/dev/null

mkdir -p build/sub
echo "src-a" > build/a.txt
echo "src-b" > build/sub/b.txt
echo "src-new" > build/new.txt

path=$("$WT_BIN" switch feat-parallel-skip --from main)

mkdir -p "$path/build/sub"
echo "dst-a" > "$path/build/a.txt"
echo "dst-b" > "$path/build/sub/b.txt"

cd "$path"
"$WT_BIN" sync --copy-ignored

assert_eq "dst-a" "$(cat "$path/build/a.txt")"
assert_eq "dst-b" "$(cat "$path/build/sub/b.txt")"
[ -f "$path/build/new.txt" ] || fail "new.txt should be added"
assert_eq "src-new" "$(cat "$path/build/new.txt")"
