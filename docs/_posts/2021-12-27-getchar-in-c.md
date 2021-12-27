---
layout: post
title: "getchar() in c"
date:  2021-12-27 10:11:53 +0800
categories: C
---

记录一下关于`getchar()`函数的一些感悟。

```c
int main()
{
	int c;

	while ((c=getchar()) != EOF)
		putchar(c);
	return 0;
}
```

这个经典的小程序，可以实现Linux程序`echo`的功能。我想讲的是，如果你
从键盘中输入`123EOF (Ctrl_D)`，程序会打印出`123`但并不会立即退出，而是需要再输入一个
`EOF (Ctrl_D)`才可以退出。即：
```
	123EOF123EOF
	<process quit>
```
这是因为`getchar`并不是从键盘文件中读一个字符就立即将这个字符返回，而是将它存在
一个缓冲区中，当`getchar`收到第一个`EOF`的时候，将缓冲区中的内容全部返回。如果缓冲区
为空，则将返回一个`EOF`。

所以，当我们输入`123EOF`的时候，`getchar`实际上返回的是已经读取的`123`；当我们输入第二个
`EOF`的时候，缓冲区中没有数据，所以`getchar`会返回一个`EOF`，程序退出。

补充，实验表明，当`getchar`接收到`回车`的时候，也会将读取到的信息（**含有收到的回车**）一并返回，
因此，当我们输入：
```
	123(Enter)    # 用户输入
	123(Enter)    # 程序输出
```

以上。
