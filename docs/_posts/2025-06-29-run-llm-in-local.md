---
layout: post
title: "在本地运行一个 LLM"
date:  2025-06-29 10:11:53 +0800
mathjax: false
mermaid: true
categories: AI
---

今天尝试在本地部署一个大模型。

> 什么是 Ollama？

[ollama](https://github.com/ollama/ollama) 是一个命令行工具，帮助人们在命令行中直接运行语言模型。

使用 ollama 安装模型非常方便：
```sh
brew install ollama # 安装 ollama

ollama serve # 启动 ollama 服务

ollama pull deepseek-r1:latest  # 拉取模型

ollama run deepseek-r1:latest # 运行模型
```

简单了解了下 ollama 的原理：当用户去运行 `ollama pull` 时，它首先会和本地运行的 server 进行
交互，然后再由 server 去和远端进行交互。用时序图描述如下：

<div class="mermaid">
sequenceDiagram
    participant User
    participant CLI as Ollama CLI
    participant Server as Ollama Server (localhost:11434)
    participant Registry as Model Registry (registry.ollama.ai)
    User->>CLI: ollama run deepseek-r1
    CLI->>Server: POST /api/generate (model="deepseek-r1")
    alt 模型已缓存
        Server-->>Server: 从 ~/.ollama 加载模型
    else 模型未缓存
        Server->>Registry: GET /v2/models/manifests/deepseek-r1
        Registry-->>Server: 返回模型清单
        Server->>Registry: 下载缺失的Blobs
        Server-->>Server: 存储到本地缓存
    end
    Server->>Server: 启动 llama.cpp 推理
    Server-->>CLI: 流式返回生成结果
    CLI-->>User: 输出响应内容
</div>
