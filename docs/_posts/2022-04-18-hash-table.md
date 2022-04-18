---
layout: post
title: "O(1) Algorithm - Hash Table"
date:  2022-04-18 13:11:53 +0800
categories: Algorithm
---

[上一篇](https://guo-sj.github.io/algorithm/2022/04/16/quick-sort.html)介绍了快速排序，这一篇我们来
说哈希表（Hash Table）。哈希表是一种效率极高的数据结构，它可以实现O(1)的查找速度。

哈希表可以用下面的公式来表示：
```
    Hash Table = Array + Hash Function
```

哈希函数（Hash Function）用来将字符串映射为数组下标（Index），过程如下图：
```
                         ---------------
     literal string --> | hash function | --> array's index
                         ---------------
```

大多数情况下我们是不需要自己去实现一个哈希表的，因为现在主流的编程语言都已经提供了内置的哈希数据结构
来供我们使用，如Python的dict类型，Golang的map等。

哈希表有三个作用：
1. 可以把两种类型建立联系，从而实现O(1)的查找速度
2. 用于查重，如map[string]bool，重复的返回true，第一次加入的则返回false
3. 用于cache，最常见的就是web server的cache机制

一个好的哈希函数把字符串均匀的映射到数组中，但是在实际情况中，即便是再好的哈希函数，都会不可避免的
产生冲突（collision）。

冲突是指把两个不同的字符串都映射到一个数组slot。当这种情况发生的时候，通常的解决办法是用链表把这两个
字符串链接起来，当搜索哈希表的时候，先根据数组下标找到这个slot，然后再遍历链表找到目标值。

通常来讲，为了避免冲突的产生，我们可以从两方面着手：
1. Low load factor
2. A good hash function

load factor描绘了哈希表的占用程度，可用下列公式进行计算：
```
    load factor = (number of item in hash tables) / (total number of slots) * 100%
```

按照经验，如果一个哈希表的load factor大于等于70%，那么我们会选择对它进行扩容（resize）；一般采用的
扩容方法是把当前的哈希表大小乘以2。

另外一个就是要有一个好的哈希函数，这里分享两个：
1. 把26个字母映射到26个素数上，对于每一个输入的字符串，把它的每个字母对应的素数相加再模上数组大小
2. 采用多项式hash：
```
            len-1
    index = ∑ C len-i-1 * a^i, a一般为奇数，如37
            i=0
```
比如对于字符串"card"，采用第二种hash function则为：
```
            3
    index = ∑ C 3-i * 37^i
            i=0
          = 'c'*37^3 + 'a'*37^2 + 'r'*37^1 + 'd'*37^0
          = ((('c') * 37 + 'a') * 37 + 'r') * 37 + 'd'
```
以上。
