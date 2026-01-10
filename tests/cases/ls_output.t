#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

repo=$(new_repo)
trap 'cleanup_repo "$repo"' EXIT

cd "$repo"
"$WT_BIN" open feat-1 --from main >/dev/null
"$WT_BIN" open feat-2 --from main >/dev/null

out=$("$WT_BIN" ls)
assert_match "feat-1" "$out"
assert_match "feat-2" "$out"

json=$("$WT_BIN" ls --json)
assert_match "\\[" "$json"
assert_match "\"branch\"" "$json"
