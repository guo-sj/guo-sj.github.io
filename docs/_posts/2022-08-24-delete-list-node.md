---
layout: post
title: "删除链表的节点"
date:  2022-08-24 20:11:53 +0800
categories: Leetcode
---

这是《剑指Offer》书中第十八题：
> 在 O(1) 时间内删除链表节点。
>
> 给定单向链表的头指针和一个节点指针，定义一个函数在 O(1) 时间内删除该节点。链表节点与函数的定义如下：
> struct ListNode 
> {
>     int m_nValue;
>     ListNode *m_pNext;
> };
> 
> void DeleteNode(ListNode \*\*pListHead, ListNode \*pToBeDeleted);

我们这篇文章，先记录这道题的思路，然后我们来说一下链表这种数据结构的一些解题注意事项。

我们先说这道题的解题思路。通常来说，如果让我们删除一个链表中的某个节点，我们首先想到的方法便是遍历
整个链表，找到需要删除的节点，然后把它删除。这种方法的时间复杂度为 O(n)，但是我们这道题却要求在 O(1) 的
时间内删除该节点。显然，这种方法并不符合要求。

我们上述方法的核心目的是为了找到需要删除节点的前一个节点 pPreNode，让 pPreNode->m_pNext = pToBeDeleted->m_pNext，
但是其实我们还可以用另一个方式来解决这个问题，虽然现在 pToBeDeleted 的前一个节点 pPreNode 不好获得，但是
它的后一个节点好获得呀，**我们可以用 pToBeDeleted->m_pNext 覆盖 pToBeDeleted，然后我们
再把 pToBeDeleted->m_pNext 删除**。这样，我们就可以在题目规定的 O(1) 时间内把 pToBeDeleted 删除啦。

有了大致思路后，我们可以根据 pToBeDeleted 的位置将问题分成三种情况：
- 如果 pToBeDeleted 是头节点，那么我们把直接将 \*pListHead = (\*pListHead)->m_pNext，然后返回
- 如果 pToBeDeleted 是尾节点，我们需要遍历整个链表，然后把 pToBeDeleted 删除。这种情况的方法和我们
一开始提出的方法一致，时间复杂度为 O(n)
- 如果 pToBeDeleted 是中间节点，那么我们可以放心的用 pToBeDeleted->m_pNext 覆盖 pToBeDeleted，然后把 pToBeDeleted->m_pNext 
删除

虽然我们有种情况的时间复杂度为 O(n)，但是我们总的时间复杂度为 [(n-1) * O(1) + O(n)] / n = O(1)，因此满足题目要求。

因为这道题 Leetcode 上没有原题，所以我们把代码贴在下面：
```c
#include <stdlib.h> /* for free() */

struct ListNode 
{
    int m_nValue;
    ListNode *m_pNext;
};

void DeleteNode(ListNode **pListHead, ListNode *pToBeDeleted)
{
    if (pListHead == NULL || pToBeDeleted == NULL) {
        return;
    }

    if (pToBeDeleted == *pListHead) {
        *pListHead = (*pListHead)->m_pNext;
        free(pToBeDeleted);
        return;
    }

    if (pToBeDeleted->m_pNext != NULL) {
        pToBeDeleted->m_nValue = pToBeDeleted->m_pNext->m_nValue;
        pToBeDeleted->m_pNext = pToBeDeleted->m_pNext->m_pNext;
        free(pToBeDeleted->m_pNext);
        return;
    }
    ListNode *node = *pListHead;

    for (; node->m_pNext != pToBeDeleted; node = node->m_pNext) {
        ;
    }
    node->m_pNext = NULL;
    free(pToBeDeleted);
    return;
}
```

在说完了解法之后，我们再来说说链表问题的注意事项。从上面的分析可以看出，**当我们分析链表问题的时候，
我们首先要考虑的是，目标节点在整个链表中的位置，是头节点、中间节点还是尾节点**。**对问题进行分类讨论，
才可以将整个问题的所有情况考虑周全，增加代码的鲁棒性**。

以上。
