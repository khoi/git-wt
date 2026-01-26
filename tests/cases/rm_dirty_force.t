#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
path=$("$WT_BIN" switch feat-1 --from main)

printf 'change\n' >> "$path/README.md"

run_cmd "$WT_BIN" rm feat-1 </dev/null
assert_rc 1
assert_match "workspace dirty" "$RUN_ERR"

"$WT_BIN" rm -f feat-1 >/dev/null
[ ! -d "$path" ] || fail "worktree path still exists"
