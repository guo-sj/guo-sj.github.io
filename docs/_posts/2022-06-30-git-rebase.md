---
layout: post
title: "Git Rebase"
date:  2022-06-30 10:11:53 +0800
categories: Git
---

`git rebase`，就像从字面意思上理解的那样，它是把当前的修改记录重新找个分支做 base。原理是把
当前的修改记录做成 patch，然后在新 base 分支上 replay 一遍。这样做的好处是，在 merge 分支的
时候，比如要把 experiment 分支的修改 merge 到 master 分支上，相比于直接使用 `git merge` 命令，
使用 `git rebase` 之后再 merge 可以产生更加清晰的提交记录。下面我们来举例说明。

```
                           experiment
                           +----+            
                           | C4 |             
                         / +----+             
                        v               
+----+    +----+    +----+    +----+ 
| C0 | <- | C1 | <- | C2 | <- | C3 | 
+----+    +----+    +----+    +----+ 
                              master
```

如上图所示，当前 experiment 分支和 master 分支有共同的祖先 C2，现在我们想将 experiment 合到 master 分支，
我们有两种方法。第一种方法，是直接使用 `git merge` 命令：
```
$ git checkout master
$ git merge experiment
```

merge 完之后，会产生一条新的提交记录 `C5`，如下图所示：
```
                           experiment
                           +----+            
                           | C4 | <--
                         / +----+    \
                        v             \  
+----+    +----+    +----+    +----+    +----+
| C0 | <- | C1 | <- | C2 | <- | C3 | <- | C5 |
+----+    +----+    +----+    +----+    +----+
                                         master
```

第二种方法，我们可以先在分支 experiment 上用 `git rebase`，然后再用 `git merge`:
```
$ git checkout experiment
$ git rebase master
```

这样之后分支情况就变成了这样：
```
                                       experiment
+----+    +----+    +----+    +----+    +----+ 
| C0 | <- | C1 | <- | C2 | <- | C3 | <- | C4'| 
+----+    +----+    +----+    +----+    +----+ 
                              master
```

可以看到，之前分叉的 C4 已经移到 C3 后面，两个分支变成了一个，就好像
之前的分叉情况没有发生过一样。然后，我们再切换到 master 分支进行 merge：
```
$ git checkout master
$ git merge experiment
```

最后的结果如下：
```
                                       experiment
+----+    +----+    +----+    +----+    +----+ 
| C0 | <- | C1 | <- | C2 | <- | C3 | <- | C4'| 
+----+    +----+    +----+    +----+    +----+ 
                                        master
```

这两种方法最后的代码是相同的，只是合并后的提交记录有所不同。
是在生产环境中，我们可以根据实际情况来进行选择使用哪种方法。

另外，如果在向开源社区提 patch 的时候，我们推荐使用第二种 rebase
的方法，因为从上述结果可以看到，rebase 之后的分支是线性的，所有可能
的冲突已经在你这边解决了，因此 maintainer 可以快速的进行 merge 操作。

以上。
