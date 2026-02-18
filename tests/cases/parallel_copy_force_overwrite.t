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

path=$("$WT_BIN" switch feat-parallel-force --from main)

mkdir -p "$path/build/sub"
echo "dst-a" > "$path/build/a.txt"
echo "dst-b" > "$path/build/sub/b.txt"

cd "$path"
"$WT_BIN" sync --copy-ignored --force

assert_eq "src-a" "$(cat "$path/build/a.txt")"
assert_eq "src-b" "$(cat "$path/build/sub/b.txt")"
