#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
"$WT_BIN" switch feat-1 --from main >/dev/null
"$WT_BIN" switch feat-2 --from main >/dev/null

out=$("$WT_BIN" ls)
assert_match "feat-1" "$out"
assert_match "feat-2" "$out"

json=$("$WT_BIN" ls --json)
assert_match "\\[" "$json"
assert_match "\"branch\"" "$json"
assert_match "\"is_bare\":false" "$json"
