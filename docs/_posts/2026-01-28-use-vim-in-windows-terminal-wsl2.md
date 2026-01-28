---
layout: post
title: "在 windows terminal wsl2 中愉快的使用 vim 输入中文"
date:  2026-01-28 02:11:53 +0800
mathjax: false
mermaid: false
categories: Vim
---

通过和豆包讨论，我得到了在 windows terminal 中愉快的使用 vim 输入中文的方法。

这个是我初始 prompt:
> wsl 中，vim 输入中文很烦人。因为输入法在 windows 这边，而 又是通过 windows terminal 去连接到 wsl 中使用的 vim。每次输入完回到 normal 模式，输入法还是中文，需要按下 shift 切换成英文后才可以自由移动。反过来，从 normal 切换成 insert 模式后，输入法还需要手动切成中文再输入

在和豆包交互几轮后，我得到了最终的答案，在 `~/.vimrc` 中加入这么 2 行即可：
```vimrc
" ============== 自动切换输入法（WSL+Windows Terminal专用） ==============

autocmd InsertEnter * call system('cmd.exe /c "powershell -Command (New-Object -ComObject WScript.Shell).SendKeys(''+'' )"')
autocmd InsertLeave * call system('cmd.exe /c "powershell -Command (New-Object -ComObject WScript.Shell).SendKeys(''+'' )"')
```
