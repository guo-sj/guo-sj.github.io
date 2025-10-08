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

刚才搜索了一下，`operator lowering` 是一个编译原理方面的技术，把高级语法转换成基础语法（primitive），这样
简化了后续的编译步骤的处理。比如一个语言有 100 种不同的语法，我们可以先把这 100 种语法转换成 20 种基础的语法，
说白了就是用这 20 种语法把这个程序重新写一遍，这样后续我们做编译只需要处理这 20 种语法。有了这个技术，我们
可以很容易的给语言增加语法糖。把程序转换成 IR 也是使用 `operator lowering` 的技术。

所以 `TorchInductor` 中，发明了一种 IR ，这种 IR 可以很方便的把新算子做 lowering，你新增一个算子，可以很方便的
使用这个 IR 表示出来。

另外，这个也是使用 Python 实现的，所以很容易的用让用户自己去使用和扩展。

> Experimental results show that TorchDynamo is able to
> capture graphs more robustly than prior approaches while
> adding minimal overhead. TorchDynamo is able to capture a
> single whole-program graph for most models and can grace-
> fully fall back to partial graphs when needed. Measurements
> show TorchInductor produces faster code on average than six
> other PyTorch compiler backends. Performance comparisons
> include both training and inference, CPU and GPU, float32
> and float16, and three large benchmark suites containing
> 180+ full-sized models taken from real-world applications.

实验结果显示，`TorchDynamo` 可以更好的抓取深度神经网络的图。对于大多数模型，它可以抓取一个完整的图，并且可以很优雅地
查看局部图。而 `TorchInductor` 可以更好的生成代码，在训推方面都有明显的效率提升。

### 2 Prior Attempts at PyTorch Graph Capture

> Graph capture in PyTorch presents unique challenges when
> compared to graph mode frameworks [2, 25, 5, 37], where
> the user is restricted to only using constructs that are repre-
> sentable in the graph. With PyTorch and other eager mode
> frameworks, the user is free to embed arbitrary code, includ-
> ing non-PyTorch libraries, inside their models. This results
> in frequent conversion from PyTorch Tensors to Python
> types (via .item(), .tolist(), etc), usage of external libraries
> (numpy, logging, etc), and usage of Python constructs (classes,
> closures, exceptions, control flow, etc) that do not map well
> to a fixed graph abstraction. Due to this mismatch between
> the flexibility provided by Python/PyTorch, and the inflexibil-
> ity of graph representations, prior attempts at graph capture
> in PyTorch have needed to place restrictions on the user
> experience. While this tension between flexibility and repre-
> sentation is solved by TorchDynamo, we examine prior art
> in the space to provide context and background.

PyTorch 是 eager mode 的框架，就是我们说的单算子模式。它的优点是灵活，方便调试。缺点嘛就是 define-by-run，相比于
graph mode 的框架，效率不高。为了解决这个问题，前人做了很多的探索，这里会简单介绍下。

#### 2.1 torch.jit.trace

> torch.jit.trace uses record/replay with example inputs to
> produce a TorchScript [17] graph. The recording is done at
> the PyTorch dispatcher level, which is inside the C++ portion
> of PyTorch and used to dispatch operators to device-specific
> kernels and for autograd. Because the recording is done in
> C++, torch.jit.trace does not capture any control flow in
> Python. Consider this example:

```python
def example1(x):
    if len(torch.nonzero(x)) > 1:
        return x + 1
    return x - 1
```

With example input torch.tensor([0, 0]), torch.jit.trace would capture a graph equivalent to:
```py
def example1_incorrect_capture(x):
    torch.nonzero(x)
    return x - 1
```

> Since the path through the program is specialized on the
> example input, a different input (such as torch.tensor([1,1]))
> will give incorrect results. Additionally, any non-PyTorch
> operators (such as external libraries, prints, logging, side
> effects, etc.) will be omitted from the captured graph.

这段说的是，`torch.jit.trace` 是基于特定输入来去生成 TorchScript 图。TorchScript 是一个嵌入式的元编程语言，可以捕捉到
control-flow，但是因为它想做的尽善尽美，导致设计过于复杂。

