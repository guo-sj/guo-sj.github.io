---
layout: post
title: "如何在命令行中应用 github 项目未合入的 pr"
date:  2025-05-11 10:11:53 +0800
mathjax: false
mermaid: false
categories: Git
---

下面我用一个例子来演示如何在命令行中应用一个未被合入的 github 仓库的 pr。

[grip](https://github.com/joeyespo/grip) 项目中有一个未被合入的 [pr](https://github.com/joeyespo/grip/pull/389)，该 pr 实现了 mermaid 图的渲染，
这个也正是我需要的功能，我们可以采用如下的命令去应用该 pr：
```sh
git clone https://github.com/joeyespo/grip.git
cd grip
git fetch origin pull/389/head:mermaid-support  # 从远程仓库 origin 获取 GitHub PR #389 的代码，并在本地创建一个名为 mermaid-support 的分支保存它
git checkout mermaid-support # 应用本地分支 mermaid-support
```

因为这个是 python 项目，所以如果要应用它的功能需要重新安装 grip 程序：
```sh
pip uninstall grip # 卸载之前版本的 grip
pip install -e .   # 安装新版本的 grip
```

以上。
