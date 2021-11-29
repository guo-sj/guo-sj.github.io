---
layout: post
title: "External Variables and Functions in C"
date:  2021-11-30 10:11:53 +0800
categories: C
---

这篇文章讲一下C语言中`external variable`和`function`。

`external`是相对于`internal`而言的。`internal variable`就是**定义在函数中的
变量**，`external variable`则是**定义在函数外的变量**。

相较于`internal variable`，`external variable`有着**更长的生命周期**。
因为`internal variable`是定义在函数内部的变量，所以它会在程序进入函数时
创建，离开函数时消失。然而，`external variable`则是永久的（permanent），所以它可以
在不同函数之间保持自己的数值。这就意味着它**可以被多个函数引用**。
所以像函数的`arguments`和`return value`一样，`external variable`可以
用于**不同函数之间的信息交流**。

如：
```c
int a;    /* define an external variable */

void func1()
{
    a = 9;
}

int main(void)
{
    int b;    /* define an internal variable */
    printf("a = %d\n", a);  /* print "a = 9" */
    
    return 0;
}
```

对于函数而言，C语言规定所有的函数必须是`external`的，因为C语言**不允许在
一个函数内定义其他函数**。

C语言中`variable`和`function`与`internal`和`external`的关系如下表所示：

|              | internal | external |
| ---          | :---:    | ---      |
| **variable** | ✓        | ✓        |
| **function** | ✗        | ✓        |

以上。
