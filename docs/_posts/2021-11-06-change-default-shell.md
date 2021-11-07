---
layout: post
title: "Change Default Shell In Ubuntu"
date:  2021-11-06 10:00:00 +0800
categories: linux ubuntu
---

Ubuntu系统的默认 log in shell 是bash，然而有时候，我们希望可以将它改成其他的shell，比如zsh。

在修改之前，我们可以先利用如下命令查看当前默认的 log in shell：
```
$ echo $SHELL
/bin/bash
```

然后，我们查看下目前系统中可以用来更换的shell：
```
$ cat /etc/shells
# /etc/shells: valid login shells                                                                                                                             
/bin/sh
/bin/bash
/usr/bin/bash
/bin/rbash
/usr/bin/rbash
/bin/dash
/usr/bin/dash
/bin/zsh
/usr/bin/zsh
/usr/bin/tmux
```

在看到系统中已经支持zsh之后，我们用如下命令将默认的log in shell 由bash改成zsh：
```
$ chsh -s /usr/bin/zsh  # /bin/zsh 也是可以的
```

值得注意的是，在运行完命令后，我们需要重启linux机器：
```
$ reboot
```

在重启完成之后呢，用以下命令查看是否更改成功：
```
$ echo $0    # 查看当前运行的shell
zsh

$ echo $SHELL   # 查看当前默认的 log in shell
/usr/bin/zsh
```

成功 ;-)。

