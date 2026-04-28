# AI 热点新闻视频生产系统

## 核心目的（最重要原则）

本项目旨在最大化利用 **ChatGPT image-2** 模型和 **Seedance 2.0** 模型的能力，通过每天从微博、抖音、小红书等国内平台挑选一个最匹配这两个模型能力的热点话题，制作一条 2-3 分钟的 AI 视频。

**选题的第一优先级是"模型能力匹配度"**——热点话题必须能充分发挥 image-2 的图像生成能力和 Seedance 2.0 的视频生成能力，而非单纯追逐热度。

**视频比例：16:9 横屏**（适配多平台：B站、YouTube、横屏模式下的抖音/小红书）

## 文档导航

- **[WORKFLOW.md](WORKFLOW.md)** - 完整工作流指南，从选题到上线的全流程
- **[HARNESS.md](HARNESS.md)** - Harness 说明，项目的工具、脚本和检查机制
- **[CHANGELOG.md](CHANGELOG.md)** - 更新日志，记录项目的改进和优化
- **[project-config.md](project-config.md)** - 项目配置和核心原则

## 核心链路

`热点输入 -> 事实核实 -> 脚本 -> Image 2 分镜图 -> Seedance 2.0 视频片段 -> 发布文案`

本次优化重点参考了：

- 火山引擎官方《Doubao Seedance 2.0 系列提示词指南》
- `make-prompt-seedance2` 的结构化提示词实践
- 你提供的飞书/X 链接中的方向性需求

说明：

- 飞书文档和 X 帖子如果后续你能贴出正文，我还能再继续对齐细节。
- 本次已经先把能公开核实、可直接落地的规范写进项目。

## 当前能力

1. 热点新闻选题卡
2. 绝对日期化脚本
3. Image 2 宫格分镜提示词
4. Seedance 2.0 结构化提示词
5. 素材引用与资产清单
6. 平台发布文案
7. 生产检查清单

## 目录结构

```text
.
├── README.md
├── project-config.md
├── agents/
├── outputs/
├── prompts/
│   ├── image2-prompt-template.md
│   ├── news-angle-template.md
│   ├── reference-asset-guide.md
│   ├── seedance-prompt-template.md
│   ├── seedance2-structured-prompt-standard.md
│   ├── shot-language-taxonomy.md
│   └── visual-style-presets.md
├── queue/
├── scripts/
│   └── tools/
│       ├── new-topic.sh
│       └── topic-queue.sh
└── templates/
    ├── assets-manifest-template.md
    ├── production-checklist-template.md
    ├── publish-copy-template.md
    ├── script-template.md
    ├── seedance-prompts-template.md
    ├── shot-image-prompts-template.md
    ├── source-log-template.md
    ├── topic-card-template.md
    └── video-segment-brief-template.md
```

## 这次优化了什么

### 1. Seedance 2.0 提示词从“自然语言描述”升级为“结构化标准”

现在每段提示词都要求显式写出：

- 风格
- 时长
- 画幅比例
- 情绪氛围
- 时间轴
- 声音设计
- 参考素材用途

这比单纯写一段长描述更稳定，也更接近官方与社区高质量实践。

### 2. 明确多模态参考素材规范

新增参考素材约定：

- `@图片1`：首帧 / 尾帧 / 人物 / 场景参考
- `@视频1`：运镜 / 动作节奏参考
- `@音频1`：配乐 / 对白 / 节奏参考

并明确约束：

- 总文件数最多 12 个
- 图片最多 9 张
- 视频最多 3 个
- 音频最多 3 个
- 参考视频与参考音频总时长都应控制在 15 秒内

### 3. 增加生产中间层文件

现在一个选题除了脚本与发布文案，还会多出：

- `00-source-log.md`：来源与核实记录
- `06-assets-manifest.md`：参考素材表
- `07-production-checklist.md`：出图/生视频前检查

这样能把“事实”和“生成资产”分开管理，适合热点快反长期复用。

## 快速开始

```bash
# 1. 评估热点话题（交互式）
bash scripts/tools/topic-evaluator.sh

# 2. 创建新选题目录
bash scripts/tools/new-topic.sh N06 topic-slug

# 3. 按工作流填写生产文件
# 详见 WORKFLOW.md

# 4. 检查完整性
bash scripts/tools/check-production.sh outputs/N06-topic-slug
```

完整工作流请查看 [WORKFLOW.md](WORKFLOW.md)。

查看队列：

```bash
scripts/tools/topic-queue.sh status
scripts/tools/topic-queue.sh list ready
```

## 推荐单条视频目录

```text
outputs/NXX-slug/
├── 00-source-log.md
├── 01-topic-card.md
├── 02-script.md
├── 03-image-prompts.md
├── 04-seedance-prompts.md
├── 05-publish-copy.md
├── 06-assets-manifest.md
├── 07-production-checklist.md
├── images/
└── videos/
```

## 推荐工作流

1. 先做 `00-source-log.md`
2. 再做 `01-topic-card.md`
3. 确定时长和段数后写 `02-script.md`
4. 按段生成 `03-image-prompts.md`
5. 若有视频/音频参考，再在 `06-assets-manifest.md` 登记
6. 用结构化模板写 `04-seedance-prompts.md`
7. 最后产出 `05-publish-copy.md`

## 使用原则

- **每天只选一个话题，优先匹配 image-2 和 Seedance 2.0 的生成能力，不单纯追热度**
- 新闻必须先核实，再写脚本
- 所有”今天/昨天/刚刚”改成绝对日期
- 一张宫格图只服务一段 `12-15 秒` 视频
- Seedance 提示词按时间轴拆开，不把多个动作团成一段长话
- 有外部参考素材时，必须写清”它用来参考什么”
