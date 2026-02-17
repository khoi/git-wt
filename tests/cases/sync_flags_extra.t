#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"

path_a=$("$WT_BIN" switch feat-a --from main)
path_b=$("$WT_BIN" switch feat-b --from main)

printf 'change\n' >> "$path_a/README.md"

run_cmd "$WT_BIN" sync feat-a --copy-modified
assert_rc 1
assert_match "missing destination branch" "$RUN_ERR"

run_cmd "$WT_BIN" sync feat-a feat-b extra --copy-modified
assert_rc 1
assert_match "unexpected argument" "$RUN_ERR"

run_cmd "$WT_BIN" sync feat-a feat-a --copy-modified
assert_rc 0

"$WT_BIN" sync feat-a feat-b --copy-modified
if printf '%s\n' "$(cat "$path_b/README.md")" | grep -q "change"; then
  fail "README.md should not be overwritten without --force"
fi

"$WT_BIN" sync feat-a feat-b --copy-modified --force
assert_match "change" "$(cat "$path_b/README.md")"
