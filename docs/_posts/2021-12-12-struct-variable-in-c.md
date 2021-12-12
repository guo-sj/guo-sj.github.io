---
layout: post
title: "Struct Variable in C"
date:  2021-12-12 10:11:53 +0800
categories: C
---

在C中，我们可以将彼此相关的多种类型的变量用一个**结构体（structure）**
变量管理起来。结构体变量的声明方式为：
```c
struct structure-tag {
    member 1
    member 2
    ...
};
```

这里，`structure-tag`是一个`optional name`，我们可以用它来定义
这个结构体的变量：
```c
struct structure-tag var1, *var2;
```

这种定义方法等同于：
```c
struct {
    member 1
    member 2
    ...
} var1, *var2;
```
其实，`struct`变量的定义语法和C语言中其他变量（*int*之类的）的定义语法一样：
```c
variable-type variable-name
```
这里，`struct structure-tag`和`struct {...}`就是`variable-type`，
`structure-tag`是`{...}`的一个简写。

当然，我们也可以在声明的时候定义变量：
```c
struct structure-tag {
    member 1
    member 2
    ...
} var1, *var2;
```

再结合上`typedef`：
```c
typedef struct structure-tag {
    member 1
    member 2
    ...
} StructVar, *StructPointer;

StructVar var1;
StructPointer var2;
```
以上。
