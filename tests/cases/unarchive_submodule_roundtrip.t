#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo_with_submodule
repo="$REPO"

cd "$repo"
path=$("$WT_BIN" switch feat-submodule-roundtrip --from main)
git -C "$path" -c protocol.file.allow=always submodule update --init --recursive >/dev/null
printf 'saved\n' > "$path/saved.txt"
git -C "$path" add saved.txt

"$WT_BIN" archive feat-submodule-roundtrip >/dev/null
restored=$("$WT_BIN" unarchive feat-submodule-roundtrip)
[ -d "$restored" ] || fail "restored worktree missing"

status=$(git -C "$restored" status --porcelain)
assert_match "A  saved.txt" "$status"

run_cmd git -C "$restored" -c protocol.file.allow=always submodule status
assert_rc 0
