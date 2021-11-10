---
layout: post
title: "Install Oh My Zsh"
date:  2021-11-06 11:11:53 +0800
categories: zsh
---

[Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) 是一款非常好用zsh框架。

按照[ohmyzsh README](https://github.com/ohmyzsh/ohmyzsh#basic-installation)的安装方法
总是遇到问题，于是自己总结了一套方法，在此记录下来。


安装它首先需要安装`zsh`：
```
$ sudo apt-get install zsh
```

然后，再从github上clone `ohmyzsh`：
```
$ git clone https://github.com/ohmyzsh/ohmyzsh.git
```

然后运行`ohmyzsh/tools/install.sh`：
```
$ ./ohmyzsh/tools/install.sh
```

等待运行完成即可。
