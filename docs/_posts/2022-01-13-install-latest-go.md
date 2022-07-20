---
layout: post
title: "Install Latest Go on Ubuntu 20.04"
date:  2022-01-13 10:11:53 +0800
categories: Go
---

最近项目涉及Go编程语言，因此需要构筑Go的编程环境。

在Ubuntu上，用`apt-get`安装`golang`版本太低（1.13），因此
需要手动安装最新版本。

首先从[官网](https://go.dev/dl/)上下载二进制压缩文件：
```
$ wget https://go.dev/dl/go1.17.7.linux-amd64.tar.gz  # 将 1.17.7 换成最新的 golang 版本
```

然后利用`tar`来解压文件到目录`/usr/local`：
```
$ sudo tar -xzf go1.17.7.linux-amd64.tar.gz -C /usr/local
```

更新环境变量`PATH`，把下面的内容加入你的shell配置文件，
以便你可以在任何路径下使用`go`：
```
# vim ~/.zshrc

# add paths of go
export GOROOT="/usr/local/go"
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
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
go version go1.17.7 linux/amd64
```

补充一下，如果需要更新当前机器上的 golang，只要把`/usr/local/go`删掉，
然后再按照上述的步骤安装即可。

当 golang 安装完成之后，还可以通过如下指令安装 golang 调试器 delve：
```
$ go install github.com/go-delve/delve/cmd/dlv@latest
```

以上。
