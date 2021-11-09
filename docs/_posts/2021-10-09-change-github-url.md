---
layout: post
title: "Change Github URL"
date:  2021-11-09 09:11:53 +0800
categories: git
---

最近换掉了[github](https://github.com/guo-sj)的账户名，本地的仓库需要
同步更新`remote url`，于是上网学习了一下，记录下来。

改之前，先用如下命令来查看本地仓库的`url`：
```
$ git remote -v    # 在安装oh-my-zsh后，输入 grv 即可
```

然后，用以下命令更新`url`：
```
$ git remote set-url origin https://github.com/guo-sj/guo-sj.github.io.git
```

以上。




