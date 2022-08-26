---
layout: post
title: "链表中倒数第 k 个节点"
date:  2022-08-26 16:11:53 +0800
categories: Leetcode
---

这是《剑指Offer》第 24 题：
> 输入一个链表，输出该链表中倒数第 k 个节点。为了符合大多数人的习惯，本题从 1 开始计数，即链表的
尾节点是倒数第一个节点。例如，一个链表有 6 个节点，从头节点开始，它们的值依次是 1、2、3、4、5、6。
这个链表的倒数第 3 个节点是值为 4 的节点。
>
> 链表节点的定义如下：
> struct ListNode 
> {
>     int m_nValue;
>     ListNode *m_pNext;
> }

这道题，我们先来说一下自己的解法，然后再来讲一下书中的解法。

自己一拿到这道题，想的是，现在要返回第 k 个节点，那么我们可以把链表节点逐个入栈，然后，再弹出 k 个
节点，最后一个节点就是题目需要的节点。这样的话，算法的时间复杂度是 O(n)，空间复杂度也是 O(n)。

[这是](https://leetcode.cn/submissions/detail/355211553/)我的提交记录。

然后我们再来看看书中的解法。书中给出了一种我从未想过的方案 -- **用两个指针去遍历链表**。题目要求是返回链表
的倒数第 k 个节点，那么我们假设链表的长度为 n，那么倒数第 k 个节点的应该是正数第 n - k + 1 个节点。那么
我们可以用一个指针 p1 指向 head，另一个指针 p2 指向 head + (n - (n - k + 1))，也就是指向 head + (k - 1)，
然后开始遍历链表。当 p2 指向尾节点时，p1 指向的节点恰好就是倒数第 k 个节点。这样我们只需要遍历一次链表，
就可以返回所需要的值。这个算法的时间复杂度为 O(n)，因为不需要额外的空间，所以空间复杂度为 O(1)。

[这是](https://leetcode.cn/submissions/detail/355227066/)我的提交记录。

所以这道题给了我们一个启示，当我们有时用一个指针遍历一次链表无法完成的工作，用两个指针去遍历或许会有
意想不到的效果，这道题就是一个例子。还有一个例子，比如现在让你返回一个链表的中间结点。我们通常的做法
是先遍历一次，得到链表的长度 n，然后再从头开始，遍历到 n / 2 的节点，然后返回。对于这个问题，我们还可以
用刚刚提到的思路，即用两个指针，一个指针一次走一个节点，另一个则一次走两个节点。等走两个节点的指针到达
链表末尾的时候，第一个节点所在的节点就是整个链表的中间节点。代码如下：
```c
struct ListNode *midNode(struct ListNode *head)
{
    if (head == NULL)
        return NULL;

    struct ListNode *oneStepNode, *twoStepNode;
    oneStepNode = twoStepNode = head;
    while (twoStepNode->next != NULL) {
        if ((twoStepNode = twoStepNode->next->next) == NULL)
            break;
        oneStepNode = oneStepNode->next;
    }
    return oneStepNode;
}
```

以上。
