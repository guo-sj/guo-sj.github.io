---
layout: post
title: "Shell Control Flow"
date:  2025-09-14 10:11:53 +0800
mathjax: false
mermaid: false
categories: Shell
---

这里我们记录一下 shell 中的 Control Flow，包括 `if-else`，`case`，`for`，`while`。

我们先来看 `if-else`，它的语法描述是这样的：
```sh
if command; then
    commands if condition true
elif command; then
    commands if condition true
else
    commands if condition false
fi
```

这里放在 `if` 或 `elif` 中的 `command` 指的是一个命令的返回值，换句话说，`if` 是根据 `command` 执行成功
还是失败来去作为条件去判断走哪个分支的。比如，我们经常用 `if` 来判断：如果一个目录不存在，那么我们
创建该目录，我们可以这样做：
```sh
if ! test -d /path/to/dir; then
    mkdir -p /path/to/dir
fi
```

这里，`! commands` 或者 `! (commands)` 表示对该命令的返回值取反，如：
```sh
➜  guo-sj.github.io git:(main) ✗ ls
docs      README.md
➜  guo-sj.github.io git:(main) ✗ test -d docs
➜  guo-sj.github.io git:(main) ✗ echo $?
0
➜  guo-sj.github.io git:(main) ✗ ! test -d docs
➜  guo-sj.github.io git:(main) ✗ echo $?       
1
➜  guo-sj.github.io git:(main) ✗ ! (test -d docs) 
➜  guo-sj.github.io git:(main) ✗ echo $?
1
➜  guo-sj.github.io git:(main) ✗ 
```

这里值得一提的就是，`test` 命令在我们写 shell 脚本的条件判断时会经常用到，它的语法是：
```
test expression
```

以下是几种常用的 expression 的写法：

| expression | meaning |
| :--: | :--: |
| -d file | 如果 `file` 存在且是一个目录，返回 True |
| -f file | 如果 `file` 存在且是一个普通文件，返回 True |
| s1 = s2 | 对于 `string` s1 和 s2，如果两者相等，返回 True |
| s1 != s2 | 对于 `string` s1 和 s2，如果两者不相等，返回 True |
| s1 < s2 | 对于 `string` s1 和 s2，如果s1 比 s2 小，返回 True |
| s1 > s2 | 对于 `string` s1 和 s2，如果s1 比 s2 大，返回 True |
| n1 -eq n2 | 对于 `integer` n1 和 n2，如果两者相等，返回 True |
| n1 -ne n2 | 对于 `integer` n1 和 n2，如果两者不相等，返回 True |
| n1 -gt n2 | 对于 `integer` n1 和 n2，如果 n1 **大于** n2，返回 True |
| n1 -ge n2 | 对于 `integer` n1 和 n2，如果 n1 **大于等于** n2，返回 True |
| n1 -lt n2 | 对于 `integer` n1 和 n2，如果 n1 **小于** n2，返回 True |
| n1 -le n2 | 对于 `integer` n1 和 n2，如果 n1 **小于等于** n2，返回 True |
| ! expression | 如果 `expression` 的值是 False，返回 True |
| e1 -a e2 | 对于 `expression` e1 和 e2，e1 **和** e2 同时成立的时候，返回 True，`-a` 表示 **and** |
| e1 -o e2 | 对于 `expression` e1 和 e2，e1 **或** e2 成立的时候，返回 True，`-o` 表示 **or** |

所以你看，`test ! expression` 和 `! test expression` 是等价的，所以上述的我们判断目录是否存在的程序也可以这么写：
```sh
if test ! -d /path/to/dir; then
    mkdir -p /path/to/dir
fi
```

> PS：`test` 和 `[ ]` 是等价的，其实 `[ ]` 就是 `test` 命令的语法糖，这个写程序的时候看个人喜好，我个人还是比较喜欢用 `test` :-)

好了，我们介绍完了 `if`，我们再来看下条件判断的另一种写法 -- `case`。`case` 的语法如下：
```
case word in
pattern)  commands ;;
pattern)  commands ;;
...
esac
```

`case` 语句会自上而下的比较 `word` 和 `pattern`，执行第一个匹配的 `pattern` 对应的 `commands`，然后退出。

> `pattern` 的写法是 shell 支持的 [wildcard](https://tldp.org/LDP/GNU-Linux-Tools-Summary/html/x11655.htm)，而不是我们熟悉的 regular expressions。

注意，每个 `pattern` 对应的 commands 是以`两个分号`结尾 -- `;;`，这个一定要注意。

比如这个例子：
```sh
for i in `date`
do
case $i in
Sun) echo "got Sun";;
2025) echo "got 2025";; 
*) echo "default branch, got $i";;
esac
done
```

运行结果如下：
```sh
➜  guo-sj.github.io git:(main) ✗ date
Sun Sep 14 20:57:05 CST 2025
➜  guo-sj.github.io git:(main) ✗ for i in `date`
for> do
for> case $i in
for case> Sun) echo "got sun";;
for case> 2025) echo "got 2025";;
for case> *) echo "default branch, got $i";;
for case> esac
for> done
got sun
default branch, got Sep
default branch, got 14
default branch, got 20:56:51
default branch, got CST
got 2025
➜  guo-sj.github.io git:(main) ✗ 
```

这个例子也顺道引出了我们下一个要介绍的 `for`，`for` 的语法如下：
```sh
for i in list of words
do
    loop body, $i set to successive elements of list
done

for i   (List is implicitly all arguments to shell file, i.e., $*)
do
    loop body, $i set to successive arguments
done
```

第一种语法我们在上一个例子中已经说明了，这里我们简单说下第二个例子。如果我们没有在 `for` 循环中指定 `list`，那么它默认指的是所有传入的参数。如：
```sh
#cat illustrate_for.sh
for i
do
    echo $i
done
```

执行结果如下：
```sh
➜  guo-sj.github.io git:(main) ✗ chmod +x illustrate_for.sh 
➜  guo-sj.github.io git:(main) ✗ ./illustrate_for.sh 
➜  guo-sj.github.io git:(main) ✗ ./illustrate_for.sh 1 test guosj
1
test
guosj
➜  guo-sj.github.io git:(main) ✗  
```

讲完了 `for`，我们接下来看下 `while` 和 `until`，他们的语法如下：
```sh
while command
do
    loop body executed as long as command returns true
done

until command
do
    loop body executed as long as command returns false
done
```

emmm...，其实 `while` 和 `until` 刚好是相反的表达，两者也很容易做到相互转换，对于同一个 `command` 我们有：
- `while ! command` <=> `until command`
- `while command` <=> `until ! command`

如果想表达无限循环，语法是这样的：
```sh
while :
do
    commands
done
```
