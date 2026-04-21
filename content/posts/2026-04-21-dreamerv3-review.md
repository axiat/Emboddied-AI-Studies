---
title: "[论文笔记] DreamerV3：固定超参数跨 150+ 任务的 World Model RL"
date: 2026-04-21
tags: ["embodied-ai", "paper-notes", "world-model", "reinforcement-learning"]
summary: "DreamerV3 用一套固定超参数在 8 个 domain、150+ 任务上稳定训练，核心是一整套让 world model RL 在异质任务分布下保持稳定的工程设计。"
toc: true
scores:
  innovation: B
  extensibility: A
  reusability: A
verdict: "world model RL 跨域稳定性的系统工程里程碑，可作为结构化技能研究的底座。"
---

## 背景

强化学习中存在一个长期未解的问题：每换一类任务，算法往往需要重新调参。PPO 相对稳定但数据效率差；SAC 在连续控制中表现好，但 entropy scale 对不同任务的敏感度差异很大；MuZero 展示了 learned model + planning 的潜力，但复现门槛高。这类**针对单一 domain 精调的算法，一旦迁移到 reward scale、观测模态、任务难度都不同的新场景，通常需要大量重调超参数才能维持性能**。

Dreamer 系列试图通过 world model 兼顾泛化性和数据效率——在 latent 空间里做 imagined rollout 来训练策略，减少对真实交互的依赖。DreamerV3 在此基础上追问：**同一套超参数，能不能在 8 个 domain、150+ 任务上全部稳定工作？**

## 核心方法：鲁棒化三板斧

DreamerV3 的架构主干是 RSSM world model + actor + critic，actor 和 critic 在 imagined trajectory 上学习而不依赖大量真实交互。

关键贡献在于系统性地处理跨域训练失稳的根源，分三类：

**Balancing**：world model 的 latent state 需要在"信息量足够重建观测"和"动态足够可预测"之间维持平衡。作者用 free bits + 对 dynamics/representation loss 分别施加 stop-gradient + 较小的 representation loss 权重来实现这个平衡。

**Normalization**：用 batch 的 5th–95th percentile 区间配合 EMA 平滑来归一化 return，而不是 max-min 或标准差。这样 sparse reward 环境或异常高回报轨迹不会破坏整体尺度估计。

**Transformations**：symlog 对大幅值正负目标做压缩，symexp twohot 把标量 value 回归转成指数分桶上的分布学习，解决不同任务间 reward/value target scale 差异导致训练不稳的问题。

这三类设计耦合在一起，使得同一套超参数能够在动作空间、观测模态、奖励稀疏性差异显著的任务上稳定训练。

## 实验

作者在 Atari、ProcGen、DMLab、Proprio Control、Visual Control、BSuite 和 Minecraft 等 benchmark 上以固定超参数统一评估。主要结论：

- 在多个 domain 上整体超过各自精调的 expert algorithm，同时优于统一配置的 PPO
- DMLab 上用 100M frames 达到 IMPALA/R2D2+ 在 1B steps 的结果
- Minecraft diamond 任务：无 human data、无 curriculum，从零开始成功挖到钻石
- 模型从 12M 扩展到 400M 参数，性能单调提升，更大模型在同等性能下所需的真实交互步数更少

Ablation 结果表明，symexp twohot regression、return normalization、KL objective 对整体性能的帮助在实验中均得到验证。

## 延伸思考

**技能级 imagination**：DreamerV3 的 imagined rollout 单位是 primitive action。如果把这个单位升级为 skill token，让 world model 预测"执行某个 skill 后的状态分布、持续时间和终止条件"，高层策略就可以在 imagined skill graph 上做规划。这是一个直接的扩展方向，论文本身没有涉及。

**稳定化技巧的可移植性**：symlog/twohot 和 percentile-based return normalization 解决的都是 target scale 不一致导致训练不稳的问题，与具体任务无关。这两个模块可以迁移到其他需要稳定价值学习的系统中——例如技能代价评估、子目标进度回归、终止价值预测，尤其适合 sparse reward 或长尾 success signal 的场景。

**Scaling 的含义**：论文展示 world model 方法具有 scaling-friendly 的性质（更大模型同时提升性能和数据效率），这对后续基于 world model 做预训练或 foundation model 的研究方向有参考意义。

## 参考

- Hafner et al., *Mastering Diverse Domains through World Models*, arXiv 2301.04104, Nature 2025. [原文](https://arxiv.org/abs/2301.04104)
