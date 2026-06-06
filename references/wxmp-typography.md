# 排版设计规范

公众号文章的手机端排版规范。AI 将 Markdown 转 HTML 时必须遵循这些规则，确保每篇文章在手机上阅读体验一致、舒适。

## 设计原则

1. **手机优先** — 所有样式以 375px 宽度为基准，手指滑动阅读
2. **呼吸感** — 密集文字之间必须有留白，让眼睛休息
3. **视觉节奏** — 连续纯文字不超过 3 段，中间插结构化元素打断
4. **一致性** — 同一篇文章的字号、间距、配色保持统一

## 字号体系

| 元素 | 字号 | 行高 | 字重 | 颜色 |
|------|------|------|------|------|
| 大标题（h2 章节标题） | 20px | 1.4 | bold | #1a1a1a |
| 小标题（h3 子标题） | 17px | 1.4 | bold | #1a1a1a |
| 正文 | 15px | 1.8 | normal | #333 |
| 引用块 | 14px | 1.8 | normal | #666 |
| 注释/来源 | 13px | 1.6 | normal | #999 |
| 金句高亮 | 18px | 1.6 | normal | #333 |

不要用 16px 以下的正文——手机上太小。不要用 22px 以上的标题——太突兀。

## 间距体系

| 位置 | 间距 |
|------|------|
| 段落之间 | `margin: 0 0 18px` |
| 章节标题与正文 | `margin: 30px 0 15px` |
| 章节之间（标题上方） | `margin: 35px 0 0` |
| 引用块上下 | `margin: 20px 0` |
| 图片上下 | `margin: 15px 0` |
| 列表项之间 | `margin: 0 0 12px` |
| 组件（卡片/信息框）上下 | `margin: 20px 0` |

首行不缩进，用段间留白代替。

## 配色方案

| 用途 | 色值 | 说明 |
|------|------|------|
| 正文 | `#333` | 主要文字 |
| 次要文字 | `#666` | 引用、补充说明 |
| 注释 | `#999` | 来源、时间、作者信息 |
| 强调/重点 | `#fa5151` | 加粗、标记、小圆点 |
| 标题底线 | `#fa5151` | h2 下方的 2px 红线 |
| 背景色 | `#f7f7f7` | 引用块、卡片、信息框背景 |
| 分割线 | `#eee` | 章节分隔 |

一篇文章只用一个强调色（`#fa5151`），不要混用多种颜色。

## 视觉节奏

### 打断规则

连续纯文字段落不超过 3 段。第 4 段之前必须插入一个视觉元素：

- 引用块（`<blockquote>`）
- 金句高亮（居中大字）
- 卡片式组件（`<section>` 带左边框）
- 图片
- 分割线（`<hr>`）
- 列表（悬挂缩进或卡片式）

### 分割线

章节之间用分割线分隔，不要只靠间距：

```html
<hr style="border: none; border-top: 1px solid #eee; margin: 35px 0;" />
```

### 金句高亮

值得划线/转发的句子，用大号居中样式突出：

```html
<p style="font-size: 18px; line-height: 1.6; color: #333; text-align: center; margin: 25px 15px; padding: 15px 0;">
  金句内容，尽量控制在 20 字以内。
</p>
```

一篇文章 1500 字至少有 2-3 个金句高亮。

## 开头策略

文章开头决定读者是否继续。不要每次都用同一种开头，根据内容选择不同手法。

### 策略库

| 手法 | 说明 | 适合 |
|------|------|------|
| 数据冲击 | 用一个反直觉的数据开头 | 深度长文、观点/评论 |
| 痛点提问 | 问一个读者正在经历的问题 | 教程/干货、观点/评论 |
| 场景代入 | 描述一个具体的生活场景 | 故事/案例、盘点/清单 |
| 反常识 | 挑战一个普遍认知 | 角点/评论、深度长文 |
| 直接下判断 | 开门见山亮出观点 | 观点/评论、深度长文 |
| 故事悬念 | 讲一个小故事，留个悬念 | 故事/案例、观点/评论 |
| 热点切入 | 从当天热点事件引入 | 观点/评论、盘点/清单 |
| 自嘲/幽默 | 用自嘲拉近距离 | 故事/案例、教程/干货 |
| 对比冲击 | 前后/新旧/理想与现实的反差 | 故事/案例、深度长文 |
| 引用金句 | 用一句有力量的话开头 | 观点/评论、深度长文 |

**选择原则：** 同一作者连续几篇文章不要用同一种开头。AI 根据文章内容和风格选最合适的，措辞每次都不同——这些是手法，不是填空模板。

## 组件库

### 信息提示框

用于 tips、注意事项、补充说明。

```html
<section style="margin: 20px 0; padding: 12px 15px; border-left: 3px solid #fa5151; background: #f7f7f7; border-radius: 0 6px 6px 0;">
  <p style="font-size: 14px; line-height: 1.8; margin: 0; color: #666;">
    💡 提示内容写在这里。
  </p>
</section>
```

