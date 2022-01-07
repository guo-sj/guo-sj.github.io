---
layout: post
title: "Github: Support for password authentication was removed ...
date:  2021-1-7 10:11:53 +0800
categories: Git
---

`Push commits` 到`github`，输入用户名和密码之后，弹出这条错误信息。

> Support for password authentication was removed on August 13, 2021. 
> Please use a personal access token instead.

之前自己也遇到过，当时的解决办法是把所有的仓库全部变成SSH的URL，
但是在公司的环境上无法实现，于是自己搜索了一下，找到解决办法，
记录下来。

这条错误信息告诉我们，**github不再接受password认证了，让我们转用
personal access token认证**。那么我们要做的就是去生成一个
personal access token，然后在原来输入password的地方输入token。

所以，我们先去自己的github主页，依次点击：自己的头像-> Settings ->
Developer settings -> Personal access tokens -> Generate new token。
输入要求输入的信息，然后点击Generate token，这样就生成了一个自己的
personal access token。

按照页面要求，复制一下自己的token，保存在一个安全的地方，每次git
提示输入password时，输入token即可。

虽然这样可以push上去，但是每次都要对token进行复制粘贴，操作频繁的时候
非常不方便。**git提供了一个保存用户名&密码的功能**，通过下列命令配置：
```
	$ git config --global credential.helper store
```
然后再输入自己的username & token进行push一次，git就会记住这些信息，
下一次，再进行push操作的时候，仅仅输入：
```
	$ git push
```
即可。

以上。
