---
layout: post
title: "使用 sed 去替换文件中的 pattern"
date:  2025-08-03 10:11:53 +0800
mathjax: false
mermaid: false
categories: Shell
---

在 GNU/Linux 中，我们可以使用 `sed -i 's/before/after/g' file1 file2 ...` 去替换文件中的某个 patten。
但是在 MacOS 中，我们用上面的命令会得到报错：
```sh
➜  hoc-unix git:(main) sed -i 's/int/double/g' init.c
sed: 1: "init.c": command i expects \ followed by text
```

这个是因为在 MacOS 中，或者说在 BSD UNIX 中，`sed -i` 的用法是这样的：
```sh
sed -i 'backup-file' 's/before/after/g' file1 file2 ...
```

相比于 `GNU/Linux` 的 sed 多了 `backup-file` 的参数，如果我们不需要，那么就写空：
```sh
sed -i '' 's/before/after/g' file1 file2 ... # 等价于 GNU 版本的 sed -i 's/before/after/g' file1 file2 ...
```

如果需要则可以这样写：
```sh
➜  hoc-unix git:(main) ✗ sed -i '.bak' 's/double/int/g' init.c
➜  hoc-unix git:(main) ✗ diff init.c init.c.bak
7c7
<     int cval;
---
>     double cval;
14c14
<     {(char *)0, (int)0},
---
>     {(char *)0, (double)0},
19c19
<     int (*func)(int);
---
>     double (*func)(double);
28c28
<     // "int", integer, /* 不清楚对应 math.h 的哪个函数 */
---
>     // "double", doubleeger, /* 不清楚对应 math.h 的哪个函数 */
35c35
<     int i;
---
>     double i;
➜  hoc-unix git:(main) ✗ 
```
