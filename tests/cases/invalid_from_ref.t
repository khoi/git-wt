#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

repo=$(new_repo)
trap 'cleanup_repo "$repo"' EXIT

cd "$repo"

run_cmd "$WT_BIN" switch feat-1 --from nonexistent-ref
assert_rc 1
assert_match "invalid --from ref" "$RUN_ERR"

run_cmd "$WT_BIN" exec feat-2 --from nonexistent-ref -- pwd
assert_rc 1
assert_match "invalid --from ref" "$RUN_ERR"
