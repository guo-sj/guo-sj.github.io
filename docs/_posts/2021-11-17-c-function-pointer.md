---
layout: post
title: "Function pointer in C"
date:  2021-11-17 10:11:53 +0800
categories: C
---

在C语言中，存在指向函数的指针类型，被称作`函数指针`。

函数指针的声明几乎和一般的函数声明一样，除了**声明中的函数名被一组括号包起
来，并在函数名前插入一个 `*` （asterisk）**，就像这样：
```
int (*function_pointer)(int *, int *);
```

以上。
