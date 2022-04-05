---
layout: post
title: "Install Latest Vim Manually"
date:  2022-01-10 14:11:53 +0800
categories: Vim
---

因为centos 7的vim package版本为7.4，而自己需要的是8.0
及以上的版本，所以决定手动安装最新版本的Vim。

过程较为简单，clone 最新的vim代码，然后编译即可：

```
$ git clone https://github.com/vim/vim

$ cd vim

# compile vim with Python3 support
$ ./configure --enable-python3interp --with-python3-command=`which python3`

$ make && make install
```

以上。
