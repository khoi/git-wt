# wt

Minimal git worktree helper with the main use case for running multiple coding agents in parallel.

## Installation

Run:

```
curl -fsSL https://raw.githubusercontent.com/khoi/git-wt/main/install.sh | sh
```


## Common Usages

Open or create a workspace:

```
wt switch feat-1 --from main
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

By default the worktrees are stored at `<gitroot>/.git/worktrees`

Override with `--base <dir>` or `GIT_WT_BASE` (flag wins).


## Unit Tests

```
./tests/run
```
