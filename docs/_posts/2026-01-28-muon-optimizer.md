---
layout: post
title: "阅读 《Muon: An optimizer for hidden layers in neural networks》"
date:  2026-01-28 03:11:53 +0800
mathjax: true
mermaid: true
categories: Paper
---

我们学习一下这篇文章 [Muon: An optimizer for hidden layers in neural networks](https://kellerjordan.github.io/posts/muon/)。

## 什么是优化器

模型的训练是说，参数 w 是一堆随机值，当模型的前向传播逻辑写好后，我们前向传播得到输出 r1，
然后使用预期输出 r2 - r1 得到 loss。再用 loss 对 w 求偏导得到梯度 g，梯度代表 loss 上升最快的方向，
那梯度的反方向就是 loss 下降最快的方向。我们设定学习率 lr，更新参数 w = w - lr x g。而我们这里说的优
化器 optimizer 就是解决更新参数这个步骤出现的问题。

常用的优化器：
- SGD（Stochastic Gradient Descent）
- Adam
- AdamW（Adam with Weight Decay）
- Muon（MomentUm Orthogonalized by Newton-Schulz）

接下来，我们看一下 Muon 是怎么做的，它和代码是如何对应的。

## Muon 优化器的设计

接下来，我需要把 Muon 优化器的核心思路理解一下，然后和 AdamW 去做个对比，而且需要在 minimind 的这个项目中去验证一下它的优势。

Muon 的算法：
Require: Learning rate $\eta$, momentum $\mu$

1: Initialize $B_{0} \leftarrow 0$

2: for $t$ = 1, ... do

3:     Compute gradient $G_{t} \leftarrow \nabla_{\theta}\mathcal{L}_{t}(\theta_{t-1})$

4:     $B_{t} \leftarrow \mu B_{t-1} + G_{t}$

5:     $O_{t} \leftarrow NewtonSchulz5(B_{t})$

6:     Update parameters $\theta_{t} \leftarrow \theta_{t-1} - \eta O_{t}$

7: end for

8: return $\theta_{t}$

这里的 $B_{0}$ 意思是存储历史动量（momentum）累积值的张量/矩阵，$\leftarrow$ 是赋值符号，等价于编程里的 `=`，表示把“右边的值赋值给左边”。这里的 $0$ 是全零张量/矩阵，维度和 Muon 要优化的 2D 参数矩阵完全一致。所以这一步的意思是说，把把 $B_{0}$ 赋值成全 0 矩阵。

B 在 Muon/SGDM（Stochatic Gradient Descent Momentum）中是动量缓冲区的意思，核心功能是**积累历史的参数更新方向** -- 动量优化的本质是“让参数更新不仅跟着当前的梯度走，还会沿着历史更新的方向惯性前进”，从而减少训练震荡、加快收敛。

而训练开始前，**没有任何历史梯度/更新信息**，相当于“没有任何惯性”，所以自然要把这个“历史累积器”（B）初始化为 0：这是所有基于动量的优化器（SGDM、Nesterov、Muon）的标配操作，不是 Muon 独创的。

在训练的第 $t$ 步，计算当前的梯度。

计算第 $t$ 步的动量，使用 Nesterov 动量公式，通过上一步的动量 $B_{t-1} $ 和当前的梯度 $g_{t}$

Nesterov 的核心公式是：
$$
B_{t} = \beta \cdot B_{t-1} + (1 - \beta) \cdot g_{t}
      = \beta \cdot B_{t-1} + g_{t} - \beta \cdot g_{t}
	  = \beta \cdot (B_{t-1} - g_{t}) + g_{t}
$$

接下来我们可以把这个算法解释一遍了：
第一步是把动量 $B_{0}$ 赋值为 0，之后对于每一个 step $t$，做：

> 仅对隐藏层的 2D （及以上维度）参数执行此初始化，其他参数按对应优化器（如 AdamW）的规则初始化。

- 计算梯度 $G_{t}$

> 这一步就是得到原始梯度。和 AdamW/RMSprop 不同的一点是：Muon 不对梯度做任何缩放或者是归一化处理（比如 AdamW 的梯度平方累积、RMSprop 的梯度均方根缩放），
梯度的所有加工都靠后续的动量累积 + NS 正交化完成，这个是 Muon 的轻量化的关键。

> 这一步的核心作用是：得到参数当前的“原始更新信号”，指示参数该往哪个方向调整才能降低损失

- 利用梯度 $G_{t}$ 去计算动量 $B_{t} = \mu B_{t-1} + G_{t}$
> 算法的意义是说，通过 SGD（Stochastic Gradient Descent）标准动量公式，将历史动量惯性和当前的梯度信号融合，得到更平滑的“综合更新信号” $B_{t}$。
> $\mu$ 是动量系数（越接近 1，历史惯性越强），$\mu B_{t-1}$ 则表示历史动量惯性，表示模型会“沿着之前更新的方向继续走”。
> $G_{t}$ 是当前的梯度信号，表示模型会“沿着当前的梯度调整”

> 这一步的核心作用在于，解决纯 SGD（Stochastic Gradient Descent）的训练震荡问题 -- 纯的 SGD 仅用 $G_{t}$ 更新，方向易受单批次数据噪声影响，而增加动量后，
动量通过累积历史方向，让更新方向更平滑、更稳定，同时加快收敛（惯性会让参数沿着最优方向“冲”得更远）

> 在文章中提到说 SGD Nesterov-style 的 momentum 公式比经典的 SGD-momentum SGD 表现更好，所以在官方代码中也使用的是 SGD Nesterov-style 的 momentum。

- 利用动量缓冲区 $B_{t}$ 去计算 NS 迭代正交化：$O_{t} = NewtonSchulz5(B_{t})$
> 这一步是 Muon 优化器的核心创新步骤，将“条件数极高、更新方向单一” 的动量矩阵 $B_{t}$，通过 NewtonSchulz5 迭代转化为**半正交矩阵 $O_{t}$**。
```py
def newtonschulz5(G, steps=5, eps=1e-7):
	assert G.ndim >= 2
	a, b, c = (3.4445, -4.7750, 2.0315)
	X = G.bfloat16()
	X /= (X.norm() + eps) # 对动量矩阵做奇异值归一化，所有奇异值收敛到 0，1。
	if G.size(0) > G.size(1):
		X = X.T
	for _ in range(steps):
		A = X @ X.T
		B = b * A + c * A @ A
		X = a * X + B @ X
	if G.size(0) > G.size(1):
		X = X.T
	return X
```

> NewtonSchulz5 会先对 $B_{t}$ 做奇异值归一化（让奇异值 $\in$ 保证收敛），再经过 5 步迭代处理，最终输出半正交矩阵 $O_{t}$

> NewtonSchulz5 的核心作用是，解决原始动量更新的**方向单一问题** -- 神经网络 2D 参数的梯度 / 动量矩阵 $B_{t}$ 是低秩，条件数极高的，更新方向被少数“主方向”主导，
很多对于学习重要的“低频小幅度稀有方向”被忽略。

使用人话表示：

> 其实就是说，引入动量是为了解决梯度的噪声问题，噪声导致梯度的方向变化，从而影响到训练效果。动量是说，我们更新参数的方向大部分都是对的，那我就引入一个动量缓冲区 B，
> 积累历史的更新参数的方向，这样噪声发生的时候，因为有历史的更新参数的方向积累，所以不会导致我们更新参数方向走的太偏。但是引入动量又会导致一个问题，那就是说一些更优的
> 低频小幅度稀有方向会被忽略。针对这个问题，Muon 引入了 NewtonSchulz5，去让更新方向的权重更均衡，提升稀有方向的更新尺度，丰富参数的更新方向，最终让模型的样本效率大幅
> 提升。这个是 Muon 比传统的 SGD/AdamW 训练更快的核心原因。

动量解决的噪声，本质是训练数据的批次噪声：小批次训练的梯度会受到单批数据的随机噪声影响，导致梯度方向频繁震荡，动量通过累积历史方向，平滑了这种随机震荡，让更新方向更贴近真实的最优下降方向。

动量导致稀有方向被忽略，累积的动量矩阵 $B_{t}$ 会呈现低秩、高条件数的特征 -- 历史惯性会不断强化那些 “贡献大” 的主更新方向，而低频小幅度的稀有方向，其信号会被主方向的强信号完全淹没，最终动量更新几乎只沿着主方向走，丢失了很多对于模型泛化/收敛关键的特征方向。

NewtonSchulz5 的核心底层作用：通过半正交化消解了动量矩阵的高条件数问题，让矩阵的更新方向不再被奇异值（主方向）主导，从而让稀有方向的小信号被“放大”并参与参数更新，实现更新方向的权重均衡。

所以，Muon 的设计巧思在于：没有推翻传统的动量优化，而是在其基础上做了一次精准的“补丁式优化” -- 既保留了动量对梯度噪声的平滑作用，又解决了动量带来的方向单一性的问题，最终实现了“平滑更新 + 丰富方向”的双重效果。

这里我想问：
- 什么是低秩？它的英文是什么？在文章中的作用是什么？
> 矩阵中的秩（rank） 是指矩阵中线性无关的行/列向量的个数，是描述矩阵“信息丰富度”的核心指标。

> 低秩的意思是说，矩阵的秩 $r$ 远小于矩阵的行 / 列数（$r \ll min(行数，列数) $），这就意味着这个矩阵的大部分行/列向量都能
由少数几个线性无关的向量表示，矩阵的“有效信息”仅集中在少数方向上。

> 文章中指出，Transformer 隐藏层 2D 参数的梯度/动量矩阵（$G_{t} / B_{t}$）几乎都是低秩矩阵，这类矩阵的更新信号仅集中在少数几个秩对应的“主方向” 上，而
那些对模型学习、泛化至关重要的低频小幅度稀有方向，基信号会被主方向的强信号淹没。

> 而低秩通常包含着高条件数（High Condition Number），最终导致传统动量/SGD的更新方向单一，样本效率低，这也是 Muon 引入 NewtonSchulz5 正交化的直接动因：
NS 正交化的本质就是消解低秩矩阵的“方向集中” 问题，让有效信息分布到更多的方向上。

- 什么是奇异值，它的英文是什么？在文章中的作用是什么？
> 奇异值（singular value）是对任意 2D 矩阵做奇异值分解（SVD）后得到的核心量，也是矩阵的固有属性。

> 奇异值的大小代表了矩阵在对应方向上的“**信号缩放幅度**”：奇异值越大，说明矩阵在这个方向上的信号越强、贡献越大；奇异值越接近 0，说明这个方向的信号越微弱。

> 奇异值是贯穿 NS 迭代正交化全流程的核心变量，核心作用有 3 点：
> 1、NS 迭代的收敛前提：文章中 NS 迭代的第一步就是对动量矩阵 $B_{t}$ 做奇异值归一化，本质上是矩阵的最大奇异值缩放到 1，让所有的奇异值的取值范围到 [0, 1]

> 2、低秩矩阵的量化特征：低秩矩阵的奇异值是只有少数几个大的奇异值，其余奇异值均接近于 0 -- 这几个大的奇异值对应的就是矩阵的“主更新方向”，接近 0 的奇异值对应“稀有方向”。

> 3、正交化的本质是变换奇异值：文章中通过数学推导证明，NS 迭代对矩阵的处理，最终会转化对奇异值的逐元素多项式映射，调优后的 NS 系数（3.4445, -4.7750, 2.0315） 会让所有奇异值收敛到 1 附近。最终让矩阵各方向的“信号缩放幅度”趋于均衡。


我们先把 muon 的算法和它的代码对应一下。

<div class="mermaid">
flowchart TD

a[MuonWithAuxAdam.step] --> b[muon_update]
b --> c[zeropower_via_newtonschulz5]

a --> d[adam_update]

e[SingleDeviceMuonWithAuxAdam.step] --> b
e --> d

f[SingleDeviceMuon.step] --> b

g[Muon.step] --> b
</div>

<div class="mermaid">
classDiagram

`torch.optim.Optimizer` <|-- Muon
`torch.optim.Optimizer` <|-- MuonWithAuxAdam
`torch.optim.Optimizer` <|-- SingleDeviceMuonWithAuxAdam
`torch.optim.Optimizer` <|-- SingleDeviceMuon
</div>

- 最后利用 NS 迭代正交化的结果 $O_{t}$ 去更新参数 $\theta_{t} = \theta_{t-1} - \eta O_{t}$

好，那我们来问问题：
1、动量 $B_{t}$ 与 momentum $\mu$ 动量系数是什么关系？因为 momentum 在中文中也是翻译成动量，我看 $B_0$ 可以看成是 2D 参数的动量缓冲区（Buffer），那动量缓冲区和动量系数是个什么关系？

> 动量 $B_{t}$ 是动量缓冲区，而 $\mu$ 是动量系数，动量缓冲区是通过公式计算出来的，是之前梯度的累积动量项。

2、公式 $\nabla_{\theta} \mathcal{L}_{t}(\theta_{t-1})$ 中，$\nabla_{\theta} \mathcal{L}_{t}$ 是一个函数，就是算第 t 步梯度的函数吗？因为 $\nabla$ 也是梯度的意思，而 $\mathcal{L}$ 是 Loss 函数的意思，Loss 函数是用来计算梯度的，所以我不明白，为什么在 $\mathcal{L}$ 的前面还要加个 $\nabla$ 呢？

3、谱范数对应的英文是什么？它的含义是什么？

4、超参数在训练中的含义是什么？


## 模型训练的步骤

首先我们要知道 miniMind 是什么？

这个仓库是说，它可以让用户自己训练一个模型，来体验和了解模型训练的全过程。有点像是一个教学的模型，类似于 minix 之于 linux。

miniMind 当前的 optimizer 是 AdamW，在文件 `train_pretrain.py` 中：
```py
optimizer = optim.AdamW(model.parameters(), lr=args.learning_rate)
```

在 minimind 的代码中，loss 分成 2 部分，`loss = logits_loss + aux_loss`。`logits_loss` 就是一次前向传播后输出的值（预测下一个输出的 token）和期待输出的值的差距。而 `aux_loss` 则是辅助损失。

Epoch 的含义是把训练集训练几次。比如一个训练集有 10000 条数据，那么 1 个 Epoch 就是用这个训练集训练一次，用这个训练集训练一次的时间叫做 `epoch_time`。

一个 step/iteration 会做一次前向传播，但是前向传播可能不会立即更新参数，转而使用 `accumulate_step` 的方式去更新，即积累到了一定 step 后，再去更新参数。这样做的好处是模拟更大的 `batch_size`。还是刚才的那个例子，使用 10000 条数据的数据集去训练一次称为一个 epoch，训练一次的时间称为 `epoch_time`。`batch_size` = 32， `accumulate_step` = 8 ，那么前向传播的次数，即 step 的次数是 10000 / 32 = 313 次，但是每 8 个 step 才会更新一次参数，所以更新参数的次数为 313 / 8 = 40 次。

好接下来，我们已经大致搞懂了训练的一些名词和概念，接下来，我们来看一下 pretrain 和 sft 的差别。

### pretrain
pretrain 是无监督训练，解决模型有没有知识的问题。这里的无监督训练的意思是说，它没有 "问题：答案" 这样的配对。是让模型通过自回归技术去预测下一个 token 的方式，把数据集中的知识压缩到模型参数中。

pretrain 的目标是：让模型通过自回归技术去预测下一个 token，把数据集中的知识压缩到模型参数中，得到一个通用基座大模型。

pretrain 的输入是：
- 模型的初始状态（随机初始化的参数）
- 训练数据集
- 训练配置（起模型的配置）

输出是：
- 包含完整的训练后的权重

此时模型的特点是：
具备强大的语言续写能力，文本补全能力，掌握海量知识，但是完全不会遵循人类指令。比如让它去“写一篇关于春天的短文”，它只会随机续写文本，而不会针对性的完成指令任务。

#### 自回归技术（AutoRegressive）

'AutoRegressive' 中的 Auto 是源自于希腊语中的 autos，意思是 self，也就是这个名词中“自回归”中的“自”。

回归（Regressive）是一类问题，输入一个自变量，通过函数变换，输出一个因变量，如 $y = f(x)$。

那合起来，自回归（AutoRegressive）指的就是说，自变量和因变量都来源于同一个序列（Sequence），可以通过输入的自变量（序列中前面的值），预测出输出的因变量（序列后面的值）。

即我们定义：
$$
X_{t} = \sum^{p}\_{i=1} \varphi_{i} X_{t-i} + \epsilon_{t}
$$

- $X_{t}$ 为 $t$ 时序的序列值
- $X_{t-1}, X_{t-2},...X_{t-p}$ 为序列前 P 个历史值
- $\varphi$ 为自回归系数
- $\epsilon_{t}$ 为白噪声项，即随机扰动/误差

### SFT(Supervised Fine-Tuning)

SFT 是 Supervised Fine-Tuning 的缩写，SFT 是有监督的训练。使用的是较低的学习率，因为是微调嘛~

SFT 的目标是：让模型学会理解人类自然语言指令，按照指令输出合规的响应，把通用的语言模型改造成指令遵循模型。

SFT 的输入是：
- pretrain 阶段的全部参数
- SFT 的训练数据集，标准格式为：指令 + 可选输入 + 标准答案
- 训练配置

SFT 的输出是：
- 指令遵循型 SFT 模型

此时模型已经可以听懂人类指令，完成问答，写作等基础任务，但是还是存在明显缺陷：输出可能冗长，逻辑粗糙，不符合人类表达偏好。

### RL(Reinforcement Learning)

第三个阶段是 RL（Reinforcement Learning）

行业主流的是 RLHF（Reinforcement Learning Human Feedback）。

针对 SFT 模型的缺陷，通过人类的偏好数据训练奖励模型，再用 RL 优化模型参数，让模型输出更符合人类偏好，更好用，更安全的内容。

RLHF 的第一步，奖励模型（Reward Model）

输入是 SFT 模型的参数权重，人类标注的偏好对比数据集，微调超参数。

RLHF 的第二步：PPO 强化学习

输入：
- 模型初始状态：SFT 阶段输出的模型参数
- 评分工具：上一步训练好的奖励模型 RM，用于为模型生成的响应计算偏好分数
- 训练数据：仅需要指令数据集（无标注答案，和 SFT 指令同源即可）
- 约束配置：KL 散度约束（防止模型过度偏离 SFT 模型，丢失预训练知识）、PPO 算法专属超参数、优化器

输出：最终对齐的商用模型权重

因此问题总结如下：
第一个问题，什么是自回归技术，pretrain 的无监督学习主要的步骤有哪些呢？
第二个问题：什么是强化学习？它和监督学习和无监督学习的差别是什么？
第三个问题，PPO 是什么的缩写，PPO 和 RM 与 RLHF 的关系是什么？

