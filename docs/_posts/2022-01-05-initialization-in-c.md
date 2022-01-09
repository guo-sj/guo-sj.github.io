---
layout: post
title: "Initialization in C"
date:  2022-1-5 10:11:53 +0800
categories: C
---

这篇post来介绍一下C语言中的初始化操作。

`external variable`和`static variable`只能通过初始化语句
进行初始化操作，且它们只能被初始化为常量（constant value）
不能是变量或表达式（expression），如：
```c
int a = 0;    /* external variable initialization */

static char b = '1';  /* external static variable initialization */

char func()
{
    static float c = 2.0;  /* internal static variable initialization */
}
```

`external variable`和`static variable`的初始化语句是在程序运行前
执行，且只会执行一次。

如果没有对它们进行初始化，那么它们会被默认初始化为0。如：
```c
int a;    /* a = 0 */

static char b;  /* b = '\0' */

char func()
{
    static float c;  /* c = 0.0 */
}
```

对于`automatic variable`，它可以被初始化为常量或表达式。如果没有对它
进行初始化，那么它可能为任意的值。实际上，`automatic variable`的初始化
语句只是它赋值语句的缩写，如：
```c
char func()
{
    int a = 1;
}
```
等同于：
```c
char func()
{
    int a;

    a = 1;
}
```
在这里，我赞成K&R书中讲的[1]，**用赋值语句而非初始化语句来对它们进行初始化操作**。

**[1]** We have generally used explicit assignments, because initializers in declarations
are harder to see and further away from the point of use. 这句话的意思是：“我们主要
使用赋值语句来对automatic variable进行初始化，因为相较于赋值语句，初始化语句更难以
被注意到，而且距离该变量被使用的地方更远”

以上。
