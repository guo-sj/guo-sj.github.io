---
layout: post
title:  "Linux Library 1: Static Libraries (.a)"
date:   2021-11-01 20:00:53 +0800
categories: Linux
---

Consider example files:
- ctest1.c
```c
void ctest1(int *i)
{
   *i=5;
}
```

- ctest2.c
```c
void ctest2(int *i)
{
   *i=100;
}
```

- prog.c
```c
#include <stdio.h>
void ctest1(int *);
void ctest2(int *);

int main()
{
   int x;
   ctest1(&x);
   printf("Valx=%d\n",x);

   return 0;
}
```
How to generate a static library (object code archive file) **libctest.a**?

First of all, Compile \*.c to \*.o:
```
$ cc -Wall -c ctest1.c ctest2.c   # -Wall: include warnings
```

Then create library **libctest.a** by using `ar` command:
```
$ ar -cvq libctest.a ctest1.o ctest2.o
```

You can list files in library:
```
$ ar -t libctest.a

ctest1.o
ctest2.o
```
In the end, linking with static library to get executable file:
```
$ cc -o prog -L. -lctest
```

`-lctest` tells gcc to look for library lib**ctest**.a in `.` (current directory), which 
is specified by `-L.`.

Read [this page](http://www.yolinux.com/TUTORIALS/LibraryArchives-StaticAndDynamic.html) for 
more details.
