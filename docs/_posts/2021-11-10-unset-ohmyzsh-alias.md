---
layout: post
title: "Unset Alias In Oh My Zsh"
date:  2021-11-10 16:11:53 +0800
categories: Zsh
---

自己最近一直在使用[Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh)。今天我发现
`Oh My Zsh`附带的`gds (alias)`和我本地的一个命令冲突了，于是学习了一下解决冲
突的方法，在此记录下来。

在命令行中查看当前`gds`的含义：
```
$ which gds
gds: aliased to git diff --staged
```

在`~/.zshrc`中加入如下语句取消`gds`设定：
```
# ~/.zshrc

# unset oh-my-zsh's gds which is alias to 'git diff --staged'
# so my /home/guosj/.local/bin/gds works instead
unalias gds
```

重载`~/.zshrc`:
```
$ . ~/.zshrc
```

再次查看`gds`的含义：
```
$ which gds
/home/guosj/.local/bin/gds
```

参考[How to unset aliases set by Oh My Zsh](https://www.peterbe.com/plog/how-to-unset-aliases-set-by-oh-my-zsh)。

以上。
