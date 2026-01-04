# git-wt

Just some dead simple sugar on top of git worktree with fzf.

## Installation

Just copy it to ur PATH

## Flow

An actual workflow will be something like this:

```
git wt switch -c fancy-new-feature
# do ur changes
# create a PR, or merge the branch from main
git wt purge # ⚠️ this destroy the wt and the branch. 
```

## Usage

```
git wt switch -c <feature>  create worktree and cd into it
git wt switch <feature>     cd into existing worktree
git wt switch               pick worktree via fzf
git wt --base <dir> switch -c <feature>  set base dir for this run
GIT_WT_BASE=<dir> git wt switch <feature>  set base dir via env
git wt purge                delete current worktree and branch, cd to main
git wt list                 list worktrees
git wt ls                   alias for list
```

## Base dir

Default base dir is `../{gitroot}-worktrees`. Override with `--base <dir>` or `GIT_WT_BASE`. The flag wins.

Examples:

```
git wt --base /tmp/wt switch -c feature
git wt --base .worktrees switch feature
GIT_WT_BASE=/tmp/wt git wt switch feature
```
