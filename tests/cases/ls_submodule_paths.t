#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo_with_submodule
submodule="$SUBMODULE_REPO"
submodule_real=$(cd "$submodule" && pwd -P)
module_gitdir=$(git -C "$submodule" rev-parse --git-common-dir)
module_gitdir_real=$(cd "$module_gitdir" && pwd -P)

cd "$submodule"
out_plain=$("$WT_BIN" ls --plain)
assert_match "main" "$out_plain"
assert_match "$submodule_real" "$out_plain"
assert_not_match "$module_gitdir_real" "$out_plain"

out_json=$("$WT_BIN" ls --json)
assert_match "\"branch\":\"main\"" "$out_json"
assert_match "\"path\":\"$submodule_real\"" "$out_json"
assert_match "\"is_bare\":false" "$out_json"
assert_not_match "$module_gitdir_real" "$out_json"
