---
layout: post
title: "Function pointer in C"
date:  2021-11-17 10:11:53 +0800
categories: C
---

在C语言中，存在指向函数的指针类型，被称作`函数指针`。

函数指针的声明几乎和一般的函数声明一样，除了**声明中的函数名被一组括号包起
来，并在函数名前插入一个 `*` （asterisk）**，就像这样：
```c
int (*function_pointer)(int *, int *);
```

和其他指针类型一样，函数指针也有它自己的数组形式。以上述的函数指针类型为例，我们声明
一个大小为 4 的函数指针：
```c
int (*function_pointer[4])(int *, int *);
```

再比如，我们有下列 4 个函数：
```c
int func1(int *, int *);
int func2(int *, int *);
int func3(int *, int *);
int func4(int *, int *);
```

我们可以这样给函数指针数组进行初始化：
```c
int (*function_pointer[4]) (int *, int *) = {
    &func1,
    &func2,
    &func3,
    &func4
};
```

或把“4”省略掉，使得定义更加灵活：
```c
int (*function_pointer[]) (int *, int *) = {
    &func1,
    &func2,
    &func3,
    &func4
};
```

以上。
