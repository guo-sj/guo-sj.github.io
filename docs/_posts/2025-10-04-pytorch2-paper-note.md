---
layout: post
title: "阅读笔记 -- PyTorch 2: Faster Machine Learning Through Dynamic Python Bytecode Transformation and Graph Compilation"
date:  2025-10-04 10:11:53 +0800
mathjax: false
mermaid: false
categories: Pytorch
---

### Abstract
> This paper introduces two extensions to the popular PyTorch machine learning framework, TorchDynamo and TorchInductor, which implement the torch.compile feature released in PyTorch 2. TorchDynamo is a Python-level just-in-time (JIT) compiler that enables graph compilation in PyTorch programs without sacrificing the flexibility of Python. It achieves this by dynamically modifying Python bytecode before execution and extracting sequences of PyTorch operations into an FX graph, which is then JIT compiled using one of many extensible backends.

这篇文章介绍了 PyTorch 的 2 个扩展件：`TorchDynamo` 和 `TorchInductor`。这 2 个扩展件实现了 PyTorch2 中的 `torch.compile` 功能。

`TorchDynamo` 是一个 Python 级的 JIT 编译前端，它可以为 PyTorch 程序使能图编译的同时不牺牲 Python 的灵活性。它主要是通过动态修改 Python
 的 bytecode，这个动作发生在执行程序和把 PyTorch 操作抽取成 FX 图之前，这个 FX 图可以后续被多个可扩展的编译器后端进行 JIT 编译。

> TorchInductor is the default compiler backend for TorchDynamo, which translates PyTorch programs into OpenAI’s Triton for GPUs and C++ for CPUs. Results show that TorchDynamo is able to capture graphs more robustly than prior approaches while adding minimal overhead, and TorchInductor is able to provide a 2.27× inference and 1.41× training geometric mean speedup on an NVIDIA A100 GPU across 180+ real-world models, which outperforms six other compilers. These extensions provide a new way to apply optimizations through compilers in eager mode frameworks like PyTorch.

`TorchInductor` 是 `TorchDynamo` 默认的编译器后端。它把前端处理后的程序翻译成 GPU 上的 OpenAI 的 Triton，CPU 上的 C++。

结果显示，相比于之前的图抓取方法，`TorchDynamo` 可以更有效的抓取图。而 `TorchInductor` 则可以提供 2.27 倍的推理性能和 1.41 倍的训练性能。

这些扩展件提供了一种新的方式去对像 PyTorch 的 eager mode 框架，通过编译器做优化。

### 1 Introduction

> Modern machine learning frameworks can be divided into eager mode frameworks, such as PyTorch [32] and JAX [8], and graph mode frameworks, such as TensorFlow [2], Caffe [25], Theano [5], and CNTK [37]. Eager mode frameworks use an imperative define-by-run [47] approach where a machine learning model is represented as code that is executed each time one wants to run the model. Graph mode frameworks take a more declarative define-and-run [47] approach, where they expose a graph building API that requires users to first construct a graph and then later execute that graph.

你看啊，现代的机器学习框架分成 2 类，一类是 `eager mode` 框架，如 PyTorch。另一类是 `graph mode` 框架，如 TensorFlow。
（所以首先，PyTorch 就是运行在 `eager mode` 的）。

`eager mode` 框架使用一种 `define-by-run` 的形式，即把机器学习程序用代码表示，这个代码每次执行时再确定好多编译优化的信息。

而 `graph mode` 框架则是用一种 `define-and-run` 的形式，先要求用户把机器学习程序构造成图，然后再根据图去执行。

所以，`eager mode` 是**通过运行来定义（define-by-run）**，说白了，计算图是运行时候定义的；而 `graph mode` 是**先把图定义好，然后执行（define-and-run）**，用户先通过框架提供的 API 把图定义好，然后再去执行。

> Users of machine learning frameworks, and especially re-
> searchers, have shown an overwhelming preference for the
> eager programming model [22]. The eager mode model is
> easier to understand and can be debugged using standard
> tools such as print and pdb in Python [23]. This user pref-
> erence towards eager mode has caused traditionally graph
> mode frameworks to switch to eager mode programming
> models [4].

机器学习框架的用户，更加喜欢使用 `eager mode` 的框架，因为 `eager mode` 框架更加直观，说白了它就是一个 Python 程序，可以使用 `print` 和
`pdb` 进行调试。

