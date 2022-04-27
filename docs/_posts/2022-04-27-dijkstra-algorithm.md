---
layout: post
title: "Dijkstra's Algorithm"
date:  2022-04-27 10:11:53 +0800
categories: Algorithm
---

[上一篇](https://guo-sj.github.io/algorithm/2022/04/19/bfs.html)
介绍了广度优先搜索，一种可以对有向无权图搜索节点的图算法。今天我们来介绍一种
对有向有权图的求最短路径的算法 -- Dijkstra's Algorithm。

[Grokking Algorithms](https://www.amazon.com/Grokking-Algorithms-illustrated-programmers-curious/dp/1617292230?msclkid=19bbc53cbfea11ecab8c4725c6dfa8ed)书中说Dijkstra's Algorithm 只适用于有向无回路图（DAG: Directed Acyclic Graph），
但是实际上，书中最后给出的算法描述，是可以解决回路问题的，因此，严格来说，
Dijkstra's Algorithm可以求解有向有权图（Directed Weighted Graph）的最短路径。
哦对了，还有一点要注意，这个算法并不适用于含有负数权的图，至于原因我下面会详细说明。

好，话不多说，我们先来看算法描述，假设我们想求一个图中节点A到节点B的最短路径，那么：
```
1. 找出当前节点A可以到达的最近的节点
2. 检查是否有更少的花销到达这个节点的neighbor,
   如果有，那么则更新它们的开销
3. 对图中的每个节点都进行上述两步
4. 最后得到的到节点B的开销就是A到B的最短路径
```

接下来，我们来举例，并用Go语言实现。

TODO
