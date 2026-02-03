#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

link_base=$(mktemp -d)
trap "cleanup_repo '$repo'; cleanup_repo '$link_base'" EXIT

cd "$repo"
path=$("$WT_BIN" switch feat-1 --from main)

printf 'payload\n' > "$repo/untracked.txt"

link_path="$link_base/worktree"
ln -s "$path" "$link_path"

if [ ! -d "$link_path" ] || ! [ "$link_path" -ef "$path" ]; then
  exit 0
fi

top=$(cd "$link_path" && git rev-parse --show-toplevel)
if [ "$top" = "$path" ]; then
  exit 0
fi

cd "$link_path"
run_cmd "$WT_BIN" sync --copy-untracked --dry-run
assert_rc 0
assert_match "untracked.txt" "$RUN_OUT"
