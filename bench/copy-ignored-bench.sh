#!/bin/bash
set -euo pipefail

die() {
  printf 'error: %s\n' "$1" >&2
  exit 1
}

usage() {
  cat <<'USAGE'
bench/copy-ignored-bench.sh <source-repo> [--runs N] [--purge]

Benchmark copy strategies for gitignored files.

Flags:
  --runs N    runs per strategy (default 3)
  --purge     sudo purge between strategies to flush disk cache
USAGE
}

# --- inlined from wt ---

list_ignored_files() {
  local root="$1"
  git -C "$root" ls-files --others --ignored --exclude-standard --directory | sed '/^\.git\//d'
}

prune_nested_copy_paths() {
  local files="$1"
  local out="" dirs="" file file_trim dir skip
  while IFS= read -r file; do
    [ -n "$file" ] || continue
    file_trim="${file%/}"
    skip=0
    while IFS= read -r dir; do
      [ -n "$dir" ] || continue
      case "$file_trim" in
      "$dir"/*)
        skip=1
        break
        ;;
      esac
    done <<< "$dirs"
    [ "$skip" -eq 1 ] && continue
    out+="$file"$'\n'
    if [ "$file" != "$file_trim" ]; then
      dirs+="$file_trim"$'\n'
    fi
  done <<< "$files"
  printf '%s' "$out"
}

# --- timing ---

now_ms() {
  perl -MTime::HiRes=gettimeofday -e '
    my ($s, $us) = gettimeofday();
    printf "%d\n", $s * 1000 + int($us / 1000);
  '
}

elapsed_ms() {
  local start="$1" end="$2"
  echo $(( end - start ))
}

# --- file counting ---

count_files() {
  local dir="$1"
  find "$dir" -not -type d 2>/dev/null | wc -l | tr -d ' '
}

# --- strategies ---

strategy_bash_loop() {
  local src="$1" dst="$2" list="$3"
  while IFS= read -r entry; do
    [ -n "$entry" ] || continue
    local entry_trim="${entry%/}"
    local srcpath="$src/$entry_trim"
    local dstpath="$dst/$entry_trim"
    if [ -d "$srcpath" ]; then
      mkdir -p "$(dirname "$dstpath")"
      cp -cRP "$srcpath" "$(dirname "$dstpath")" 2>/dev/null || cp -RP "$srcpath" "$(dirname "$dstpath")" 2>/dev/null || true
    elif [ -f "$srcpath" ] || [ -L "$srcpath" ]; then
      mkdir -p "$(dirname "$dstpath")"
      cp -c "$srcpath" "$dstpath" 2>/dev/null || cp "$srcpath" "$dstpath" 2>/dev/null || true
    fi
  done < "$list"
}

strategy_xargs_cp() {
  local src="$1" dst="$2" list="$3" jobs="$4"
  while IFS= read -r entry; do
    [ -n "$entry" ] || continue
    local entry_trim="${entry%/}"
    mkdir -p "$dst/$(dirname "$entry_trim")"
  done < "$list"
  xargs -I{} -P "$jobs" bash -c '
    entry="$1"; src="$2"; dst="$3"
    entry_trim="${entry%/}"
    srcpath="$src/$entry_trim"
    dstpath="$dst/$entry_trim"
    if [ -d "$srcpath" ]; then
      cp -cRP "$srcpath" "$(dirname "$dstpath")" 2>/dev/null || cp -RP "$srcpath" "$(dirname "$dstpath")" 2>/dev/null || true
    elif [ -f "$srcpath" ] || [ -L "$srcpath" ]; then
      cp -c "$srcpath" "$dstpath" 2>/dev/null || cp "$srcpath" "$dstpath" 2>/dev/null || true
    fi
  ' _ {} "$src" "$dst" < "$list"
}

strategy_ditto_loop() {
  local src="$1" dst="$2" list="$3"
  while IFS= read -r entry; do
    [ -n "$entry" ] || continue
    local entry_trim="${entry%/}"
    local srcpath="$src/$entry_trim"
    local dstpath="$dst/$entry_trim"
    [ -e "$srcpath" ] || [ -L "$srcpath" ] || continue
    mkdir -p "$(dirname "$dstpath")"
    ditto --clone "$srcpath" "$dstpath" 2>/dev/null || ditto "$srcpath" "$dstpath" 2>/dev/null || true
  done < "$list"
}

strategy_ditto_xargs() {
  local src="$1" dst="$2" list="$3" jobs="$4"
  while IFS= read -r entry; do
    [ -n "$entry" ] || continue
    local entry_trim="${entry%/}"
    mkdir -p "$dst/$(dirname "$entry_trim")"
  done < "$list"
  xargs -I{} -P "$jobs" bash -c '
    entry="$1"; src="$2"; dst="$3"
    entry_trim="${entry%/}"
    srcpath="$src/$entry_trim"
    dstpath="$dst/$entry_trim"
    [ -e "$srcpath" ] || [ -L "$srcpath" ] || exit 0
    ditto --clone "$srcpath" "$dstpath" 2>/dev/null || ditto "$srcpath" "$dstpath" 2>/dev/null || true
  ' _ {} "$src" "$dst" < "$list"
}

strategy_tar_pipe() {
  local src="$1" dst="$2" list="$3"
  local tarlist
  tarlist=$(mktemp)
  while IFS= read -r entry; do
    [ -n "$entry" ] || continue
    printf '%s\n' "${entry%/}"
  done < "$list" > "$tarlist"
  mkdir -p "$dst"
  tar cf - -C "$src" -T "$tarlist" 2>/dev/null | tar xf - -C "$dst" 2>/dev/null || true
  rm -f "$tarlist"
}

strategy_rsync() {
  local src="$1" dst="$2" list="$3"
  local rsynclist
  rsynclist=$(mktemp)
  while IFS= read -r entry; do
    [ -n "$entry" ] || continue
    printf '%s\n' "${entry%/}"
  done < "$list" > "$rsynclist"
  mkdir -p "$dst"
  rsync -a --files-from="$rsynclist" "$src/" "$dst/" 2>/dev/null || true
  rm -f "$rsynclist"
}

# --- main ---

SRC=""
RUNS=3
PURGE=0

while [ "$#" -gt 0 ]; do
  case "$1" in
  -h | --help) usage; exit 0 ;;
  --runs)
    [ -n "${2:-}" ] || die "missing value for --runs"
    RUNS="$2"
    shift
    ;;
  --runs=*) RUNS="${1#--runs=}" ;;
  --purge) PURGE=1 ;;
  --*) die "unknown flag '$1'" ;;
  *)
    [ -z "$SRC" ] || die "unexpected argument '$1'"
    SRC="$1"
    ;;
  esac
  shift
done

[ -n "$SRC" ] || die "missing source repo path"
[ -d "$SRC/.git" ] || [ -f "$SRC/.git" ] || die "not a git repository: $SRC"

SRC=$(cd "$SRC" && pwd -P)

CPUS=$(sysctl -n hw.logicalcpu 2>/dev/null || nproc 2>/dev/null || echo 8)

printf 'copy-ignored benchmark\n'
printf '======================\n'
printf 'Source:     %s\n' "$SRC"

raw_files=$(list_ignored_files "$SRC")
sorted=$(printf '%s' "$raw_files" | sed '/^$/d' | LC_ALL=C sort -u)
pruned=$(prune_nested_copy_paths "$sorted")

LISTFILE=$(mktemp)
printf '%s' "$pruned" | sed '/^$/d' > "$LISTFILE"

TOTAL=$(wc -l < "$LISTFILE" | tr -d ' ')
NDIRS=$(grep -c '/$' "$LISTFILE" || true)
NFILES=$(( TOTAL - NDIRS ))

printf 'Entries:    %s (%s dirs, %s files)\n' "$TOTAL" "$NDIRS" "$NFILES"
printf 'CPUs:       %s\n' "$CPUS"
printf 'Runs:       %s\n' "$RUNS"
printf '\n'

TMPBASE=$(mktemp -d)
src_dev=$(stat -f '%d' "$SRC")
tmp_dev=$(stat -f '%d' "$TMPBASE")
if [ "$src_dev" != "$tmp_dev" ]; then
  printf 'warning: source (dev %s) and tmpdir (dev %s) on different volumes\n' "$src_dev" "$tmp_dev" >&2
  printf '         APFS clonefile will not work; relocating tmpdir under source\n' >&2
  rm -rf "$TMPBASE"
  TMPBASE=$(mktemp -d "$SRC/.bench-tmp.XXXXXX")
fi

cleanup() {
  rm -rf "$TMPBASE" "$LISTFILE"
}
trap cleanup EXIT

STRATEGIES=(
  "bash loop + cp -cRP"
  "xargs -P${CPUS} + cp -cRP"
  "xargs -P8 + cp -cRP"
  "ditto --clone (loop)"
  "ditto --clone (xargs -P${CPUS})"
  "tar cf - | tar xf -"
  "rsync -a --files-from"
)

run_strategy() {
  local idx="$1" dst="$2"
  case "$idx" in
  0) strategy_bash_loop "$SRC" "$dst" "$LISTFILE" ;;
  1) strategy_xargs_cp "$SRC" "$dst" "$LISTFILE" "$CPUS" ;;
  2) strategy_xargs_cp "$SRC" "$dst" "$LISTFILE" 8 ;;
  3) strategy_ditto_loop "$SRC" "$dst" "$LISTFILE" ;;
  4) strategy_ditto_xargs "$SRC" "$dst" "$LISTFILE" "$CPUS" ;;
  5) strategy_tar_pipe "$SRC" "$dst" "$LISTFILE" ;;
  6) strategy_rsync "$SRC" "$dst" "$LISTFILE" ;;
  esac
}

header_fmt="%-38s"
run_fmt="%8s"
printf "$header_fmt" "Strategy"
for r in $(seq 1 "$RUNS"); do
  printf "$run_fmt" "Run $r"
done
printf "%8s\n" "Min"
printf '%0.s─' $(seq 1 $(( 38 + 8 * RUNS + 8 ))); printf '\n'

for si in "${!STRATEGIES[@]}"; do
  name="${STRATEGIES[$si]}"
  times=()
  verified=0

  if [ "$PURGE" -eq 1 ]; then
    sudo purge 2>/dev/null || true
  fi

  for r in $(seq 1 "$RUNS"); do
    dst="$TMPBASE/run-${si}-${r}"
    mkdir -p "$dst"

    t0=$(now_ms)
    run_strategy "$si" "$dst"
    t1=$(now_ms)
    ms=$(elapsed_ms "$t0" "$t1")
    times+=("$ms")

    if [ "$verified" -eq 0 ]; then
      fc=$(count_files "$dst")
      verified=1
    fi

    rm -rf "$dst"
  done

  min="${times[0]}"
  for t in "${times[@]}"; do
    [ "$t" -lt "$min" ] && min="$t"
  done

  printf "$header_fmt" "$name"
  for t in "${times[@]}"; do
    printf "$run_fmt" "${t}ms"
  done
  printf "%8s" "${min}ms"
  printf "  (%s files)\n" "$fc"
done
