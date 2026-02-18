# wt

Minimal git worktree helper with the main use case for running multiple coding agents in parallel.

The silent engine behind https://supacode.sh

## Installation

Run:

```
curl -fsSL https://raw.githubusercontent.com/khoi/git-wt/main/install.sh | sh
```

## Shell Integration

Add to shell config for auto-cd on `wt switch`:

```bash
# bash (~/.bashrc)
eval "$(wt completion bash)"

# zsh (~/.zshrc)
eval "$(wt completion zsh)"

# fish (~/.config/fish/conf.d/wt.fish)
source ~/.config/fish/completions/wt.fish
```

## Common Usages

Open or create a workspace (or use `wt sw`):

```
wt sw feat-1 --from main 

# and if copying dirty files also

wt switch feat-2 --from main \
  --copy-all

```

Sync files from the main worktree to the current worktree:

```
wt sync --copy-modified
```

Sync between two existing worktrees:

```
wt sync main feat-1 --copy-all
```

Return to main worktree:

```
cd "$(wt root)"
```

Run Codex directly in a workspace:

```
wt exec feat-1 -- codex
```

Remove a workspace:

```
wt rm feat-1
```

Full commands:

```
wt --help
wt <subcommand> --help
```

## Base dir

By default worktrees are stored at `<gitroot>/.worktrees`

Override with `--base-dir <dir>` or `GIT_WT_BASE` (flag wins). `wt ls` lists all worktrees unless `--base-dir` is set.

## Bare repositories

wt supports bare repositories and linked worktrees. `wt root` prints the bare repo path and `wt ls` includes a `(bare)` entry. JSON output includes `is_bare` for each entry. Copy flags and `wt sync` are supported for linked worktrees in bare repository setups.

### Quick walkthrough

```
git init --bare /tmp/my-repo.git
git -C /tmp/my-repo.git worktree add /tmp/my-repo main

cd /tmp/my-repo.git
wt root
wt ls
```

Expected output includes the bare repo path for `wt root` and a `(bare)` row in `wt ls`.


## Unit Tests

```
./tests/run
```
