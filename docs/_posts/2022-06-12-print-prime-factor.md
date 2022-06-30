---
layout: post
title: "Print Prime Factor"
date:  2022-06-12 10:11:53 +0800
categories: Leetcode
---

这是华为机试的一道题，题目叫做“质数因子”：
> 输入一个正整数，按照从小到大的顺序输出它所有的质因子（重复的也要列举）。如 180 的质因子为 2, 2, 3, 3, 5。

我们首先来介绍一下什么是“质数”。数字分为质数和合数。质数也叫素数，它只可以被 1 和它本身整除。除质数以外
的数就叫做合数。最小的质数是 2 。

一个合数一定可以由若干个质数相乘得到。这些质数就是这个合数的“质数因子”。求解一个合数 n 的“质因子”的方法如下：
```
1. 我们定义 k 等于最小质数 2，如果 n == k，那么将 n 输出，程序结束
2. 如果 n 可以被 k 整除，则应该打印 k 的值，并让 n = n / k
3. 如果 n 不可以被 k 整除，则 k = k + 1
4. 如果 k 小于等于根号 n，那么重复第二步
```

根据上述方法写出的代码如下：
```c
#include <stdio.h>

int main()
{
    int i, n;

    scanf("%d", &n);
    for (i = 2; i * i <= n; ++i) {
        while (n % i == 0) {
            printf("%d ", i); /* print prime factor of n */
            n /= i;
        }
    }
    if (n > 1) {
        /* n is the last prime factor */
        printf("%d ", n);
    }
    printf("\n");
    return 0;
}
```

以上。
