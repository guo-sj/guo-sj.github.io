---
layout: post
title: "Git submodules"
date:  2023-09-24 10:11:53 +0800
mathjax: false
categories: Git
---

## 为你的项目增加一个 submodule
```sh
git submodule add https://github.com/preservim/nerdtree.git
```

它会在本地生成一个 `.gitmodules` 的文件，长这个样子：
```
[submodule "vim/bundle/nerdtree"]
	path = vim/bundle/nerdtree
	url = https://github.com/preservim/nerdtree.git
```

## clone 一个带 submodule 的仓库
```sh
git clone --recurse-submodules https://github.com/you/project
```

如果你不怕麻烦也可以这样：
```sh
git clone https://github.com/you/project
cd project
git submodule init
git submodule update
```

## 更新当前仓库中的 submodules
```sh
git pull --recurse-submodules
```

注意，这只是更新仓库中的 submodules，并没有更新仓库原本的文件，所以你可能还需要
再运行下：
```sh
git pull origin <your-current-branch>
```
来更新你当前仓库中的文件。

## 删除一个 submodule
删除一个 submodule 比较麻烦，要分为 3 步：
- 使用命令 `git rm path/to/submodule` 去删除对应的 submodule 同时修改 `.gitmodules` 文件
- 删除 `.git/config` 文件中相关的行
- commit & push

以上。
