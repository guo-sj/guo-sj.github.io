---
layout: post
title: "'Username' is not in the sudoers file."
date:  2022-01-10 10:11:53 +0800
categories: Linux
---

最近在公司分配的虚拟机上运行`sudo yum update`的时候，收到报错：
```
'Username' is not in the sudoers file. This incident will be reported.
```
原因是：当前用户不在`sudoers`文件中，因此我们只要把当前用户加
到`sudoers`文件中即可：
```
$ su    # 获得root权限

$ visudo    # 编辑 /etc/sudoers 文件
```
把当前用户信息加在管理员信息下面，如：
```
# visudo

... ...

## Allow root to run any commands anywhere
root    ALL=(ALL)       ALL    # 管理员信息
guosj   ALL=(ALL)       ALL    # 当前用户信息

... ...

```

以上。
