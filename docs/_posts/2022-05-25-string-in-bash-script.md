---
layout: post
title: "String in Bash Script"
date:  2022-05-25 10:11:53 +0800
categories: Shell
---

如果我们想要把两个 string 变量 str1 和 str2 合成一个 str3，那么可以这样做：
```sh
str1="Hello, "
str2="World."
str3=$str1$str2
echo $str3 # "Hello, World."
```

如果我们想要把 str3 分开按照“,”分开，那么我们可以借助`cut`程序来实现：
```sh
$ echo $str3 | cut -d ',' -f 1  # "Hello"
$ echo $str3 | cut -d ',' -f 2  # " World"
```

以上。
