---
layout: post
title: "Static Variables and Functions in C"
date:  2021-12-02 10:11:53 +0800
categories: C
---

在介绍完C语言中的[external variable和function](https://guo-sj.github.io/c/2021/11/30/external-variables-and-functions-in-c.html)
和[scope rules](https://guo-sj.github.io/c/2021/11/30/scope-rules-in-c.html)之后，
这一次，我们来谈谈C语言中的`static variable`和`static function`。

对于`external variable`，关键字`static`可以用来限制该变量的`scope`为
它定义的这一行到文件末尾，**并且无法通过`extern`声明来从其他文件来访问**。
因此，我们可以说，**`static external variable`对于它所在的文件是`私有的`。**

对于`internal variable`，`static`可以使**变量的值保持下来**，不会随着所在函数
的调用而重新创建，或随着函数的退出而消失。

C语言中规定函数只能是`external`的，所以和`external variable`的效果一样，
对于`static function`来说，它的`scope`为其声明所在的那一行到文件结束，
**其他文件无法通过声明来对它进行访问**。

最后，我们可以通过一张图来从计算机科学的角度看一下C/C++中的变量和函数
在stack中的位置：

![stack and heap](/assets/stack-and-heap.jpg)

以上。
