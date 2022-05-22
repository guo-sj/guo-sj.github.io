---
layout: post
title: "Island Problem in Leetcode"
date:  2022-05-22 10:11:53 +0800
categories: Leetcode
---

Leetcode中有一系列的岛屿问题：
1. [岛屿数量](https://leetcode.cn/problems/number-of-islands/)
2. [岛屿的周长](https://leetcode.cn/problems/island-perimeter/)
3. [岛屿最大面积](https://leetcode.cn/problems/max-area-of-island/)

三个月前趋势的那场笔试中就有一道计算“岛屿数量”题，当时自己没做出来。现在自己
已经掌握了一些经典的数据结构和算法，准备开始刷题，首先想到的就是把这个岛屿问题
解决了。经过学习[nettee](https://leetcode.cn/u/nettee/)同学的这篇[题解](https://leetcode.cn/problems/number-of-islands/solution/dao-yu-lei-wen-ti-de-tong-yong-jie-fa-dfs-bian-li-/)，
加上自己的思考和练习，目前已经基本掌握了岛屿类问题的解题方法，故在此记录下来。

我们先来介绍一下什么是岛屿问题。岛屿问题是指，一个矩阵中只有0和1两种值，0代表
海洋，1代表陆地。陆地之间通过上下左右四个方向相连可以组成更大的陆地。如果一片
陆地四周都被海洋包围，那么就称这片陆地为“岛屿”。并且假设矩阵周围都被海洋包围。如
下图中就有两块岛屿。
```
[0 0 0 1]
[0 1 0 0]
[0 1 1 0]
[0 0 0 0]
```

在此基础上就延伸出一系列问题，如求岛屿数量，岛屿周长，岛屿最大面积等。我们先不
着急分析具体问题，先来讲一下这类问题的通用思路。

首先是用DFS（深度优先搜索）算法来解决这类问题。我之前写过[一篇文章](https://guo-sj.github.io/algorithm/2022/05/19/dfs.html)来介绍DFS，
这里就不过多介绍了。我们的主要思路是：把这个矩阵中的岛屿抽象成图，然后用DFS去遍历图中的每一个节点。比如
我们发现矩阵中的一个值等于1，它的上下左右为1的节点就相当于它的邻居节点，我们就沿上下左右四个方向去深度遍历它。
为了避免重复遍历同一个岛屿，每遍历到一个节点，我们把它的值由1改为2。

在了解了具体的思路之后，我们来看最初提到的三个例子。

### 岛屿数量

算法：
1. 遍历二维数组grid，元素的横坐标为r，纵坐标为c，定义当前岛屿数量islandNum为0
2. 如果grid[r][c] == 1，则探索岛屿，islandNum += 1
3. return islandNum

定义探索岛屿的函数名为exploreIsland，算法为：
1. 如果 r < 0 || r >= len(grid) || c < 0 || c >= len(grid[0])，则return
2. 如果grid[r][c] != 1，说明不是岛屿的一部分，return
3. grid[r][c] = 2
4. 向上，下，左，右四个方向递归探索岛屿的其他部分，exploreIsland(grid, r-1, c),
exploreIsland(grid, r+1, c)，exploreIsland(grid, r, c-1)，exploreIsland(grid, r, c+1)

这是我的[提交记录](https://leetcode.cn/submissions/detail/316393481/)。

### 岛屿周长
算法：
1. 遍历二维数组grid，元素的横坐标为r，纵坐标为c，定义当前岛屿周长islandPerimeter为0
2. 如果grid[r][c] == 1，则islandPerimeter = calcIslandPerimeter()
3. return islandPerimeter

calcIslandPerimeter()是计算岛屿周长的函数。如果要用DFS计算岛屿周长的话，
那么实际上要求的就是用DFS遍历岛屿时出界的次数，对吧？想明白了这个，算法
就好写了。算法为：
1. 如果 r < 0 || r >= len(grid) || c < 0 || c >= len(grid[0])，超出边界，则return 1
2. 如果grid[r][c] == 0，说明找到了海洋，则return 1
3. grid[r][c] = 2
4. 向上，下，左，右四个方向递归探索岛屿的其他部分，return calcIslandPerimeter(grid, r-1, c) +
calcIslandPerimeter(grid, r+1, c) + calcIslandPerimeter(grid, r, c-1) + calcIslandPerimeter(grid, r, c+1)

值得一提的是在实际实现的过程中，calcIslandPerimeter()的第二步要稍稍修改一下，将grid[r][c] == 0改为“如果 
grid[r][c] == 2，则return。如果grid[r][c] != 1，则return 1”。因为我这边测试时用golang写的程序，用前者
会内存溢出。

这是我的[提交记录](https://leetcode.cn/submissions/detail/316404806/)。

### 岛屿最大面积
算法：
1. 遍历二维数组grid，元素的横坐标为r，纵坐标为c，定义当前岛屿最大面积maxArea为0
2. 如果grid[r][c] == 1，则用函数calcArea来计算岛屿的面积area，maxArea = max(maxArea, area)
3. return maxArea

calcArea()是计算岛屿面积的函数，我们的思路和上面计算岛屿周长的相反，上面是如果遍历出界，
则返回1，而这边是如果没有出界，返回1。算法为：
1. 如果 r < 0 || r >= len(grid) || c < 0 || c >= len(grid[0])，超出边界，则return 0
2. 如果grid[r][c] == 0，说明找到了海洋，则return 0
3. grid[r][c] = 2
4. 向上，下，左，右四个方向递归探索岛屿的其他部分，return 1 + calcArea(grid, r-1, c) +
calcArea(grid, r+1, c) + calcArea(grid, r, c-1) + calcArea(grid, r, c+1)

这是我的[提交记录](https://leetcode.cn/submissions/detail/316187537/)。

最后我们说一下岛屿问题一些subtle的点：
1. 当从头开始遍历矩阵的时候，我们要确保遇到的第一个1一定是岛屿的第一个节点，否则就会陷入重复遍历。
这边采用的方法是每遍历一个1，就把1改为2

以上。
