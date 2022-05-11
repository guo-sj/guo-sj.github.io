---
layout: post
title: "MobaXterm连接显示Linux图形化界面"
date:  2022-04-28 11:08:53 +0800
categories: KVM
---

> 这篇文章在[MobaXterm连接显示Linux图形化界面](https://blog.csdn.net/ly7472712/article/details/116993554?msclkid=9e8a500fc53f11ec9ec2bbb87ad05660)的基础了加入了自己的一些思考。

**1.** Linux操作系统中安装X11相关安装包

```
$ yum install -y xorg-x11-xauth xorg-x11-fonts-* xorg-x11-font-utils \
xorg-x11-fonts-Type1 xclock
```

**2.** 修改/etc/ssh/sshd_config配置文件
```
# vi /etc/ssh/sshd_config

...
#AllowAgentForwarding yes
#AllowTcpForwarding yes
#GatewayPorts no
X11Forwarding yes 				#将X11Forwarding去掉注释改为yes
#X11DisplayOffset 10
#X11UseLocalhost no
#PermitTTY yes
#PrintMotd yes
...
```

**3.** 当我们修改完配置ssh的配置文件之后，需要重启ssh服务
```
$ systemctl restart sshd
```

**4.** 修改完成之后，我们需要新建session并勾选X11-Forwarding
输入ip —> 勾选Specify username —> 输入用户名 —> 勾选X11-Forwarding。

![](/assets/mobaxterm-x11-configuration-1.png)

**5.** 执行xclock测试能否调用出虚拟机gui界面

![](/assets/mobaxterm-x11-configuration-2.png)

以上。
