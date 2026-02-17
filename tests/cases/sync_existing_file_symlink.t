#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
echo "source-file" > conflict.txt
echo "source-target" > src-target.txt
ln -s src-target.txt link.txt

path=$("$WT_BIN" switch feat-sync-existing-file-symlink --from main)

cd "$path"
echo "dest-file" > conflict.txt
echo "dest-target" > dest-target.txt
ln -s dest-target.txt link.txt

run_cmd "$WT_BIN" sync --copy-untracked
assert_rc 0

[ -f "$path/src-target.txt" ] || fail "src-target.txt not copied"
assert_eq "dest-file" "$(cat "$path/conflict.txt")"
assert_eq "dest-target.txt" "$(readlink "$path/link.txt")"

run_cmd "$WT_BIN" sync --copy-untracked --force
assert_rc 0

assert_eq "source-file" "$(cat "$path/conflict.txt")"
assert_eq "src-target.txt" "$(readlink "$path/link.txt")"
