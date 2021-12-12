---
layout: post
title: "The .gitignore file"
date:  2021-12-12 19:11:53 +0800
categories: Git
---

`.gitignore`文件可以用来告诉`git`哪些文件可以忽略，这个文件
通常被放在项目的根目录。如：
```
$ cat .gitignore

# ignore vim backup files
*~
.*~

# ignore tags
tags
```

在`.gitignore`中，**一行就是一个或一类文件**，描述文件可以使用`wildcard (*)`；用`#`
来标注**注释**。

你可以创建`~/.gitignore_global`文件，在其中标明你想让git忽略的文件，
然后用如下命令，**让所有的用`git`管理的项目都忽略这些文件**：
```
$ git config --global core.excludesfile ~/.gitignore_global
```

以上。
