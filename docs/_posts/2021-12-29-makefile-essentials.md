---
layout: post
title: "Makefile essentials"
date:  2021-12-29 10:11:53 +0800
categories: Makefile
---

在这篇文章里，我想把已经知晓的`Makefile`的知识做一个整理。

### Makefile的基本语法
`Makefile`的基本语法比较简单：
```
    target-name: list-of-dependences
        commands
```
用自然语言来描述：
1. 生成`target-name`需要`list-of-dependences`
2. `list-of-dependences`通过`commands`来生成`target-name`

这里需要说明一点，用来生成`target`的`dependences`也有可能
是另一个语句的`target`，如：
```
    target: dependence1 dependence2
        commands

    dependence1: dependence3
        commands
```

### Makefile的核心理念
众所周知的是`Makefile 可以为我们编译大型项目节省大量的时间`，
但是具体是如何做到这一点的呢？

这里，就需要引入Makefile的一个核心理念：**up-to-date**。
`up-to-date`指的是**target的最后修改时间（last modified time）
不早于它的dependences的最后修改时间**。如果生成一个target
需要多个dependences，那么这时的target的最后修改
时间应该不早于它的多个dependences中**最晚的**最后修改时间。

另外，在Makefile实际上是以`递归`的形式编写，所以在确定target
的up-to-date的状态的时候也是`递归`进行的。

因此运行make程序，实际上只做了这样一件事，即**检查对应的`target`
的当前状态是否为`up-to-date`，如果不是，则执行相应的操作更新
`target`为`up-to-date`的状态**。

现在我们来假设这样一种情况，需要编译100个.c文件来生成一个
可执行目标文件。这时我们因为对应一个需求，修改了其中的一个
.c文件，如果没有Makefile，那么我们就需要重新编译这100个文件
来生成一个新的可执行文件，这中间的过程包括将100个.c编译生成
100个.o文件，再将100个.o文件链接生成可执行文件。

但是如果有Makefile，当执行make程序
的时候，发现只有该.c文件及相关的.c文件对应的.o文件没有达到
up-to-date的状态，因此只要编译该.c文件及相关的.c文件使得
它们对应的.o文件的状态为up-to-date，再通过将所有的.o
文件链接起来使得最后的可执行文件为up-to-date。

可以看到，后者相较于前者，在大多数情况
下较大程度的减少了需要重新编译文件的数量，因此相应的节省了
编译花费的时间。最极端的情况，即所有文件都被修改的情况，后者
的时间和前者等同，但是这是极少发生的。因此，总的来说，
Makefile可以帮助我们节省大量的时间。

### Makefile的变量
考虑这样一个Makefile:
```
TARGET = main
OBJECTS = copy.o main.o
SOURCES = copy.c main.c
CC = gcc
LDFLAGS = -o
CFLAGS = -g -c

all: $(TARGET)

$(TARGET): $(OBJECTS)
    $(CC) $(LDFLAGS) $(TARGET) $(OBJECTS)

$(OBJECTS): $(SOURCES)
    $(CC) $(CFLAGS) $(OBJECTS) $(SOURCES)

clean:
    rm $(OBJECTS) $(TARGET)
```

上述的Makefile在开头定义了一些变量，如`TARGET`，`OBJECTS`等，
它们是大部分的Makefile都会含有的一些变量，所以值得了解它们
各自的具体含义：

- TARGET: 整个Makefile最终的产物，通常为一个二进制可执行文件或者一个`.so`文件
- OBJECTS: 编译过程第三阶段（assembler）生成的`.o`文件
- SOURCES: 源代码文件，对于`C/C++`来说，为`.c`或`.cpp`文件
- CC: 编译器（compiler），如`gcc`或`g++`
- LDFLAGS: 链接标志位（linker flags）
- CFLAGS: 编译标志位（compiler flags）

如果需要引用之前定义的变量，那么需要在变量名前加一个美元符号（$），并用
大括号（{}）或者小括号（()）把这个变量名括起来。如对于变量`TARGET`来说，
引用时应当写成`${TARGET}`或者`$(TARGET)`。

值得注意的是，虽然这两种方式都可以用来引用变量，但是这里并
不建议它们混合使用。为了Makefile的可读性，在它们中选择一个
你喜欢的，然后从头到尾的使用，如上面的Makefile中所呈现的那样。

### Makefile的特殊符号
Makefile中有一些特殊的变量 -- automatic variables，可以让编写
的过程更加简单，如：

- $@: 代表当前操作中target的文件名
- $<: 代表第一个dependence的文件名
- $^: 代表所有dependences的文件名，文件名之间用空格分隔

更多信息见手册[Automatic Variables (GNU make)](https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html#Automatic-Variables)。

### Makefile的执行

在含有`Makefile`的目录下，输入：
```
    $ make target-name
```
注意，这里的`target-name`是Makefile中众多target的其中一个。这条shell语句
用来指示make程序按照当前目录下的Makefile去生成`target-name`。

如果把`target-name`省略，仅仅输入：
```
    $ make
```
则make程序会去生成Makefile中定义的第一个`target`。

值得说明的是，在Makefile中，一个`target`不仅可以是文件名，也可以是一个
任务名（task name），如上文Makefile中的`all`和`clean`。这里鼓励把最终
的`target`写成这样的任务名，这样使得执行起来更加方便和准确，如对于上文
Makefile，我们想要执行clean任务后，再生成最终的可执行文件，输入下述命令
即可：
```
    $ make clean all
```

### 一些有用的命令行标志位

这里介绍一些实用的命令行标志位：

- -f filename: 

用于指定make程序执行的文件，例如我们想让make程序执行`file1.mk`而不是默认的
`Makefile`，我们可以这样做：
```
    $ make -f file1.mk target-name
```

- -C dir:

用于切换到目录`dir`，并执行`dir`目录下的Makefile，在子目录中存在Makefile的情况
下用到。语法为：
```
    $ make -C target-name
```

- -d:

用于打印make程序工作的信息，非常详细，可以用来Debug所执行的Makefile。

### Makefile中的一些小技巧

这里记述一下目前积累的编写Makefile的小技巧（tricks）。

- $(wildcard lib/*.c):
这个技巧经常用在给SOURCES变量赋值的过程中，如：
```
SOURCES = main.c \
         $(wildcard lib/*.c) \
         $(wildcard lib/fileio/*.c)
```

- OBJECTS = $(SOURCES:.c=.o):
这个技巧通常用来给OBJECTS变量赋值的过程中，
意思是“指定OBJECTS为所有SOURCES的.c文件对应
的.o文件”

- %.o: %.c:
这个语句的意思是，先找到文件名和`.o`文件一样，
但是后缀为`.c`的文件，编译它们来生成对应的`.o`
文件。

以上。
