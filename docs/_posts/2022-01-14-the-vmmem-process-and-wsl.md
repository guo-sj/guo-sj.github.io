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

对于 Thinkpadx1 ultra7 + 32G + 1T，使用 wsl 配置如下，避免卡死或者闪退：
```
[wsl2]
# 核心：32G内存分配16GB给WSL2，留16GB给Windows（兼顾性能和系统流畅）
memory=16GB
# 分配10核CPU（Ultra 7 155H共14核，留4核给Windows，足够进程调度）
processors=10
# 交换空间（虚拟内存）：8GB，解决内存峰值OOM问题（装包/跑代码必备）
swap=8GB
# 交换文件路径，默认C盘（你的C盘1T，空间充足，无需修改）
swapfile=C:\\Users\\guosj\\wsl2-swap.vhdx
# 关闭显存限制（运行TileLang/PyTorch/GPU相关MHC代码必开，释放显卡显存）
gpu_memory=0
# 自动回收WSL2虚拟硬盘空间（避免镜像文件无限膨胀，1T硬盘也建议开启）
autoReclaimStorage=true
# 禁用WSL2休眠（避免进程挂起/死锁）
hibernate=false
# 启用嵌套虚拟化（可选，若后续需要在WSL2中运行其他虚拟机）
nestedVirtualization=true
```

以上。
