---
layout: post
title: "Scope Rules in C"
date:  2021-11-30 14:11:53 +0800
categories: C
---

上一篇文章讲了[C语言中external variable和function](https://guo-sj.github.io/c/2021/11/30/external-variables-and-functions-in-c)，
这篇文章讲一下C语言中的`Scope Rules`。

一个变量名或者函数名`Scope`是指**它可以被使用的那部分程序空间**[1]。

对于一个定义于函数开头的`internal variable`来说，它的`scope`就是它所在的函数。

不同函数间的命名相同的`internal variable`之间没有关联；
不同函数间命名相同的`parameter`之前没有关联，因为在一个函数中，
它的`parameter`等同于一个`internal variable`。如：
```c
void func1(int b)
{
    int a = 1;
    
    return a + b;
}

void func2(int b)
{
    int a = 100;   /* unrelated with a defined in func1() */
    
    return a - b;  /* unrelated with b which is parameter of func1() */
}
```

对于`external variable`或`function`而言，它的`scope`是从它声明（declaration）的那一行起，
到所在文件的末尾[2]。如：
```c
main() { ... }

/* define external variable sp and val */
int sp = 0;
double val[MAXVAL];

void push(double f) { ... }

double pop(void) { ... }
```
作为`external variable`，`sp`和`val`可以用于函数`push`和`pop`，但是不可以用于函数`main`。
同样的，函数`push`和`pop`也不可以用于`main`。

如果想在一个`external variable`的定义（definition）之前使用它，或者想在一个文件中使用
定义在另一个文件中的`external variable`，则需要对这个`external variable`进行强制的
`extern`声明。

因此，如果想要在`main`中使用`sp`和`val`，我们只需要在`main`前面加上它们两个的`extern`
声明即可，就像这样：
```c
/* declaration external variable sp and val */
extern int sp;
extern double val[];

main() { ... }

/* define external variable sp and val */
int sp = 0;
double val[MAXVAL];

void push(double f) { ... }

double pop(void) { ... }
```

我们有必要在这里说明一下，一个`external variable`的**声明**（declaration）和
**定义**（definition）的区别。

声明（declaration）宣告了变量的属性，主要是这个变量的类型；而定义（definition）不仅
宣告了变量的属性，同时还为它分配了存储空间。比如：
```c
int sp = 0;
double val[MAXVAL];
```
这段代码定义了`external variable`sp和val，为它们分配了存储空间，并且作为声明宣告了它们
的`scope`为这一行到文件末尾。

而：
```c
extern int sp;
extern double val[];
```
声明了`sp`是一个`int`类型变量，`val`是一个`double`类型的数组，数组的大小则由变量定义
的地方决定。但是这段代码并不创建它们也不为它们分配空间。

此外，在一个程序的源代码中，只能有一个`external variable`的定义，其他文件可以通过
`extern`声明来对它进行访问。对于数组变量，数组大小必须在其定义的时候进行说明，声明
的时候说或不说（像上面的val[]）都可以。

`external variable`的初始化只能在**定义**的时候进行。

以上。

[1] 来自K&R的《The C Programming Language》，原句为“The scope of a name is the part
of the program within which the name can be used.”

[2] 来自K&R的《The C Programming Language》，原句为“The scope of an external variable
or a function lasts from the point at which it is declared to the end of the file being
compiled.”
