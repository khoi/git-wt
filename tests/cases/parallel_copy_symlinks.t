#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"

echo "payload" > target.txt
echo "*.lnk" >> .gitignore
git add .gitignore
git commit -m "add gitignore" >/dev/null

ln -s target.txt valid.lnk
ln -s nonexistent.txt dangling.lnk

path=$("$WT_BIN" switch feat-parallel-sym --from main --copy-ignored --copy-untracked)

[ -L "$path/valid.lnk" ] || fail "valid.lnk should be symlink"
assert_eq "target.txt" "$(readlink "$path/valid.lnk")"

[ -L "$path/dangling.lnk" ] || fail "dangling.lnk should be symlink"
assert_eq "nonexistent.txt" "$(readlink "$path/dangling.lnk")"

[ -f "$path/target.txt" ] || fail "target.txt should be copied as untracked"
assert_eq "payload" "$(cat "$path/target.txt")"
