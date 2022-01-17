---
layout: post
title: "Vim-go proxy problem"
date:  2022-01-17 10:11:53 +0800
categories: Go
---

安装[vim-go](https://github.com/fatih/vim-go)插件后，需要用命令`:GoInstallBinaries`安装`gopls`等文件，
但是因为国内网络问题，安装过程经常会报错。

经过调查，发现可以通过配置[代理](https://goproxy.cn/)解决这个问题。

在shell中输入如下命令：
```
$ go env -w GO111MODULE=on

$ go env -w GOPROXY=https://goproxy.cn,direct
```

然后进入Vim运行`:GoInstallBinaries`等待安装完成即可。

以上。

