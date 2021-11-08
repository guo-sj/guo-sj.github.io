---
layout: post
title: "ssh: Connection Refused"
date:  2021-11-08 10:11:53 +0800
categories: linux ssh
---

用windows机器通过ssh （Secure Shell）连接Linux机器时，报错：
```
ssh: connect to host 10.167.158.84 port 22: Connection refused
```

在解决问题前，首先明确一点：**ssh连接的本质是客户端对服务器的一
个连接请求，在上面的场景中，windows机器是客户端，Linux机器是服务器。**

解决问题，首先检查客户端和服务器对应的机器是否安装了相应的ssh软件，即
Windows机器是否安装了`openssh-client`，Linux机器是否安装了`openssh-server`。

这里，我们默认windows机器环境正常（通常如此），主要排查Linux端的问题。

Linux端可以用如下命令来检查是否安装了`openssh-server`：
```
$ apt list --installed | grep openssh-server

openssh-server/bionic-security,bionic-updates,now 1:7.6p1-4ubuntu0.5 amd64 [installed]
```

如果没有安装，则运行以下命令安装`openssh-server`：
```
$ sudo apt-get install openssh-server
```

然后，运行如下命令检查`ssh`的运行状况：
```
$ sudo service ssh status

[sudo] password for guosj:
● ssh.service - OpenBSD Secure Shell server
   Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2021-11-08 09:10:46 CST; 41min ago
  Process: 8422 ExecReload=/bin/kill -HUP $MAINPID (code=exited, status=0/SUCCESS)
  Process: 8418 ExecReload=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
 Main PID: 7105 (sshd)
    Tasks: 1 (limit: 4526)
   CGroup: /system.slice/ssh.service
           └─7105 /usr/sbin/sshd -D
```

如果ssh的状态为`inactive`，运行下面的命令来启动`ssh`服务：
```
$ sudo service ssh restart
```

最后，检查防火墙的状态：
```
$ sudo ufw status

Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
22/tcp (v6)                ALLOW       Anywhere (v6)
```

下面两栏的的`Action`一列的状态为`DENY`，说明当前防火墙规则
不允许ssh连接，运行如下命令修改规则：
```
$ sudo ufw allow ssh
```

以上。


