---
layout: post
title: "Paste mode in Vim"
date:  2025-07-02 10:13:53 +0800
categories: Vim
---


vim 里有个 `paste mode`，当进入这个模式后，你在 .vimrc 中的所有的设置将不会生效，因此
可以很方便的粘贴文本而不用担心格式之类的问题。

```vimscript
:set paste " 进入 paste 模式
:set nopaste " 退出 paste 模式
```

In addition，我更喜欢这种方式，把下面这行加入到你的 .vimrc 中：
```vimscript
" 进入/退出粘贴模式
set pastetoggle=<F2>
```

这样每次粘贴时，只需要按下 `<F2>`，然后粘贴完成后再按 `<F2>` 退出即可。

以上。