这里的 `record/replay`，record 指的就是把多个算子记录一下，replay 就是把这多个算子一起下发到 kernel 侧（GPU 侧）。

因为 `torch.jit.trace` 的 record 操作是放在 C++ 侧，所以 Python/PyTorch 的控制流都记录不到。

又因为 `torch.jit.trace` 是基于特定输入去 record 算子，所以当输入一变，又得重新记录。

最后，任何非 PyTorch 的算子都不支持被记录。

#### 2.2 torch.jit.script
> torch.jit.script also constructs a TorchScript [17] graph,
> but does so by parsing the Python AST and performing static
> analysis. It is able to capture example1 above correctly and,
> unlike torch.jit.trace, it is a sound approach that should
> not produce incorrect results.

> The major challenge torch.jit.script faces is that it is
> trying to reimplement all of Python as a static language. This
> approach is all or nothing: encountering an unimplemented
> component of Python makes the entire program unfit for
> capture. Emulating all of Python statically is a daunting
> task and, in practice, torch.jit.script only supports a subset
> of Python. Experimental results show that torch.jit.script
> works only about half the time on real-world models in the
> TorchBench benchmark suite, and anecdotally we have heard
> stories of it taking weeks or months to “torchscript” large
> models, which leads to a frustrating user experience.

第二位出场的选手是 `torch.jit.script`，它是对 Python 的 AST 做解析而且是依赖静态分析技术，所以解决了 `torch.jit.trace` 的不能
捕捉 control-flow 的问题。但是它的问题在于，它实际上去实现了一个 static Python 语言，那工作量可就海了去了。实际上，它只实现了
Python 语言的一个子集，在子集外面的特性都不支持。而且它的捕捉图速度较慢。

#### 2.3 Lazy Tensors
> Lazy Tensors were introduced in the PyTorch/XLA [42, 39]
> project, which is primarily focused on supporting Google
> TPUs [26] with PyTorch. Lazy Tensors is a C++ level graph
> capture technology. Every iteration, it defers execution of
> operations to accumulate a graph and then sends the accumu-
> lated graph to the XLA [45] compiler. By hashing this graph,
> Lazy Tensors can avoid recompilation when the captured
> graph is identical across iterations. While this approach is
> effective and sound, it has a few major downsides:

Lazy Tensor 主要是为了在 Google 的 TPU（Tensor Process Unit） 上使用 PyTorch 发明的。它是一个 C++ 级别的库，实现了 record / replay。

> Higher overheads: Lazy Tensors incurs additional work
> when compared to PyTorch eager. Besides running
> the same Python code and PyTorch dispatcher stack
> that eager does, it must maintain additional graph data
> structures that incur added runtime costs.

Lazy Tensor 的第一个缺点它相比于 eager mode 有有更高的开销。除了运行 eager mode 的 Python 代码外，它还需要维护一个额外的
图数据结构，而这个会给运行时带来开销。

> Introduced delays: PyTorch eager issues the first kernel
> on the first operation of the model, after which point
> host-side code is run in parallel with kernels on the
> GPU or accelerator thus hiding overheads. In contrast,
> Lazy Tensors doesn’t issue the first kernel until the
> model’s code has finished executing, resulting in added
> delays before the first kernel is issued and after any
> operation that requires a round trip to the CPU (which
> are common in real-world models). Thus, Lazy Tensors
> often serializes host execution with GPU/accelerator
> utilization, which amplifies host side overheads. Mod-
> els, loss logging, and optimizers need to be modified
> to work around this issue.

它第二个缺点是它有更高的延迟。PyTorch 的 CPU 侧和 GPU 侧的代码是可以并发执行的。而 Lazy Tensor 却只能在 CPU 侧执行完后
GPU 侧才执行。

这里插个题外话，介绍下上文的 kernel 是什么。这里说的 kernel 和我们平时说的 OS Kernel 不是一个东西，在 CUDA 体系中，
一个 kernel 就是**一个运行在 GPU 上的函数**。这个 kernel 函数通常是 void 类型，它没有返回值，它做的事情是做计算，并把
计算后的结果写到 GPU 的某块内存上，这些结果会定期返回给 CPU。

