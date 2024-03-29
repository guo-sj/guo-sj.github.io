---
layout: post
title: "树的子结构"
date:  2022-08-31 09:11:53 +0800
categories: Leetcode
---

这是《剑指Offer》的第 26 题：
> 输入两棵二叉树 A 和 B，判断 B 是不是 A 的子结构。二叉树的定义如下：
```c
struct TreeNode {  
    int val;
    struct TreeNode *left;
    struct TreeNode *right;
};
```

这道题涉及二叉树的遍历，所以我们初步应该要想到用递归这种自上而下的思想去解决问题。初步的思想为，我们
对于 A 的每一个节点，都去判断是否可以沿着找到 B。然后还有一点需要注意的就是，B 是 A 的子结构的含义是
**在 A 中可以找到 B**，这并不一定意味着 B 是 A 的一个子树，B 也可以在 A 中间的某个位置。这一点要搞清楚。
然后我们就可以写出代码啦。

[这是](https://leetcode.cn/submissions/detail/357021900/)我的提交记录。

我还想说的是，大家有没有发现这道题和我们之前做过的[矩阵中的路径](https://guo-sj.github.io/leetcode/2022/08/15/route-in-matrix.html)
非常像。前者是要在二叉树中找另一个二叉树，后者则是在矩阵中找路径。然后两个题目用到的思想是完全一样的。都是用两个函数，外层
函数来遍历整个空间，内层函数来用 DFS 进行递归调用。唯一有一点不同的就是，二叉树本身的定义就是自上而下的，所以你遍历的时候是不会
遍历到重复的节点的，所以这道题的内层函数中没有判断重复的操作。但是矩阵本质上是一个图，用 DFS 遍历时是有可能重复遍历同一个节点的，
所以在[矩阵中的路径](https://guo-sj.github.io/leetcode/2022/08/15/route-in-matrix.html)这道题中，内层函数就要有判断重复的操作。

启示：
- 这道题考察了二叉树的遍历操作，DFS 算法，是一道比较综合的题。虽然是一道新题，但是我依旧可以从中找出
和之前遇到的题相似的地方，并用同一个算法思想去解决它
- 二叉树的定义本身就是递归的，所以涉及到二叉树的问题首先应该考虑递归的思路

以上。
