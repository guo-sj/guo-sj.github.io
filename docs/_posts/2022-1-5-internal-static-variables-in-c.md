---
layout: post
title: "Internal static variables in C"
date:  2022-1-5 10:11:53 +0800
categories: C
---

在C中，internal static variable 可以保持自身的值。初始化语句
定义的internal static variable 只会在第一次进入所在函数的时候
执行。此外，internal static variable 只能被初始化为常量(constant value)。

在一个递归函数中使用internal static variable由其注意它们的复位问题。

以上。
