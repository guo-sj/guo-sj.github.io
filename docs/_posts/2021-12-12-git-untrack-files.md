---
layout: post
title: "Git Untrack Files"
date:  2021-12-12 18:11:53 +0800
categories: Git
---

在Git中，我们可以用如下命令去`untrack`某个文件：
```
$ git rm --cached <filename>
```

如果想要`untrack`文件夹，那么可以：
```
$ git rm -r --cached <folder>
```

上面两个命令都是仅仅让git不再管理特定的文件
或文件夹，但是它们还保存在你的磁盘上。如果
想要也**从磁盘上删除它们**，则可以用以下命令：
```
$ git rm <filename>

$ git rm -r <folder>
```

以上。
