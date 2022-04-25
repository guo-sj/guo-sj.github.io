---
layout: post
title: "Ssh without Password"
date:  2022-01-24 10:11:53 +0800
categories: Ssh
---

经常需要用`scp`拷贝文件到服务器，每次都需要输入密码，比较烦。

经过搜索发现，其实通过一些设置，可以省去输入密码的步骤。

首先，生成本地的`ssh key`：
```
$ ssh-keygen -t rsa -b 2048
Generating public/private rsa key pair.
Enter file in which to save the key (/home/username/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/username/.ssh/id_rsa.
Your public key has been saved in /home/username/.ssh/id_rsa.pub.
```

然后把生成好的`ssh key`拷贝到目标服务器：
```
$ ssh-copy-id username@server_ip
```
这一步需要输入服务器密码。

最后，测试无密码登录：
```
$ ssh username@server_ip

username@server_ip:~$
```

成功。

以上是Linux/MacOS平台的做法，下面补充一下Windows平台的。步骤都是一样的，
只是命令略有不同。

首先生成SSH Key：
```
$ ssh-keygen
```

然后，拷贝SSH Key到目标服务器：
```
$ type $env:USERPROFILE\.ssh\id_rsa.pub | ssh username@server_ip "cat >> .ssh/authorized_keys"
```

成功。

以上。
