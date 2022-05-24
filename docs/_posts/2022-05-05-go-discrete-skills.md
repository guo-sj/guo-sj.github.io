---
layout: post
title: "Go Discrete Skills"
date:  2022-05-05 10:11:53 +0800
categories: Go
---

这里记录一些平时学到的一些离散的Golang技巧。

1. 当搞不清把Slice变量当参数应该传它的指针还是值的时候，看看下面这段代码：
```go
package main

import "fmt"

func main() {
    s := []string{"a", "b"}
    fmt.Println(testPassValue(s))    // [b]
    fmt.Println(s)                   // [a b]
    fmt.Println(testPassAddress(&s)) // [b]
    fmt.Println(s)                   // [b]
}

func testPassValue(s []string) []string {
    s = s[1:]
    return s
}

func testPassAddress(s *[]string) []string {
    *s = (*s)[1:]
    return *s
}
```

2. 当用copy函数进行两个slice赋值的时候，应该先为目标slice分配和源slice一样大小的数组空间：
```go
// copy x to y, type of both x and y is []int
y = make([]int, len(x), cap(x))
copy(y, x)
```

3. map 类型的变量使用前应该用map literal或者make初使化：
```go
var m map[string]int

m = map[string]int{ ... }  // keys is requried

m = make(map[string]int) // make
```

4. 得益于slice，用golang实现栈或者对列非常简单。我们先来看栈的实现：
```go
stack := []string{}

stack = append(stack, "elem")  // push one element to stack
top := stack[len(stack)-1]  // get the top element of stack
stack = stack[:len(stack)-1] // pop one element from stack
```
再来看对列的实现：
```go
queue := []string{}

queue = append(queue, "elem") // push one element to queue
top := queue[0] // get the top element of queue
queue = queue[1:] // pop one element from queue
```

5. 在golang中，一个类型的变量是可以调用对应类型的方法（Method）的。如下面的代码：
```go
package main
import "fmt"

type myInt int

func main() {
    var i, j myInt
    i.changeValue(3)
    j.changeNothing(5)
    fmt.Println(i, j) // i: 3 j: 0
}

func (mi *myInt) changeValue(val myInt) {
    *mi = val
}

func (mi myInt) changeNothing(val myInt) {
    mi = val
}

```

6. 在golang中for循环的第二个参数是值传递的方式，不能用于修改原变量的值。如果
想要修改原变量的值，可以用for的第一个参数，对原数据进行下标访问。如：
```go
var a []int{1, 2, 3}
for _, item := range a {
    item += 1
}
fmt.Println(a) // a: 1, 2, 3 数据没有发生变化

for i := range a {
    a[i] += 1
}
fmt.Println(a) // a: 2, 3, 4 数据发生变化
```

7. 为结构体fields加上两种格式tag的方法如下：
```go
type Person struct {
    Name string `xml:"Name,omitempty" json:"Name,omitempty"`
    Age  int `xml:",omitempty" json:",omitempty"`
}
```

以上。
