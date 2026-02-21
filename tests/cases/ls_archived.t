#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
archived_path=$("$WT_BIN" switch feat-archived --from main)
"$WT_BIN" switch feat-live --from main >/dev/null
"$WT_BIN" archive feat-archived >/dev/null

out=$("$WT_BIN" ls)
assert_match "feat-archived (archived)" "$out"
assert_match "$archived_path" "$out"
assert_match "feat-live" "$out"

plain=$("$WT_BIN" ls --plain)
assert_match "feat-archived (archived)" "$plain"
assert_match "$archived_path" "$plain"

json=$("$WT_BIN" ls --json)
assert_match "\"branch\":\"feat-archived\"" "$json"
assert_match "\"path\":\"$archived_path\"" "$json"
assert_match "\"is_archived\":true" "$json"
assert_match "\"is_archived\":false" "$json"
