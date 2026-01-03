# git-wt

Create and manage git worktrees fast.

## Install

Requirements: `git`, `bash`.

Clone:

```
ghq get git@github.com:khoi/git-wt.git
```

Link into your PATH:

```
ln -sf ~/Developer/code/github.com/khoi/git-wt/git-wt ~/.bin/git-wt
```

Ensure `~/.bin` is on your `PATH`, then use:

```
git wt new
git wt list
git wt ls
```

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
