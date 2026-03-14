---
layout: post
title: "学习 Speech Language Model"
date:  2026-03-14 10:11:53 +0800
mathjax: false
mermaid: false
categories: Paper
---

最近接到一个任务：

> 前面其他同学主要梳理了一下图像/视频生成和理解的模型结构的原理，音频的还没有看，你这 2 天梳理一下，周一或周二我们内部交流一下，要求梳理一下，从 Encoder mllm Decoder 每一个部分每一步的核心工作机理，算法原理。另外，中间如果涉及一些知识点没有接触过的，不要硬啃，用豆包给你解释一下


接到任务后我先收集一下资料：
- [2025/09: qwen3-omni](https://github.com/QwenLM/Qwen3-Omni/blob/main/assets/Qwen3_Omni.pdf)
    - [Qwen3-Omni：统一多模态大模型再升级](https://zhuanlan.zhihu.com/p/1954190930811810835)
- [2025/05: VoxEval: Benchmarking the Knowledge Understanding Capabilities of End-to-End Spoken Language Models](https://arxiv.org/pdf/2501.04962)
- [2025/05: VoxEval -- github](https://github.com/dreamtheater123/VoxEval)
- [2024/05: Recent Advances in Speech Language Models: A Survey](https://aclanthology.org/2025.acl-long.682.pdf)
- [2024/05: Awesome-SpeechLM-Survey -- github](https://github.com/dreamtheater123/Awesome-SpeechLM-Survey)

有了资料了，接下来我们学习一下 SLM(Speech Language Model) 的基本概念，然后主要以 qwen3-omni 和 VoxEval 去学习一下当前最新模型的设计思路和结构。

我们先看 qwen3-omni，`omni` 源自拉丁语中的 `所有`，模型名称中加 `omni` 表示它是一个支持文本，图像，视频，音频的多模态模型。

ASR 是什么？ ASR stands for `Automatic Speech Recognition`，它用来将语言转换成文字，然后丢给 LLM 去理解，最后输出文字，再使用 TTS(Text-To-Speech) 技术转换成语音。

这一套是传统的做法，现在的技术是：

直接使用 Encoder 把输入的音频变成 IR(Intermidiate Representation，中间表达)，然后 MLLM (Multimodel Large Language Model) 去处理并输出结果，Decoder 把结果转换成音频。


Qwen3-Omni 模型采用 Thinker-Talker 双 MoE 核心架构

Thinker 负责多模态理解与文本生成，基于 30B-A3B MoE Transformer，对接视觉、音频编码器，支持全模态推理，可独立通过系统提示词定制对话风格。

Talker 负责流式语音生成，基于 3B-A0.3B MoE Transformer，采用多码本自回归预测方案，直接接收 Thinker 的多模态特征，与 Thinker 解耦设计，可独立定制语音风格。

所以你看，Thinker 负责多模态理解和文本生成，Talker 负责流式语音生成，这个就包含了领导要求的语音理解和生成的工作范围。

AuT(Audio Transformer)

Hz（赫兹）是**频率**单位，用来表示**每秒发生多少次**：
- 1Hz = 每秒 1 次
- 100Hz = 每秒 100 次

在输入音频时每隔 10ms 提取一个音频的特征，那么 1s 中就会提取 100 次，提取的频率是 100Hz。然后这些特征经过 AuT Encoder 后，被压缩成了 12.5Hz，也就是 1s 中有 12.5 个特征，对比原来的 1s 中 100 个特征，压缩了 100 / 12.5 = 8 倍。这样做的好处是减少了 AuT Encoder 后 32 层及 AuT Decoder 的处理长度，使得处理速度更快。

这里补充一下 Hidden 和“拟合”的概念。

Hidden 意思是“隐藏”，为啥叫隐藏呢，是因为它是大模型内部的黑箱产物，我们看不到原始输入的痕迹，但它包含了模型学到的，对任务有用的关键信息（比如音频的语义，文本的逻辑关系）。

我们在代码中常见的 `hidden_state` 中存储的就是这个黑箱产物，而 `hidden_size` 则是 `hidden_state` 的维度，维度越大，信息越丰富。

`拟合(fitting)` 指的是**模型通过调整自身参数，让自己的输出尽可能“贴近”真实数据规律的过程**。

好，我们来看 AuT 处理的具体过程：
1. 输入原始语音波形：底层的黑色声波图，这是待识别的语音信号。
2. 生成 FBank 特征（前置处理）：对原始语音做分帧，帧移为 10ms，生成 100Hz 的 FBank 特征（黄色方块）。这是声音的数字化 “切片”。
3. AuT Encoder 正向传播:
    - 先经过卷积下采样：进入编码器后，首先通过 3 层 Downsampling Conv2d，在时间维度进行 8 倍压缩。
    - 再经过注意力层：下采样之后，特征进入 32 层 Self-Attention Layer 进行深度特征提取。
4. 编码器输出（AuT Hidden）：输出特征帧率为 12.5Hz，对应 80ms 原始音频。这是对语音语义高度浓缩后的 “思想向量”
5. AuT Decoder 解码（文本生成）
    - 将 AuT Hidden 输入到 8 层解码器中，每层的结构 `Decoder Self-Attention` + `Decoder Cross-Attention`
        - Self-Attention: 负责生成文本的语法和语序（如何组词成句）
        - Cross-Attention: 负责**翻译**，将编码器的音频主义特征映射成具体的文字
6. 最终输出：识别出的文本内容

这个码本（multi-codebook）是个什么东西？

Thinker 生成的是文本

Talker 生成的是音频或视频

Time-aligned Multimodel Rotary Embedding(TM-RoPE)

什么是 RoPE: Rotary Position Embedding 旋转位置编码，把 token 的位置，变成向量的旋转角度，让注意力计算天然只关心位置差，不关心【绝对位置】。

`.ipynb` 文件是 Jupyter /ˈdʒuːpɪtər/ Notebook 的后缀

Qwen3-Omni 系统包含如下的几个模块：
- 感知模块（Perception Module），也叫**多模态编码器**，负责将不同模态的原始输入转换成统一的特征表示
    - 音频编码器：采用自研的 AuT（Audio Transformer），用于处理音频信号
    - 视觉编码器：采用基于 SigLIP2-So400m 初始化的模型，用于处理图像和视频帧
- 思考者（Thinker）：一个 30B 参数规模的 MoE Transformer 模型。其主要职责是：
    - 多模态理解：接收并融合来自编码器的文本、图像、音频、视频特征
    - 高级推理：基于融合后的信息进行复杂的逻辑推理、知识问答和指令遵循
    - 文本生成：生成最终的文本形式响应
- 说话者（Talker）：一个相对较小的 3B 参数规模的 MoE Transformer 模型，其核心任务是：
    - 语音风格建模：接收来自 Thinker 的高维多模态特征和对话历史，以确定生成语音的音色，韵律和情感
    - 流式语音编码生成：自回归地生成离散的语音编码（speech codecs）
- 语音合成模块：
    - MTP（Multi-Token Prediction）模块：一个轻量级的 Transformer，用于在 Talker 生成主编码后，快速预测剩余的残差编码。
    - Code2Wav 解码器：一个轻量级的因果卷积网络（Causal ConvNet），负责将完整的语音编码实时转换成音频波形。

