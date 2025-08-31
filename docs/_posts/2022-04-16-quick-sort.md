---
layout: post
title: "O(nLogn) Algorithm - Quick Sort"
date:  2022-04-16 13:11:53 +0800
categories: Algorithm
---

[上一篇](https://guo-sj.github.io/algorithm/2022/04/16/binary-search.html)
文章我们介绍了一种非常快速的查找算法 -- 二分查找，今天呢我们来介绍一种同样
效率非常高算法 -- 快速排序。

对于平均情况，快速排序的时间复杂度为O(nLogn)，而最差情况，它的时间复杂度则
为O(n^2)。不过，快速排序击中平均情况的次数远多于最差情况，因此我们通常就说
它的时间复杂度为O(nLogn)。

下面，我们来介绍快速排序的算法描述及Go语言的实现。

快速排序的算法描述：
```
1. 如果数组的长度为0或1，则返回
2. 选择数组中的一个元素为pivot（支撑点）
3. 把所有小于pivot的元素移到它的左边，大于pivot的元素移到它的右边
4. 分别对左边和右边的子数组进行快速排序
```
可以看到快速排序的算法描述相当简单，也充分体现了分治思想（Divide and Conquer）
。它把一个数组分成两个子数组，再分别对它们进行快速排序。

尽管描述简单，但是实现起来还是有一些难度的。对于我来说，难点就在于算法的
第三步，即如何把所有小于pivot的元素移到它的左边，把大于它的元素移到它的
右边。要实现它有很多不同的方法，这里给出一种我比较容易接受的方法：
```
1. 对于数组list，选取第一个元素为pivot，我们定义i为0，j为len(list)-1
2. 在i小于j的条件下遍历数组：
      从数组末尾往前扫，如果list[j]小于pivot，那么把list[j]赋值给
      list[i]，然后让i++；再从前往后扫，如果list[i]大于pivot，那么把
      list[i]赋值给list[j]，j--;
```

在说完了算法，我们再来看Go语言的实现：
```go
func quickSort(list []int) {
    if len(list) < 2 {
        return
    }
    i, j := 0, len(list)-1
    pivot := list[i]
    for i < j {
        for i < j && list[j] > pivot {
            j--
        }
        if i < j {
            list[i] = list[j]
            i++
        }
        for i < j && list[i] <= pivot {
            i++
        }
        if i < j {
            list[j] = list[i]
            j--
        }
    }
    list[i] = pivot
    quickSort(list[:i])
    quickSort(list[i+1:])
}
```

**=============== 2025/08/24 更新 ===============**

看了《The Practice of Programming》中的 quick sort 后，才意识到自己之前理解的 quick sort 的
实现是不优雅的。主要是关于如何把小于 pivot 的元素移到它的左边，把大于它的元素移到它的右边。
我们一起看下书中的方法：
```
1. 对于数组 list，选取任意一个元素做为 pivot
2. 把 pivot 和 list[0] 互换
3. 定义 pivot 正确位置的下标为 last，初始化为 0
4. 遍历 list，如果 list[i] 小于 list[0]，last 自增一位，则将 list[i] 和 list[last] 互换
5. 将 list[0] 和 list[last] 互换
```

这个算法的关键就在于，如果我把小于 pivot 的元素都放到它前面，那么自然大于它的元素就在它的
后面了。我们用 C 语言实现一下：
```c
void quickSort(int a[], int num)
{
    if (num < 2) {
        return;
    }
    swap(a, 0, rand() % num);
    int last = 0;
    for (int i = 0; i < num; i++) {
        if (a[i] < a[0]) {
            swap(a, i, ++last);
        }
    }
    printf("%d\n", a[last]);
    swap(a, 0, last);
    quickSort(a, last);
    quickSort(a + last + 1, num - last - 1);
    return;
}
```
以上。
