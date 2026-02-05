---
layout: post
title: "如何借助 AI 做代码辅助检视"
date:  2026-02-04 10:11:53 +0800
mathjax: false
mermaid: false
categories: Engineering
---


> prompt: 我们公司目前在搞 AI 提效，现在我即将负责一个点，就是“AI辅助代码检视”。我们的代码都是放在开源平台 gitcode。我给你讲下我们的开发流程。我们公司分 3 个区，分别是B区，Y区和 G区，信息流通的方式是：B区 -> G区 -> Y区。只能单向流动，而不能反过来。正常的开发流程是在 B 区 fork 开源仓代码到自己的仓，记为 private-repo，然后 clone 下来开发。开发好后，提交到 private-repo。然后去 G 区/Y区，在设备上 clone 下来自己的 private-repo，进行验证。如果需要修改，则还需要在 B 区修改，然后 push 到 private-repo，再到 G区/Y区 clone 下来验证。直到验证Ok。然后从 private-repo 提 PR 到公共的仓库，接受大家检视，最后合入。你帮我看看，这种开发流程中，我在哪些点可以使用到 “AI 辅助代码检视”来提升效率呢？

这边和豆包交流了一下，我理解基于我们当前的情况，应该是在 2 个点去部署 AI 检视：
```

 +++++++++++++++++     1. fork     +++++++++++++++++        4. pull
 |               | --------------> |               | ---------------------+
 | public-repo   |     5. pr       | private-repo  |                      |
 |               | <-------------- |               |                      |
 +++++++++++++++++                 +++++++++++++++++                      |
                                        |    ^                            |
                               2.  pull |    | 3. push                    |
                                        v    |                            v
                                   +++++++++++++++++                   +++++++++++++++++
                                   |               |                   |               |
                                   | B zone        |                   | Y/G zone      |
                                   |               |                   |               |
                                   +++++++++++++++++                   +++++++++++++++++
```

在第 3 处和第 5 处部署即可：

- 第一步：B 区 commit 前 pre-commit 钩子 → 拦基础规范 / 语法问题（和 3 步版一致）；
- 第二步：提 PR 后 webhook → 全维度检视（增加跨区适配检视项），一次检视覆盖「基础问题 + 跨区问题 + 核心问题」；
适配点：gitcode 的 PR 增量 diff 能完整识别所有修改，合并检视项后，仅需 1 次 AI 调用


在决定在哪里部署后，接下来要看具体如何实现。

首先，我觉得代码开发主要分为这 3 类问题：

- 规范类问题，比如函数和变量命名是否规范，使用 try...catch 语法时是否符合业界的最佳实践等等。
- 业务功能性问题，比如当前的实现是否有场景遗漏
- 程序架构上的问题，比如函数和类的组织是否合理，代码是否满足面向对象的七大原则（单一职责，开闭原则，依赖倒置，里氏替换法则，迪米特法则，接口隔离，合成复用），是否可以使用设计模式去重构。

有了这 3 类问题后，我们如何针对这 3 类问题做 AI 辅助检视呢？

对于规范类问题，主要的步骤如下：
- 编程标准结构化，而不是纯文本投喂，把它拆解成“规则条目 + 示例 + 反例”的结构化 prompt。
- 规范类问题可以结合静态分析工具，做“AI+工具”双校验，意思是用现成工具先扫一遍，AI 再做补充检验。这样做可以减少 AI 的计算成本。

对于业务功能类问题，核心是让 AI 懂业务，主要是因为 AI 缺乏上下文。主要的步骤如下：
- 第一步，提前沉淀“业务知识库”，作为 AI 的固定 skill，意思就是说，让 AI 先懂我们的业务场景，我理解类似于 Claude Code 使用 /init 命令先生成一个 Claude.md，作为它对整个项目的理解，这个理解不会太细，但是会对项目有个整体性的把握。
- 第二步，检视时绑定“代码对应的业务场景”，这一步可以要求在 commit 信息/PR 描述中注明“本次修改对应的业务场景”，AI 结合这个场景，就可以精准判断了。第三步；结合“历史问题库”，做场景化的查漏补缺。

