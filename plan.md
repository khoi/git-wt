# Plan + CLI design (clean slate, aligned with CLI Guidelines)

## Goals
- Purpose-built for running multiple AI agents in parallel in the same repo.
- Human-first defaults with composable, script-safe output when piped.
- Zero shell hijack: commands never `cd` or spawn shells; they only print paths and status.
- One identifier: branch == workspace == default path.

## Core model
- A workspace is a git worktree + a git branch.
- The workspace identifier is the branch name.
- Default workspace path: `<base>/<branch>` where `/` in branch becomes directories.

## Base dir
- Default: `<gitroot>/.wt` (hidden, local, repo-scoped).
- Override with `--base <dir>` or `GIT_WT_BASE` (flag wins).
- Relative `--base` is resolved from `<gitroot>`.

## Output contract
- If stdout is a TTY: human-readable output.
- If stdout is not a TTY: plain, parseable output by default.
- `--plain`: one record per line, tab-delimited fields.
- `--json`: machine-readable structured output.
- Errors go to stderr, no noisy logs.
- Exit 0 on success, non-zero on failure.

## Commands

### `wt open <branch>`
Creates or opens a workspace and prints its absolute path.

Flags:
- `--from <base-branch>`: base ref for new branch (default: current `HEAD` on main worktree).
- `--base <dir>`: override base dir.
- `--path <dir>`: explicit worktree path (absolute or relative to gitroot).
- `--fetch`: explicitly fetch remotes before resolving `--from`.

Rules:
- If worktree for `<branch>` already exists, print its path and exit 0.
- If branch exists but no worktree at expected path, error (explicitly require cleanup or `--path`).
- If branch does not exist, create it at `--from` and add worktree.
- Always prints one absolute path on stdout, nothing else.

### `wt ls`
Lists workspaces under base.

Flags:
- `--base <dir>`: base dir override.
- `--plain`: `branch<TAB>path` per line.
- `--json`: JSON array of `{branch, path, head}`.

Defaults:
- TTY: aligned human table with branch, path, head.
- Non-TTY: same as `--plain`.

### `wt rm <branch>`
Removes a workspace.

Flags:
- `-f, --force`: delete even if dirty; delete branch with `-D`.
- `--base <dir>`: base dir override.

Rules:
- If TTY and dirty: prompt for confirmation; require `--force` when non-interactive.
- If clean: remove worktree, delete branch, exit 0.
- If branch not found: exit 1.
- Prints removed path on stdout when successful.

### `wt here`
Prints the current workspace branch name if inside a managed worktree, else empty with exit 1.

### `wt base`
Prints the resolved base dir path.

### `wt help [command]`
Shows help for a command. Include examples and common flags first for discoverability.

### `wt version`
Prints version.

## Naming + flags
- Prefer explicit flags for optional inputs; keep the single primary arg as the branch name.
- Use standard flag names (`-h/--help`, `-f/--force`, `--json`, `--version`).
- No implicit subcommand abbreviations.

## Errors and guidance
- Errors should be human-readable and actionable.
- Suggest likely commands on typos (unknown subcommand).

## Examples
Create 5 workspaces for 5 Ghostty tabs:

```
printf '%s\n' feat-1 feat-2 feat-3 feat-4 feat-5 | while read -r b; do wt open "$b" --from main; done
```

Each line from `wt open` is a path. Pipe to your tab opener or use it in Codex CLI:

```
wt open feat-1 --from main
```

Custom base:

```
wt open agent-a/feat-1 --from main --base /tmp/wt
```

## Implementation notes
- Source of truth: `git worktree list --porcelain`.
- Resolve gitroot via `git rev-parse --show-toplevel`.
- Path resolution:
  - `--path` absolute: use as-is.
  - `--path` relative: resolve under gitroot.
  - default: `<base>/<branch>`
- Branch names passed through unchanged; only map `/` to directories for paths.

## Tests (bash)
- Tests are pure bash, no external dependencies.
- Layout:
  - `tests/run` entrypoint
  - `tests/lib` small harness (assert, run, tmp)
  - `tests/cases/*.t` test cases
- Each test runs in a temp git repo, uses local branches only, cleans up on exit.
- Coverage:
  - `open` creates, opens existing, path overrides, base overrides
  - `ls` output modes (tty vs non-tty, `--plain`, `--json`)
  - `rm` dirty vs clean, `--force`, branch missing
  - `here` inside and outside a managed worktree
  - error cases and exit codes
