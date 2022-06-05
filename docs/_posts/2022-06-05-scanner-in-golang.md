---
layout: post
title: "Scanner in Golang"
date:  2022-06-05 10:11:53 +0800
categories: Go
---

`scanner` 类型提供了很多方法，这些方法可以用来方便地处理以 newline 为结尾的文件。我们
可以用 `bufio` package 的方法 `NewScanner` 来创建一个 scanner 类型的实体，然后用 scanner 
的方法 `Scan()` 去扫描该文件。`Scan()` 用来在文件中找 token，每找到一个 token，你就可以
用 `Text()` 方法来获得从本次扫描开始到这个 token 的位置的字符内容。这个 token 可以用 splitFunc 类型的
函数定义，默认为 newline。

下面我们来看一个例子，用 `scanner` 来实现一个 UINX 的经典程序 `cat`：
```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	if len(os.Args) == 1 {
		scanner := bufio.NewScanner(os.Stdin)
		for scanner.Scan() {
			fmt.Println(scanner.Text()) // Println will add back the final '\n'
		}
		if err := scanner.Err(); err != nil {
			fmt.Fprintf(os.Stderr, "reading stand input: %v\n", err)
		}
	} else {
		for _, arg := range os.Args[1:] {
			file, err := os.Open(arg)
			if err != nil {
				fmt.Fprintf(os.Stderr, "%v\n", err)
				continue
			}
			scanner := bufio.NewScanner(file)
			for scanner.Scan() {
				fmt.Println(scanner.Text()) // Println will add back the final '\n'
			}
			if err := scanner.Err(); err != nil {
				fmt.Fprintf(os.Stderr, "reading stand input: %v\n", err)
			}
		}
	}
}
```

以上。
