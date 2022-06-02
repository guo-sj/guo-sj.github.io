---
layout: post
title: "Binary Tree Traverse"
date:  2022-06-02 10:11:53 +0800
categories: Algorithm
---

这篇文章介绍一下二叉树的三种遍历方式：前序（Pre-order）遍历，中序（In-order）遍历，和后序（Post-order）遍历。
每种遍历我都会给出递归和循环两种实现思路，最后给出我自己用 Golang 的实现链接。

不管是前序，中序还是后序，左，右两个节点的遍历的相对顺序是固定的，都是“先左后右”，其中的“前”，“中”，“后”指明
了“根节点”相对于其他两个节点的相对位置。所以前序遍历就可以写成是“根 -> 左 -> 右”，中序遍历就是“左 -> 根 -> 右”，后序遍历就
是“左 -> 右 -> 根”。

我们先来看三种遍历方式的递归形式。以前序遍历为例，假设递归函数为 preOrder(Tree \*tree)，我们的递归思路为：
```
1. 如果 tree 为空，那么返回
2. 输出 tree->Val
3. preOrder(tree->Left)
4. preOrder(tree->Right)
```

第一步为递归的 base 条件，第二步为函数真正做的事情，第三，四步为递归调用。我们把第一步不动，调整第二步和
最后两步的相对顺序，就可以得出中序和后序的递归思路。

中序遍历（inOrder(Tree \*tree)）的思路为：
```
1. 如果 tree 为空，那么返回
2. inOrder(tree->Left)
3. 输出 tree->Val
4. inOrder(tree->Right)
```

后序遍历（postOrder(Tree \*tree)）的思路为：
```
1. 如果 tree 为空，那么返回
2. postOrder(tree->Left)
3. postOrder(tree->Right)
4. 输出 tree->Val
```

因为二叉树本身就是递归定义的，所以用递归的方式遍历它显得非常优雅。值得一提的是，
这三种遍历算法都属于深度优先搜索算法（DFS）。我之前
写过[一篇文章](https://guo-sj.github.io/algorithm/2022/05/19/dfs.html)来介绍 DFS，
不熟悉的小伙伴可以看看。

我们知道，递归本身就是一种栈结构，所以一个递归的算法一定可以用循环和栈来改写。接下来，我们来分别介绍上述
三种遍历方法的非递归实现的思路。

和刚才一样，我们先来看前序遍历（preOrderLoop(Tree \*tree)）：
```
1. 如果 tree 为空，则返回
2. 将 tree 入栈 stack
3. 当 stack 不为空时：
    1. 将 tree 出栈，输出 tree->Val
    2. 如果 tree->Right 非空，则将 tree->Right 入栈
    3. 如果 tree->Left 非空，则将 tree->Left 入栈
4. return
```
注意，前序遍历的时候，我们是先将 tree->Right 入栈，再将 tree->Left 入栈，思考一下
这是为什么 :-) ？

前序遍历的非递归算法和 DFS 的非递归实现基本相同，因为二叉树没有由子节点指向父节点的边，所以相比图的 DFS 实现，
少了判断已经遍历过的节点的步骤。

接下来，我们来看中序遍历和后序遍历。中序遍历的顺序是“左 -> 根 -> 右”，后序遍历的顺序是“左 -> 右 -> 根”，所以对于一个二叉树，第一个遍历的节点一定属于这三种情况的一种：
    1. 对于一个有左子树的二叉树，第一个遍历的节点是它左子树的最左边的叶子节点
    2. 对于一个没有左子树但是有右子树的二叉树，第一个遍历的节点是它右子树的最左边的叶子节点
    3. 如果一个没有左、右子树的二叉树，第一个遍历的节点是它的根节点

所以对于这两种遍历方法，我们首先沿着根节点找它最左边的叶子节点，并用栈记录寻找路线。接下来，**我们把这个节点作为新的根节点再去遍历**，这个也体现了二叉树的递归定义的思想。
对于中序遍历，此时我们先把这个节点出栈，并输出，以这个节点为根节点，再去找这个根节点右子树的最左节点；
对于后序遍历，和中序遍历相反，我们把这个节点标记为“已经搜索过”，然后去找它的右子树的最左节点，
等把右子树都遍历完后，再将根节点出栈。理解了这一点之后，中序遍历和后序遍历的非递归思路就不难
书写了，两者的思路分别为：

中序遍历（inOrderLoop(Tree \*tree)）的思路：
```
1. 如果 tree 为空，则返回
2. 将 tree 入栈 stack
3. 定义 node = tree->Left
4. 当 stack 不为空时：
    1. 如果 node 不为空，将 node 入栈，node = node->Left
    2. 反之：
        1. 设这次栈顶元素为 newRoot。把 newRoot 出栈，并输出
        2. 如果 newRoot->Right 不为空，则将 newRoot->Right 入栈，定义 node = newRoot->Right->Left
        3. 反之，node = NULL
```

后序遍历（postOrderLoop(Tree \*tree)）的思路：
```
1. 如果 tree 为空，则返回
2. 将 tree 入栈 stack
3. 定义 node = tree->Left
4. 当 stack 不为空时：
    1. 如果 node 不为空，将 node 入栈，node = node->Left
    2. 反之：
        1. 设这次栈顶元素为 newRoot。
        2. 如果 newRoot->Right 为空或 newRoot 已经被标记为搜索过，
           则将 newRoot 出栈，并输出，node = NULL，continue
        3. 如果 newRoot->Right 不为空，将 newRoot 标记为搜索过，将 newRoot->Right 入栈，
           node = newRoot->Right->Left
```

这是我的 Golang 实现[链接](https://github.com/guo-sj/algorithm-go/blob/master/binary-tree-traverse/main.go)。

以上。
