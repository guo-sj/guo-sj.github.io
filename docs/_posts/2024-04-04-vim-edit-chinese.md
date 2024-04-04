---
layout: post
title: "如何在 Ubuntu 系统中使用终端 vim 流畅地输入中文"
date:  2024-04-04 10:11:53 +0800
categories: Vim
---

我很喜欢在 Ubuntu 的终端里用 vim 去写一些东西。但是因为我的母语是中文，所以大部分的内容
都会拿中文去写。但是终端的 vim 对于中文的支持并不友好，常常是输入完中文，按下 `Esc` 回到
 normal mode 想上下移动的时候，因为输入法没有自动切换回英文，导致无法正常移动。

后来我发现了这个插件[vim-barbaric](https://github.com/rlue/vim-barbaric) 可以解决上述的痛点，
下面我就来描述一下我的使用过程。

先说下我的环境：Ubuntu 22.04 LTS + vim 8.2（终端中使用）

首先使用 [Vundle](https://github.com/VundleVim/Vundle.vim) 去安装 `vim-barbaric`，在 `~/.vimrc` 中写入：
```vimscript
" barbaric
Plugin 'rlue/vim-barbaric'
```

然后在 vim 中敲入 `:PluginInstall` 安装插件。

第二步，使用 ibus 去安装中文输入法，我这里以五笔为例：
```sh
sudo apt update && sudo apt upgrade
sudo apt install ibus-table-wubi
```

接着**重启**，重启之后，在命令行中敲入 `ibus engine xkb:us::eng` 把默认的输入法改成英文，即可以在 vim 的 normal mode
 流畅移动的输入法：
```sh
ibus engine xkb:us::eng # 设置默认输入法
ibus engine # 查看当前默认输入法
xkb:us::eng # 回显成这个样子就证明设置成功
```

最后我们看一下效果：打开 vim，切换到中文输入法输入几个字，接着按下 `Ecs`，你可以像正常的上下左右移动，然后你
再按下 `i` 进入 `Input Mode`，你又可以正常地输入中文。

最后简单地讲下 `barbaric` 的原理。它首先有一个全局变量 `g:barbaric_ime` 识别当前的 IME，还有一个全局
变量 `g:barbaric_default` 来记录你切换成 normal mode 时的输入法，
对于 ibus 而言，这个变量的值就是 `ibus engine` 命令的输出，所以我们上面才要把 `ibus engine` 改成 `xkb:us::eng`。
此外 `barbaric` 还会把你在 input mode 的输入法记录下来。这样的话，就可以在对应的模式下切换到正确的输入法了。

如果按照上述操作没有得到预期的结果，那么可以在 vim 的 command mode 使用命令 `echo g:barbaric_ime` 或 `echo g:barbaric_default`
来查看对应的全局变量结合插件源码进行问题定位。

以上。
