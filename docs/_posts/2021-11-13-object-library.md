---
layout: post
title: "What is Object Library?"
date:  2021-11-13 10:11:53 +0800
categories: Linux
---

什么是`object library`？

`object library`是多个`object files`合成的一个`object file`，可以被多个`executable file`方便
地使用。

我们知道，一种生成`executable file`的方式是，先根据`source files`生成相应的`object files`，
然后将生成的`object files`用`linker`链接起来，最后生成可运行的`executable file`，就像这样：
```
$ cc -g -c prog.c mod1.c mod2.c mod3.c

$ cc -g -o prog_nolib prog.o mod1.o mod2.o mod3.o
```

但是呢，有很多时候，我们或许会有一些`source files`被不止一个`executable file`用到。在这种
情况下，我们可以首先将`source files`生成相应的`object files`，然后，再将生成的`object files`
按需链接起来，生成不同的`executable files`。这样虽然节省了我们编译时间，但是又造成了另一个
问题，那就是我们仍然需要在链接阶段一个一个地列出`object file`的名字，而且我们在自己的机器上
会充满大量的`object files`。

因此为了解决这个问题，我们可以将多个`object files`打包成一个`unit`，这个`unit`就叫做
`object library`。

`object library`分为两种，`static library`和`shared library`。
其中`shared library`更加先进，而且相较于出现较早的`static library`，有很多优势。

**注**：以上内容基本相当于对“《The Linux Programming Interface》Chapter 41: Fundamentals of Shared 
Libraries 41.1 Object Libraries” 的翻译，更加具体详细的内容，请看原版。

以上。
