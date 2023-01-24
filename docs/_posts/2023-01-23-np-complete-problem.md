---
layout: post
title: "NP Complete Problem"
date:  2023-01-23 10:11:53 +0800
mathjax: true
comments: true
categories: Algorithm
---

这段时间打算复习一下算法，发现不记得旅行家问题（$Traveling\ Saleperson\ Problem$）
的含义了，就去学习了一下。学习完之后，又发现这个问题属于 $NP\ (Nondeterministic\ Polynomial)\ Complete\ Problem$，简写为 $NPC$，就又去学习了一下什么是 $NPC$ 问题，这下到好，彻底给自己整糊涂了，到目前为止也没有完全搞明白到底啥是 $NPC$ 问题。
那作为读者你可能就要问了，你都没搞明白，你在这里写个啥呀？您要是非要这么说，也对。我在这边写的东西主要是为了整理
一下自己的思路，毕竟看了不少的文章，多多少少还是学到一些东西的。

我们先来看下什么是 $NPC$ 问题：
- $X \in NP$
- 对于任意一个 $Y \in NP$，$Y$ 可以在多项式时间内转化成 $X$，即 $Y \le_{p} X$

什么是 $NP$？

$NP$ 是 $Nondeterministic\ Polynomial$ 的缩写，它指的是一类选择性问题，可以用 $NTM\ (Nondeterministic\ Turing\ Machine)$ 在多项式时间
解决的问题。$NTM$ 是指到达一个状态之后需要附加选择才能到达下一个状态；与之相对的是 $DTM\ (Deterministic\ Turing\ Machine)$ 
则是每到达一个状态之后，可以确定的到达下一个状态。如果在 $NTM$ 中把每次的选择都固定下来，则 $NTM$ 就变成了 $DTM$。所以 $DTM \in NTM$。

什么是 $P$？

$P$ 是 $Polynomial$ 的缩写，它指的是一类问题，这类问题可以在 $DTM$ 下以多项式时间内计算出结果。因为上面我们已经知道 $DTM \in NTM$，
所以 $P \in NP$。

什么是多项式时间（$Polynomial\ Time$）？

多项式时间是用来衡量一个算法时间复杂度的工具。如果一个算法的时间复杂度可以用表达式 $T(n) = O(n^{k})$ 来表示，$k$ 是一个常数，
那么我们就说这个算法是多项式时间的。其实意思就是说，这个算法是可以被计算的。

以上这些就是我学习到的一些知识，它们除了可以帮我增强我的专业英文水平和使用 $Markdown$ 去表达数学符号外没有任何其他的作用，$So\ 
just\ let\ it\ go!$ 在文章的最后，我会放一些搜集到的资料，有兴趣的同学可以看看。

下面我来说一下自己的理解。首先，$NPC$ 问题就是一类无法在多项式时间内解决的问题，比如下面要讲到的旅行家问题，它的时间复杂度是$O(n!)$，
当 $n$ 达到一定的数量的时候，比如说 $10000$，那么当太阳寿命耗尽你也算不出来。对于这类问题，我们只能采取一种估计算法（$approximation\ algorithm$）,
也就是我们常说的[贪心算法](https://guo-sj.github.io/algorithm/2022/05/14/greedy-algorithm.html)。

现在我们来举 $NPC$ 问题的两个例子。

首当其冲的是旅行家问题（$Traveling\ Saleperson\ Problem$）。说是有一个旅行家，它想去 $n$ 个城市旅游，希望可以找到一个总里程最短的
游玩路线。这个问题是一个典型的 $NPC$ 问题。它的算法很简单，把这 $n$ 个城市所有可能的组合情况都列出来并计算它们的总里程，最后从中
选出一个最小值。我们想一下，要计算出所有可能的情况的话，需要 $n!$ 次计算，这显然不是一个可以在多项式时间里可以解决的问题。

另一个例子就是集合覆盖问题（$Set\ Cover\ Problem$）。说是有一个全集 $U$，然后有 $m$ 个集合 $S_{1}, S_{2}, ... S_{m}$，现在我们求最少的
集合，让它的并集等于 $U$。比如 $U = \{1,\ 2,\ 3,\ 4\},\ S_{1} = \{1,\ 3\}, S_{2} = \{2,\ 4\}, S_{3} = \{3,\ 4\}$，那么最少的集合就是 $S_{1},\ S_{2}$。
要解决这个问题，我们需要把这这 $m$ 个集合看成一个大集合中的元素，然后，对这个大集合求解它的幂集（$Power\ Set$），然后再从幂集中找出一个
个数最少的元素，让它的并集等于 $U$。所以这个算法的时间复杂度为 $O(2^{n})$。显然，这也不是一个可以在多项式时间里可以解决的问题。

那么我们该如何确定一个问题是否是 $NPC$ 问题呢？通常我们会采用**化归与转化**的思想：如果一个问题可以简化（$reducible$）为我们上面讲过的
旅行家问题或者集合覆盖问题，那么它就是一个 $NPC$ 问题。

最后，我列出一些为了写这篇文章的参考资料，供有兴趣的同学学习，也可以让我日后想完善这篇文章时进行参考：
- [集合覆盖问题](https://zhuanlan.zhihu.com/p/408556395)
- [Reductions & NP-completeness](https://www.cs.cmu.edu/~ckingsf/bioinfo-lectures/npcomplete.pdf)
- [What is an NP-complete in computer science?](https://stackoverflow.com/questions/210829/what-is-an-np-complete-in-computer-science)
- [Time Complexity](https://en.wikipedia.org/wiki/Time_complexity#Strongly_and_weakly_polynomial_time)
- [Turing Machine](https://en.wikipedia.org/wiki/Turing_machine)
- [Exponentiation by Spuaring （快速幂）](https://en.wikipedia.org/wiki/Exponentiation_by_squaring)

以上。
