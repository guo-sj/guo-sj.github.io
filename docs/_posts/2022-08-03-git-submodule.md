---
layout: post
title: "Git Submodule"
date:  2022-08-03 10:11:53 +0800
categories: Git
---

Git 提供了一个命令，git submodule，它可以让一个 git 仓库嵌入到另一个 git 仓库中。
比如，我们想把仓库 b (https://github.com/guo-sj/b.git) 嵌入到仓库 a 中，我们可以
这样做：
```
$ cd a/
$ git submodule add https://github.com/guo-sj/b.git
```

等这个命令执行完之后，你会发现在当前目录中生成了一个 .gitmodules 的文件，它里面记录了
该仓库 module 的 local path 和 remote url 的对应关系。我们可以用 cat 命令查看它：
```
$ cat .gitmodules
[submodule "b"]
    path = b
    url = https://github.com/guo-sj/b.git
```

如果我们想 clone 一个带有若干 submodules 的仓库，我们可以有两种方法。第一种方法，我们可以先 clone 最外层的仓库，
然后再 fetch 它里面嵌着的 submodules：
```
$ git clone https://github.com/guo-sj/a
$ cd a/
$ git submodule update --init
```

或者，就像很多 Git 命令一样，你可以用一条命令直接完成上述动作：
```
$ git clone --recurse-submodules https://github.com/guo-sj/a
```

最后，当你想 fetch submodules 的 upstream 的时候，你可以这样做：
```
$ git submodule update --remote [submodule-name]
```

命令中的 submodule-name 可以被替换为某个特定的 submodule 的 local path。就像我们上面讲的那样，你可以在仓库的 .gitmodules 文件中
找到所有 submodules 的 local path。如果你缺省了 submodule-name，那么这条命令会更新当前仓库包含的所有 submodules。

以上。
