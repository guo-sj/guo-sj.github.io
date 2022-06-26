---
layout: post
title: "Bubble Sort"
date:  2022-06-26 10:11:53 +0800
categories: Algorithm
---

关于排序，一直以来我都是用快速排序的方法去解决问题。直到昨天遇到的一道题，用快速排序
无法解决，经过调查，最后是采用冒泡排序的方法。题目是这样的：
> 给定一个字符串序列，要求我们对其中的大小写字母进行排序，排序只考虑字母顺序，不考虑大小写因素。
字母之外的字符的位置不允许发生变化。而且规定，如果大小相同的字母的相对位置与它们在原字符串中的相对
位置保持一致。如，输入“a A k a”，输出为“a A a k”。

这道题不难，稍加思考，我就想出了解法：
```
1. 把原字符串中的字母读到一个新的字符数组中
2. 对这个新的字符数组进行排序
3. 把排序后的字符数组写入到原字符串中
```

我一开始采用的是快速排序，并对原算法进行了修改。快速排序的思想是选取一个 pivot，然后把
当前数组中所有小于它的元素移到它的左边，大于它的元素移到它的右边。因为题目要求是不能修改
相同大小的字母的相对位置，所以我想着，如果每次比较 pivot 和数组元素时加上等于号，这样不就可以
避免相同顺序的字母发生移动了吗？ C 语言的实现如下：
```c
void sort_letters(int start, int end, char letters[])
{
    if (end - start + 1 < 2)
        return;

    int i, j, pivot;
    i = start;
    j = end;
    pivot = letters[i];

    while (i < j) {
        while (i < j && tolower(pivot) <= tolower(letters[j]))
            j--;
        if (i < j)
            letters[i++] = letters[j];
        while (i < j && tolower(pivot) >= tolower(letters[i]))
            i++;
        if (i < j)
            letters[j--] = letters[i];
    }
    letters[i] = pivot;
    sort_letters(start, i - 1, letters);
    sort_letters(i + 1, end, letters);
}
```

但这样实际上是不行的。这样只是保证了那些和 pivot 相等的元素的位置不会发生变化，
但是对于这样的情况，如字符串为“znNjn”，pivot 为 'z'，i 指向 'z'，j 指向 'n'，因为 'n' <= 'z'，
所以 'n' 就要移到现在 'z' 的位置，这时字符串中的 'n'，'N'，'n'三个字符的相对位置
就发生了改变，变成了 'n'，'n'，'N'。

现在我们来看下冒泡排序为什么可以在不改变大小相同的元素的相对位置的情况下完成排序。
首先我们来讲一下冒泡排序的基本思想。冒泡排序会重复地走访过要排序的序列，一次比较
两个相邻的元素，如果它们的顺序错误，就把它们交换过来。因此，如果我们定义“只有在前一个
元素大于后一个元素的情况下才交换两者的位置”，那么相同大小元素的相对位置就可以保留下来。
C 语言的实现如下：
```c
void sort_letters(char letters[], int len)
{
    int i, j, tmp;

    for (i = 0; i < len - 1; i++)
        for (j = 0; j < len - 1 - i; j++)
            if (letters[j] > letters[j+1]) {
                tmp = letters[j+1];
                letters[j+1] = letters[j];
                letters[j] = tmp;
            }
}
```

以上。
