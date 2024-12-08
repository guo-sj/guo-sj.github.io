---
layout: post
title: "Dynamic Programming - Knapsack Problem"
date:  2022-05-14 10:11:53 +0800
categories: Algorithm
---

今天我们来讲动态规划（Dynamic Programming）。动态规划的思想是将一个问题分为若干个不相关的子问题（Subproblem），
然后再去逐个求解它们。当把它们全部都解决了，那么原问题也就解决了。

动态规划有一个特点，那就是它总是将原问题看成一个表格（Grid）：
```
++++++++++++++++++++++++++
|    |    |    |    |    |
++++++++++++++++++++++++++
|    |    |    |    |    |
++++++++++++++++++++++++++
|    |    |    |    |    |
++++++++++++++++++++++++++
|    |    |    |    |    |
++++++++++++++++++++++++++
|    |    |    |    |    |
++++++++++++++++++++++++++
```
表格中的每个格子（Cell）就代表一个子问题，格子的值就是子问题的答案。
只要把表格的每个格子填上合适的值，原问题也就解决了。

因此，当我们遇到一个问题的时候，如果考虑用动态规划来求解，那么要做的就两件事情：
1. 把问题看成一个表格（分割问题为若干子问题），确定表格的横轴，纵轴的含义
2. 找一个公式（Formula）去填满表格

怎么样，动态规划的原理是不是比较简单？那么它有哪些应用场景呢？

在我看来，动态规划可以为生活中的一类特定的问题提供解决方案，那就是在**有一定限制的情况下
去找到一个最优方案**。如：经典的背包问题（Knapsack Problem），如何把自己的1000元零花钱花得
更有意义。

下面我们就以经典的背包问题为例，详细讲解一下用动态规划解决问题的思路，最后给出一个我自己的 Golang
实现方案。

