#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

repo=$(new_repo)
trap 'cleanup_repo "$repo"' EXIT

cd "$repo"

run_cmd "$WT_BIN" rm nonexistent
assert_rc 1
assert_match "workspace not found" "$RUN_ERR"
