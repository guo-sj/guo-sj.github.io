---
layout: post
title: "Linux Library 2: Shared Object (.so)"
date:  2021-11-01 20:11:53 +0800
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
How to generate a dynamically linked library (shared object) **libctest.so**?

At first, create object code:
```
$ cc -Wall -fPIC -c ctest1.c ctest2.c  
```
The `-fPIC` flag means to output **P**osition **I**ndependent **C**ode, 
a characteristic **required** by shared libraries.

Then, create library:
```
$ cc -shared -o libctest.so ctest1.o ctest2.o
```
The `-shared` flag is required to produce a shared object which can then 
be linked with other objects to form an executable.

Optionally, Move the shared object to some special directories, such as `/usr/local/lib` to make linker could find it easily.
```
$ sudo mv libctest.so /usr/local/lib
```

The last step, link with shared library to create an executable file:
```
$ cc -o prog -lctest
```

When you got an executable file, you can list its shared library dependencies by using `ldd` command:
```
$ ldd prog

linux-vdso.so.1 (0x00007ffe9aba5000)
libctest.so => /usr/local/lib/libctest.so (0x00007f87a541f000)
libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f87a522d000)
/lib64/ld-linux-x86-64.so.2 (0x00007f87a5440000)
```

**TODO**: make it better, add contents about ldconfig and list /etc/ld.so.conf.d

