#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo_with_submodule
repo="$REPO"

cd "$repo"

git -C "$repo" submodule deinit -f sub >/dev/null
rm -rf "$repo/.git/modules/sub"
rm -rf "$repo/sub"
git -C "$repo" config protocol.file.allow always

path=$(GIT_ALLOW_PROTOCOL=file "$WT_BIN" switch feat-sub --from main --init-submodules)
run_cmd git -C "$path" submodule status
assert_rc 0
case "$RUN_OUT" in
-*) fail "expected submodule to be initialized" ;;
esac
[ -e "$path/sub/.git" ] || fail "expected submodule to be initialized"
