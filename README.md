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

# fish (~/.config/fish/config.fish)
wt completion fish | source
```

## Common Usages

Open or create a workspace (or use `wt sw`):

```
wt sw feat-1 --from main 

# and if copying dirty files also

wt switch feat-2 --from main \
  --copyignored 
  --copyuntracked \
  --copymodified
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

Override with `--base <dir>` or `GIT_WT_BASE` (flag wins).


## Unit Tests

```
./tests/run
```
