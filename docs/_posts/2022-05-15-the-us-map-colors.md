---
layout: post
title: "How many colors needed to draw a US map"
date:  2022-05-15 13:11:53 +0800
categories: Algorithm
---

最近看到一个问题：如果要求美国地图中的每组相邻的州颜色不同，那么画这样一个美国地图需要多少种颜色？

[Grokking Algorithms](https://www.amazon.com/Grokking-Algorithms-illustrated-programmers-curious/dp/1617292230?msclkid=19bbc53cbfea11ecab8c4725c6dfa8ed)
书中说这是一个NP完全问题，但是我还没有想通它为什么是一个NP完全问题，如果有看到这篇文章的小伙伴知道，
欢迎通过页面底部的邮箱告诉我。

尽管如此，我还是提出了一个算法来解决它，下面我们来讲讲我的思路，以及Go语言的实现。

我的想法是将美国地图抽象成一个无向图，每个州作为图中的一个顶点，如果两个州相邻，那么就在这两个顶点
中间加一条边。每个节点有一个不能上色的列表，notColor。我们用广度优先搜索遍历图中的每一个节点，对于
每个节点只干两件事情，**一是给节点上色**，**二是把节点的颜色加到其邻居节点notColor列表中**。

我们还维护着一个当前图中的所有颜色的集合finalColor，在给节点上色的时候，我们先用finalColor与该节点的
notColor进行集合相减，得到在finalColor中可以给节点涂的颜色集合optionColors。如果optionColors为空，那
说明不能用当前已经有的颜色给这个节点上色，因此我们需要给节点涂上一种新的颜色，然后把这个新的颜色加入
到finalColor集合中；如果optionColors不为空，那我们则选取optionColors集合的第一个颜色作为该节点的颜色。

算法思路：
```
   --> 当有节点可以处理
  |            |
  |            V
  |    给节点上色
  |            |
  |            V
  |    更新这些节点的邻居节点的notColor
  |            |
  |            V
  |    标记这个节点已经被处理过了
  |            |
   ------------
```

因为美国地图太大了，我们选取了最西边的5个州，它们分别是WA，OR，ID，CA和NV。它们的相邻情况如下：
```
        WA
       /  \
      /    \
     OR----ID
     | \    |
     |  \   |
     |   \  |
     |    \ |
     CA----NV
```

我们经过程序得出结论，如果要画这个小地图的话，需要三种颜色。这是Go语言的[实现](https://github.com/guo-sj/algorithm-go/blob/master/the-us-map-colors/main.go)。

值得一提的是，这个算法有一个待提高的地方，那就是
> 当optionColors不为空的时候，我们选取optionColors集合的第一个颜色作为该节点的颜色。

这会导致一个问题：随着你选取的起始节点不同，有可能会得到不同的结果。在给出的[实现](https://github.com/guo-sj/algorithm-go/blob/master/the-us-map-colors/main.go)
中，我们是以wa作为起始节点，得到的finalColor长度为3。但是如果我们以ca作为起始节点，得到的finalColor长度为4。
针对这个问题，我还没有想出合适的优化方案。

以上。
