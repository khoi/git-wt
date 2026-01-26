# wt

Minimal git worktree helper with the main use case for running multiple coding agents in parallel.

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

# initialize submodules in the new worktree (new worktrees only)

wt sw feat-sub --from main \
  --init-submodules
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


## Unit Tests

```
./tests/run
```
