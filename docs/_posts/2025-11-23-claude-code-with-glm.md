---
layout: post
title: "安装 claude code 并配置 GLM 模型做它的后端"
date:  2025-11-23 10:11:53 +0800
mathjax: false
mermaid: false
categories: AI
---

首先我们使用 brew 安装 [Claude Code](https://www.claude.com/product/claude-code)：
```sh
brew install claude-code
```

然后我们按照 [GLM 的官方指导](https://docs.bigmodel.cn/cn/coding-plan/tool/claude)一步步去做就好，购买套餐，创建 API Key，然后在 `~/.claude/settings.json` 写入：
```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "your-glm-api-key",
    "ANTHROPIC_BASE_URL": "https://open.bigmodel.cn/api/anthropic",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.5-air",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-4.6",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-4.6"
  }
}
```

接着在终端中打开 claude-code 并输入 `/status` 查看状态：
```sh
➜  guo-sj.github.io git:(main) ✗ claude

╭─── Claude Code v2.0.50 ───────────────────────────────────────────────────────────────────────────────────────────╮
│                                               │ Tips for getting started                                          │
│                 Welcome back!                 │ Run /init to create a CLAUDE.md file with instructions for Claude │
│                                               │ ───────────────────────────────────────────────────────────────── │
│                    ▐▛███▜▌                    │ Recent activity                                                   │
│                   ▝▜█████▛▘                   │ No recent activity                                                │
│                     ▘▘ ▝▝                     │                                                                   │
│                                               │                                                                   │
│          glm-4.6 · API Usage Billing          │                                                                   │
│   ~/Documents/github_repos/guo-sj.github.io   │                                                                   │
╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯

> /status 
  ⎿  Status dialog dismissed

> /status 
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 Settings:  Status   Config   Usage   (tab to cycle)

 Version: 2.0.50
 Session ID: c6d21bfb-2fba-4fb2-8e1b-9a0d5a1e6187
 cwd: /Users/guosj-mac-mini/Documents/github_repos/guo-sj.github.io
 Auth token: ANTHROPIC_AUTH_TOKEN
 Anthropic base URL: https://open.bigmodel.cn/api/anthropic

 Model: Default (glm-4.6)
 Memory:
 Setting sources: User settings, Shared project settings, Local, Command line arguments, Enterprise managed policies
 Esc to exit
```

这样就算是安装完成啦！下面我讲讲我的使用体验。

我购买的是 19.9 元/1000万 token 的套餐，我在[自己的博客](https://guo-sj.github.io)的目录下启动 claude-code，然后使用 vibe-coding 的方式，
希望对博客页面增加目录功能。我进行了 10 次对话，消耗了 50 万的 token，最终这个功能也没有实现……

这个事情让我感叹，没有计算机思维的人（我刚才的 vibe-coding 是完全不在乎工具改了什么代码，只做测试和提建议）是使用不好这些 AI 工具的，因为人们需要给工具尽可能精确的指令来指导它工作，
否则，它会不受控制的瞎搞，而且疯狂的消耗你购买的 token 数。同时我也休会到，作为程序员，需要借助 AI 工具更快的学习和成长，然后再去使用 AI 做更多的事情：
```
while (1) {
    people learn something from AI
    people instruct AI do something
}
```

So learning is more important than ever, research Eric!
