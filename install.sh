#!/bin/sh
set -e

repo=${GIT_WT_REPO:-"https://raw.githubusercontent.com/khoi/git-wt/main"}

dest=""
for d in "$HOME/.local/bin" "/usr/local/bin" "/opt/homebrew/bin"; do
  if [ -d "$d" ] && [ -w "$d" ]; then
    dest="$d"
    break
  fi
done
if [ -z "$dest" ]; then
  dest=$(printf '%s' "$PATH" | tr ':' '\n' | while IFS= read -r d; do [ -d "$d" ] && [ -w "$d" ] && printf '%s\n' "$d" && break; done)
fi
if [ -z "$dest" ]; then
  dest=${XDG_BIN_HOME:-"$HOME/.local/bin"}
  mkdir -p "$dest"
fi

tmp=$(mktemp)
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$repo/wt" -o "$tmp"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$tmp" "$repo/wt"
else
  printf '%s\n' "error: curl or wget required" >&2
  exit 1
fi

mv "$tmp" "$dest/wt"
chmod +x "$dest/wt"
printf 'installed %s\n' "$dest/wt"
