---
layout: post
title: "Install Shadowsocks/V2ray in Ubuntu/MacOS"
date:  2022-03-13 10:11:53 +0800
categories: Tech
---

最近我的xps 9360坏掉了，系统boot不起来，自己折腾了两个周，没有效果，又去dell官方指定维修点去
找原因，人家说是硬盘坏了，要换一块，我这里有个1TB的，1000块便宜给你。我寻思我这电脑还有1个月
就满4周岁了，整那么大的硬盘也没用，索性拒绝了。自己在京东下单了一块和原来一样大小的256GB的ssd，
又买了小米的螺丝刀套装，自己换了一下，这才把问题解决。然后，我把xps直接装成自己喜爱的ubuntu系统，
并买了[Just My Socks](https://justmysocks2.net/members/clientarea.php)，用于科学上网，这里
记录一下整个搭建的过程。

### Ubuntu 安装 shadowsocks

首先讲下shadowsocks的原理，装shadowsocks之前，我们的上网过程是客户端直接和服务器端
交流，如下图所示：
```
client <---> target
```

而装了shadowsocks之后，我们上网则是客户端发出的请求先发送给shadowsocks client，即ss-local程序，
再由它发送给shadowsocks server，即ssserver程序，最后再发送给target。接收信息的过程是发送信息的逆过程。
具体如下图所示：
```
client <---> ss-local <---> [encrypted] <---> ssserver <---> target
                ^                               ^
    shadowsocks client                  shadowsocks server
```

至于为什么这样就可以科学上网，举个例子你就明白了。比如说你想访问google，装shadowsocks之前，
你是直接发送http请求给google，因为GFW的限制，你的请求在到达google之前，就被拦截下来了。而
装上shadowsocks之后情况就不一样了。你的请求首先会由ss-local发送给ssserver，因为ssserver是
部署在国外的机器上，所以访问网站就不会受到GFW的限制，所以请求会被ssserver成功发送给google，
而google收到请求后，会回复ssserver，然后ssserver再转发给ss-local，最后你就可以收到回复了。

在原理清楚了之后，我们开始动手安装相应的软件。首先我们来安装shadowsocks：
```
sudo apt-get install shadowsocks-libev
```

然后我们来编辑shadowsocks的配置文件：
```
# sudo vim /etc/shadowsocks-libev/config.json

{
    "server":"server_ip",  // 安装ssserver机器的IP或域名
    "mode":"tcp_and_udp",  // 连接模式，这里选择的是tcp和udp
    "server_port":xxx,     // 安装ssserver机器的端口
    "local_port":xxx,      // ss-local监听的端口号，默认为1080
    "password":"xxx",      // ss-local和ssserver通信的密码
    "timeout":100,         // 超时设置
    "method":"aes-256-gcm" // ss-local和ssserver的通信加密方式
}
```

这里要提一嘴，因为我在配置文件中选择的是`aes-256-gcm`加密方式，所以有可能还需要
安装`libsodium-dev`：
```
sudo apt-get install libsodium-dev
```

对照着[Just My Socks 客户界面](https://justmysocks2.net/members/clientarea.php?action=productdetails&id=473570)
填写完配置文件后，就可以运行`ss-local`啦：
```
ss-local -c /etc/shadowsocks-libev/config.json
INFO: loading config from /etc/shadowsocks-libev/config.json
2022-03-13 10:29:23 INFO     loading libcrypto from libcrypto.so.1.1
2022-03-13 10:29:23 INFO     loading libsodium from libsodium.so.23
2022-03-13 10:29:23 INFO     starting local at 127.0.0.1:1080
... ...
```

这样还不可以科学上网，因为我们只是setup了ss-local，并没有让上网请求走这个代理。
所以，接下来，我们介绍两种走代理的方式，一种是全局代理（global proxy），另
一种则是PAC（Proxy Auto-Config）。

#### 全局代理

我们先来说全局代理。首先我们需要安装`privoxy`，它能够实现不同代理之间的切换，
我们可以使用它作为SOCKS代理和HTTP代理和HTTPS代理之间的桥梁，它能把所有的http
请求（包括终端执行的命令，浏览器等）转发给shadowsocks，像一个适配器一样。

原理图如下：
```
client <---> privoxy <---> ss-local <---> [encrypted] <---> ssserver <---> target
                              ^                               ^
                shadowsocks client                  shadowsocks server
```

安装privoxy的命令如下：
```
sudo apt-get install privoxy
```

然后我们打开privoxy的配置文件，在章节4.1. listen-address和5.1. forward加入下面的内容：
```
# sudo vim /etc/privoxy/config

... ...

# 4.1. listen-address
... ...
listen-address 127.0.0.1:8118
listen-address [::1]:8118

... ...

# 5.1. forward
... ...
forward-socks5t / 127.0.0.1:1080 .
```

修改完成之后，重启privoxy。
```
systemctl restart privoxy
```

如果你只需要在命令行中访问国外的资源，那么只需要执行下列命令即可：
```
export http_proxy=http://127.0.0.1:8118
export https_proxy=http://127.0.0.1:8118
```

可以get Google页面来判断是否设置成功：
```
curl www.google.com
```

如果你也想浏览器使用代理，那么可以配置系统网络代理，步骤是：
1. Settings -> Network -> Network Proxy -> Manual
2. 设置HTTP，HTTPS，FTP代理：

![global proxy setting](/assets/global_proxy.png)

再用浏览器访问google：

![access google in explorer](/assets/access_google_in_explorer.png)

这样就设置好了。

#### PAC

PAC是 Proxy Auto-Config 的首字母缩写，是一种网页浏览器技术，用于定义
浏览器该如何自动选择适当的代理服务器来访问一个网址。

当访问一个网址的时候，浏览器会根据PAC file中定义的访问规则，恰当的选择
代理服务器。对于科学上网来说，我们要做的就是制作一个这样的PAC file，
使得浏览器在访问被墙网站的时候走shadowsocks代理，而访问正常网站的时候
采用直连方式。访问过程如下图：
```

client <---> browser <---> local PAC file
                ^
                |<---------> target
                |              ^
                |              |
                |              |
                v              v
                ss-local <---> ssserver
```

在了解了原理之后，我们首先要制作这个PAC file。制作的过程需要两样东西，
一个是生成PAC file的工具，另一个则是被墙网站的列表。
首先我们来安装生成的工具GenPAC：
```
sudo pip install genpac
sudo pip install --upgrade genpac
```

被墙网站的列表已经有人帮我们收集好了，存放在[gfwlist/gfwlist](https://github.com/gfwlist/gfwlist)，
我们把它clone下来就好了：
```
git clone https://github.com/gfwlist/gfwlist
```

接着我们来生成自己的PAC file：
```
cd gfwlist

sudo genpac --pac-proxy="SOCKS5 127.0.0.1:1080" -o ~/.autoproxy.pac --gfwlist-local gfwlist.txt
```

然后，我们对系统网络进行设置：
1. Settings -> Network -> Network Proxy -> Automatic
2. 在Configuration URL一栏填写：file:///home/guosj/.autoproxy.pac

照理说，介绍到这里，PAC设置就应该结束了。但是，我发现Microsoft Edge已经移除了对于`file://`和`data:`协议的支持，只能使用`http://`协议。
也就是说，上述的`file:///home/guosj/.autoproxy.pac`内容人家浏览器是不认的，应该写成`http://...`。

因此，我们这里还要加上一个步骤，即用nginx实现对本地文件的http映射。nginx可以在本地起一个server，
server的资源可以通过http请求进行访问。也就是说，浏览器会通过http请求对本地的nginx server开放的
PAC file进行访问，然后再确定访问方式为直连还是走代理。
过程如下图：
```
client <---> browser <---> nginx server <---> local PAC file
                ^
                |<---------> target
                |              ^
                |              |
                |              |
                v              v
                ss-local <---> ssserver

```

还是一样，我们首先安装nginx：
```
sudo apt-get install nginx
```

然后修改默认配置文件，在`http { ... }`中加入：
```
# sudo vim /etc/nginx/nginx.conf

http {
... ...

	server{
		listen 80;  # 监听的端口
		server_name 127.0.0.1; # 服务器地址
		location /autoproxy.pac{ # PAC file path
			alias /home/guosj/.autoproxy.pac;
		}
	}

... ...
}

```

接着，我们启动nginx：
```
sudo nginx
```

最后，我们把系统网络设置的Configuration URL一栏写上`http://127.0.0.1/autoproxy.pac`：

![automatic proxy](/assets/automatic_proxy.png)

访问google进行测试：

![PAC mode google test](/assets/pac_mode_google_test.png)

#### 定位手段
如果发现网络不通了，可以按照下列手段先定位下。

##### 看下各服务的状态是否正常
```sh
sudo systemctl status shadowsocks.service # 查看 shadowsocks 的服务状态
sudo systemctl status privoxy.service # 查看 privoxy 的服务状态
```

##### 是否是域名暂时被禁了

用如下命令编辑下 config.json 文件：
```sh
sudo vim /etc/shadowsocks-libev/config.json
```

然后再重启服务：
```sh
sudo systemctl restart shadowsocks.service
sudo systemctl restart privoxy.service
```

##### 其他问题

尝试重启电脑解决 :)

### 安装 V2ray

#### Ubuntu
shadowsocks 的网速比较慢，渐渐地我产生了换成 [v2ray](https://github.com/v2fly/v2ray-core) 的想法。在 Ubuntu 系统上安装也
比较简单，直接用官方的脚本加上[手册](https://www.v2ray.com/chapter_00/start.html)就可以完成：
```sh
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
```

然后修改配置文件 `/usr/local/etc/v2ray/config.json`，把 `address`，`port`，`id` 三项填写好：
```json
...

    "outbounds": [
        {
            "protocol": "vmess",
            "settings": {
                "vnext": [
                    {
                        "address": "server", // 服务器地址，请修改为你自己的服务器 ip 或域名
                        "port": 10086, // 服务器端口
                        "users": [
                            {
                                "id": "b831381d-6324-4d53-ad4f-8cda48b30811" // UUID
                            }
                        ]
                    }
                ]
            }
        },
......
```

启动并设置开机自启动：
```sh
sudo systemctl start v2ray
sudo systemctl enable v2ray
```

#### MacOS
我于 2025/05/28 买了一台 MacMini（24 + 512），安装 V2ray 也耗了一些时间，这里记录下。

先下载最新的 [V2ray](https://github.com/v2fly/v2ray-core/releases/)：
```sh
curl -LO https://github.com/v2fly/v2ray-core/releases/download/v5.33.0/v2ray-macos-arm64-v8a.zip
unzip v2ray-macos-arm64-v8a.zip
```

接着填写好 `config.json` 文件，和 Ubuntu 上面一样，然后在命令行中启动：
```sh
./v2ray run -c config.json
V2Ray 5.33.0 (V2Fly, a community-driven edition of V2Ray.) Custom (go1.24.3 darwin/arm64)
A unified platform for anti-censorship.
2025/06/01 15:42:49 [Warning] V2Ray 5.33.0 started
2025/06/01 15:42:51 [Warning] [1552976251] app/dispatcher: default route for tcp:alive.github.com:443

ALL_PROXY=socks://127.0.0.1:1080 # 配置命令行代理
```

如下是我的完整配置文件：
```json
{
    "inbounds": [
        {
            "port": 1080, // SOCKS 代理端口，在浏览器中需配置代理并指向这个端口
            "listen": "127.0.0.1",
            "protocol": "socks",
            "settings": {
                "udp": true
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "vmess",
            "tag": "proxy",  // 添加这个标签，匹配路由规则
            "settings": {
                "vnext": [
                    {
                        "address": "xxxx", // 隐藏一下，服务器地址，请修改为你自己的服务器 ip 或域名
                        "port": xxxx, // 隐藏一下，服务器端口
                        "users": [
                            {
                                "id": "xxxx" // 隐藏一下
                            }
                        ]
                    }
                ]
            }
        },
        {
            "protocol": "freedom",
            "tag": "direct"
        }
    ],
    "routing": { // 配置路由，实现国内不走代理
        "domainStrategy": "IPIfNonMatch",
        "rules": [
            {
                "type": "field",
                "outboundTag": "direct",
                "domain": [
                    "geosite:cn"
                ]
            },
            {
                "type": "field",
                "outboundTag": "direct",
                "ip": [
                    "geoip:cn",
                    "geoip:private"
                ]
            },
            {
                "type": "field",
                "outboundTag": "proxy",
                "domain": [
                    "geosite:geolocation-!cn"
                ]
            }
        ]
    }
}
```

接下来，我们配置 v2ray 作为后台进程，每次开机自动运行（emmm……，尽管 mac-mini 通常都是一直运行的，但是还是加上这步比较好）

我们首先按照 apple 要求的格式创建文件 `~/Library/LaunchAgents/com.v2ray.v2ray.plist`：
```
# cat ~/Library/LaunchAgents/com.v2ray.v2ray.plist

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>com.v2ray.v2ray</string>

    <key>ProgramArguments</key>
    <array>
      <string>/usr/local/bin/v2ray</string>
      <string>run</string>
      <string>-config</string>
      <string>/usr/local/bin/config.json</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardErrorPath</key>
    <string>/tmp/v2ray.err</string>

    <key>StandardOutPath</key>
    <string>/tmp/v2ray.out</string>
  </dict>
</plist>
```

然后将 v2ray 放到 `/usr/local/bin` 目录下：
```sh

ls /usr/local/bin

config.json
geoip-only-cn-private.dat
geoip.dat
geosite.dat
v2ray
vpoint_socks_vmess.json
vpoint_vmess_freedom.json
```

通过 `launchctl bootstrap/bootout` 去加卸载 v2ray 服务，这里的 `launchctl` 就相当于 Linux 系统中的 `systemctl`，用来管理后台进程和服务的控制工具：
```sh
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.v2ray.v2ray.plist # 加载 v2ray 服务
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.v2ray.v2ray.plist # 卸载 v2ray 服务
```

最后查看 v2ray 的执行情况：
```sh
ps aux | grep -i v2ray

guosj-mac-mini   32570   0.0  1.1 416289952 268000   ??  S     5:13下午   0:12.64 /usr/local/bin/v2ray run -config /usr/local/bin/config.json  # 这个就是我们启动的服务
guosj-mac-mini   38291   0.0  0.0 410724096   1472 s002  S+    9:39上午   0:00.00 grep -i v2ray
guosj-mac-mini   38289   0.0  0.0 410734160   2384 s002  S+    9:39上午   0:00.01 /bin/zsh -c (ps aux | grep -i v2ray)>/var/folders/64/72549wbd2y7bzyyn4nhhlt6r0000gn/T/vdg5H9k/174 2>&1
```

如果需要图形界面也走代理，那么我们可以直接在系统设置中直接搜索 `proxy -> SOCKS 代理`，输入 config.json 文件中指定的 ip 和 端口即可。

至此，v2ray 的安装和配置已经正式完成了。

以上。
