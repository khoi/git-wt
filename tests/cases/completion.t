#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

out=$("$WT_BIN" completion bash)
assert_match "command -v wt >/dev/null 2>&1 || return 0" "$out"
assert_match "compopt +o default +o bashdefault" "$out"
assert_match "complete -F _wt_complete wt" "$out"
assert_match "__wt_branches" "$out"
assert_match "switch exec ls rm here base help completion" "$out"

out=$("$WT_BIN" completion zsh)
assert_match "command -v wt >/dev/null 2>&1 || return 0" "$out"
assert_match "compdef _wt wt" "$out"
assert_match "__wt_branches" "$out"
assert_match "create or open a workspace" "$out"
assert_match "print shell completion" "$out"
assert_match "base dir override" "$out"
assert_match "tab-delimited output" "$out"
assert_match "return 0" "$out"

out=$("$WT_BIN" completion fish)
assert_match "type -q wt; or return" "$out"
assert_match "complete -c wt -f" "$out"
assert_match "complete -c wt" "$out"
assert_match "__wt_branches" "$out"
assert_match "create or open a workspace" "$out"
assert_match "print shell completion" "$out"
assert_match "base dir override" "$out"
assert_match "tab-delimited output" "$out"
