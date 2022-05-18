---
layout: post
title: "Discrete Skills of Bash Script"
date:  2022-04-14 10:11:53 +0800
categories: Bash-Script
---

工作和生活中不可避免的会用到Bash Script，但是又没有足够的时间系统的学习，
索性用博客记录下来平时用到的一些小技巧，避免重复的搜索。

1. 判断一个程序是否安装。如，我想知道当前系统中是否安装了`vim`，则可以
这样写：
```sh
#!/bin/bash

if ! command -v vim >/dev/null
then
    echo vim is not found.
else
    # some operations
fi
```

2. 判断一个变量的值是否为空。如我想知道当前系统中的`MYVIMRC`是否为空，
则可以这样判断：
```sh
#!/bin/bash

if [ -z "$MYVIMRC" ]; then
    echo "\$MYVIMRC is empty"
else
    # some operations
fi
```

3. 判断一个命令是否执行正确：
```sh
#!/bin/bash

if command; then
    echo "succeed"
else
    echo "fail"
fi
```
或者可以这样：
```sh
#!/bin/bash

command
if [ $? -eq 0 ]; then
    echo "succeed"
else
    echo "fail"
fi
```

以上。
