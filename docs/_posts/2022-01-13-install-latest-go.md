---
layout: post
title: "Install Latest Go on Ubuntu 20.04"
date:  2022-01-13 10:11:53 +0800
categories: Go
---

最近项目涉及Go编程语言，因此需要构筑Go的编程环境。

在Ubuntu上，用`apt-get`安装`golang`版本太低（1.13），因此
需要手动安装最新版本。

首先从网址上下载二进制压缩文件：
```
$ wget https://go.dev/dl/go1.17.6.linux-amd64.tar.gz
```

然后利用`tar`来解压文件到目录`/usr/local`：
```
$ sudo tar -xzf go1.17.6.linux-amd64.tar.gz -C /usr/local
```

更新环境变量`PATH`，把下面的内容加入你的shell配置文件，
以便你可以在任何路径下使用`go`：
```
# vim ~/.zshrc

# add path of go
export PATH=$PATH:/usr/local/go/bin
```

重新加载shell配置文件，并用`which`程序检查：
```
$ . ~/.zshrc

$ which go
/usr/local/go/bin/go
```

最后，查看go的版本信息：
```
$ go verison
go version go1.17.6 linux/amd64
```

以上。