### 步骤卡

用于教程/操作步骤。

```html
<p style="font-size: 15px; line-height: 1.8; margin: 0 0 12px; padding-left: 1.5em; text-indent: -1.5em;">
  <span style="display: inline-block; width: 22px; height: 22px; line-height: 22px; text-align: center; background: #fa5151; color: #fff; border-radius: 50%; font-size: 13px; font-weight: bold; margin-right: 8px;">1</span>
  <strong>第一步标题</strong> — 具体操作说明
</p>
```

步骤超过 5 步时，拆成多组，每组之间加空行。

### 对比卡

用于正确 vs 错误、优点 vs 缺点。

```html
<section style="margin: 20px 0; padding: 12px 15px; border-left: 3px solid #07c160; background: #f0faf4; border-radius: 0 6px 6px 0;">
  <p style="font-size: 14px; line-height: 1.8; margin: 0; color: #333;">
    <strong style="color: #07c160;">✅ 正确：</strong>具体示例
  </p>
</section>
<section style="margin: 5px 0 20px; padding: 12px 15px; border-left: 3px solid #fa5151; background: #fef0f0; border-radius: 0 6px 6px 0;">
  <p style="font-size: 14px; line-height: 1.8; margin: 0; color: #333;">
    <strong style="color: #fa5151;">❌ 错误：</strong>具体示例
  </p>
</section>
```

### 重点卡片

用于核心观点、关键结论。

```html
<section style="margin: 20px 0; padding: 14px 16px; border-left: 3px solid #fa5151; background: #f7f7f7; border-radius: 0 6px 6px 0;">
  <p style="font-size: 15px; line-height: 1.8; margin: 0; color: #333;">
    <strong style="color: #fa5151;">关键点</strong> — 核心内容描述
  </p>
</section>
```

### 互动引导区

文章结尾的固定互动区域，引导读者行动。

```html
<hr style="border: none; border-top: 1px solid #eee; margin: 35px 0 20px;" />
<p style="font-size: 14px; line-height: 1.8; color: #999; text-align: center; margin: 0 0 8px;">
  👆 觉得有用？点个<strong style="color: #fa5151;">「在看」</strong>让更多人看到
</p>
<p style="font-size: 14px; line-height: 1.8; color: #999; text-align: center; margin: 0;">
  💬 你怎么看？评论区聊聊
</p>
```

互动引导区每篇文章都要有，措辞可以变化，但位置和样式保持一致。

## 深色模式兼容

微信有深色模式，排版必须兼容。核心原则：

| 规则 | 说明 |
|------|------|
| 不设背景色 | `<body>`、`<section>` 外层不设 background，让微信自动适配 |
| 不用纯白文字 | 深色模式下纯白 (#fff) 太刺眼，用 `#e8e8e8` 或让微信自动处理 |
| 文字用中性色 | `#333`/`#666`/`#999` 在深色模式下微信会自动反转 |
| 背景色用浅灰 | `#f7f7f7` 比纯白在深色模式下表现更好 |
| 强调色不要大面积 | `#fa5151` 只用于小元素（加粗、边框、圆点），不要做大面积背景 |
| 图片加透明背景 | `background: transparent`，不要给图片加白色背景框 |

模板文件已经遵循这些规则。内容转换时也要遵守。

## 完整示例：一篇文章的结构

```
┌─────────────────────────┐
│  标题（20px, bold, #1a1a1a）      │
│  作者 · 来源（13px, #999）        │
├─────────────────────────┤
│                              │
│  开头段落（选一种开头策略）      │
│                              │
│  正文段落 1（15px, #333）       │
│                              │
│  正文段落 2                    │
│                              │
│  正文段落 3                    │
│                              │
│  ─── 视觉断点 ───             │
│  引用块 / 金句 / 卡片          │
│                              │
│  正文段落 4                    │
│                              │
│  ────────────────             │
│  章节标题（20px, 底线）         │
│                              │
│  ...更多内容...                │
│                              │
│  ────────────────             │
│  互动引导区（居中, #999）       │
│                              │
└─────────────────────────┘
```

## 检查清单

排版完成后，逐项检查：

- [ ] 正文 15px，行高 ≥1.8
- [ ] 连续纯文字 ≤3 段，中间有视觉断点
- [ ] 章节标题有底线装饰
- [ ] 段落首行不缩进，段间留白
- [ ] 1500 字至少 2-3 个金句高亮
- [ ] 1500 字至少 1 个组件（信息框/卡片/步骤卡）
- [ ] 结尾有互动引导区
- [ ] 图片宽度 100%，有圆角
- [ ] 无 `<ul>`/`<ol>`/`<li>` 标签
- [ ] 强调色统一用 `#fa5151`
- [ ] 深色模式兼容（无大面积背景色、无纯白文字）
