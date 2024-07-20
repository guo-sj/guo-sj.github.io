---
layout: post
title: "如何使用 awesomeTTS 给 anki 卡片生成语音"
date:  2024-07-20 11:11:53 +0800
mathjax: true
categories: Anki
---

首先在 anki 中安装 awesomeTTS 的插件，`Tools -> Add-ons -> Get Add-ons`，输入 `1436550454`。

先试一下 awesomeTTS 功能是否好使。选择 `Tools -> AwesomeTTS:Configuration -> Advanced -> Manage Service Presets`：

![](/assets/anki-awesome-tts_1.png)

再对需要的卡片进行语音生成，这里我们使用的是 batch generation，即生成的音频可以和卡片一起保存在 anki 中，这样的话在手机和电脑平台都可以播放。
除了这种生成方式外，awesomeTTS 还有一种叫做 `On the fly TTS`的生成方式，顾名思义，就是在“空中生成TTS”，音频不在本地保存，而是当 review 卡片的
时候在线生成，这种方法的好处是不占空间，坏处嘛就是 android 设备不支持。

![](/assets/anki-awesome-tts_2.png)

此外，还可以观看[视频](https://www.youtube.com/watch?v=i_NRsUiUxHc)和[官方网页](https://www.vocab.ai/awesometts)了解更多信息。

以上。
