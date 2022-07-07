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
assertion形式：
```sh
#!/bin/bash

if ! command; then
    echo "fail"
else
    echo "succeed"
fi
```

当然，我们也可以使用`$?`进行判断，像这样：
```sh
#!/bin/bash

command
if [ $? -eq 0 ]; then
    echo "succeed"
else
    echo "fail"
fi
```

4. 用一个例子来介绍，Shell中的`for`循环语法：
```sh
#!/bin/bash

people="Tom Mary Eric"
for person in $people
do
    echo $person
done
```
值得注意的是，这里的 person 是 people 中元素的一个拷贝，不能用于修改
people中元素的值。

5. 用以下命令可以向远程机器发送命令：
```sh
$ ssh host@ipaddr [command]
```
如：我们去杀掉`tom@192.168.3.45`机器上的`vim`进程（pid: 9985）：
```sh
$ ssh tom@192.168.3.45 kill -9 9985
```

6. Bash 中的数组用法。
```sh
# define an array
elems=(
    "1"
    "2"
    "3"
    "4"
)

# iterate this array
for elem in "${elems[@]}"
do
    echo $elem
done
```

以上。
