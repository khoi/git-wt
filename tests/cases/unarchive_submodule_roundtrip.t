#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo_with_submodule
repo="$REPO"

cd "$repo"
path=$("$WT_BIN" switch feat-submodule-roundtrip --from main)
run_cmd "$WT_BIN" archive feat-submodule-roundtrip
assert_rc 1
assert_match "submodules are not supported by archive/unarchive" "$RUN_ERR"

[ -d "$path" ] || fail "worktree path missing after failed archive"

archive_key=$(printf 'feat-submodule-roundtrip' | git -C "$repo" hash-object --stdin)
archive_prefix="refs/wt/archive/$archive_key"
if git -C "$repo" show-ref --verify --quiet "$archive_prefix/meta"; then
  fail "archive metadata ref should not exist when submodules are unsupported"
fi
