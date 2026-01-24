#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

repo=$(new_repo)
alt_base=$(mktemp -d)
alt_base=$(cd "$alt_base" && pwd -P)
trap 'cleanup_repo "$repo"; rm -rf "$alt_base"' EXIT

cd "$repo"
path=$("$WT_BIN" switch feat-1 --from main)

run_cmd "$WT_BIN" rm
assert_rc 1
assert_match "missing branch" "$RUN_ERR"

run_cmd "$WT_BIN" rm feat-1 --nope
assert_rc 1
assert_match "unknown flag" "$RUN_ERR"

run_cmd "$WT_BIN" --base-dir "$alt_base" rm feat-1
assert_rc 1
assert_match "workspace not under base" "$RUN_ERR"

"$WT_BIN" rm feat-1 >/dev/null
[ ! -d "$path" ] || fail "worktree path still exists"
