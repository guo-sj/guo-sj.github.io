---
layout: post
title: "Save as in Vim"
date:  2021-12-02 10:11:53 +0800
categories: Vim
---

用`MS Office`的时候，`Save as（另存为）`功能是一个非常实用的功能。
它可以完成两个功能：

1. 把当前文件保存成一个新的文件
2. 自动转到这个新生成的文件进行编辑。

在`Vim`中，可以用`saveas`命令实现`Save as`的功能：
```
    :saveas new-file<CR>
```

更多信息参考Vim手册`usr_07.txt: 07.7 Changing the file name`。

以上。

