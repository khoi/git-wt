#!/bin/sh
set -e

printf '%s\n' "wt: installing"
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
fi
mkdir -p "$dest"
printf '%s\n' "wt: target $dest"

local_src=""
if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  root=$(git rev-parse --show-toplevel)
  if [ -f "$root/wt" ]; then
    local_src="$root/wt"
  fi
fi

if [ -n "$local_src" ]; then
  printf '%s\n' "wt: source local"
  cp "$local_src" "$dest/wt"
else
  repo=${GIT_WT_REPO:-"https://raw.githubusercontent.com/khoi/git-wt/main"}
  tmp=$(mktemp)
  if command -v curl >/dev/null 2>&1; then
    printf '%s\n' "wt: source remote (curl)"
    curl -fsSL "$repo/wt" -o "$tmp"
  elif command -v wget >/dev/null 2>&1; then
    printf '%s\n' "wt: source remote (wget)"
    wget -qO "$tmp" "$repo/wt"
  else
    printf '%s\n' "error: curl or wget required" >&2
    exit 1
  fi
  mv "$tmp" "$dest/wt"
fi
chmod +x "$dest/wt"

install_completion() {
  shell="$1"
  target="$2"
  user_dir="$3"
  dir=""
  shift 3
  for d in "$@"; do
    if [ -d "$d" ] && [ -w "$d" ]; then
      dir="$d"
      break
    fi
  done
  if [ -z "$dir" ]; then
    dir="$user_dir"
    mkdir -p "$dir"
  fi
  "$dest/wt" completion "$shell" > "$dir/$target"
  printf '%s\n' "wt: completion $shell $dir/$target"
}

bash_user="${XDG_DATA_HOME:-"$HOME/.local/share"}/bash-completion/completions"
zsh_user="${XDG_DATA_HOME:-"$HOME/.local/share"}/zsh/site-functions"
fish_user="${XDG_CONFIG_HOME:-"$HOME/.config"}/fish/completions"
mkdir -p "$fish_user"

install_completion bash wt "$bash_user" \
  /usr/local/share/bash-completion/completions \
  /opt/homebrew/share/bash-completion/completions \
  /usr/share/bash-completion/completions \
  "$bash_user"

install_completion zsh _wt "$zsh_user" \
  /usr/local/share/zsh/site-functions \
  /opt/homebrew/share/zsh/site-functions \
  /usr/share/zsh/site-functions \
  "$zsh_user"

install_completion fish wt.fish "$fish_user" \
  "$fish_user" \
  /usr/local/share/fish/vendor_completions.d \
  /opt/homebrew/share/fish/vendor_completions.d \
  /usr/share/fish/vendor_completions.d

printf 'installed %s\n' "$dest/wt"
