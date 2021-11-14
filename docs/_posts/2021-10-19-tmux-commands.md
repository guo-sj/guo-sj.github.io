---
layout: post
title: "Tmux Commands"
date:  2021-10-19 17:28:53 +0800
categories: Tmux
---

 这是一些我平时会用到的`tmux`命令。

| command     | action  |
| :---:       | :---:     |
| **tmux new-session -s Name**    | create a new session and name it |
| **^b .**    | move windows |
| **^b ,**    | rename window |
| **^b c**    | create another window |
| **^b !**    | close all panes except the one you focusing |
| **^b "**    | open a horizental pane |
| **^b %**    | open a vertical pane |
| **^b Esc**    | enter select-mode |
| **^b space && enter**    | start select test && finish |
| **^b p**    | paste buffer (**personal**) |

And my personal [.tmux.conf](https://github.com/guo-sj/my-dot-file/blob/main/tmux/.tmux.conf) file.
