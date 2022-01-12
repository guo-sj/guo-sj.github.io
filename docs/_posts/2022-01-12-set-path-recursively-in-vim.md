---
layout: post
title: "Set Path Recursively in Vim"
date:  2022-01-12 10:11:53 +0800
categories: Vim
---

在Vim中，`find <file-name>` 可以帮助我们快速在`path`中查找文件。

这个功能非常好用，但是美中不足的是必须要设置变量`path`，如：
```
: set path+=weed,weed/filer/
```
如果遇到一个大型的项目，有几十个folder和sub-foler，按照上述方法
设置`path`简直是一种灾难。

最近学到的一种方法可以解决这个问题：
```
: set path+=./**    " 增加当前目录下所有sub-folders
```
上述命令告诉Vim增加当前目录下所有sub-folders到`path`，
这样我们就能愉快地用`find`检索文件啦。

当然，你还可以更进一步，将这个方法应用到自己的.vimrc中，像这样：
```
let pwd = getcwd()    " get current directory
if pwd == "/home/guosj/Documents/github/seaweedfs"
    echo "enter directory seaweedfs"
    set path=.,/usr/include,weed/**
endif
```

以上。
