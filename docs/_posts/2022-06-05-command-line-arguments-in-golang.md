---
layout: post
title: "Parse Command Line Arguments and Flags in Golang"
date:  2022-06-05 09:11:53 +0800
categories: Go
---

Golang 中用 `os.Args` 来访问命令行参数，它相当于 C 语言中的 `char *argv[]`。如我们可以用它来实现一个 `echo` 程序：
```go

package main

import (
	"fmt"
	"os"
)

func main() {
	for _, arg := range os.Args[1:] {
		fmt.Printf("%s ", arg)
	}
	fmt.Println()
}
```

Golang 中还提供了处理命令行 flag 的方法，这些方法位于 `flag` package 中。比如下面的程序提供了一个 `-port` 的
命令行 flag，用来指定 server 监听的端口：
```go
package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"net"
	"time"
)

var port *int

func init() {
	port = flag.Int("port", 8000, "port the server will listen to")
	flag.Parse()
}

func main() {
	ipport := fmt.Sprintf("localhost:%d", *port)
	listener, err := net.Listen("tcp", ipport)
	if err != nil {
		log.Fatal(err)
	}
	for {
		conn, err := listener.Accept()
		if err != nil {
			log.Print(err)
			continue
		}
		go handleConn(conn)
	}
}

func handleConn(c net.Conn) {
	defer c.Close()
	for {
		_, err := io.WriteString(c, time.Now().Format("15:04:05\n"))
		if err != nil {
			return
		}
		time.Sleep(1 * time.Second)
	}
}
```
> port = flag.Int("port", 8000, "port the server will listen to")

这一行中，`flag.Int` 用来设置 `-port` flag，其中，方法名 `Int` 代表的是 flag 的类型为 `int`，第一个参数为 flag 名，这里是 `port`，
第二个参数为默认值，这里是 `8000`，第三个参数是 flag 的描述，是当你输入 `./server -h` 或 `./server --help` 的时候输出
的内容，这里写的是 "port the server will listen to"。 

这里给出的是一个 int 类型的命令行 flag，其实其他类型的 flag 定义的方法和这个大同小异，比如我们可以定义一个 string 类型的
flag `ip`：
```go
ip := flag.String("ip", "localhost", "server's ip")
```

不管是 `flag.Int` 还是 `flag.String`，它们返回的都是对应类型的指针变量，如 `*int` 和 `*string`。而且这些变量只有在经过
`flag.Parse()` 之后才能使用。

以上。
