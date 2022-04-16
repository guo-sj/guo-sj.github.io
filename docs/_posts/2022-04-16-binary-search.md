---
layout: post
title: "O(Logn) Algorithm - Binary Search"
date:  2022-04-16 10:11:53 +0800
categories: Algorithm
---

用二分查找对一个已经顺序排好的数组进行查找的效率非常高。具体有多高呢，它的时间复杂度为O(Logn)，
也就是说，对于一个有100个元素的数组，它可以在7次内给出结果。

下面我们给出二分查找的递归和循环的算法描述，并给出Go语言的实现。

递归版本的算法描述：
```
1. 如果数组为空，那么返回-1
2. 如果数组中间的元素等于Target，那么返回元素下标；
   如果大于，那么在前半个数组中用二分查找；反之，
   则在后半个数组中用二分查找
```

go语言实现：
```go
func binarySearch(list []int, target int) int {
    low, high := 0, len(list)-1
    if low > high {
        return -1
    }

    mid := (low + high) / 2
    if list[mid] == target {
        return mid
    }
    if list[mid] > target {
        return binarySearch(list[:mid], target)
    } else {
        return binarySearch(list[mid+1:], target)
    }
}
```

说完了递归版本的算法，现在我们来看循环版本的。我们知道在很多情况下，
递归和循环是可以相互转化的，两者的关键都是在于终止条件。

对于二分查找来说，递归版本的终止条件为数组的长度为0；而对于它的
循环版本，终止条件则是下限low大于上限high。下面给出循环版本的算法
及实现。

循环版本的算法描述：
```
1. 定义low为0，high为数组长度减1
2. 遍历数组list，条件为low小于等于high，定义mid为(low + high) / 2，
   如果list[mid]等于Target，那么返回mid；如果list[mid]大于Target，
   则更新high为mid-1；反之，更新low为mid+1
3. 没有找到Target，返回-1
```

go语言实现：
```go
func binarySearchLoop(list []int, target int) int {
    low, high := 0, len(list)-1
    for low <= high {
        mid := (low + high) / 2
        if list[mid] == target {
            return mid
        }
        if list[mid] > target {
            high = mid - 1
        } else {
            low = mid + 1
        }
    }
    return -1
}
```

以上。
