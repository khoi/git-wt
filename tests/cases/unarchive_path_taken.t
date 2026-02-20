#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
path=$("$WT_BIN" switch feat-path --from main)
printf 'saved\n' > "$path/saved.txt"
"$WT_BIN" archive feat-path >/dev/null

mkdir -p "$path"

restored=$("$WT_BIN" unarchive feat-path)
assert_ne "$path" "$restored"
assert_match "${path}-restored" "$restored"
[ -d "$restored" ] || fail "restored path missing"
[ -f "$restored/saved.txt" ] || fail "saved file missing after unarchive"
