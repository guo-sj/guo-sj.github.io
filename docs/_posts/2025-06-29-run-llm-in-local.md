---
layout: post
title: "在本地运行一个 LLM 并尝试用 RAG 的方式增强输出结果"
date:  2025-06-29 10:11:53 +0800
mathjax: false
mermaid: true
categories: AI
---

今天尝试在本地部署一个大模型。

### 使用 ollama 创建一个本地大模型
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

### 尝试用 RAG 去调用本地模型

`RAG(Retrieval Augment Generation)` ，它是一种通过引入外部资料增强大模型输出结果的手段。

流程图如下：

<div class="mermaid">
flowchart TD
    a[准备知识库] --> b[加载并分割文档]
    b --> c[创建向量数据库]
    c --> d[创建 RAG 链]
    d --> e[提问]
</div>

代码如下：
```py
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import FAISS
from langchain_ollama import OllamaEmbeddings
from langchain_ollama import OllamaLLM
from langchain_community.llms import Ollama
from langchain.chains import RetrievalQA
from langchain.text_splitter import CharacterTextSplitter
from dotenv import load_dotenv
import os

MODEL_NAME="deepseek-r1"

# 1. 准备知识库
with open("knowledge.txt", "w") as f:
    f.write("""
小郭是一个来自南京 28 岁的软件工程师，他喜欢在命令行中编程。
DeepSeek-R1 是深度求索公司开发的大语言模型，支持128K上下文。
Ollama 是一个本地运行大模型的开源工具，支持macOS和Linux。
LangChain 是构建大模型应用的框架，简化了RAG等复杂流程。
""")

# 2. 加载并分割文档
loader = TextLoader("knowledge.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=100, chunk_overlap=0)
texts = text_splitter.split_documents(documents)

# 3. 创建向量数据库
embeddings = OllamaEmbeddings(model=MODEL_NAME)
db = FAISS.from_documents(texts, embeddings)

# 4. 创建 RAG 链
llm = OllamaLLM(model=MODEL_NAME)
qa = RetrievalQA.from_chain_type(
        llm=llm,
        chain_type="stuff",
        retriever=db.as_retriever(),
        return_source_documents=True
)

# 5. 提问
query = "介绍下小郭？"
result = qa.invoke({"query": query})

# 6. 输出结果
print(f"问题：{query}")
print(f"答案：{result['result']}")
print(f"来源：{result['source_documents'][0].page_content}")
```

运行的话，我们先安装对应的 python 库：
```sh
pip3 install pysocks socksio langchain langchain-core python-dotenv faiss-cpu langchain-community langchain-ollama
```

然后启动 ollama server：
```sh
ollama serve
```

运行代码：
```sh
(.venv) ➜  myPythonPlayground python3 learnRag/learnRag.py
问题：介绍下小郭？
答案：<think>
嗯...用户问的是"介绍下小郭？"，这个问题看起来简单但需要小心处理。首先注意到上下文里只有一句关于小郭的信 息："小郭是一个来自南京28岁的软件工程师，他喜欢在命令行中编程。"

让我想想怎么组织这个回答会比较自然。作为DeepSeek助手的回答应该保持专业友好的风格，同时要基于提供的信息。

考虑设计一个简洁明了的介绍结构：先给出基本身份和年龄，然后补充地域背景，最后说明职业偏好吗？这样可以让用户对小郭有个完整的印象。

准备在回复中包含：
1. 他的基本信息（来自南京、28岁）
2. 职业身份（软件工程师）
3. 特别指出他喜欢命令行编程

不需要添加其他信息，因为上下文只提供了这些内容。如果需要更详细的信息，用户应该提供更多背景。

考虑用什么样语气会比较合适？准备保持中立专业的风格，但可以稍微带点亲切感。
</think>
好的，根据提供的信息：

小郭是一位来自南京的软件工程师，年龄28岁。他特别喜欢在命令行环境中进行编程工作。
来源：小郭是一个来自南京 28 岁的软件工程师，他喜欢在命令行中编程。
DeepSeek-R1 是深度求索公司开发的大语言模型，支持128K上下文。
Ollama 是一个本地运行大模型的开源工具，支持macOS和Linux。
LangChain 是构建大模型应用的框架，简化了RAG等复杂流程。
(.venv) ➜  myPythonPlayground
```
