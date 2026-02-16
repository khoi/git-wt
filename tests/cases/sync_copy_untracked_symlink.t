#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
echo "payload" > target.txt
ln -s target.txt link.txt

path=$("$WT_BIN" switch feat-sync-symlink --from main)

cd "$path"
"$WT_BIN" sync --copy-untracked

[ -L "$path/link.txt" ] || fail "link.txt should be symlink"
assert_eq "target.txt" "$(readlink "$path/link.txt")"
[ -f "$path/target.txt" ] || fail "target.txt missing"
assert_match "payload" "$(cat "$path/target.txt")"
