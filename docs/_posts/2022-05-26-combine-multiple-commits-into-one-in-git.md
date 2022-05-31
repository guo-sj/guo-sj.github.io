---
layout: post
title: "Combine Multiple Commits into One in Git"
date:  2022-05-26 10:11:53 +0800
categories: Git
---

我们在提PR的时候，经常需要把多个 git 提交记录合成一个，这个操作可以通过 `git rebase` 来完成。

先选好需要合成的记录范围，这里指的范围是相对 HEAD 而言的。比如说，如果我们想把 HEAD 开始的前
四条记录合成一条，那么我们可以用下面的命令：
```
$ git rebase -i HEAD~4
```

`-i` 代表着 `interactive`，执行上述命令会弹出一个窗口，大致是这个样子：
```
pick 80d0533 [Language/C] Update TestCode
pick 972187c [Language/C] Update TestCode
pick e5ddaf9 [concurrent-programming] add dir
pick e5sdaf9 [programming] rm dir

# Rebase f4b32d3..e5ddaf9 onto f4b32d3 (4 commands)

# Commands:
# p, pick <commit> = use commit
# r, reword <commit> = use commit, but edit the commit message
# e, edit <commit> = use commit, but stop for amending
# s, squash <commit> = use commit, but meld into previous commit
... ...
```

然后，我们从第二行开始把 `pick` 改为 `squash` ，就像这样：
```
pick 80d0533 [Language/C] Update TestCode
squash 972187c [Language/C] Update TestCode
squash e5ddaf9 [concurrent-programming] add dir
squash e5sdaf9 [programming] rm dir
```

然后我们输入 `:wq` 保存退出，这时又会弹出一个窗口让你编辑最终合成一条的提交信息：
```
# This is a combination of 4 commits.
# This is the 1st commit message:
... ...
# This is the 2nd commit message:
... ...
# This is the 3rd commit message:
... ...
# This is the 4th commit message:
... ...
```

编辑成功之后，用 `git log` 检查一下子，最后用下面的命令强制提交到对应的 github 分支：
```
$ git push --force origin <branch-name>
```

**=========================补充=========================**

如果想要 revert rebase 操作，那么可以用命令 `git reflog` 查看你想回退的点，然后用命令：
```
$ git reset --hard HEAD@{x}  # x为你想回退的点
```
进行回退。


以上。
