---
layout: post
title: "Git Delete Branch"
date:  2022-02-11 10:11:53 +0800
categories: Git
---

Git删除本地分支的命令为：
```
$ git branch -d <branch-name>
```
或是强制删除本地分支：
```
$ git branch -D <branch-name>
```

如果是删除github上的分支，则用命令：
```
$ git push <remote-name> --delete <branch-name>
```
例如：
```
$ git push origin --delete test_branch
```

以上。
