#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
"$WT_BIN" switch feat --from main >/dev/null
"$WT_BIN" archive feat >/dev/null
git -C "$repo" branch -D feat >/dev/null

path=$("$WT_BIN" switch feat/index --from main)
printf 'nested branch\n' > "$path/nested.txt"
"$WT_BIN" archive feat/index >/dev/null

out=$("$WT_BIN" ls --plain)
assert_match "feat (archived)" "$out"
assert_match "feat/index (archived)" "$out"

restored=$("$WT_BIN" unarchive feat/index)
[ -f "$restored/nested.txt" ] || fail "nested archive file missing"
