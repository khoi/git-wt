# git-wt

Just some dead simple sugar on top of git worktree in Bash.

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
git wt purge                delete current worktree and branch, cd to main
git wt list                 list worktrees
git wt ls                   alias for list
```
