---
layout: post
title: "在 Ubuntu 22.04 上安装 Java 环境"
date:  2024-12-14 12:11:53 +0800
mathjax: false
mermaid: false
categories: Java
---

最近在读《设计模式的艺术》，里面的例程都用的是 Java 代码，代码光看不写肯定不行，所以需要在机器上配置一下 Java 环境，这里记录一下。

```sh
sudo apt update && sudo apt install openjdk-17-jdk
```

```sh
$ javac --version

javac 17.0.13
```

接着就可以写自己第一个 Java 程序啦～

```java
// cat HelloWorld.java
public class HelloWorld {
    // A Java program begins with a call to main().
    public static void main(String args[]) {
        System.out.println("Hello, World");
    }
}
```

java 和我接触过的其他语言不一样的是，文件的名称通常要求和类名一样，所以要把上述代码保存为 `HelloWorld.java`。
接着，我们用 `javac`，即 `java compiler` 去编译它，生成一个 `HelloWorld.class` 的 bytecode 文件。
```sh
$ javac HelloWorld.java

$ ls
HelloWorld.class  HelloWorld.java
```

因为 java 程序是跑在 JVM (Java Virtual Machine) 上的，所以 javac 编译生成的文件无法在机器上直接运行，需要再
用 `java` 解释器运行：
```sh
$ java HelloWorld
Hello, World
```
