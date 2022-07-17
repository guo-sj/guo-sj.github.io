---
layout: post
title: "Huawei Interview"
date:  2022-07-10 10:11:53 +0800
categories: Interview
---

从 06/08 ~ 07/10 一个月左右的时间，我准备并通过了华为公司的 5 轮面试加一轮性格测试。在秦川经理
的帮助下，我最终顺利拿到了期待的 offer。下面我来对整个过程做一个记录，做为自己的总结，也希望可以对其他的小伙伴
有帮助。

华为的第一轮是机考，有三道题，第一道题和第二道题各 100 分，第三道题为 200 分。时间为 150 分钟。
150 分视为通过。

我这边准备的话是用牛客网的[华为机试](https://www.nowcoder.com/exam/oj/ta?tpId=37)版块，我的思路
就是从头开始做，主要以“简单”和“中等”难度的题目为主。准备时间大概是 10 天左右，这个时间可以和华为
那边的招聘人员商量，可长可短，不过一般为 1 个周左右。

在刷了 19 道题后，我开始参加线上笔试。因为之前没有参加过类似的测试，所以第一次还是很紧张的。不过，在第一道
题目做出来之后，紧张情绪就慢慢的缓解了。接着是第二道。两道题都做出来后，自己心里松了一口气，总算是
达到了最低通过要求。一般来说，前两道题是比较简单的，但是我感觉我抽中的这两道题的难度都是中等难度，
稍不小心，就有可能做不出来。第三道题考 DFS，但是因为自己能力有限，没做出来，最终自己的笔试成绩
定格在了 200 分。现在回想起来，自己这个属于临阵磨枪，如果想要稳妥的通过机试，还是要从平时练起，《剑指Offer》
就是一个不错的选择。把这本书读透，再加上考前适当的练习，一定可以稳稳通过华为的机试。

线上笔试之后是性格测试。这个性格测试，秦经理还找华为的小伙伴给我专门辅导了一下子。大致就是说，要
选择“积极向上”，“乐观”，“放松”之类的选项。还有一个注意点就是要保持一致性。就是说这份性格测试会用
多个相似的选项来测试你，它期待你应该是每次选择的内容都是一致的。比如说，一道题问你“你是什么样的人？”，
第一次你选择了“我是一个乐观的人”。第二次它又问“当你遇到困难的时候你会怎么做？”，这个时候你应该选
“我会保持乐观”而不是其他选项。这样叫做一致性。知乎上有关于性格测试的详细解答，如果实在心里没底，可以
去[这里](https://www.zhihu.com/question/19863757)看高赞回答。

性格测试之后是两轮技术面试。第一轮是你应聘部门的 19 级专家面试你，第二轮则是其他部门的 19 级专家面试你。
两轮面试的流程相当，主要分为技术知识考察和手撕代码两部分。技术知识考察是说，面试官根据你的简历
测试你技术方面知识的掌握程度。这个因面试的部门岗位不同而各有区别。我这边的感触是，数据结构和算法，计算机网络，
操作系统方面的知识都会被问到一些。所以要好好准备这些基础的专业内容。手撕代码则是说，面试官会现场出题，
然后你共享屏幕当场编写程序。这里主要是对你解决问题的思路的考察。值得注意的是，这边如果题目你有不太懂的地方
一定要及时提出来，这个是允许的。我一开始不知道这一点，因为题目不理解导致编程思路出现了偏差，经面试官好心
提醒，这才把问题解决。还有就是，程序是可以用 gdb 调试的。

我遇到的两道题是：
1. 输入一个字符串，如果这个字符串是回文串，则输出它的长度。反之，则输出 0。

2. 输入两个字符串，判断它们除空格字符外是否相等。

题目并不难，有兴趣的朋友可以试一试。

两轮技术面试之后，我们来到 HR 面试。我遇到的这个 HR 一开始非常 aggressive。他一开始是俯视你，审问你的态度。
我则保持不卑不亢的态度沉着应对。他问的问题主要集中“创新”上。他希望这个面试者是一个具有创新精神的人，当遇到
一个新问题，一个技术难题时，可以想出创新的解法去解决它。而我则从技术和解决问题的思路这两个角度来回答。我拿
进程间的相互通信来举例子。我说，比如现在两个进程需要通信，用共享内存的方式始终无法实现，那么这个时候我们可能
需要去分析不能实现的原因，并且去用其他方式去尝试，如用管道，socket 或 signal。我认为这就是一个创新。我理解，
创新不一定是说要你去重新发明一种进程间通信的方式，而是说你是否可以用现在已经掌握的知识去创造性的组合，从而
产生一个新的且有效的解决方法。所以要实现创新，首先你得有足够的技术知识和问题解决经验的积累，其次要有发散思维，
要敢想，敢把那些知识和经验以不一样的方式组合起来。HR 是比较满意我的这个回答，所以这一轮面试也比较顺利的通过了。
我也由一开始的俯视着和他对话，最后变成两个人平视着对话。值得一提的是，华为的 HR 和其他公司的有一个很大的不同
就是，他们可能并不只是 HR，比如面试我的这个 HR，他工作 10 多年了，先做测试，再做研发，再做质量控制，去年才
开始做 HR。这在其他公司是很难想象的一件事情。哦，我还有一点想说，就是这个 HR 的一句话让我印象深刻，他说，“在
华为，不是‘爱一行，干一行’，而是‘干一行，爱一行’。”

最后一轮，则是主管面试。和 HR 面试一样，它考察的也是非技术方面的一些软实力。有一个问题，我和主管聊的比较多，
那就是“加班问题”。主管问我对加班这件事怎么看，我的回答是说，首先我希望的是有效的加班。比如一天，到了该下班
的点，我的工作还没做完，那么我会通过加班来把工作完成。但是强制加班我也是可以接受的，因为大家都清楚，华为是
一家有加班文件的公司，如果我害怕加班或者反对加班，那么我就不会选择华为了。主管则表示，华为和我想的一样，它
鼓励大家有效的加班，而且不希望加班影响员工的身体健康和家庭生活。另外，我们还聊到了任正非先生。我说，我选择
华为的一大原因是因为这是任正非先生的公司。我很少看到一个人像他那样，在如此高龄的年纪下，对当下的时局还保持
着如此清醒的认识。他说：“我认为，和平不是谈出来的，而是打出来的。”我非常赞同这句话。我也相信，对于我这样的
年轻人来说，只有靠实打实的努力，才有可能在像南京这样的城市闯出自己的一片天地。主管说，在我的自我介绍中，“Lifelong Leaner”
这个词触动了他，因为他最欣赏终身学习的人。他也希望他的每一位同事都抱有终身学习的心态去工作和生活。

好啦，以上就是我的华为面试过程了。最终收到 offer 之后，给我的定级是 D3，对标的是华为 15 级。秦经理说，
第一年我最重要的任务就是尽快转华为。我争取做到吧。希望自己能够在华为有所成长，努力进取，用硬实力去实现自己的
人生理想，为这个社会做点事情，给这个世界留下点东西。

以上。