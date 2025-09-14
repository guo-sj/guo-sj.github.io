---
layout: post
title: "Shell Quotes"
date:  2023-05-08 01:01:53 +0800
mathjax: false
categories: Shell
---

这篇文章整理一下在 shell 中单引号 `''`，双引号 `""`，和反引号 \`` 的作用。

先介绍反引号。**shell 会把反引号中的内容作为命令来执行，通常用于将命令执行的结果作为另一个命令的参数**。
比如下面这段命令就将 `cat dirs` 的输出结果作为 `ls` 的参数。注意，**在将命令执行的结果作为另一个命令的参数时，
newline 会被当作参数分隔符而非命令结束符**，就像下面所展示的那样：
```sh
$ cat dirs
dir1
dir2
dir3 dir4

$ ls `cat dirs`
dir1:
... ...

dir2:
... ...

dir3:
... ...

dir4:
... ...

```

还有一点就是，**当反引号中嵌套反引号时，要用 backslash 去把位于里面的反引号 escape 掉，防止
shell 在解释外层反引号内容时把里面的也解释掉**：
```sh
$ mail `pick \`mailinglist\``
```

说完了反引号，再来说说单引号和双引号。

**单引号中的内容，shell 会按照字面表示处理，也就是你单引号里面写的啥就是啥**，shell 会
直接按照字符串来处理；**而双引号的内容，shell 则会进去找三种 metacharacters，它们分别是
dollar `$`，backslash `\` 和反引号 \``**。对于这三种符号，shell 会按照它们的特殊意义处理，
它们的特殊意义分别是：
- dollar `$`：用于传参，`$1` 代表参数 1，`$2` 代表参数 2，`$*` 则代表所有参数
- backslash `\`：用于消解它后面字符的特殊含义，如 \$1 就会把 dollar 符号变成单纯的字符串。
注意，\newline 会把 newline 丢弃掉，这也就是为啥你可以在输入一个比较长的命令时把 `\` 放在行
尾的原因
- 反引号 \``：用于把反引号中的内容作为命令来执行，通常用于将命令执行的结果作为另一个命令的参数

下面这段命令解释了 shell 对待单引号和双引号的区别。
```sh
$ echo 'Date is `date`'
Date is `date`

$ echo "Date is `date`"
Date is Mon May  8 01:31:40 CST 2023
```

这里，**单引号和双引号不仅可以放在字符串的首尾，也可以单独把其中的某些字符括起来**，如下面 5 条
命令的输出结果是等价的：
```sh
$ echo "x*y"
$ echo x"*"y
$ echo 'x*y'
$ echo x'*'y
$ echo x\*y
```


以上。
