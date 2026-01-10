#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

out=$("$WT_BIN" completion bash)
assert_match "command -v wt >/dev/null 2>&1 || return 0" "$out"
assert_match "complete -F _wt_complete wt" "$out"
assert_match "__wt_branches" "$out"
assert_match "open exec ls rm here base help completion" "$out"

out=$("$WT_BIN" completion zsh)
assert_match "command -v wt >/dev/null 2>&1 || return 0" "$out"
assert_match "compdef _wt wt" "$out"
assert_match "__wt_branches" "$out"
assert_match "open exec ls rm here base help completion" "$out"

out=$("$WT_BIN" completion fish)
assert_match "type -q wt; or return" "$out"
assert_match "complete -c wt -f" "$out"
assert_match "complete -c wt" "$out"
assert_match "__wt_branches" "$out"
assert_match "open exec ls rm here base help completion" "$out"
