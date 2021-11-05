---
layout: post
title: "Switch to Zsh Vi mode"
date:  2021-11-05 10:11:53 +0800
categories: zsh
---

在zsh中将输入方式切换成vi模式会使输入命令时更加高效，设置方式是在`~/.zshrc`的底部追加
`bindkey -v`。

不过最近我发现了一个相关的zsh插件[jeffreytse/zsh-vi-mode](https://github.com/jeffreytse/zsh-vi-mode)，
感觉功能很强大的样子。如果你已经安装了[oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)，安装这个插件
的步骤也比较简单：

1. clone `zsh-vi-mode`到`oh-my-zsh`的插件目录：
```
$ git clone https://github.com/jeffreytse/zsh-vi-mode \
        $ZSH/custom/plugins/zsh-vi-mode
```

2. 在zsh配置文件`.zshrc`中增加：
```
$ plugins+=(zsh-vi-mode)
```

3. reload your `.zshrc`：
```
$ . ~/.zshrc
```
或
```
$ source ~/.zshrc
```
