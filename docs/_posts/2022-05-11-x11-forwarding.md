---
layout: post
title: "X11 Forwarding"
date:  2022-05-11 10:11:53 +0800
categories: KVM
---

X Windows Server 是一种可以让Windows Manager去显示GUI应用的协议，X11则是第11代的
X Windows Server。

这个东西一般可以用来显示Linux服务器端的图形应用，如`gedit`、`xclock`等。我们的host主机
运行着X11 Server，Linux服务器运行着X11 Client。host主机和服务器的通信则通过ssh进行。原理
图如下：

![](/assets/x11.png)

注：这个图片转载自[通过SSH进行X11转发](https://z-rui.github.io/post/2015/10/x11forward/)。

因为ssh服务要转发X11的数据，所以要编辑ssh服务的配置文件，在CentOS7中，这个文件是`/etc/ssh/sshd_config`：
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

然后重启ssh服务：
```
$ systemctl restart sshd
```

这时，Linux服务器端就配置好了。接下来我们来看Host主机这边。
如果你的Host主机是Linux机器，那么你只需要输入：
```
$ ssh -X root@10.10.10.2
```
`ssh -X`会帮助你设置Linux服务器这边的`DISPLAY`系统变量，这个变量的作用是告诉X11 Client如何去连接X11 Server，
而且一般不需要你自己手动设置。
在你连接上之后，你可以查看`DISPLAY`的值：
```
$ echo $DISPLAY
localhost:11.0
```

如果你的Host主机是Windows机器，那么这边有一篇[MobaXterm连接显示Linux图形化界面](https://guo-sj.github.io/kvm/2022/04/28/mobaxterm-linux-gui.html)或许可以帮到你。

以上。
