---
layout: post
title: "size_t and ssize_t"
date:  2022-08-01 10:11:53 +0800
categories: C
---

在 C 语言中，有 size_t 和 ssize_t 两种类型。我们先说 size_t。

size_t 用来描述机器中任意数量的 byte。用来承载像运算符 sizeof() 或 函数strlen() 的返回值，是无符号类型。也就是
说，它是一个足够大的类型，大到可以描述该机器上任意大小的无符号整数。

而 ssize_t 则可以理解为 signed size_t，它是 size_t 的带符号版本，可以用来描述负数。

当输出时，我们可以用 %zu 和 %zd 来对 size_t 和 ssize_t 类型进行输出，如：
```c
int main(void)
{
    size_t a;
    ssize_t b;

    printf("%zu %zd\n", a, b);
    return 0;
}
```

以上。
