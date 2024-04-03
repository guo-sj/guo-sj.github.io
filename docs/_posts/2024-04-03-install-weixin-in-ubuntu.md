---
layout: post
title: "在 ubuntu 上安装微信"
date:  2024-04-03 10:11:53 +0800
mathjax: true
categories: Linux
---

最近重新用回了 ubuntu~，这里记录一下安装微信的过程。

在[ubuntukylin](https://archive.ubuntukylin.com/software/pool/partner/)中，有 `weixin_2.1.4_amd64.deb`。

安装的话也比较简单：
```sh
wget http://archive.ubuntukylin.com/software/pool/partner/weixin_2.1.4_amd64.deb
dpkg -i weixin_2.1.4_amd64.deb
```

不过这个版本的微信不支持各种表情包，也不支持接龙或者红包等操作。emmm...，这里先记录下，之后有更好的版本再更新:-)。

以上。
