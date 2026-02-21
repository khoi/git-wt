#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
hook="$repo/hook.sh"
cat > "$hook" <<'HOOK'
#!/bin/bash
set -euo pipefail
printf '%s|%s\n' "$WT_BRANCH" "$WT_PATH" >> "$WT_ROOT/.wt-hook.log"
HOOK
chmod +x "$hook"

path=$(GIT_WT_POST_SWITCH="$hook" "$WT_BIN" switch feat-hook --from main)
[ -d "$path" ] || fail "hook switch path missing"

GIT_WT_POST_SWITCH="$hook" "$WT_BIN" archive feat-hook >/dev/null
restored=$(GIT_WT_POST_SWITCH="$hook" "$WT_BIN" unarchive feat-hook)
[ -d "$restored" ] || fail "hook unarchive path missing"

log="$repo/.wt-hook.log"
[ -f "$log" ] || fail "hook log missing"
log_content=$(cat "$log")
line_count=$(printf '%s\n' "$log_content" | wc -l | tr -d ' ')
assert_eq "2" "$line_count"
assert_match "feat-hook|$path" "$log_content"
assert_match "feat-hook|$restored" "$log_content"
