---
layout: post
title: "Ubuntu Touchpad"
date:  2024-04-05 10:11:53 +0800
mathjax: true
categories: Linux
---

作为一个从 macbook 切换过来的用户，自然会非常怀念 mac 上的触控板手势。下面我就记录下如何在 ubuntu 上实现
我 macbook 上最中意的两个触控板手势：四指切换 workspace，三指选中和拖拽。

### 四指切换 workspace

Ubuntu 默认是三指切换 workspace，要用四指实现，需要安装 [gnome-gesture-improvements](https://github.com/harshadgavali/gnome-gesture-improvements)：
```sh
git clone https://github.com/harshadgavali/gnome-gesture-improvements.git/
cd gnome-gesture-improvements
npm install # 如果没有 npm，首先使用 `sudo apt install npm` 安装
npm run update
```

接着重启电脑，然后再使用 `gnome-extensions enable gestureImprovements@gestures` 去使能 `gnome-gesture-improvements`，
或者也可以通过在 `extension manager` 中使能。

需要注意的是，需要在插件中把三指的功能禁用掉，方便我们之后实现三指选中和拖拽。

### 三指选中和拖拽

要实现这个功能，我们需要用到另一个开源软件[draggy](https://gitlab.com/daveriedstra/draggy)。安装方法如下：

首先安装 `python3` 和 `python3-evdev`：
```sh
sudo apt install python3
sudo pip install evdev
```

然后再安装 [libinput](https://github.com/bulletmark/libinput-gestures?tab=readme-ov-file)：
```sh
sudo apt-get install wmctrl xdotool libinput-tools # install prerequisite
git clone https://github.com/bulletmark/libinput-gestures.git
cd libinput-gestures
sudo ./libinput-gestures-setup install
```

接着按照[draggy](https://gitlab.com/daveriedstra/draggy)中的安装指示完成安装：
```
git clone https://gitlab.com/daveriedstra/draggy
cd draggy
sudo cp -t /usr/local/bin draggy get_gesture_devices.py
sudo cp draggy.service /usr/lib/systemd/system
```

最后，Fire it up：
```sh
sudo systemctl start draggy.service
sudo systemctl status draggy.service
```

**已知 BUG**：

当开启 draggy 服务的情况下，合上电脑盖子，然后再打开，draggy 服务就不可用了，查看服务状态显示：
```sh
sudo systemctl status draggy.service
● draggy.service - draggy
     Loaded: loaded (/lib/systemd/system/draggy.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2024-04-05 13:45:10 CST; 21min ago
   Main PID: 10445 (python3)
      Tasks: 1 (limit: 4133)
     Memory: 20.5M
        CPU: 8.419s
     CGroup: /system.slice/draggy.service
             └─10445 python3 /usr/local/bin/draggy

4月 05 13:53:37 guosj-Surface-Pro-7 draggy[10445]:     return await handler(input_device, surrogate_device)
4月 05 13:53:37 guosj-Surface-Pro-7 draggy[10445]:   File "/usr/local/bin/draggy", line 127, in handler
4月 05 13:53:37 guosj-Surface-Pro-7 draggy[10445]:     async for event in in_dev.async_read_loop():
4月 05 13:53:37 guosj-Surface-Pro-7 draggy[10445]:   File "/usr/lib/python3.10/asyncio/coroutines.py", line 127, in coro
4月 05 13:53:37 guosj-Surface-Pro-7 draggy[10445]:     res = yield from res
4月 05 13:53:37 guosj-Surface-Pro-7 draggy[10445]:   File "/usr/lib/python3/dist-packages/evdev/eventio_async.py", line 98, in next_batch_ready
4月 05 13:53:37 guosj-Surface-Pro-7 draggy[10445]:     future.set_result(next(self.current_batch))
4月 05 13:53:37 guosj-Surface-Pro-7 draggy[10445]:   File "/usr/lib/python3/dist-packages/evdev/eventio.py", line 71, in read
4月 05 13:53:37 guosj-Surface-Pro-7 draggy[10445]:     events = _input.device_read_many(self.fd)
4月 05 13:53:37 guosj-Surface-Pro-7 draggy[10445]: OSError: [Errno 19] No such device
```

目前还没有好的解决办法，只能重启服务：
```sh
sudo systemctl stop draggy.service && systemctl start draggy.service
```

以上。
