#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

new_repo_with_submodule >/dev/null
repo="$REPO_WITH_SUBMODULE"
sub="$SUBMODULE_REPO"
trap 'cleanup_repo "$repo"; cleanup_repo "$sub"' EXIT

cd "$repo"

rm -rf "$repo/.git/modules/sub"
git -C "$repo" config protocol.file.allow never

run_cmd "$WT_BIN" switch feat-bad --from main
assert_rc 0
[ -d "$RUN_OUT" ] || fail "worktree path missing"