首先我们先来简单介绍一个背包问题。背包问题是说假如你是一个小偷，摆在你面前有几件价值不同的物品，你
只有一个容量有限的背包，问如何用这个容量有限的背包装价值尽可能大的物品？我们用 [Grokking Algorithms](https://www.amazon.com/Grokking-Algorithms-illustrated-programmers-curious/dp/1617292230?msclkid=19bbc53cbfea11ecab8c4725c6dfa8ed)
书中的例子来说，摆在你面前的有这么几件物品，每个物品都有自己的价值和重量：

| GUITAR | STEREO | LAPTOP | IPHONE | MP3 |
| :---:  | :---:  | :---:  | :---:  | :---: |
| $1500  | $3000  | $2000  | $2000  | $1000  |
| 1lbs   | 4lbs   | 3lbs   | 1lbs   | 1lbs   |

此时你的背包的容量为 4lbs，每件物品的个数为 1，问装哪些物品获得的价值最大？

在说清楚问题之后，我们来看如何用动态规划来解决它。上面说了，动态规划的思想就是将原问题
分解成若干个不相关的子问题，然后再分别对子问题进行求解。现在我们是有 4lbs 的背包，有 5 件
物品，想要求解装哪些物品获得的价值最大？那么自然就可以想到，它的一些子问题就是，如果有 3lbs 的
背包，有 5 件物品，求解装哪些物品获得的价值最大？或是背包容量不变，物品变为 4 件，求解装哪些
物品获得的价值最大？沿着这个思路，我们可以确定，表格的横轴应该为背包的容量，纵轴应该为
物品的种类，接下来就可以把表格画出来啦：
```
         1lbs 2lbs 3lbs 4lbs
        +++++++++++++++++++++
 GUITAR |    |    |    |    |
        +++++++++++++++++++++
 STEREO |    |    |    |    |
        +++++++++++++++++++++
 LAPTOP |    |    |    |    |
        +++++++++++++++++++++
 IPHONE |    |    |    |    |
        +++++++++++++++++++++
    MP3 |    |    |    |    |
        +++++++++++++++++++++
```
表格的意思是，每一行，从左到右，背包容量依次增加。每一列，从上到下，物品种类依次增加。
我们可以用一个二维数组 arr 来表示，arr[0][0] 代表的意思是当背包容量为 1lbs，物品只有 GUITAR 的
时候，装哪些物品获得的价值最大；arr[0][1] 代表的意思是当背包容量为 2lbs，物品只有 GUITAR 的
时候，装哪些物品获得的价值最大；arr[1][0] 代表的意思是当背包容量为 1lbs，物品有 GUITAR 和
 STEREO 时，装哪些物品获得的价值最大。依次类推。

然后，我们来确定填写表格的公式。我们假设填写顺序为从左到右一行一行的填写，即先填写第一行，
再填写第二行……那么我们可以思考一下，当我们准备填写 arr[i][j] 的时候，它可能会是哪些值？我
觉得只有这两种可能，一种是第 i 行的物品的价值加上当前背包容量减去第 i 行物品重量之后的可装
物品的最大价值，或者是在没有遇到第 i 行物品之前的背包可装物品的最大价值，也就是 arr[i-1][j]。
所以 arr[i][j] 的值应该取这两者之间的最大值。Bingo，公式有了！

我们用 price(i) 表示第 i 行物品的价值，weight(i) 表示第 i 行物品的重量，那么填写表格的公式就可以这样
描述：
```
arr[i][j] = max(price(i)+arr[i-1][j-weight(i)], arr[i-1][j])
```

好的，经过上述讨论，针对背包问题的表格有了，填写表格的公式也有了，接下来，我们给出 go 语言
的实现：
```go
package main

import "fmt"

func main() {
	knapsack()
	fmt.Println(getResult())
	getMatrixAndItems()
}

const (
	maxLen       = 5
	knapsackSize = 4
	itemSize     = 5
)

var (
	price       map[string]int      // item's price
	weight      map[string]int      // item's weight
	yAxeMap     map[int]string      // map y axe index to items
	xAxeMap     map[int]int         // map x axe index to knapsack size
	valueToItem map[int][]string    // items of every cell
	matrix      [maxLen][maxLen]int // dynamic programming grid
)

func init() {
	price = make(map[string]int)
	price["guitar"] = 1500
	price["stereo"] = 3000
	price["laptop"] = 2000
	price["iphone"] = 2000
	price["mp3"] = 1000

	weight = make(map[string]int)
	weight["guitar"] = 1
	weight["stereo"] = 4
	weight["laptop"] = 3
	weight["iphone"] = 1
	weight["mp3"] = 1

	yAxeMap = make(map[int]string)
	yAxeMap[0] = "guitar"
	yAxeMap[1] = "stereo"
	yAxeMap[2] = "laptop"
	yAxeMap[3] = "iphone"
	yAxeMap[4] = "mp3"

	xAxeMap = make(map[int]int)
	xAxeMap[0] = 1
	xAxeMap[1] = 2
	xAxeMap[2] = 3
	xAxeMap[3] = 4
	xAxeMap[4] = 5

	valueToItem = make(map[int][]string)
}

// knapsack fills the cells of matrix
func knapsack() {
	for i := 0; i < itemSize; i++ {
		for j := 0; j < knapsackSize; j++ {
			matrix[i][j] = getValue(i, j)
		}
	}
}

// getValue returns correct value of each cell
func getValue(i, j int) int {
	var previousMaxValue, possibleMaxValue int

	if i < 1 {
		previousMaxValue = 0
	} else {
		previousMaxValue = matrix[i-1][j]
	}
	item := yAxeMap[i]
	leftWeight := xAxeMap[j] - weight[item]
	index := i*knapsackSize + j

	// calculate possibleMaxValue
	if leftWeight < 0 {
		// the weight of current item is larger than the current knapsackSize
		// return previousMaxValue
		if i < 1 {
			valueToItem[index] = []string{}
			return previousMaxValue
		}
		previousIndex := (i-1)*knapsackSize + j
		valueToItem[index] = make([]string, len(valueToItem[previousIndex]), cap(valueToItem[previousIndex]))
		copy(valueToItem[index], valueToItem[previousIndex])
		return previousMaxValue
	} else if leftWeight == 0 {
		possibleMaxValue = price[item]
	} else {
		if i < 1 {
			possibleMaxValue = price[item]
		} else {
			possibleMaxValue = price[item] + matrix[i-1][leftWeight-1]
		}
	}

	if possibleMaxValue > previousMaxValue {
		if leftWeight == 0 {
			valueToItem[index] = []string{item}
		} else {
			// copy items of leftWeight cell to current cell's items
			// and append current item to current cell's items
			if i < 1 {
				valueToItem[index] = []string{item}
				return possibleMaxValue
			}
			leftWeightIndex := (i-1)*knapsackSize + leftWeight - 1
			valueToItem[index] = make([]string, len(valueToItem[leftWeightIndex]), cap(valueToItem[leftWeightIndex])+1)
			copy(valueToItem[index], valueToItem[leftWeightIndex])
			valueToItem[index] = append(valueToItem[index], item)
		}
		return possibleMaxValue
	} else {
		// Because previousMaxValue >= possibleMaxValue > 0, the variable i couldn't less than 1.
		previousIndex := (i-1)*knapsackSize + j
		valueToItem[index] = make([]string, len(valueToItem[previousIndex]), cap(valueToItem[previousIndex]))
		copy(valueToItem[index], valueToItem[previousIndex])
		return previousMaxValue
	}
}

// getResult gets final result of the knapsack problem
func getResult() ([]string, int) {
	i := itemSize - 1
	j := knapsackSize - 1
	index := i*knapsackSize + j
	return valueToItem[index], matrix[i][j]
}

// getMatrixAndItems prints matrix and valueToItem
func getMatrixAndItems() {
	i := itemSize - 1
	j := knapsackSize - 1
	length := i*knapsackSize + j
	for i := 0; i < itemSize; i++ {
		fmt.Println(matrix[i])
	}
	for i := 0; i <= length; i++ {
		fmt.Printf("[%d] %v\n", i, valueToItem[i])
	}
}

```

以上。
