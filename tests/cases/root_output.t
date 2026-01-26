#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"
repo_real=$(cd "$repo" && pwd -P)

cd "$repo"
root=$("$WT_BIN" root)
assert_eq "$repo_real" "$root"
