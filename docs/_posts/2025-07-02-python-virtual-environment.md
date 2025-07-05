---
layout: post
title: "python 虚拟环境"
date:  2025-07-02 15:15:53 +0800
mathjax: false
mermaid: false
categories: Python
---

那天我用 `pip3 install langchain-ollama` 命令时遇到如下报错：
```sh
➜  docs git:(main) ✗ pip3 install langchain-ollama
error: externally-managed-environment

× This environment is externally managed
╰─> To install Python packages system-wide, try brew install
    xyz, where xyz is the package you are trying to
    install.
    
    If you wish to install a Python library that isn't in Homebrew,
    use a virtual environment:
    
    python3 -m venv path/to/venv
    source path/to/venv/bin/activate
    python3 -m pip install xyz
    
    If you wish to install a Python application that isn't in Homebrew,
    it may be easiest to use 'pipx install xyz', which will manage a
    virtual environment for you. You can install pipx with
    
    brew install pipx
    
    You may restore the old behavior of pip by passing
    the '--break-system-packages' flag to pip, or by adding
    'break-system-packages = true' to your pip.conf file. The latter
    will permanently disable this error.
    
    If you disable this error, we STRONGLY recommend that you additionally
    pass the '--user' flag to pip, or set 'user = true' in your pip.conf
    file. Failure to do this can result in a broken Homebrew installation.
    
    Read more about this behavior here: <https://peps.python.org/pep-0668/>

note: If you believe this is a mistake, please contact your Python installation or OS distribution provid
er. You can override this, at the risk of breaking your Python installation or OS, by passing --break-sys
tem-packages.
hint: See PEP 668 for the detailed specification.
```

仔细搜索了下才知道，python 现在要求都是在虚拟环境中运行。我们可以按照提示信息操作：
```sh
python3 -m venv .venv # 创建 python 虚拟环境
source path/to/venv/bin/activate # 进入 python 虚拟环境
python3 -m pip install xyz # 安装 xyz
deactivate # 退出虚拟环境
```

这个设定也是为了告知开发者，python 的 module 不应当为全局使用，针对每个不同的项目维护不同的 python module 依赖。

我的通常做法是，创建一个 `pythonPlayground`，然后在这个目录下维护一个 `.venv` 文件，然后再分别创建多个 python 子
目录：
```
➜  myPythonPlayground tree
.
├── learnRag
│   ├── knowledge.txt
│   └── learnRag.py
└── readme.md

2 directories, 3 files
➜  myPythonPlayground ls -a
.         ..        .venv     learnRag  readme.md
➜  myPythonPlayground cat readme.md
这个目录下有统一的 python3 虚拟环境 `.venv/`。
可以直接在该目录创建新的子目录，然后使用同一个 `.venv`。
➜  myPythonPlayground
```

另外，因为我在 macOS 上运行 pip，而且还使用了 v2ray 的 socks 代理，所以会遇到这个错误：
```sh
python3 -m pip install pysocks  # 让 python 识别 socks 代理
export ALL_PROXY=socks5://127.0.0.1:1080 # 指明 socks 代理的版本使得 pip3 可以正常工作
```

