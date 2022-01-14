---
layout: post
title: "The vmmem Process and WSL"
date:  2022-01-14 10:11:53 +0800
categories: WSL
---

运行WSL2（Windows Subsystem for Linux）的时候，电脑一度卡到
没有响应。好不容易打开任务管理器，发现占用系统资源最高的是一个
名叫`vmmem`的进程。

对于`vmmem`，是无法手动从任务管理器中杀掉的，无论是普通用户
权限还是系统管理员权限都不行。事实上，它是跟随WSL2一起运行的，
因此，只要关闭WSL2，`vmmem`就会自动消失。

在Powershell中输入下列指令可以杀掉WSL2：
```
$ wsl --shutdown
```

再打开任务管理器，发现`vmmem`进程已经消失，电脑的运行速度
也随之恢复正常。

我们现在知道，如果运行WSL2，`vmmem`进程就会在内存中运行；而
`vmmem`会不断的占用系统内存和CPU资源，导致电脑变得卡顿。那么
有没有一种方法去限制`vmmem`的资源使用，使得Windows和WSL2
和谐的运行呢？

经过查阅资料，通过为WSL设置配置文件的方法可以解决这个问题。

在Powershell的`~（home）`目录下创建WSL2配置文件`.wslconfig`，
然后输入下列内容：
```
# gvim ~/.wslconfig

[wsl2]
memory=2GB   # Limits VM memory in WSL 2 up to 2GB
processors=2 # Makes the WSL 2 VM use two virtual processors
```

保存文件并退出。这样下次开启WSL2的时候，`vmmem`进程对系统内存
的占用就会被限定到2GB，对处理器的占用也会被限制到2个核心。

以上。