> The downside of eager mode frameworks is that they make
> it harder to apply graph-level optimizations through compil-
> ers. The framework only has visibility of a single operator at a
> time, and thus cannot automatically perform optimizations,
> like fusion or scheduling, that cross operator boundaries.
> To address this, there have been attempts to allow graph
> capture in PyTorch through record/replay [17, 34], Python
> parsing [17], and lazy evaluation [39]. Unfortunately, these
> approaches have sacrificed much of the usability that draws
> users to PyTorch. Record/replay is unsound and can produce
> incorrect behavior [17]. Python parsing works for simple
> programs, but has not been able to replicate the complex
> semantics of all of Python, so results will show it fails on
> over half of real-world models. Lazy evaluation incurs high
> run-time overheads and adds latency to kernel launches. Ad-
> ditionally, an exclusively graph mode backend for PyTorch is
> intractable for some models. Due to the flexibility provided
> by PyTorch, many model authors take advantage of features
> that do not easily map to graphs, such as: dictionaries, lists,
> custom classes, third party libraries (numpy, logging, etc),
> disk/network, multiprocessing, exceptions, and handwritten
> kernels.

`eager mode` 框架的缺点是：它很难去通过编译器去做图级别的优化。

说白了，`eager mode` 就是我们在公司常说的“单算子模式”，把算子一个一个去执行。所以它才直观，好调试嘛。
但是这就带来了一个问题，每次执行时只能看到一个算子，那你怎么去做跨算子级别的优化呢？

之前尝试了好多种方式，什么 `TorchScript`，`torch.fx` 之类的，不是不好用，就是对于复杂的模型容易出错。

> This paper presents two open source extensions to Py-
> Torch: TorchDynamo and TorchInductor. These extensions
> are behind the torch.compile feature introduced in PyTorch
> 2 and officially released in March 2023. TorchDynamo is a
> Python-level JIT compiler designed to allow graph compila-
> tion in PyTorch programs while retaining the full flexibility
> of Python. TorchDynamo hooks into the Python frame eval-
> uation API [9] in CPython to dynamically modify Python
> bytecode right before it is executed. It rewrites Python byte-
> code in order to extract sequences of PyTorch operations into
> an FX graph [34] which is then just-in-time compiled with
> many extensible backends. It creates this FX graph through
> bytecode analysis and is designed to generate smaller graph
> fragments that can be mixed with Python execution to get
> the best of both worlds: usability and performance.

重点来了，我们这个文章给大家带来 2 个扩展插件，`TorchDynamo` 和 `TorchInductor`，它们共同完成了
`torch.compile` 功能。在实际的使用中，用户只需要调用 `torch.compile` 这个函数，就可以完成图优化。

`TorchDynamo` 是一个 Python 级别的 JIT 编译器前端，它可以在维持 PyTorch 程序的灵活易用性的同时
去使能图编译优化。它对 Python Frame Evaluation API 做了修改，所以可以在动态执行前对 Python 的 Bytecode
做改动。它重新编写了 Python 的 ByteCode，把程序的操作抽取成一个 FX 图，这个 FX 图可以被多种编译后端做编译。
这里的这个 FX 图就是连接编译前后端的 IR。

`TorchDynamo` 通过 Bytecode 分析来生成 FX 图，然后用于生成更小的 graph 片段，这些片段可以混合在 Python 的程序
执行中，用于实现易用性（eager mode）和性能（graph mode）的平衡。

> TorchInductor is a new compiler backend for TorchDy-
> namo. It translates PyTorch programs into OpenAI’s Tri-
> ton [46] for GPUs and C++/OpenMP [15] for CPUs. TorchIn-
> ductor is able to support the flexibility and dynamism of Py-
> Torch by using similar abstractions to PyTorch eager mode.
> It introduces a new define-by-run loop-level intermediate
> representation (IR) to make it easy to add new operator low-
> erings. Additionally, it is implemented in Python, so it is easy
> for PyTorch users to extend and modify to meet their needs.

`TorchInductor` 是 `TorchDynamo` 的编译后端。它把 FX 图翻译成 GPU 上的 Triton 语言和 CPU 上的 C++/OpenMP 语言。

`TorchInductor` 通过使用 PyTorch eager mode 相似的抽象结构，因此保持了和 PyTorch 相似的灵活性和动态性。它介绍了
一种新的 define-by-run 的 IR，使得它很容易添加新算子的 lowerings。什么是 operator lowering？
