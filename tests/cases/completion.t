#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

out=$("$WT_BIN" completion bash)
assert_match "command -v wt >/dev/null 2>&1 || return 0" "$out"
assert_match "compopt +o default +o bashdefault" "$out"
assert_match "complete -F _wt_complete wt" "$out"
assert_match "__wt_branches" "$out"
assert_match "switch sw exec ls rm here base root help completion" "$out"
assert_match "wt()" "$out"
assert_match "command wt" "$out"
assert_match 'cd "\$path"' "$out"

out=$("$WT_BIN" completion zsh)
assert_match "command -v wt >/dev/null 2>&1 || return 0" "$out"
assert_match "compdef _wt wt" "$out"
assert_match "__wt_branches" "$out"
assert_match "create or open a workspace" "$out"
assert_match "print shell completion" "$out"
assert_match "base dir override" "$out"
assert_match "tab-delimited output" "$out"
assert_match "return 0" "$out"
assert_match "wt()" "$out"
assert_match "command wt" "$out"
assert_match 'cd "\$path"' "$out"

out=$("$WT_BIN" completion fish)
assert_match "type -q wt; or return" "$out"
assert_match "complete -c wt -f" "$out"
assert_match "complete -c wt" "$out"
assert_match "__wt_branches" "$out"
assert_match "create or open a workspace" "$out"
assert_match "print shell completion" "$out"
assert_match "base dir override" "$out"
assert_match "tab-delimited output" "$out"
assert_match "function wt" "$out"
assert_match "command wt" "$out"
assert_match 'cd "\$path"' "$out"

completion_bash=$("$WT_BIN" completion bash)
completion_zsh=$("$WT_BIN" completion zsh)
completion_fish=$("$WT_BIN" completion fish)

help_flags() {
  local out
  if ! out=$("$WT_BIN" "$1" --help 2>/dev/null); then
    return 0
  fi
  printf '%s\n' "$out" | awk '
    /^Flags:/ {section=1; next}
    section && NF==0 {exit}
    section {
      for (i=1; i<=NF; i++) {
        t=$i
        gsub(/,/, "", t)
        if (t ~ /^-/) print t
      }
    }
  ' | sort -u
}

bash_flags() {
  printf '%s\n' "$completion_bash" | awk -v cmd="$1" '
    $0 ~ /case ".*cmd.*" in/ {in_case=1; next}
    in_case && $0 ~ "^[[:space:]]*[^)]*"cmd"[^)]*\\)" {section=1; next}
    section && $0 ~ /flags="/ {
      sub(/.*flags="/, "")
      sub(/".*/, "")
      print
      exit
    }
    section && $0 ~ /^[[:space:]]*;;/ {exit}
  ' | tr ' ' '\n' | awk 'NF' | sort -u
}

zsh_flags() {
  printf '%s\n' "$completion_zsh" | awk -v cmd="$1" '
    $0 ~ cmd"_flags=\\(" {
      line=$0
      sub(".*"cmd"_flags=\\(", "", line)
      sub("\\).*", "", line)
      print line
      exit
    }
  ' | tr ' ' '\n' | awk 'NF' | sort -u
}

fish_flags() {
  printf '%s\n' "$completion_fish" | awk -v cmd="$1" '
    $0 ~ "complete -c wt" && $0 ~ "__fish_seen_subcommand_from" {
      if ($0 ~ "__fish_seen_subcommand_from .*"cmd) {
        for (i=1; i<=NF; i++) {
          if ($i == "-l" && (i+1) <= NF) print "--"$(i+1)
          if ($i == "-s" && (i+1) <= NF) print "-"$(i+1)
        }
      }
    }
  ' | sort -u
}

assert_flag_in() {
  local flag="$1"
  local flags="$2"
  local where="$3"
  printf '%s\n' "$flags" | grep -qx -- "$flag" || fail "missing $flag in $where completion"
}

subcmds=$("$WT_BIN" --help | awk '
  /^Commands:/ {section=1; next}
  section && NF==0 {exit}
  section {print $1}
')

for cmd in $subcmds; do
  hf=$(help_flags "$cmd")
  [ -n "$hf" ] || continue
  comp_cmd="$cmd"
  if [ "$cmd" = "sw" ]; then
    comp_cmd="switch"
  fi
  bf=$(bash_flags "$comp_cmd")
  zf=$(zsh_flags "$comp_cmd")
  ff=$(fish_flags "$comp_cmd")
  for flag in $hf; do
    assert_flag_in "$flag" "$bf" "bash $cmd"
    assert_flag_in "$flag" "$zf" "zsh $cmd"
    assert_flag_in "$flag" "$ff" "fish $cmd"
  done
done
