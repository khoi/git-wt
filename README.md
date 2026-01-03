# git-wt

Create and manage git worktrees fast.

## Install

Requirements: `git`, `bash`.

Clone:

```
git clone https://github.com/khoi/git-wt.git
cd git-wt
```

Install to a directory on your `PATH`:

```
install -m 755 git-wt /usr/local/bin/git-wt
```

If you do not have permission for `/usr/local/bin`, use a user-local bin:

```
install -m 755 git-wt ~/.local/bin/git-wt
```

Ensure the chosen `bin` directory is on your `PATH`.

## Commands

```
new   create a new worktree and cd into it
list  list worktrees
ls    alias for list
```

## Help

```
git wt --help
git wt help
git wt help new
git wt help list
```
