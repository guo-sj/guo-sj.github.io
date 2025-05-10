---
layout: post
title: "在 ubuntu 上安装微信"
date:  2024-04-03 10:11:53 +0800
mathjax: false
categories: Linux
---

**============================2025-05-10更新============================**

微信官方增加了对 Linux 的支持，可以直接去[网站](https://linux.weixin.qq.com/en)上下载，然后使用 `dpkg` 进行安装：
```
dpkg -i WeChatLinux_x86_64.deb
```

官方体验还是要比之前的好很多的～

**============================2025-05-10更新============================**


最近重新用回了 ubuntu~，这里记录一下安装微信的过程。

在[ubuntukylin](https://archive.ubuntukylin.com/software/pool/partner/)中，有 `weixin_2.1.4_amd64.deb`。

安装的话也比较简单：
```sh
wget http://archive.ubuntukylin.com/software/pool/partner/weixin_2.1.4_amd64.deb
dpkg -i weixin_2.1.4_amd64.deb
```

不过这个版本的微信不支持各种表情包，也不支持接龙或者红包等操作。emmm...，这里先记录下，之后有更好的版本再更新:-)。

以上。
