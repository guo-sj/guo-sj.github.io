---
layout: post
title: "Handle tar.gz file"
date:  2021-11-08 12:11:53 +0800
categories: Linux
---

工作生活中时常会遇到`xxx.tar.gz`这样的文件，每次都是现查现用，这样不好，所以
在此记录下来。

`tar.gz`的介绍：
> A tar.gz file contains several compressed files to save storage space, as well as bandwidth during the downloading process. The .tar file acts as a portable container for other files and is sometimes called a tarball. The .gz part of the extension, stands for gzip, a commonly-used compression utility.

在遇到`file.tar.gz`后，用`tar`命令去解压它：
```
$ tar -xvzf file.tar.gz
```

`-xvzf`分别代表：
- `x` - instructs tar to extract the files from the zipped file
- `v` - means verbose, or to list out the files it’s extracting
- `z` - instructs tar to decompress the files – without this, you’d have a folder full of compressed files
- `f` - tells tar the filename you want it to work on

如果需要在解压前，**查看压缩文件中包含的内容**，则运行如下命令：
```
$ tar -tzf file.tar.gz
```

如果需要**定义解压后文件的存放目录**，则执行：
```
$ tar -xvzf file.tar.gz -C /specified/path
```

反过来，用如下命令可以创建一个`tar.gz`文件：
```
$ tar -cvzf dir.tar.gz ./dir
```

- `c` - creates a new archive
- `v` - verbose, meaning it lists the files it includes
- `z` - signals tar to compress the files
- `f` - specifies the name of the file

**注**：这篇文章的内容主要来源于[这篇文章](https://phoenixnap.com/kb/extract-tar-gz-files-linux-command-line)。英文部分自己也尝试翻译过，但是还是觉得原文表达的意思更加准确，所以选择沿用。更详细的内容请访问原网址。

