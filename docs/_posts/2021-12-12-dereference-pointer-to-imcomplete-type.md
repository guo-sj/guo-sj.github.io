---
layout: post
title: "Dereference pointer to incomplete type"
date:  2021-12-12 12:11:53 +0800
categories: C
---

在处理如下代码时，编译器报错`Dereference pointer to incomplete type`。

a.c:
```c
1 struct point {
2     double x;
3     double y;
4 };
5 
6 ... other code ...
```

a.h:
```c
1 typedef struct point *Point;
```

main.c:
```c
1 #include "a.h"
2 
3 int main(void)
4 {
5     Point p;
6     p->x = 2.3;    /* Dereference pointer to incomplete type */
7     return 0;
8 }
```

原因是`Point`声明在`a.h`中，`main.c`包含了`a.h`，所以在`main.c`中，`Point`的[scope](https://guo-sj.github.io/c/2021/11/30/scope-rules-in-c.html)
为第一行到文件末尾。`struct point`的`scope`为`a.c`的第4行到该文件末尾。
**因为`main.c`并不在`struct point`的`scope`内，所以当你在`main.c`中试图
对`(struct point *) p`进行dereference的时候，编译器并不知道此时`struct point`
在`main.c`的意思，所以会报错**。

解决方法也简单，**在`main.c`中dereference `(struct point *) p`之前，声明`struct point`
即可**。修改后的`main.c`如下：
```c
1  #include "a.h"
2 
3  struct point {
4      double x;
5      double y;
6  };
7
8  int main(void)
9  {
10     Point p;
11     p->x = 2.3;    /* problem gone! */
12     return 0;
13 }
```

以上。