当 CPU 侧 launch 一个 kernel 函数时，它会指定一个 grid 的 thread blocks 去做这个 kernel 计算。一个 grid 含有多个 thread blocks，
一个 thread block 含有多个 thread，每个 thread 都有一个 pid，并行计算这个 kernel 函数。

那 kernel 和 operator（算子）的关系是什么呢？operator 是计算图的基本单元，它代表着某一个算法操作，而这个操作落到 GPU 上时，
可能对应一个或者多个 kernel 函数。kernel 函数你可以理解为是 GPU 上的操作接口，我们编写算子通过调用这些接口去实现。

总之，可以简单这样理解，一个计算图包含一个或多个算子，一个算子包含一个或多个 kernel 函数。

> Recompilation: Whenever the captured graph has a
> new hash, Lazy Tensors must recompile. This can lead
> to some pathological cases where recompilation hap-
> pens frequently.

`Lazy Tensor` 的第三个缺点是，只要抓取的图有了一个新 hash 时，它就要重新编译。在某些场景下，重编译会很频繁的发生。

> The PyTorch/XLA project has built [10] an integration with
> TorchDynamo which uses a hybrid of both Lazy Tensors
> and TorchDynamo. This integration hides the overheads of
> Lazy Tensors by only running Lazy Tensors once, rather than
> every iteration, and using TorchDynamo to figure out when
> recapture is needed. The PyTorch/XLA results later in the
> paper use this integration.

PyTorch/XLA 已经和 TorchDynamo 整合在一起了，这样做隐藏了前者带来的开销，通过只运行 PyTorch/XLA 一次，然后通过 TorchDynamo 判断
是否需要重新编译。

#### 2.4 torch.fx.symbolic_trace

> torch.fx.symbolic_trace [34] is the newest of these systems
> and introduced the FX graph format that is shared by Torch-
> Dynamo. It takes a similar record/replay-based approach to
> torch.jit.trace, but does its tracing at the Python level as
> opposed to at the PyTorch C++ dispatcher level. It runs the
> user code using a Proxy Python object to record its behavior
> and uses the torch_function [3] extension point in PyTorch.

