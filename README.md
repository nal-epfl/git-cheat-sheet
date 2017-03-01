# Introduction

## What is Git?

Git is a source control system: a system that can be used to manage a directory tree storing source code, documentation or other files (this is called a repository), offering the following main features:

* Changes (commits) can be made from multiple computers, and are shared easily (no need to send files by e-mail etc.);
* Changes are tracked automatically for all the files, and all the previous versions of all the files are saved in the repository history (there is no need to make manual backups; it is easy to revert or compare to an earlier version of a file when a change breaks something);
* Each change is given a code (a hash), and saved in the history with a timestamp and information about the user who made the change;
* In addition to being stored on each developer's computer, the repository is sometimes also stored remotely in a central location (e.g. when using services such as GitLab, GitHub etc.).

## The basic 3-operation workflow

Git uses three important operations, which every user should understand:

* add: adds new/changed files to a commit;
* commit: finalizes the commit locally, storing it in the local repository (on the user's computer);
* push: copies the commits from the local repository to the remote repository.

## The branching workflow

Advanced users should become familiar with a git feature called branching.

Branches are multiple versions of the file tree that exist in parallel. Their main use is to keep the clean version in the master branch (known as 'trunk' in SVN) and the work-in-progress version in a separate branch. Once you are happy with the changes, you merge them into the stable branch. This is very useful especially when there are at least two people working on the same repository: each one maintains his own development branch, and they all eventually merge into the stable branch.

A nice feature of branching in git is that when switching to another branch, git automagically makes all the files and changes appear and disappear, depending on whether they belong to the current branch or not. So there is no need to make duplicate directories etc.

A nasty problem is that git does not know what to do with uncommited changes when you switch the branch (what it does is to just carry the changes over, which is most likely not what you intend). You should always commit everything before you switch branches, or stash the changes (more about that below).

The rule of thumb is that you should always have a clean tree (no uncommited changes) whenever you move code around (downloading from remote repository, switching branches, merging changes between branches).

# Setting it up

Use the following gitconfig, which has some sane settings. (save it as ~/.gitconfig or /etc/gitconfig). Fill in your name and e-mail.

```
[color]
  ui = auto
[color "branch"]
  current = yellow
  local = yellow
  remote = green
[color "diff"]
  meta = yellow bold
  frag = magenta bold
  old = red bold
  new = green bold
[color "status"]
  added = green
  changed = yellow bold
  untracked = cyan
  deleted = red
[format]
  pretty = %C(yellow)%h%Creset %C(bold blue)%an <%ae>%Creset %s %C(green bold)(%cr)%Creset %C(green)(%ci)%Creset%C(yellow bold)%d%Creset
[merge]
  conflictstyle = diff3
[alias]
  delta = "!f() { git diff $1^ $1; }; f"
  deltaf = "!f() { git diff --name-status $1^ $1; }; f"
[push]
  default = matching
[credential]
  helper = cache --timeout=36000
```

Explanation for the options above:

* `[color ...]`: Configures some nicer colors for the output in `git status`, `git diff` etc.
* `[format] pretty`: Configures how commit metadata is displayed in commands such as `git log`.
* `[merge] conflictstyle = diff3`: Use 3-way merge for conflicts, which is IMHO easier to read.
* `[alias] delta, deltaf`: Introduces the custom commands `git delta` and `git deltaf`, which allow you to inspect directly the diff of a given commit (e.g. `git delta ffaabb`).
* `[push] default = matching`: Push only the current branch to the remote, instead of pushing ALL local branches.
* `[credential] helper = cache`: Store passwords for 10 hours. Otherwise you have to type it in every time.

You should really use a git-aware terminal prompt. There are many options especially for shells such as zsh. Search the web for something like "custom shell prompt git" or use [this one](https://gitlab.com/snippets/16785).

# Basic operations

## Creating a new repository

Option 1: Create a repository locally on your computer:

```
cd existing_folder
git init
git add .
git commit
```

You can then configure a remote repository to which all local changes should be pushed:

```
git remote add origin https://example.com/myuser/myrepo.git
```

Option 2: Create the repository remotely through the (usually web) interface of your git hosting provider.

## Creating a local copy of a remote repository

Run the command as indicated by the git hosting provider, for example:

```
git clone https://example.com/myuser/myrepo.git
```

## Displaying the current state of your copy

```
git status
```

If you use the gitconfig file given above, you should see in yellow files tracked by git which have changes not added to commit, in green files tracked by git which have changes added to commit but not commited yet (i.e. the commit has not been finalized) and in blue the files which are not tracked by git.

!!! If you see a message such as "Your branch is ahead of 'origin/master' by 1 commit", it means that you commited locally but did not push (i.e. upload) the commit to the remote repository. Keep in mind that in git commits are always local, and the push needs to be done manually. !!!

## Displaying a diff with the changes not yet added to commit

```
git diff
```

## Adding a new file to commit

```
git add path/to/file
```

## Adding a modified file to commit

```
git add path/to/file
```

## Adding parts of a new/modified file to commit

```
git add -p path/to/file
```

## Displaying a diff with the changes added to commit

```
git diff --staged
```

## Committing

First, check that you added all the necessary files to the commit, then commit:

```
git status
git commit -m 'The commit message'
```

Or to let git add all modified files for you and commit, all in one step:

```
git commit -am 'The commit message'
```

## Pushing the commited changes from the local copy into the remote copy

In git, the remote repository is called origin, and the name of the main branch is master (like trunk in SVN). Therefore the following command means "push the commited changes into the repository origin on branch master":

```
git push origin master
```

## Pulling changes from the remote copy into the local copy

!!! Warning: you should always commit before pulling. !!!

If you have conflicts, see instructions for solving them in the next sections.

```
git pull origin master
```

## Displaying the commit log

```
git log
```

## Displaying the commit log with diff

```
git log -p
```

## Displaying the commit log with per-file change statistics

```
git log --stat
```

## Displaying the commit log with commit graph

```
git log --graph
```

## Displaying the changes (diff) from a specific commit

Note: this is not an actual git command; it is an alias defined in the gitconfig given above.

```
git delta thecommithash
```

## Displaying the list of files changed in a specific commit

Note: this is not an actual git command; it is an alias defined in the gitconfig given above.

```
git deltaf thecommithash
```

# Fixing mistakes

!!! When in doubt, make a manual backup! !!!

## Changing the last commit message

Run this command and then commit again:

```
git commit --amend
```

## Undoing a commit after push

This actually creates a new commit with the opposite change of a past commit: 

```
git revert bad_commit_hash
```

## Undoing the last commit before push (keep the changed files)

!!! Never undo a commit if you have already pushed to a remote from which someone else might have pulled. Use git revert instead !!!

```
git reset HEAD~1
```

## Undoing a git add before git commit

Does not modify the file(s). Only removes the changes from the next commit. You can use git add to add them again.

```
git reset HEAD path/to/file
```

## Undoing all git adds before git commit (i.e. remove all changes from the next commit; does not modify the files)

```
git reset
```

## Throwing away local changes to a file (resets the file to the repo version)

```
git checkout -- path/to/file
```

## Removing a file from the repo (keep the file on disk)

```
git rm --cached path/to/file
```

## Removing a file from the repo (delete the file from disk)

```
git rm path/to/file
```

## Storing away all uncommited changes (push to a stack structure)

```
git stash
```

## Restoring all uncommited changes previously stashed (pop from the stack structure)

```
git stash pop
```

## You modified the wrong branch (but did not commit)

```
git checkout the_right_branch
```

## You accidentaly destroyed commits

You ran some command found on the Internet, which was supposed to help you modify your commit history, but instead you lost your last commit(s). They do not even show up in the log anymore, and you start to panic.

First, make a backup of your repository (copy the entire directory somewhere else).

Then inspect the output of:

```
git reflog
```

If you see your commit there (let's say its hash is acc3551b13), you can still recover it. Run:

```
git merge acc3551b13
```

# Git branch basics

There is always a branch called master, which is similar to trunk in SVN.

This is just a basic introduction to the branching commands. To understand how using more than one branch can be useful, see the 'Git branch workflow' below.

## Displaying existing local branches

These are branches that have been created or downloaded locally. Normally git will not download all existing branches from the remote unless instructed specifically.

```
git branch
```

## Displaying all existing branches (local and remote)

Remote branches are prefixed with `remotes/`.

```
git branch -a
```

## Creating a new branch and switching to it

```
git checkout -b the_branch_name:
```

## Switching to another existing branch

```
git checkout the_branch_name
```

## Switching to another branch that does not exist locally but exists in remote

```
git checkout -b the_branch_name origin/the_branch_name
```

## Deleting a local branch

```
git branch -d the_branch_name
```

## Merging changes from branch_x into the current branch

!!! WARNING: NEVER start a merge when you have uncommited changes in any branch. !!!

Note: you might have to solve merge conflicts. There are instructions for that below.

```
git merge branch_x
```

## Rebasing changes from branch_x into the current branch

!!! WARNING: NEVER start a merge when you have uncommited changes in any branch. !!!

Note: you might have to solve rebase conflicts. There are instructions for that below.

```
git rebase branch_x
```

## Understanding merge vs. rebase

Merge takes all the changes in one branch and merges them into another branch in one commit, logging that two parallel timelines have joined. Use it ONLY for intentional changes (new features, modified behavior etc.).

Rebase moves the point at which you branched in the past to a new starting point at the current time, putting all the individual commits that happened in the meantime in a linear timeline. The previous parallel timelines disappear from history. Use it for unrelated changes (e.g. synchronizing changes to module A with changes to module B).

The 'Git branch workflow' below shows when to use merge and when rebase.

!!! WARNING Commit your changes whenever you switch branches, otherwise git checkout will carry the uncommited changes to the other branch. Alternatively you can do a git stash to store away your work and finally git stash pop when you want to restore it. Make sure you are in the right branch when you commit/stash/unstash. !!!

# Git branch workflow

You should always keep the clean, stable version of your work in the master branch, especially if you share your repository with someone else. Do not work in master, instead use a different development branch called, for example, yourname-feature (e.g. john-gui-cleanup).

Usually you should create a separate branch for any well-defined task which requires several non-trivial commits with changes that are independent of the work currently hapenning in the master branch; these development branches are sometimes called feature branches.
You should merge the development branch back into master *as soon as possible*, usually when the task is implemented and reasonably tested. The longer you keep branches separate, the more code diverges and the merge will be more difficult.

There are a few important actions you need to know how to perform:

### 1. Work in the development branch and commit there

Create the branch john-gui-cleanup and switch to it:

```
git checkout -b john-gui-cleanup
git push -u origin john-gui-cleanup
```

Make some changes. Commit as usual.

```
git add blah blah blah
git commit -m 'Reorganized top menu'
```

### 2. Sync changes from the master branch

You notice master has been updated remotely (e.g. by a coworker), and you decide to incorporate the changes into your branch. First, commit your changes in the development branch.

```
git add blah blah blah
git commit -m 'Changed some of the left menu entries'
```

Switch to master and pull the changes from remote:

```
git checkout master
git pull origin master
```

Bring those changes back into the development branch (rebase will redo your commits on top of them, unless there are conflicts):

```
git checkout john-gui-cleanup
git rebase master
```

Now you can continue your work in the development branch.

### 3. Save the changes in the development branch remotely

All the commits you make (in any branch) are local to your machine. It is good practice to make several small commits during the day, and upload all your changes to the remote repo at the end of every day--or whenever you switch from one machine to another (e.g. desktop to laptop).

Push commited changes from local into the remote repository:

```
git push origin john-gui-cleanup
```

Pull changes from remote into local (you should always commit first):

```
git pull origin john-gui-cleanup
```

Note that the last two commands are similar to the way of pulling/pushing changes in the master branch.

### 4. Merge all the changes from the development branch into master  

This should be done when the task implemented in the development branch is completed.

First, make sure you have committed all the changes in the development branch. Then switch to master and merge:

```
git checkout master
git pull origin master
git merge john-gui-cleanup
```

# Solving merge conflicts

If you use the gitconfig recommended above, text files with conflicts will contain something like this:

```
<<<<<<<
Changes from the current branch.
|||||||
The common ancestor version.
=======
Changes from branch_x.
>>>>>>>
```

You need to edit the file so that in the end it is clean, without any markers (`<<<<`, `||||`, `====`, `>>>>`).

It might be useful to inspect the commit history starting from the common ancestor. To do this, run:

```
git log --merge -p path/to/file
```

Once you have resolved the conflicts in a file, run:

```
git add path/to/file
```

Once you have resolved all the conflicts, you must do a commit to complete the merge:

```
git commit -m 'Merged branch_x, resolved conflicts'
```

If you want to abort the merge and reset your working copy to the state it was before the merge:

```
git merge --abort
```

Versions of git older than 1.7.4 need:

```
git reset --merge
```

Versions of git older than 1.6.2 need:

```
git reset --hard
```

# Solving rebase conflicts

This is similar to solving merge conflicts. You clean up files with conflicts, and then run:

```
git rebase --continue
```

Repeat until git is happy.

It might happen that you want to drop your local changes from a commit completely in a way that looks like an empty commit, in which case git will suspect that you are making a mistake. In this case you need to run:

```
git rebase --skip
```

If you want to abort the rebase and reset your working copy to the state it was before the rebase:

```
git rebase --abort
```

Tip: make your life easy and rebase often (daily is usually fine), otherwise you will have tons of conflicts which might be difficult to merge. Rebasing weeks of work is bad practice.

# Tagging

Tags are essentially named commits. They are most commonly used to mark releases (e.g. "3.14").

## Inspecting existing tags

```
git tag
```

## Checking out an existing tag

```
git checkout 3.14
```

## Going back to master

```
git checkout master
```

## Creating a local, annotated tag from HEAD

```
git tag -a 3.14 -m 'Version 3.14'
```

You will have to check it out to switch to it.

## Pushing local tags to remote

```
git push origin master --tags
```

# Advanced operations

## Ignoring changes to a file

```
git update-index --assume-unchanged /path/to/file
```

## Not ignoring changes to a file

```
git update-index --no-assume-unchanged /path/to/file
```

## Changing your author name/email in all commits

!!! WARNING: using git push --mirror will first erase the content of the remote repo, then upload your version. If anything breaks during this process, you might have a bad time!!! Backup first using git clone --mirror. !!!

### Step 1: mirror the remote into a new directory

```
mkdir tmp
cd tmp
git clone --mirror https://the.remote.repo
```

Now backup:

```
cd ..
cp -r tmp tmp-backup
cd tmp
```

### Step 2: change your name in all commits

```
git filter-branch --commit-filter 'if [ "$GIT_AUTHOR_NAME" = "Bob" ]; then export GIT_AUTHOR_NAME="Robert"; export GIT_AUTHOR_EMAIL=robert@example.com; fi; git commit-tree "$@"'
```

### Step 3: force the remote repository to become a perfect copy of this repository

```
git push --mirror
```

## Removing a file from all the commit history:  

```
git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch the/path/to/file' --prune-empty --tag-name-filter cat -- --all
git show-ref --head
git update-ref -d refs/original/refs/heads/master
git update-ref -d refs/original/refs/remotes/origin/master
git update-ref -d refs/original/refs/stash
git push origin master --force
```

# Git as SVN client

You need to install git-svn. Afterwards, use git operations as usual, except for the following:

## Creating a local copy of the SVN repository

```
git svn clone --stdlayout https://the.svn.repo
```

## Pulling commits from the remote repository

```
git svn rebase
```

## Pushing commits to the remote repository

```
git svn dcommit
```

## Showing the SVN log (with SVN revision numbers)

```
git svn log
```
