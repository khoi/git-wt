# wt

Minimal git worktree helper with the main use case for running multiple coding agents in parallel.

## Installation

Run:

```
curl -fsSL https://raw.githubusercontent.com/khoi/git-wt/main/install.sh | sh
```

## Usage

```
wt open <branch> [--from <ref>] [--base <dir>] [--path <dir>] [--fetch]
wt exec <branch> -- <cmd...>
wt ls [--base <dir>] [--plain] [--json]
wt rm <branch> [--force] [--base <dir>]
wt here
wt base
wt help [command]
```

## Model

- A workspace is a git worktree + a git branch.
- The workspace identifier is the branch name.
- Default worktree path is `<base>/<branch>`.

## Base dir

Default: `<gitroot>/.wt`

Override with `--base <dir>` or `GIT_WT_BASE` (flag wins).

## Output

- If stdout is a TTY, `wt ls` prints a human table.
- If stdout is not a TTY, `wt ls` prints `branch<TAB>path`.
- `--plain` forces tab-delimited output.
- `--json` returns JSON.

## Examples

Create five workspaces:

```
echo "feature-a feature-b feature-c" | xargs -n1 wt open --from main
```

Open or create a workspace:

```
wt open feat-1 --from main
```

Run Codex directly in a workspace:

```
wt exec feat-1 -- codex
```

Remove a workspace:

```
wt rm feat-1
```

## Unit Tests

```
./tests/run
```
