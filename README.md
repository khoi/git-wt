# git-wt

Create and manage git worktrees fast.

## Install

Requirements: `git`, `bash`.

Clone:

```
git clone https://github.com/khoi/git-wt.git
cd git-wt
```

Install:

```
./install.sh
```

Custom prefix:

```
PREFIX=~/.local ./install.sh
```

Ensure your chosen `bin` directory is on your `PATH`.

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
