# wxmp-workflow

微信公众号全流程工作流 skill — 从发现灵感、撰写文章到直接发布。

## 功能

- **选题发现** — 热点话题扫描、竞品分析、用户互动挖掘
- **调研素材** — 自动搜集竞品文章、行业数据、权威引用
- **文章撰写** — 大纲生成、正文撰写、多轮修改
- **打磨优化** — 去 AI 味检查、文章体检报告、爆款标题生成、摘要生成
- **排版发布** — 转公众号 HTML、API 发布、数据统计
- **发布复盘** — 阅读量/分享率分析、经验总结

支持**全自动**（无人值守）和**半自动**（交互式确认）两种模式。

## 快速开始

### 1. 安装

```bash
npx skills add SoulChildTc/wxmp-workflow
```

或手动安装：将本目录放到 `~/.claude/skills/wxmp-workflow/`。

### 2. 配置公众号 API（可选）

```bash
cp config/wxmp.example.json config/wxmp.json
```

填入你的微信公众号 AppID 和 Secret。

获取方式：微信公众平台 → 设置与开发 → 基本配置

没有 API 也能用，只是发布环节需要手动操作。

### 3. 使用

在 Claude Code 中说：

- "帮我写篇公众号" — 完整流程
- "帮我写篇关于 AI 的文章" — 跳过选题
- "帮我想几个标题" — 单独调用工具
- "全自动帮我写完直接发" — 无人值守模式

## 项目结构

```
wxmp-workflow/
├── SKILL.md                    # skill 入口（意图路由 + 流程概览）
├── CLAUDE.md                   # Claude Code 开发指引
├── config/
│   └── wxmp.example.json       # 配置模板
├── references/                 # 各阶段详细说明
│   ├── wxmp-inspiration.md     # 选题流程
│   ├── wxmp-research.md        # 调研流程
│   ├── wxmp-writing.md         # 撰写 + 打磨 + 配图 + 排版
│   ├── wxmp-tools.md           # 增强工具（标题/摘要/体检/标签）
│   └── wxmp-publishing.md      # 发布 + 预览 + 复盘
├── scripts/                    # API 脚本
│   ├── wx-auth.sh              # 获取/缓存 access_token
│   ├── wx-upload-image.sh      # 上传封面图素材
│   ├── wx-draft.sh             # 创建草稿
│   ├── wx-publish.sh           # 发布文章
│   ├── wx-stats.sh             # 查询数据统计
│   ├── wx-articles.sh          # 获取已发布文章列表
│   ├── wx-article-stats.sh     # 查询单篇文章详细数据
│   └── wx-generate-image.sh    # Agnes AI 图片生成
├── templates/                  # 5 个精美 HTML 模板
│   ├── minimal-white.html      # 简约白（教程、指南）
│   ├── magazine.html           # 杂志风（深度、观点）
│   ├── dark-mode.html          # 科技风（技术、编程）
│   ├── card-style.html         # 卡片式（清单、盘点）
│   └── gradient.html           # 渐变风（生活、故事）
└── output/                     # 生成的文章输出目录
```

## 脚本用法

```bash
# 获取 token（自动缓存 2 小时）
bash scripts/wx-auth.sh

# 上传封面图
bash scripts/wx-upload-image.sh /path/to/cover.jpg

# 创建草稿
bash scripts/wx-draft.sh --title "标题" --content output/xxx.html --thumb MEDIA_ID

# 发布文章
bash scripts/wx-publish.sh --media-id DRAFT_MEDIA_ID

# 查询数据
bash scripts/wx-stats.sh --date 2026-06-05          # 查当天数据
bash scripts/wx-stats.sh --recent 7                  # 最近7天

# 已发布文章管理
bash scripts/wx-articles.sh                          # 获取已发布文章列表
bash scripts/wx-article-stats.sh --recent 7          # 单篇文章详细数据

# AI 图片生成（需要配置 Agnes API Key）
bash scripts/wx-generate-image.sh --prompt "图片描述" --size 1024x768
```

## 注意事项

- 微信公众号每天发布次数有限制：订阅号 1 次，服务号 4 次
- 文章 HTML 必须使用内联样式，不支持外部 CSS/JS
- 图片必须先上传到微信素材库才能在文章中使用
- 发布后文章无法修改，只能删除重发
