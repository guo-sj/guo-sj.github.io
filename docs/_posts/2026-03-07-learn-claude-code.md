---
layout: post
title: "学习 ClaudeCode"
date:  2026-03-07 10:11:53 +0800
mathjax: false
mermaid: false
categories: AI
---

这里记录一下学习 ClaudeCode(aka: CC) 的一些技巧。

### `/clear` 命令

我们与 CC 交流的每个会话内容都会保存在 `~/.claude/projects/` 目录下。`/clear` 命令会清除当前会话的所有上下文，但并不会删除该上下文在 `~/.claude/projects` 下的文件，这就意味着即使你无意中清除了会话的上下文，还是可以去 `~/.claude/projects` 中找到它。
