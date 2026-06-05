# wxmp-workflow

> 微信公众号全流程工作流 — 从灵感到发布，一站式完成

一个 AI Agent skill，帮你完成公众号内容创作的全链路。兼容 Claude Code、Cursor、Windsurf 等支持 skill 的 Agent 工具：

```
选题 → 调研 → 大纲 → 写稿 → 打磨 → 配图 → 排版 → 发布 → 复盘 → 多平台同步
```

支持**全自动**（无人值守）和**半自动**（交互式确认）两种模式。

---

## ✨ 功能

| 阶段 | 能力 |
|------|------|
| 📡 选题 | 热点扫描、国际新闻源、竞品分析、用户互动挖掘 |
| 🔍 调研 | 竞品文章、行业数据、权威引用、用户案例 |
| ✍️ 撰写 | 大纲生成、正文撰写、多轮修改 |
| 💎 打磨 | 去 AI 味（4 轮扫描）、文章体检报告、爆款标题、摘要 |
| 🎨 配图 | Agnes AI 一句话生成配图 |
| 📐 排版 | 5 个精美 HTML 模板，适配微信深色/浅色模式 |
| 🚀 发布 | API 自动发布、数据统计查询 |
| 📊 复盘 | 阅读量/分享率分析、经验总结 |
| 🔄 同步 | 一键同步到知乎、掘金、CSDN 等 29+ 平台草稿箱 |

---

## 🚀 快速开始

### 1. 安装

```bash
npx skills add SoulChildTc/wxmp-workflow
```

### 2. 使用

在支持 skill 的 Agent 工具中调用 skill，再输入指令：

```
> /wxmp-workflow
> 帮我写篇公众号
```

常用指令：

| 指令 | 说明 |
|------|------|
| 帮我配置 | 配置助手，引导完成各项设置 |
| 帮我写篇公众号 | 完整流程：选题 → 发布 |
| 帮我写篇关于 AI 的文章 | 跳过选题，从调研开始 |
| 全自动帮我写完直接发 | 无人值守模式 |
| 帮我想几个标题 | 单独调用爆款标题生成器 |
| 帮我看看文章怎么样 | 调用文章体检报告 |
| 同步到其他平台 | 发布后同步到知乎/掘金等平台 |

---

## ⚙️ 配置

```bash
cp config/wxmp.example.json config/wxmp.json
```

配置文件支持两个位置（当前项目目录优先）：

| 功能 | 是否必须 | 配置项 |
|------|---------|--------|
| 写文章、打磨、排版 | ✅ 必须 | 无，开箱即用 |
| 发布到公众号 | 推荐 | `appid` + `secret` |
| AI 生成配图 | 可选 | `agnes_api_key` |
| 多平台同步 | 可选 | Wechatsync CLI + Chrome 扩展 |

获取公众号 API：微信公众平台 → 我的业务与服务 → 公众号 → 开发密钥

说"帮我配置"可以引导完成所有设置。

---

## 📁 项目结构

```
wxmp-workflow/
├── SKILL.md                    # skill 入口
├── config/
│   └── wxmp.example.json       # 配置模板
├── references/                 # 各阶段详细指引
│   ├── wxmp-inspiration.md     # 选题（含国际新闻源）
│   ├── wxmp-research.md        # 调研
│   ├── wxmp-writing.md         # 撰写 + 打磨 + 配图 + 排版
│   ├── wxmp-tools.md           # 增强工具集
│   ├── wxmp-publishing.md      # 发布 + 复盘
│   ├── wxmp-sync.md            # 多平台同步
│   └── wxmp-setup.md           # 配置助手
├── scripts/                    # API 脚本（curl + jq）
├── templates/                  # 5 个精美 HTML 模板
└── output/                     # 生成的文章输出目录
```

---

## 📝 脚本用法

```bash
# 获取 token（自动缓存 2 小时）
bash scripts/wx-auth.sh

# 上传封面图 → 创建草稿 → 发布
bash scripts/wx-upload-image.sh /path/to/cover.jpg
bash scripts/wx-draft.sh --title "标题" --content output/xxx.html --thumb MEDIA_ID
bash scripts/wx-publish.sh --media-id DRAFT_MEDIA_ID

# 查询数据
bash scripts/wx-stats.sh --recent 7
bash scripts/wx-article-stats.sh --recent 7

# AI 图片生成
bash scripts/wx-generate-image.sh --prompt "图片描述"

# 多平台同步
wechatsync sync output/xxx.html -p zhihu,juejin,csdn
```

---

## 📌 注意事项

- 公众号每天发布次数有限制：订阅号 1 次，服务号 4 次
- 文章 HTML 必须使用内联样式，不支持外部 CSS/JS
- 图片必须先上传到微信素材库才能在文章中使用
- 发布后文章无法修改，只能删除重发（会占用当天发布次数）

---

## License

MIT
