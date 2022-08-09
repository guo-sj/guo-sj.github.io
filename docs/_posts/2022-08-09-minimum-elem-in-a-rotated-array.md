---
layout: post
title: "旋转数组中的最小元素"
date:  2022-08-09 10:11:53 +0800
categories: Leetcode
---

> 题目：把一个数组最开始的若干个元素搬到数组的末尾，我们称之为数组的旋转。输入一个递增排序的数组的
一个旋转，输出旋转数组的最小元素。例如，数组 {3, 4, 5, 1, 2} 为 {1, 2, 3, 4, 5} 的一个旋转，该数组的最
小元素为 1 。

这个题目，找一个数组中的最小元素嘛，我们遍历整个数组就可以完成任务。但是这样的话，就没有应用上题目中
“递增数组”的这个条件，面试官是不会满意的。应该会有更快的解法。你想，遍历数组这种暴力解法的时间复杂度
都已经是 O(n) 了，我们现在还要比它快，那就只能是 O(logn) 了。O(logn) 的算法，还和排序过后的数组有关，
我们很容易就想到**二分查找**。

接着我们来看，旋转的排序数组 numbers 可以被看作是两个分开的排序数组。而我们要找的最小元素，即第二个数组的第一个
元素，则刚好是两个数组的分界线的位置。我们用两个指针，low 指向原数组的第一个元素，位于第一个子数组内；
high 指向原数组的第二个元素，位于第二个子数组内。我们再用 mid = (low + high) / 2，如果 numbers[mid] 小于等于
numbers[low]，则说明 mid 此时位于第一个子数组内，我们更新 low = mid；如果 numbers[mid] 大于等于 numbers[high]，
则说明 mid 此时位于第二个子数组内，我们更新 high = mid。如果 low - high == 1，则说明此时 low 已经指向
第一个子数组的最后一个元素，high 也已经指向第二个子数组的第一个元素，numbers[high] 就是我们要找的元素。我们把
这个过程用一个循环 wrap 起来，因为无论怎么变，low 永远都指向第一个子数组，high 永远都指向第二个子数组，而
第一个子数组的元素都是大于第二个子数组的元素的，所以我们循环的条件可以为 numbers[low] >= numbers[high]。
值得注意的是，数组可以旋转 n 次，得到的数组与原数组完全相同，那么此时第一个元素就是我们要找的元素。

经过上述讨论，我们可以写出如下代码：
```c
int minArray(int *numbers, int numbersSize)
{
    int low = 0, high = numbersSize - 1;
    int mid = low; /* n 次旋转后得到的数组与原数组相同 */

    if (numbers == NULL || low < high)
        return -1;

    if (low == high)
        return numbers[low];
    while (numbers[low] >= numbers[high]) {
        if (high - low == 1) {
            mid = high;
            break;
        }
        mid = (low + high) / 2;
        if (numbers[mid] >= numbers[low])
            low = mid;
        else if (numbers[mid] <= numbers[high])
            high = mid;
    }
    return numbers[mid];
}
```

完美！但是当我把上述代码提交之后，系统却告诉我还有 10 个左右的用例没有通过。其中一个用例是这个样子：
```
输入：[10, 1, 10, 10, 10]
期待输出：1
结果输出：10
```

如果按照我们上述的方法，mid = (low + high) / 2 = 2，而且因为numbers[mid] = 10 >= numbers[low] = 10，所以我们
会认为此时 mid 指向的是第一个子数组的元素，但是实际上，mid 却指向的是第二个子数组的元素。这个是我们出错的原因。
这种情况下，也就是当 numbers[low], numbers[high] 和 numbers[mid] 三者相等的时候，我们无法判断 mid 指向的元素
在哪个子数组中，所以此时我们只能采用暴力解法，遍历整个数组然后找出数组中最小的元素。

这是我的[提交记录](https://leetcode.cn/submissions/detail/347804955/)。

以上。
