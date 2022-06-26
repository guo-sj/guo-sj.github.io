---
layout: post
title: "strtok() in C"
date:  2022-06-26 13:11:53 +0800
categories: C
---

> char \*strtok(char \*str, const char \*delim);

strtok() 会把 str 按照 delim 分开，每次调用会返回一个指向下一个子字符串的指针，解析完成的时候返回 NULL。
因为子字符串以 NULL 结尾，所以你可以把返回的指针按照一个常规的字符串来处理。

第一次调用 strtok 的时候 str 位置传入需要解析的字符串，之后调用的时候则需要传入 NULL。

调用方法如下：
```c
#include <stdio.h>
#include <string.h> /* for strtok() */

int main(void)
{
    char s[] = "1,2,3,4";
    const char *delim = ",";
    char *p;

    for (p = strtok(s, delim); p != NULL; p = strtok(NULL, delim))
        printf("%s\n", p);
    return 0;
}
```

函数运行的结果为：
```
1
2
3
4
```

以上。