对于架构类问题，主要的步骤是：
- 第一步，让 AI 自动生成“项目架构文档”，而非手动编写。
- 第二步，架构检视分 2 层，“局部代码合规性“ + ”全局架构一致性“。让 AI 基于架构文档，做 2 层检视，局部层，查看当前修改是否OK；整体层，查看当前修改是否影响项目的整体结构- 第三步，聚焦”增量架构问题“，不做全量复盘。每次 PR 来了只看增量代码。

一些具体实施的注意事项：
1、无论哪类问题，AI 输出的结果都要包含：
- 问题类型（规范/功能/架构）
- 问题代码行 + 问题描述
- 风险等级（高/中/低）
- 具体修改建议（详细说明）

2、分阶段开放检视能力，避免初期误报过多

3、建议“反馈闭环”，让 AI 越用越准

接下来，我需要了解一些工具的用法：
- [Claude Code 的最佳实践](https://code.claude.com/docs/en/best-practices)
- [Claude Code 的 skills](https://code.claude.com/docs/en/skills)
	- [agentskills](https://github.com/agentskills/agentskills)
- [Claude Code 的原理](https://code.claude.com/docs/en/how-claude-code-works)

下面用一个例子去展示 ClaudeCode 工具在仓库 [guo-sj/omni_infer](https://gitee.com/jackie-mantou/omniinfer) 这样一个 python 代码仓库对 python 代码的 review 情况。

在仓库的目录下启动 claude，并运行 `/init` 初始化去生成 `CLAUDE.md` 文件，如果需要，我们可以通过 `/memory` 去编辑它：
```
 ▐▛███▜▌   Claude Code v2.1.29
▝▜█████▛▘  GlmMoe · API Usage Billing
  ▘▘ ▝▝    /home/g00919896/omniinfer

  /model to try Opus 4.5

❯ hi

● Hi! I'm here to help you with your software engineering tasks. What would you like to work on today?

❯ /init

● Explore(Explore codebase architecture)
  ⎿  Done (73 tool uses · 0 tokens · 4m 9s)

● Let me read some key files to get more specific details for the CLAUDE.md file.

● Read 7 files (ctrl+o to expand)

● Let me read a few more files to understand the vLLM integration and key architecture patterns.

● Read 3 files (ctrl+o to expand)

● Now I have enough information to create the CLAUDE.md file. Let me write it.

● Write(CLAUDE.md)
  ⎿  Wrote 209 lines to CLAUDE.md
     # CLAUDE.md

     This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

     ## Project Overview

     Omni-Infer is a suite of inference accelerators for the Ascend NPU platform (Huawei hardware). It provides enterprise-grade LLM inference with full compatibility with vLLM, featuring P/D
     (Prefill/Decode) disaggregation, MoE optimization, and global proxy scheduling.

     **Key Concepts:**
     - **P/D Disaggregation**: Splits prefill and decode stages for optimized scheduling and scale-out
     … +199 lines (ctrl+o to expand)

● I've created the CLAUDE.md file for the Omni-Infer repository. The file includes:

  1. Project Overview - Describes Omni-Infer as an Ascend NPU inference accelerator with vLLM integration, P/D disaggregation, and MoE optimization
  2. Build and Installation - Commands for building the project, including:
    - bash build/build.sh - Full build
    - bash build/build.sh --ci - CI build with mock models
    - python -m build - Direct Python build
  3. Running Tests - Test commands using the pytest-based framework:
    - bash tests/run_tests.sh - All tests
    - bash tests/run_tests.sh --unit - Unit tests only
    - bash tests/run_tests.sh --integrated - Integration tests only
    - pytest tests/unit_tests/.../test_xxx.py - Run specific test file
  4. Architecture Overview - Key components organized under:
    - omni/accelerators/ - Performance accelerators (PD, placement, scheduling)
    - omni/adaptors/ - Framework adaptors (vLLM, SGLang, LMCache)
    - omni/layers/ - Neural network layers
    - omni/models/ - Model implementations
  5. vLLM Integration - Explains the forked vLLM at infer_engines/vllm/ with 60+ patches applied
  6. Key Configuration - Environment variables and model configuration via JSON
  7. Adding Custom Models - Brief summary referencing the detailed documentation
  8. Parallelism - Supported strategies (PP/TP/EP/DP) and communication utilities
  9. PR Classification - Required prefixes for pull requests

✻ Crunched for 5m 25s

❯ /memory
  ⎿  Opened memory file at ./CLAUDE.md

     To use a different editor, set the $EDITOR or $VISUAL environment variable.
```

接下来，我们计划让它去检视最近的一次提交的代码，首先我们先让它总结一下这一次提交`commit 6309109f47fdecfe664d94cd304734cc637be654`：
```
❯ 你看下最近的一个提交记录修改了什么？

● Bash(git show --stat HEAD)
  ⎿  commit 6309109f47fdecfe664d94cd304734cc637be654
     Author: yinxiaoyun_hw <yinxiaoyun@huawei.com>
     Date:   Thu Feb 5 01:25:25 2026 +0000
     … +12 lines (ctrl+o to expand)

● Bash(git show HEAD --no-stat)
  ⎿  Error: Exit code 128
     /etc/profile.d/colorxzgrep.sh: line 1: /usr/libexec/grepconf.sh: No such file or directory
     fatal: unrecognized argument: --no-stat

● Bash(git show HEAD)
  ⎿  commit 6309109f47fdecfe664d94cd304734cc637be654
     Author: yinxiaoyun_hw <yinxiaoyun@huawei.com>
     Date:   Thu Feb 5 01:25:25 2026 +0000
     … +812 lines (ctrl+o to expand)

● 根据最近的提交记录（commit 6309109f），这次修改主要是关于 导出 MoE 专家功能的验证脚本。具体修改了以下文件：
  ┌──────────────────────────────────────────────────────────┬──────┬──────────────────────────────────────┐
  │                           文件                           │ 类型 │                 说明                 │
  ├──────────────────────────────────────────────────────────┼──────┼──────────────────────────────────────┤
  │ omni/adaptors/vllm/patches/export_moe_experts_fix.patch  │ 新增 │ vLLM 修复补丁                        │
  ├──────────────────────────────────────────────────────────┼──────┼──────────────────────────────────────┤
  │ omni/adaptors/vllm/sched/routed_experts_capturer.py      │ 修改 │ 专家路由捕获器                       │
  ├──────────────────────────────────────────────────────────┼──────┼──────────────────────────────────────┤
  │ omni/adaptors/vllm/sched/test_routed_experts_capturer.py │ 修改 │ 测试文件                             │
  ├──────────────────────────────────────────────────────────┼──────┼──────────────────────────────────────┤
  │ tools/accuracy/export_moe_accuracy_comparison.py         │ 新增 │ MoE 专家导出准确率对比脚本（573 行） │
  └──────────────────────────────────────────────────────────┴──────┴──────────────────────────────────────┘
  让我读取一下新增的主要文件看看具体内容：

● Read 2 files (ctrl+o to expand)

● 最近提交修改总结

  提交信息：!2023 Add the verification script for the export moe experts feature.

  修改的文件（共 4 个，+629/-21 行）：
  ┌──────────────────────────────────────────────────────────┬──────┬──────────────┐
  │                           文件                           │ 变更 │     行数     │
  ├──────────────────────────────────────────────────────────┼──────┼──────────────┤
  │ omni/adaptors/vllm/patches/export_moe_experts_fix.patch  │ 新增 │ +18          │
  ├──────────────────────────────────────────────────────────┼──────┼──────────────┤
  │ omni/adaptors/vllm/sched/routed_experts_capturer.py      │ 修改 │ 修改约 43 行 │
  ├──────────────────────────────────────────────────────────┼──────┼──────────────┤
  │ omni/adaptors/vllm/sched/test_routed_experts_capturer.py │ 修改 │ 修改约 16 行 │
  ├──────────────────────────────────────────────────────────┼──────┼──────────────┤
  │ tools/accuracy/export_moe_accuracy_comparison.py         │ 新增 │ +573 行      │
  └──────────────────────────────────────────────────────────┴──────┴──────────────┘
  主要功能说明：

  新增文件：tools/accuracy/export_moe_accuracy_comparison.py

  这是一个 MoE 专家导出准确率对比验证脚本，主要功能包括：

  1. API 客户端 - 提供统一的 API 请求处理
  2. 支持流式和非流式请求 - /v1/completions 和 /v1/chat/completions
  3. MoE 专家路由数据捕获 - 在推理过程中捕获哪些专家被路由
  4. 准确率对比 - 验证导出的 MoE 专家路由数据是否正确

  新增补丁：export_moe_experts_fix.patch

  修复了 vLLM 中 serving_chat.py 的问题，确保在响应中正确添加 routed_experts 字段信息。

  用途： 这个功能用于在 MoE（Mixture of Experts）模型推理时，验证每个 token 路由到了哪些专家，用于调试和性能分析。

✻ Cogitated for 40s

```

看着它读的不错，那我来让它去检视一下这个 commit：
```
❯ 好，那你看它的修改，聚焦【规范类/功能性/架构类】问题，做一次代码 review，看下它有哪些问题？

● 让我完整读取这次提交的所有修改内容，进行深入的代码审查。

● Bash(git show HEAD --format="")
  ⎿  diff --git a/omni/adaptors/vllm/patches/export_moe_experts_fix.patch b/omni/adaptors/vllm/patches/export_moe_experts_fix.patch
     new file mode 100644
     index 00000000..3b9db660
     … +803 lines (ctrl+o to expand)

● Read 1 file (ctrl+o to expand)

● 根据完整的提交 diff，我进行了详细的代码审查。以下从【规范类/功能性/架构类】三个维度分析发现的问题：

  ---
  Code Review 报告

  【规范类问题】

  1. 全局变量污染风险

  routed_experts_capturer.py:42-43
  SAVE_DIR = os.getenv("EXPORT_MOE_EXPERTS_TEST_PATH", None)
  ROLE = os.getenv("ROLE", None)  # 模块级全局变量在导入时求值

  问题：模块级全局变量 ROLE 在导入时就求值，测试环境如果设置了 ROLE 环境变量会导致测试污染。测试代码中硬编码 part_key = 'total'，如果环境变量设置了 ROLE=prefill，测试可能会失败。

  建议：使用延迟初始化或提供测试专用的 setter 方法。

  ---
  2. 文件末尾缺少换行符

  \ No newline at end of file

  两个文件缺少末尾换行符：test_routed_experts_capturer.py 和 export_moe_accuracy_comparison.py

  ---
  3. 魔法字符串/硬编码值过多

  export_moe_accuracy_comparison.py:
  FILE_EXTEN_LEN = 4      # 为什么是 4？应该命名为 FILE_EXTENSION_LEN
  DIM_THREE = 3           # 应命名为 THREE_DIM 或使用枚举
  INCLUDE_USAGE = False   # 模块级变量作为全局开关
  IGNORE_EOS = True       # 模块级变量作为全局开关

  硬编码路径：
  dir_path = './test'      # 第 555 行
  os.makedirs("saved_req_arrays", exist_ok=True)  # 第 432 行
  filename = os.path.join("dump_arrays", prefix + f'{request_id}.txt')  # 第 582 行

  ---
  4. 格式不一致

  test_routed_experts_capturer.py:165
  part_key  = 'total'  # 双空格

  export_moe_experts_fix.patch:16
  expert_ids = getattr(res, \'routed_experts\', None)  # 单引号转写，与其他风格不一致

  ---
  5. 命名不规范

  export_moe_accuracy_comparison.py:597
  for p in prefixes:  # 单字母命名 p 不够清晰

  ---
  【功能性问题】

  1. 会话资源未正确关闭

  export_moe_accuracy_comparison.py:733-745
  def run_scripts_parallel(max_workers=3, ...):
      with ThreadPoolExecutor(max_workers=max_workers) as executor:
          futures = [
              executor.submit(run_all_request, ip_addr, port, max_tokens, model_name)
              for _ in range(max_workers)
          ]

          for future in futures:
              try:
                  future.result()  # 如果 run_all_request 抛出异常，processor 可能未 close
              except Exception as e:
                  print(f"脚本执行失败: {str(e)[:100]}")  # 错误信息被截断

  APIClient 虽然有 close() 方法，但在异常路径下可能不会被调用。

  ---
  2. 异常处理不当，静默吞掉错误

  export_moe_accuracy_comparison.py:723-730
  for f in base.glob(pattern):
      try:
          if f.is_file():
              f.unlink()
          else:
              shutil.rmtree(f)
      except Exception:  # 捕获所有异常且静默处理
          pass

  静默忽略所有异常可能掩盖文件权限问题、文件被占用等实际问题。

  ---
  3. 环境变量未检查

  routed_experts_capturer.py:54
  EXPORT_MOE_EXPERTS_TMP_DIR = os.getenv("EXPORT_MOE_EXPERTS_TMP_DIR", "./tmp_lock_dir")
  Path(EXPORT_MOE_EXPERTS_TMP_DIR).mkdir(exist_ok=True)  # 如果环境变量为 None，会抛异常

  当 EXPORT_MOE_EXPERTS_TMP_DIR 环境变量设置为 None 时，Path(None).mkdir() 会抛出 TypeError。

  ---
  4. 数据保存逻辑存在时间戳竞争

  routed_experts_capturer.py:64, 76
  save_name = os.path.join(save_dir, f"data_{time.time()}.pkl")
  save_name = os.path.join(save_dir, f"indices_{time.time()}.pkl")

  使用 time.time() 作为文件名，高并发下可能产生相同文件名，导致文件覆盖或数据丢失。

  ---
  5. 字符串格式化不一致混用

  export_moe_accuracy_comparison.py:568-579
  def save_data():
      list_data = read_pkl("indices_")
      dict_data = read_pkl("data_")
      ...
      for f in files:  # 又是用 f

  混用 f-string、format 和 % 格式化风格。

  ---
  【架构类问题】

  1. 单一职责原则违反

  export_moe_accuracy_comparison.py (573行) 包含：
  - API 客户端 (APIClient, UnifiedAPIHandler)
  - 数据处理 (merge, read_pkl, save_data)
  - 文件处理 (find_prefix_files, parse_array_content, merge_3d_arrays)
  - 主测试逻辑 (main)

  建议：拆分为多个模块，如 api_client.py, data_processor.py, file_operations.py。

  ---
  2. 全局状态管理混乱

  routed_experts_capturer.py:
  _global_experts_capturer: Optional["RoutedExpertsCapturer"] = None
  _global_experts_reader: Optional["RoutedExpertsReader"] = None
  SAVE_DIR = os.getenv("EXPORT_MOE_EXPERTS_TEST_PATH", None)
  ROLE = os.getenv("ROLE", None)

  模块级全局变量过多，状态管理不清晰，依赖隐式共享状态。

  ---
  3. 条件判断逻辑复杂，可读性差

  routed_experts_capturer.py:106-111
  if self.is_pd_disaggregation:
      part_key = 'prefill' if self.is_pd_prefill else 'decode'
  else:
      part_key = 'total'
  save_data(indices, data, SAVE_DIR, part_key)

  这段相同逻辑在两个地方出现：

  routed_experts_capturer.py:142-147
  if self.is_pd_disaggregation:
      part_key = 'prefill' if is_prefill else 'decode'
  else:
      part_key = 'total'
  save_indices(indices, request.request_id, SAVE_DIR, part_key)

  建议：抽取为方法 def _get_part_key(self, is_prefill):。

  ---
  4. 测试与生产代码耦合

  routed_experts_capturer.py 中的 save_data() 和 save_indices() 直接写入文件系统，且依赖于环境变量 SAVE_DIR。这使得单元测试难以隔离。

  ---
  5. 数据序列化/反序列化效率问题

  export_moe_accuracy_comparison.py:419-423
  @staticmethod
  def _decode_numpy_array(encoded_str, shape, dtype):
      decoded_bytes = base64.b64decode(encoded_str)
      decompressed_bytes = zlib.decompress(decoded_bytes)
      arr = np.frombuffer(decompressed_bytes, dtype=dtype)
      return arr.reshape(shape).tolist()  # 转换为 list，失去 numpy 的高效性

  将 numpy 数组转换为 list 后再序列化，失去了 numpy 的高效存储和计算优势。

  ---
  6. 目录创建的边界情况处理不足

  export_moe_accuracy_comparison.py:684-711
  def setup_paths(mode="create"):
      ...
      if mode == "create":
          for p in paths:
              p.mkdir(parents=True, exist_ok=True)
      elif mode == "delete":
          for p in paths:
              if p.exists():
                  if p.is_dir():
                      shutil.rmtree(p)  # 如果目录正在被使用（如文件句柄未关闭），会失败
                  else:
                      p.unlink()

  删除目录时没有处理目录被占用的场景（如文件未关闭、进程权限不足等）。

  ---
  【总结】
  ┌────────┬──────────┬──────────┐
  │  类别  │ 问题数量 │ 严重程度 │
  ├────────┼──────────┼──────────┤
  │ 规范类 │ 5        │ 中       │
  ├────────┼──────────┼──────────┤
  │ 功能性 │ 5        │ 高       │
  ├────────┼──────────┼──────────┤
  │ 架构类 │ 6        │ 高       │
  └────────┴──────────┴──────────┘
  建议优先处理：

  1. 功能性 1：修复会话资源未关闭问题（可能导致资源泄漏）
  2. 功能性 3：修复 mkdir(None) 的异常
  3. 功能性 4：修复时间戳竞争问题
  4. 架构类 1：拆分大文件，提高可维护性
  5. 架构类 3：抽取重复的 part_key 逻辑
  6. 规范类 1：重构全局变量，提高可测试性

✻ Crunched for 1m 18s

❯ /context
  ⎿  Context Usage
     ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛀ ⛁ ⛁   GlmMoe · 0k/200k tokens (0%)
     ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁
     ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁   Estimated usage by category
     ⛁ ⛁ ⛁ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶   ⛁ System prompt: 2.6k tokens (1.3%)
     ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶   ⛁ System tools: 13.1k tokens (6.6%)
     ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶   ⛁ Memory files: 6.0k tokens (3.0%)
     ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶   ⛁ Messages: 44.7k tokens (22.4%)
     ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶   ⛶ Free space: 101k (50.3%)
     ⛶ ⛶ ⛶ ⛝ ⛝ ⛝ ⛝ ⛝ ⛝ ⛝   ⛝ Autocompact buffer: 33.0k tokens (16.5%)
     ⛝ ⛝ ⛝ ⛝ ⛝ ⛝ ⛝ ⛝ ⛝ ⛝

     Memory files · /memory
     └ ~/.claude/CLAUDE.md: 4.1k tokens
     └ CLAUDE.md: 1.8k tokens
```

看下来它检视的很完善，接下来，我们挑一个问题让它修改下：
```
❯ 我觉得你说的很对，现在帮我修改 1 个问题吧，把你刚才说的`routed_experts_capturer.py:106-111` 和 `routed_experts_capturer.py:142-147` 这 2 段重复的判断逻辑抽取为方法 def _get_part_key(self, is_prefill)

● Read 1 file (ctrl+o to expand)

● 现在我来进行修改。我需要：

  1. 在 _RoutedExpertsCapturer 类中添加 _get_part_key 方法
  2. 将第 267-270 行的重复逻辑替换为方法调用
  3. 在 _RoutedExpertsReader 类中添加 _get_part_key 方法
  4. 将第 429-432 行的重复逻辑替换为方法调用

● Update(omni/adaptors/vllm/sched/routed_experts_capturer.py)
  ⎿  Added 6 lines
      106      """Concrete implementation of routed experts capturer."""
      107
      108      def __init__(self) -> None:
      109 +
      110 +    def _get_part_key(self) -> str:
      111 +        """Get the partition key for saving data based on PD disaggregation mode."""
      112 +        if self.is_pd_disaggregation:
      113 +            return 'prefill' if self.is_pd_prefill else 'decode'
      114 +        return 'total'
      115          self._experts_capturer_device_buffer: Optional[torch.Tensor] = None
      116          self._shm: Optional[shared_memory.SharedMemory] = None
      117          self._host_buffer_view: Optional[np.ndarray] = None

● Update(omni/adaptors/vllm/sched/routed_experts_capturer.py)
  ⎿  Error editing file

● Read 1 file (ctrl+o to expand)

● 我的第一次编辑破坏了文件结构。让我重新修复这个文件：

● Read 1 file (ctrl+o to expand)

● 文件已经被我之前的编辑破坏了。让我先恢复文件：

● Bash(git checkout omni/adaptors/vllm/sched/routed_experts_capturer.py)
  ⎿  /etc/profile.d/colorxzgrep.sh: line 1: /usr/libexec/grepconf.sh: No such file or directory
     Updated 1 path from the index

● 文件已恢复。现在让我正确地进行修改：

● Read 1 file (ctrl+o to expand)

● 文件已恢复。现在让我正确地进行修改。首先在 _RoutedExpertsCapturer 类中添加 _get_part_key 方法：

● Update(omni/adaptors/vllm/sched/routed_experts_capturer.py)
  ⎿  Added 6 lines
      118          self.max_num_kv_tokens: int = 0
      119          self.lock_file: Optional[str] = None
      120
      121 +    def _get_part_key(self) -> str:
      122 +        """Get the partition key for saving data based on PD disaggregation mode."""
      123 +        if self.is_pd_disaggregation:
      124 +            return 'prefill' if self.is_pd_prefill else 'decode'
      125 +        return 'total'
      126 +
      127      def init_buffer(
      128          self,
      129          max_num_batched_tokens: int,

● 现在替换第一处重复逻辑（第 267-271 行）：

● Update(omni/adaptors/vllm/sched/routed_experts_capturer.py)
  ⎿  Added 1 line, removed 5 lines
      270                      and self._experts_capturer_device_buffer is not None
      271                  ):
      272                      self._host_buffer_view[indices, :, :] = data
      273 -                    if self.is_pd_disaggregation:
      274 -                        part_key = 'prefill' if self.is_pd_prefill else 'decode'
      275 -                    else:
      276 -                        part_key = 'total'
      277 -                    save_data(indices, data, SAVE_DIR, part_key)
      273 +                    save_data(indices, data, SAVE_DIR, self._get_part_key())
      274                  if self._shm_total_token_num is not None:
      275                      current_count = struct.unpack_from(
      276                          FMT, self._shm_total_token_num.buf, 0

● 现在在 _RoutedExpertsReader 类中添加 _get_part_key 方法，先找到它的 __init__ 位置：

● Read 1 file (ctrl+o to expand)

● 在 _RoutedExpertsReader 类中添加 _get_part_key 方法：

● Update(omni/adaptors/vllm/sched/routed_experts_capturer.py)
  ⎿  Added 6 lines
      355          self.lock_file: Optional[str] = None
      356          self.np_dtype: np.dtype = np.uint8
      357
      358 +    def _get_part_key(self, is_prefill: bool) -> str:
      359 +        """Get the partition key for saving data based on PD disaggregation mode."""
      360 +        if self.is_pd_disaggregation:
      361 +            return 'prefill' if is_prefill else 'decode'
      362 +        return 'total'
      363 +
      364      def attach_buffer(
      365          self,
      366          hf_config,

● 现在查找并替换第二处重复逻辑：

● Read 1 file (ctrl+o to expand)

● 替换第二处重复逻辑：

● Update(omni/adaptors/vllm/sched/routed_experts_capturer.py)
  ⎿  Added 1 line, removed 5 lines
      434              + np.arange(self.block_size)
      435          ).flatten()[start_tokens:num_tokens]
      436          if indices is not None and stopped:
      437 -            if self.is_pd_disaggregation:
      438 -                part_key = 'prefill' if is_prefill else 'decode'
      439 -            else:
      440 -                part_key = 'total'
      441 -            save_indices(indices, request.request_id, SAVE_DIR, part_key)
      437 +            save_indices(indices, request.request_id, SAVE_DIR, self._get_part_key(is_prefill))
      438          if not is_prefill and is_stream:
      439              indices = indices[-num_new_token:]
      440          expect_token_num = indices.size

● 修改完成。让我验证一下修改结果：

● Read 1 file (ctrl+o to expand)

● 让我再验证两处调用的修改是否正确：

● Read 1 file (ctrl+o to expand)

● 修改已完成。让我总结一下所做的更改：

  修改总结

  1. 在 _RoutedExpertsCapturer 类中添加 _get_part_key() 方法

  位置: routed_experts_capturer.py:121-125

  def _get_part_key(self) -> str:
      """Get the partition key for saving data based on PD disaggregation mode."""
      if self.is_pd_disaggregation:
          return 'prefill' if self.is_pd_prefill else 'decode'
      return 'total'

  2. 替换第一处重复逻辑

  位置: routed_experts_capturer.py:273

  修改前:
  if self.is_pd_disaggregation:
      part_key = 'prefill' if self.is_pd_prefill else 'decode'
  else:
      part_key = 'total'
  save_data(indices, data, SAVE_DIR, part_key)

  修改后:
  save_data(indices, data, SAVE_DIR, self._get_part_key())

  3. 在 _RoutedExpertsReader 类中添加 _get_part_key() 方法

  位置: routed_experts_capturer.py:358-362

  def _get_part_key(self, is_prefill: bool) -> str:
      """Get the partition key for saving data based on PD disaggregation mode."""
      if self.is_pd_disaggregation:
          return 'prefill' if is_prefill else 'decode'
      return 'total'

  4. 替换第二处重复逻辑

  位置: routed_experts_capturer.py:437

  修改前:
  if self.is_pd_disaggregation:
      part_key = 'prefill' if is_prefill else 'decode'
  else:
      part_key = 'total'
  save_indices(indices, request.request_id, SAVE_DIR, part_key)

  修改后:
  save_indices(indices, request.request_id, SAVE_DIR, self._get_part_key(is_prefill))

  ---
  这段重构代码消除了两处重复的条件判断逻辑，提高了代码的可维护性。如果未来需要修改 part_key 的计算规则，只需要在 _get_part_key() 方法中修改一处即可。

✻ Churned for 2m 5s

```

最后我们使用 `git diff` 去看下它的修改：
```
[root@056e04b4b4db omniinfer]# git diff
diff --git a/omni/adaptors/vllm/sched/routed_experts_capturer.py b/omni/adaptors/vllm/sched/routed_experts_capturer.py
index 2636da92..2a128fe4 100644
--- a/omni/adaptors/vllm/sched/routed_experts_capturer.py
+++ b/omni/adaptors/vllm/sched/routed_experts_capturer.py
@@ -118,6 +118,12 @@ class _RoutedExpertsCapturer:
         self.max_num_kv_tokens: int = 0
         self.lock_file: Optional[str] = None

+    def _get_part_key(self) -> str:
+        """Get the partition key for saving data based on PD disaggregation mode."""
+        if self.is_pd_disaggregation:
+            return 'prefill' if self.is_pd_prefill else 'decode'
+        return 'total'
+
     def init_buffer(
         self,
         max_num_batched_tokens: int,
@@ -264,11 +270,7 @@ class _RoutedExpertsCapturer:
                     and self._experts_capturer_device_buffer is not None
                 ):
                     self._host_buffer_view[indices, :, :] = data
-                    if self.is_pd_disaggregation:
-                        part_key = 'prefill' if self.is_pd_prefill else 'decode'
-                    else:
-                        part_key = 'total'
-                    save_data(indices, data, SAVE_DIR, part_key)
+                    save_data(indices, data, SAVE_DIR, self._get_part_key())
                 if self._shm_total_token_num is not None:
                     current_count = struct.unpack_from(
                         FMT, self._shm_total_token_num.buf, 0
@@ -353,6 +355,12 @@ class _RoutedExpertsReader:
         self.lock_file: Optional[str] = None
         self.np_dtype: np.dtype = np.uint8

+    def _get_part_key(self, is_prefill: bool) -> str:
+        """Get the partition key for saving data based on PD disaggregation mode."""
+        if self.is_pd_disaggregation:
+            return 'prefill' if is_prefill else 'decode'
+        return 'total'
+
     def attach_buffer(
         self,
         hf_config,
@@ -426,11 +434,7 @@ class _RoutedExpertsReader:
             + np.arange(self.block_size)
         ).flatten()[start_tokens:num_tokens]
         if indices is not None and stopped:
-            if self.is_pd_disaggregation:
-                part_key = 'prefill' if is_prefill else 'decode'
-            else:
-                part_key = 'total'
-            save_indices(indices, request.request_id, SAVE_DIR, part_key)
+            save_indices(indices, request.request_id, SAVE_DIR, self._get_part_key(is_prefill))
         if not is_prefill and is_stream:
             indices = indices[-num_new_token:]
         expect_token_num = indices.size
```
