---
layout: post
title: "用两个栈实现一个对列"
date:  2022-07-16 10:11:53 +0800
categories: Leetcode
---

这是《剑指Offer》的第九题 -- “用两个栈实现一个对列”的记录。

题目是这样的：
> 用两个栈实现一个对列。请实现它的两个函数 appendTail 和 deleteHead，分别完成在对列尾部插入
节点和在对列头部删除节点的功能。

栈的特点的“后进先出”，对列的特点是“先进先出”。如果要用两个栈去实现一个对列的话，假设两个栈
分别为 stack1 和 stack2，我们可以先让数据输入到 stack1 里，然后再把数据从 stack1 中按照“后进先出”
的顺序 pop 到 stack2，这时 stack2 中数据的顺序就和将数据直接输入进一个对列的顺序是一致的。

知道了这一点之后，我们来看题目中的两个功能。先来看 appendTail。这个功能的设计思想，就像我们
上一段说的那样，用 stack1 去接收元素，再将元素从 stack1 pop 到 stack2。然后我们再来看第二个
功能 deleteHead。这个功能也简单，因为 stack2 的栈顶元素就是对列的第一个元素，所以我们只要将
 stack2 指向栈顶的指针减一即可。

可以看到，这两个功能单独实现起来是比较简单的，但是要将它们结合起来的话，就会出现一个问题，
那就是：测试时，是将 appendTail 和 deleteHead 两个函数按照任意顺序调用的，那么我们何时将 stack1
的元素 pop 到 stack2 呢？对于这个问题，我一开始想的是只要调到 deleteHead 函数时就 pop，但是这样
就会产生一个问题：假设我们按照以下的函数调用顺序进行测试，结果就会出现问题：
```
appendTail(queue, 1);
appendTail(queue, 2);
appendTail(queue, 3);
appendTail(queue, 4);
deleteHead(queue);
deleteHead(queue);
appendTail(queue, 5);
appendTail(queue, 6);
deleteHead(queue);
```

正常情况下，经过上述调用后，queue 中的元素应该为： 4 5 6，但是实际上，如果你每次调到 deleteHead 函数
就 pop 的话，你的 queue 中元素却是： 6 3 4。这是为什么？原因是当你 append 1，2，3，4，然后 delete 2 次，
此时的 queue 为：3 4，这时你又 append 两个元素 5，6，再调 deleteHead，程序首先会将 5，6 一起 pop 到 stack2
，因此在没有删除之前，queue 中的元素为：5 6 3 4。栈顶元素为 5，你删除的时候把 5 删除了，所以 queue 的
元素就是 6 3 4 。所以在一调到 deleteHead 函数就 pop 的方法是不对的。

为了解决这个问题，我想了一种方法。我发现，上述的 pop 方法在 stack2 中元素为空的时候是可以正常运行的。因为
stack2 为空，所以不存在上述的错序问题。因此，我们只要在 stack2 为空的时候 pop 就可以了。

最后，附上我的 C 语言的[提交记录](https://leetcode.cn/submissions/detail/338076833/)。

以上。
