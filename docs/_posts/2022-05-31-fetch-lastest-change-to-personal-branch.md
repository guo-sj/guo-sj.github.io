---
layout: post
title: "Fetch Latest Changes to Personal Branch"
date:  2022-05-31 10:11:53 +0800
categories: Git
---

当我们用 Git 进行版本管理的时候，经常会遇到这样的情况：为了实现一个功能，
我们用 `git checkout -b personal-branch` 命令从 master 分支 fork 了一个
 personal-branch 分支，然后就在 personal-branch 上进行开发。在开发的过程中，
 master 分支发生了更新。这时应该怎么办呢？

我之前的办法是：
```
$ git stash # keep personal branch clean
$ git checkout master && git pull # fetch lastest changes to local master branch
$ git checkout personal-branch # checkout to personal-branch
$ git merge master # merge master to personal-branch
$ git stash pop # restore changes
```

这样略显繁琐，后来我学会了这种方法：
```
$ git stash # keep personal branch clean
$ git fetch origin master # fetch lastest changes in master branch but not merge to local master branch
$ git merge origin/master # merge origin/master to personal-branch
$ git stash pop # restore changes
```

这两种方法都是可以的。不过后者比前者少了来回 checkout 的步骤，因此如
果只是想要 fetch master 分支上最新的修改到自己正在开发的分支上，那么无
疑是第二种方法更加方便。

如果你既想 fetch master 分支上最新的修改到自己正在开发的分支上，
也想更新本地的 master branch 到最新，那么就采用第一种方法。

以上。