`torch.fx.symbolic_trace` 是[这篇论文](https://arxiv.org/pdf/2112.08429)中提出的概念，它提供了 `torch.fx` 库，用于在 Python 层面
对深度学习代码进行抓取和转换，创建了一个基于 6 指令的 IR，这个也就是我们说的 FX 图，在运行前（Ahead-Of-Time）对程序进行静态分析，
得到 FX，用户可以调用 `torch.fx` 提供的接口对这个 FX 图进行修改，这个就是我们常说的 transformation，然后再去把 FX 图转换成 Python 代码，
下发下去执行。

By recording higher up at the Python level, symbolic_trace
is able to capture many operations that torch.jit.trace can-
not. Since it records using Proxy objects instead of real ten-
sors, it is able to detect many cases where torch.jit.trace
would be incorrect, e.g., when trying to read sizes or values
from Proxy tensors or when using them in control flow, such
as example1 above. It also suffers from the all-or-nothing lim-
itation of many solutions described above. For example, in
the control flow case above, the user is still forced to rewrite
the code they want to trace.

尽管 `torch.fx` 可以将 Python 程序解析成 FX 图，但是还是会经常遇到解析失败的情况，这时就要求用户去修改程序。

> Unfortunately, torch.fx.symbolic_trace is still unsound
> and can produce incorrect results. Consider this example,
> which increments a global variable and calls a function not
> dependent on the function input:

```py
def example3(x):
    global call_count
    call_count += 1
    return torch.rand(10) + x
```

> If one runs torch.fx.symbolic_trace on this example it pro-
> duces a graph equivalent to:

```py
def example3_incorrect_capture(x):
    return _tensor_constant0 + x
```

> The call to torch.rand got removed and the result of it got
> burned into the graph as a fixed constant. Subsequent uses
> of the graph will not get new randomness, but instead reuse
> whatever value was generated during capture. This type
> of incorrect capture can be difficult to debug and may go
> unnoticed by users.

`torch.fx` 还可能产生不正确的分析结果。比如 torch.rand(10) 的值就被替换成了首次抓取时的值，后续再运行代码，这个值
也不会变。这个和用户的期待是不符合的。而且这样的错误也很难察觉出来。

> The call_count operations are completely lost because
> they did not interact with the Proxy object x. Instead, the
> call_count got incremented to 1 during tracing and will not
> be incremented when the graph is called. This is also an
> example of something that is not supported by any of the
> graph representations. Nearly all graphs formats for ma-
> chine learning have no concept of a Python global, so even
> if this could be captured, it is not supported by downstream
> backend compilers.

另外，`torch.fx` 对于全局变量的抓取实现的也不好。在上面这个例子中，它直接把不相关的全局变量给优化掉了。

#### 2.5 torch.onnx.export

> ONNX [31] export is not actually a graph capture mechanism,
> but some people confuse it for one, so we include it here for
> completeness. Internally, ONNX export uses torch.jit.trace
> and torch.jit.script (Section 2.1 and 2.2), so it faces all the
> same limitations imposed by those systems. Additionally, the
> conversion from TorchScript to the ONNX format can fail
> due to ONNX not supporting all PyTorch operators. Thus,
> the set of models supported by ONNX is a subset of those
> supported by TorchScript.

ONNX（Open Neural Network Exchange）是一个去展现 ML 模型的格式标准，说白了，就是一种对模型的图形式的表达，
我们在工作中常说的导出图指的就是按照 ONNX 模式导出图，而这个图通常可以使用 [Netron](https://github.com/lutzroeder/netron?tab=readme-ov-file) 去打开它。如：

![](/assets/netron_example.png)

这段时出现了一个词 `PyTorch operators`，我想再说明下。在 PyTorch 中，一个 operator 就是一个对于一个或多个 tensor 进行特定操作的函数。
比如 `torch.add` 和 `torch.sum`。这个和我们上面说的 operator 也可以对应上，即 operator 是一个比 kernel 更高层的函数，一个模型有多
个 operator，一个 operator 含有多个 kernel 函数。

在 PyTorch 中，`Aten(stands for A Tensor)` 是一个 C++ 库，定义了 Tensor 类和最基础的[算子函数](https://docs.pytorch.org/docs/main/torch.compiler_ir.html)，其他的算子操作都基于这个库进行搭建的。

> The ONNX team is working on an integration with Torch-
> Dynamo that will replace TorchScript with a direct Torch-
> Dynamo integration. Once finished, this will increase the
> number of models ONNX works on.

一开始，ONNX 导出功能在 PyTorch 中是用的 `torch.jit.trace` 和 `torch.jit.script`，这 2 位大哥有很多缺点，是吧，上面已经列了。后续 ONNX 会
和 `TorchDynamo` 整合在一起。

#### 2.6 Comparison To Graph Capture In JAX

> JAX [8] largely doesn’t face the same challenges being solved
> by TorchDynamo. The initial design of JAX was heavily
> coupled to the design of XLA [45], and JAX has been backed
> by XLA from its inception. This has the effect of forcing
> JAX programs to conform to the constraints built into the
> design coming up the stack from XLA. Thus, JAX uses a
> simpler capture mechanism, and expects users to write their
> programs to meet the constraints of that capture mechanism.
> As an example, jax.jit does not support data-dependent
> Python control flow and requires user code to be functionally
> pure.

> In contrast, PyTorch started as an eager-only framework
> without any compiler-minded constraints built into its de-
> sign. A large corpus of models has grown on top of PyTorch,
> most of which were written without any regard to how hard
> to capture and compile they would be.

> On an implementation level, the capture mechanism in
> JAX is similar to torch.fx.symbolic_trace (Section 2.4), but
> somewhat simpler, because JAX programs are purely func-
> tional and thus do not need to worry about state. The Torch
> FX paper [34] contains a more detailed comparison with
> JAX.

JAX 也是一个 Python 库，和 XLA 有很强的关联性，抓取机制类似于 `torch.fx.symbolic_trace`。

### 3 TorchDynamo Design and Implementation

> TorchDynamo takes a fundamentally different approach
> from prior graph capture systems in PyTorch. Rather than
> trying to remove or replace Python, TorchDynamo tries to
> work with CPython by just-in-time (JIT) compiling Python
> bytecode. TorchDynamo is a Python bytecode to Python
> bytecode translator, where it extracts PyTorch operations
> from the original bytecode and replaces them with calls to
> compiled artifacts that fuse many PyTorch operations to-
> gether. Figure 1 provides an overview of how TorchDynamo
> operates and will be explained in the remainder of this sec-
> tion.

终于到论文的重头戏了。

`TorchDynamo` 与 CPython 一起工作，通过 JIT 编译 Python bytecode。什么是 CPython？

CPython 就是当前最广泛采用的 Python 实现形式，叫这个名字的原因是它是使用 C 语言去实现的 Python 语言。如果我们从官网安装 Python，那么
我们默认安装的就是 CPython。

CPython 执行时，先把 Python 代码翻译成一种与平台无关的 bytecode（IR），然后再使用 PVM（Python Virtual Machine）去执行 bytecode。
从这个角度来说，Python 的执行方式和 Java 有点像。

`TorchDynamo` 是一个 Python bytecode 到 bytecode 的翻译器，通过把 PyTorch 操作从原始的 bytecode 抽取出来，把它替换一下，然后再转换回去。

**artifact**: an object that has been made by a person, such as a tool or decoration, especially one that is of historical interests  人工制品

**fuse**: to join together physically, or to join things together physically  融合，结合

#### 3.1 Usage API

> The primary API introduced in this paper is torch.compile.
> It can be used either by calling it on a PyTorch Module or as
> a function decorator. It has the following keyword options:
>
> • backend: allows the user to provide a custom compile
> function which takes a torch.fx.Graph and a list of
> example inputs and returns a Python callable. This
> defaults to TorchInductor, but can also be set to one
> of many builtin backends or a user-defined backend.
>
> • options: An optional dictionary of backend-specific
> configuration flags.
>
> • mode: Shorthand strings for a predefined set of op-
> tions: "default", "reduce-overhead", or "max-autotune".
>
> When you run a module with torch.compile, the module
> is executed with the modified CPython behavior shown in
> Figure 1. Specifically, a custom CPython frame evaluation
> hook will rewrite the bytecode of of each Python function
> being executed in order to extract and compile sequences
> of PyTorch operations. This bytecode rewriting process is
> cached, but the analysis relies on certain dynamic properties
> of the program that we use guards to check on subsequent
> calls.

`TorchDynamo` 的基础接口是 `torch.compile`，有 3 个关键参数：
- `backend`：默认是 `TorchInductor`，当然我们可以指定其他的编译后端，比如我们华为的 `torch_npu` :-)
- `option`：指定后端的配置参数
- `mode`： 可以选择 `default`，`reduce-overhead` 或者是 `max-autotune`，等等，后面 2 个词我在华为昇腾手册里见过啊

当我们运行 `torch.compile` 时，一个定制的 CPython 框架计算钩子将会重写即将执行的 Python 函数的 bytecode，为了抽取
和编译 PyTorch 操作。这个重写 bytecode 的过程会被缓存下来，但是这个分析过程依赖于这个程序的特定的动态属性，我们会
用 guards 去检查后续的调用。（这段不是很明白）

### 3.2 CPython Frame Evaluation Hook

> PEP 523 [9] introduced the frame evaluation API into the
> CPython interpreter. A frame is the data structure in CPython
> used to represent a function call. This is the main extension
> point used by TorchDynamo, and it was designed to facilitate
> just in time (JIT) compilers and debuggers in Python. PEP 523
> added an eval\_frame function pointer to PyInterpreterState,
> which allows overriding the core function used to interpret
> a single function call in CPython. Whenever CPython calls
> a function, it first creates a PyFrameObject, then it calls this
> user defined eval\_frame hook. By default, eval\_frame points
> to \_PyEval\_EvalFrameDefault, which contains the main inter-
> preter loop for CPython. TorchDynamo modifies eval\_frame
> to replace this standard CPython interpreter loop with one
> that performs JIT compilation of Python frames.

PEP（Python Enhancement Proposals）523 为 CPython Interpreter 引入了 frame evaluation API。

一个 frame 是一个 CPython 中的数据结构，用于代表一个函数调用。它是 `TorchDynamo` 使用的主要扩展点，同时也是被设计用于
和 JIT 编译器和调试器一起使用。

PEP 523 增加了一个 `eval_frame` 函数指针指向 `PyInterpreterState`，这个用于覆盖 CPython 中解析单个函数调用的核心函数。
当 CPython 调用一个函数时，它首先创建一个 `PyFrameObject`，然后它调用用户自己定义的 `eval_frame` 钩子函数。
`eval_frame` 默认指向 `_PyEval_EvalFrameDefault`，它包含了 CPython 的主要的解析器循环。
`TorchDynamo` 让 `eval_frame` 指向一个自定义函数来实现它的 JIT 编译功能。

> The custom eval frame function installed by TorchDynamo performs the following operations:

> • Check if the frame should be skipped due to filename
> exclusion, previous failures in analysis (which mark
> the frame to be skipped), or exceeded cache size limits.
> Filename exclusions are used for common libraries,
> like Python standard libraries and numpy, which will
> not contain PyTorch operations. For skipped files, call
> `_PyEval_EvalFrameDefault` on the original bytecode and
> return.

`TorchDynamo` 定制的 `eval_frame` 函数主要包括这么几点：

第一步，如果这个 frame 满足如下任何一个条件就会被跳过，从而使用 `_PyEval_EvalFrameDefault` 去处理。
- 文件扩展名（这里讨论的是 frame，怎么又扯到文件了？）
- 之前分析失败过
- 超过 cache 大小限制的

> • Check if the frame has previously been compiled and
> is cached; if so, execute the generated guard function
> (Section 3.3) for each entry in the cache. If a guard func-
> tion returns True, run the matching cached compiled
> bytecode with `_PyEval_EvalFrameDefault` and return.

第二步，如果这个 frame 之前已经被处理过且被 cached，那么会对 cache 中的每个 entry 直接执行 guard function。
如果 guard function 返回 True，那么用 `_PyEval_EvalFrameDefault` 执行匹配的 cached 编译过的 bytecode，然后返回。

> • Perform symbolic analysis (instruction by instruction)
> of the function bytecode to extract an FX graph [34],
> guards, and side effects. This analysis can stop partway
> through the function if it encounters an unsupported
> operation.

第三步，对函数的 bytecode 执行 symbolic analysis 得到 FX graph，guards 和边际效应。（这个和之前的机制就不一样了，之前是直接对 Python 代码
做 symbolic_trace，现在是对 bytecode 做分析。）当遇到不支持的场景时，这个分析会停止。

> • Compile the FX graph with a user-defined compiler
> function specified by the `backend=` argument provided
> to torch.compile.

第四步，使用 `backend=` 指定的编译器去编译 FX 图。

> • Generate and compile a single Python function that
> checks all of the guards. It returns True if the guards
> pass and the existing compiled artifact can be reused.
 
第五步，产生和编译一个 Python 函数去检查所有的 guards。如果检查成功，那么现存的编译结果可以被复用。

> • If the analysis did not reach the end of the function,
> generate `resume_at_XX` continuation functions. Contin-
> uation functions run the remainder of the function in
> a new frame and are described in Section 3.8.

第六步，如果这个分析没有到达函数的结束位置，产生 `resume_at_XX` 的 continuation function。

> • Generate new Python bytecode. This new bytecode
> will: 1) call the compiled FX graph; 2) store and recon-
> struct the local/stack state; 3) perform side effects the
> original function should have had, see Section 3.7; 4)
> either return or implement a graph break by falling
> back to the original bytecode and calling the generated
> continuation function(s).

第七步，产生新的 Python bytecode，这个新的 bytecode 将会：
- 调用编译过的 FX 图
- 存储和重塑 local/stack 状态
- 执行原函数的边际效应
- 返回或执行一个图，通过回到原函数的 bytecode 并且调用 continuation function。
 
> • Install the generated Python bytecode and guard func-
> tion in the cache, run the generated bytecode with
> `_PyEval_EvalFrameDefault`, and return.

第八步，安装产生的 Python bytecode 和 guard function 到 cache。用 `_PyEval_EvalFrameDefault` 去运行生成的 bytecode，并返回。
