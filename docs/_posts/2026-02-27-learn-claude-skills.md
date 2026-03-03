---
layout: post
title: "学习 ClaudeCode skills"
date:  2026-02-27 10:11:53 +0800
mathjax: false
mermaid: false
categories: AI
---

先整理下 skill 的文档：
- [Equipping agents for the real world with Agent Skills](https://claude.com/blog/equipping-agents-for-the-real-world-with-agent-skills) <-- 这个写的非常好，作为入门，它又介绍了下面这 3 篇文章
	- [Agent Skills -- overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
	- [Skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) <-- 这个可以，后续可以参考一下
	- [Skills for enterprise](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise) <-- 这个用于演进
- [agent skill](https://agentskills.io/home)
- [Introducing Agent Skills](https://claude.com/blog/skills)
- [Extend Claude with skills](https://code.claude.com/docs/en/skills)

最近我准备系统性学习 skill，感觉最近每个人都在讲 skill，这个词快被用烂了。还是要好好学习一下文档，搞清楚它的真面目。

### skill 的基本原理

skill 的模板是这个样子的：
```
---
name: your-skill-name <--------------- 最多 64 个字符
description: Brief description of what this Skill does and when to use it  <-------------- 最多 1024 个字符
---

# Your Skill Name

## Instructions
[Clear, step-by-step guidance for Claude to follow]

## Examples
[Concrete examples of using this Skill]
```


skill 中包含一个 yaml 头，称为是 metadata（元数据）：
```
---
name: pdf
description: Use this skill whenever the user wants to do anything with PDF files. This includes reading or extracting text/tables from PDFs, combining or merging multiple PDFs into one, splitting PDFs apart, rotating pages, adding watermarks, creating new PDFs, filling PDF forms, encrypting/decrypting PDFs, extracting images, and OCR on scanned PDFs to make them searchable. If the user mentions a .pdf file or asks to produce one, use this skill.
license: Proprietary. LICENSE.txt has complete terms
---
```

你看，这个元数据包含 `name`，`description` 和 `license` 3 部分。

元数据是在 ClaudeCode 启动时就加载好的，只要在 `~/.claude/skills/` 目录下的 skills 都会提前加载，我们可以通过 `/context` 查看：
```
❯ /context
  ⎿  Context Usage
     ⛀ ⛁ ⛁ ⛁ ⛀ ⛀ ⛁ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶   claude-opus-4-6[1m] · 25k/1000k tokens
     ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶    (3%)
     ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶   Estimated usage by category
     ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶   ⛁ System prompt: 2.9k tokens (0.3%)
     ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶   ⛁ System tools: 14.8k tokens (1.5%)
     ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶   ⛁ Custom agents: 170 tokens (0.0%)
     ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶   ⛁ Skills: 3.5k tokens (0.3%)    <------------------ skills 占用的内存
     ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶   ⛁ Messages: 5.8k tokens (0.6%)
     ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶   ⛶ Free space: 940k (94.0%)
     ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛝ ⛝ ⛝ ⛝ ⛝ ⛝ ⛝   ⛝ Autocompact buffer: 33k tokens
                                                                     (3.3%)
```

提前加载的目的是说，ClaudeCode 可以根据用户的 prompt 去匹配 `description` 的触发条件，从而决定是否需要触发这个 skill。当然也可以通过 `/+skill_name` 去触发 skill。

按下来，是 SKILL.md 的第二部分，skill 的内容，在 skill 的内容里面还可以指定其他的文件，如下面描述的 `./reference.md` 和 `./forms.md`：
```
This guide covers essential PDF processing operations using Python libraries and command-line tools. For advanced features, JavaScript libraries, and detailed examples, see ./reference.md. If you need to fill out a PDF form, read ./forms.md and follow its instructions.
```

目录结构为：
```
-----pdf
  |-------SKILL.md
  |-------reference.md
  |-------forms.md
```

skills 对于各个部分是有一些限制的：
| Level | File  | Context Window  | #tokens |
| :--:  | :--:  | :--:  | :--:  |
| 1 | SKILL.md Metadata(YAML) | Always loaded | ~100 |
| 2 | SKILL.md Body (Markdown) | Loaded when Skill triggers | <5k |
| 3 | Bundled files (text files, scripts, data) | Loaded as-needed by Claude | unlimited* |

所以，你看，skills 的 Body 内容是不能写太长的，所以这个限制就决定了，它的主体不能太长，主体的作用是类似一个 main 函数，描述一个 skill 全局有哪几步，每一步，再去读其他的文档或者脚本去具体执行。

Skills and code execution
如果是确定的事情，那么我们尽可能使用代码去执行，而不是使用模型的能力。

执行代码是不会占用上下文的。

### 如何编写和测试 skill

那么如何编写和测试 skill 呢？

- **先用 agent，再创建 skill**：先让 agent 去执行特定的任务，看下它哪里表现不好，然后再使用 skill 去给它补充足够的上下文和规范它的行为
- **设计可扩展的结构**：当 `SKILL.md` 文件变的臃肿，那么最好就把内容分成多个引用文件或脚本。脚本可以放在 markdown 文件里面（会占用上下文）或者直接变成脚本（不占用上下文）
- **站在 Claude 的角度思考**：观察 Claude 如何在真实场景下使用你的 skill，哪些不好的地方，及时去改善。因为你的 skill 是给 Claude 用的，你必须让 Claude 理解它。每个 skill 的 `name` 和 `description` 很关键，它决定了是否可以触发这个 skill
- **与 Claude 一起迭代**。当你与 Claude 一起工作的时候，让 Claude 去总结它做的好的点与做的不好的点，把这些东西总结成脚本代码和可复用的上下文。如果它跑偏了，那么让它自己反思如何才能跑正确，我需要提供哪些上下文给它才可以跑正确。

本身可以用 `skill-creator` 这个 skill 让 claude 去生成 skill，见[官方仓库](https://github.com/anthropics/skills/tree/main/skills/skill-creator)接着再迭代。

### 使用 skill 的安全问题

从可信的源头去安装 Claude skill，防止安全问题。

### 如何安装 skill

### 初步方案

我这里想的是说，采用 skill 集中管控的方式：
- 原则上只有 CMC 成员才可以修改 skill，CMC 成员需要对各自仓库的 review 结果负责
- 统一放到一个代码仓（需要指定），由我来负责合入
- 使用命令行直接安装即可，这里我需要了解一下安装的方法
- claude 遇到的问题咨询各组的 AI 接口人

