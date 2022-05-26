---
layout: post
title: "System Call in Linux"
date:  2022-05-25 14:11:53 +0800
categories: C
---

| function name | header file | return value |
| :----:        | :----:      | :------:     |
| open | fcntl.h | new fd or -1 |
| read | unistd.h | number of bytes read or -1 |
| write | unistd.h | number of bytes write or -1 |
| close | unistd.h | 0 or -1 |
| perror | stdio.h | - |
| exit | stdlib.h | - |
| fork | unistd.h | 0 or -1 |

### 1. int open(const char \*pathname, int flags, mode_t mode)
`open` 可以用来打开 `pathname` 指定的文件，`flags`可以为 O_RDONLY （只读），
O_WDONLY（只写），O_RDWR（读写）。如果你希望如果文件不存在时创建文件，那么
`flags` 可以再加上 `O_CREAT`，然后填上合适的权限（参考`chmod`）给 `mode` 。

### 2. ssize_t read(int fd, void \*buf, size_t count)
`read` 函数的作用是从 `fd` 指定的文件中读取 `count` 大小的 byte 到 `buf`中。
如果读取成功，它返回读取的 byte 数量；反之返回 -1。

### 3. ssize_t write(int fd, const void \*buf, size_t count)
`write` 函数的作用是从 `buf` 中读取 `count` 大小的 byte 并写入 `fd` 指定的文件。
如果写入成功，它返回写入的 byte 数量；反之返回 -1。

### 4. int close(int fd)
`close` 函数的作用是关闭 `fd` 指定的文件。

### 5. void perror(const char \*s)
`perror` 函数并不属于系统调用，但是它经常和系统调用一起使用，所以
也把它记录在这里。当一个系统调用失败的时候，`errno` 会被设置成相应的错误码，`perror` 
就是用来输出 `errno` 存储的错误码的自然语言描述。参数 `s` 可以指定输出信息的前缀，
一般是出错的函数名。

### 6. void exit(int status)
和 `perror` 一样，`exit` 也不是系统调用函数，但是它经常和系统调用函数一起使用。`exit` 
可以用来结束一个进程，并把 `status` 指定的值返回这个进程的父进程。

open，read，write，close，perror 和 exit 的示例可以参考[这个程序](https://github.com/guo-sj/OSExperiment_Repo/blob/guosj/FileRW/mycp.c)。

### 7. pid_t fork(void)
`fork` 把当前的进程复制成一个子进程（Child Process）。如果创建成功，那么子进程的
进程号（PID）会返回给父进程（Parent Process），并返回 `0` 。反之返回 `-1`。用法如下：
```c
pid_t cpid;

if ((cpid = fork()) == -1) {
    perror("fork: ");
    exit(EXIT_FAILURE);
}

if (cpid == 0) { 
    /* code executed by child process */
} else {
    /* code executed by parent process */
}
```

以上。
