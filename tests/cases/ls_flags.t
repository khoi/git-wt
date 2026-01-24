#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

repo=$(new_repo)
trap 'cleanup_repo "$repo"' EXIT

cd "$repo"
"$WT_BIN" switch feat-1 --from main >/dev/null
"$WT_BIN" switch feat-2 --from main >/dev/null

run_cmd "$WT_BIN" ls --plain --json
assert_rc 1
assert_match "cannot use" "$RUN_ERR"

run_cmd "$WT_BIN" ls --nope
assert_rc 1
assert_match "unknown flag" "$RUN_ERR"

out_plain=$("$WT_BIN" ls --plain)
assert_match "main" "$out_plain"
assert_match "$repo" "$out_plain"
assert_match "feat-1" "$out_plain"

out_json=$("$WT_BIN" ls --json)
assert_match "\"branch\"" "$out_json"
assert_match "feat-2" "$out_json"
