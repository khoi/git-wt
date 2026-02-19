#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo_with_submodule
submodule="$SUBMODULE_REPO"
submodule_real=$(cd "$submodule" && pwd -P)
module_gitdir=$(git -C "$submodule" rev-parse --git-common-dir)
module_gitdir_real=$(cd "$module_gitdir" && pwd -P)

cd "$submodule"
root=$("$WT_BIN" root)

assert_eq "$submodule_real" "$root"
assert_ne "$module_gitdir_real" "$root"
