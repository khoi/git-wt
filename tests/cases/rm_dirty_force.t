#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

repo=$(new_repo)
trap 'cleanup_repo "$repo"' EXIT

cd "$repo"
path=$("$WT_BIN" switch feat-1 --from main)

printf 'change\n' >> "$path/README.md"

if "$WT_BIN" rm feat-1 </dev/null >/dev/null 2>&1; then
  fail "expected failure on dirty workspace"
fi

"$WT_BIN" rm -f feat-1 >/dev/null
[ ! -d "$path" ] || fail "worktree path still exists"
