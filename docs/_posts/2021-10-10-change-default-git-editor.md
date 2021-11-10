---
layout: post
title: "Change Default Git Editor"
date:  2021-11-10 10:11:53 +0800
categories: git
---

在Ubuntu上初次安装`git`的时候，`git`的默认编辑器为`nano`，自己
更喜欢`vim`一些，于是学习了一下修改方法，在此记录下来。

运行如下命令即可：
```
$ git config --global core.editor vim
```

可用的编辑器列表 **[1]**：

| Editor  | Config value |
| :---:   |  :---:       |
| nano	  | nano         |
| vim	  | vim          |
| neovim  | nvim         |
| emacs   | emacs        |
| sublime text | subl -n -w |
| atom	  | atom --wait |
| vscode  | code --wait |


当然，你也可以应用一下以前记录的[内容](https://guo-sj.github.io/git/2021/11/08/git-alias.html)，
用`cfg`来代替`config`，如：
```
$ git config --global alias.cfg config
```
然后：
```
$ git cfg --global core.editor vim
```

**[1]** 列表来自[Change the default git editor](https://koenwoortman.com/git-change-default-editor/)

以上。
