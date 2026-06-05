# 配置助手

首次使用或需要配置新功能时，引导用户完成前置准备。按需配置，不是所有功能都需要。

## 执行流程

当用户说"帮我配置"时，按以下步骤执行：

### 第 1 步：检查现有配置

读取 `config/wxmp.json`，检查各项配置状态。配置文件支持两个位置，按优先级查找：

1. **当前项目目录**：`{项目}/config/wxmp.json`（用户自己的项目）
2. **Skill 安装目录**：skill 安装位置下的 `config/wxmp.json`（所有项目共享）

配置状态检查：

```
📋 配置检查

| 功能 | 状态 | 说明 |
|------|------|------|
| 公众号 API | ✅ 已配置 / ❌ 未配置 | AppID + Secret，发布必需 |
| Agnes AI | ✅ 已配置 / ❌ 未配置 | 图片生成，可选 |
| Wechatsync | ✅ 已配置 / ❌ 未配置 | 多平台同步，可选 |
```

### 第 2 步：处理必需配置

如果公众号 API 未配置，优先引导配置（发布功能依赖它）。

### 第 3 步：询问可选配置

逐个询问未配置的可选功能：

- Agnes AI："要配置 AI 图片生成吗？可以一句话生成配图。"
- Wechatsync："要配置多平台同步吗？可以把文章一键同步到知乎、掘金等 29+ 平台。"

用户说"要"→ 引导配置；说"不要"→ 跳过，不打扰。

### 第 4 步：确认

配置完成后，再次运行检查，展示最终状态。

## 配置总览

| 功能 | 是否必须 | 需要什么 |
|------|---------|---------|
| 写文章、打磨、排版 | ✅ 必须 | 无，开箱即用 |
| 发布到公众号 | 推荐 | 微信公众号 AppID + Secret |
| AI 生成配图 | 可选 | Agnes AI API Key |
| 同步到其他平台 | 可选 | Wechatsync CLI + Chrome 扩展 |

## 1. 微信公众号 API

用于：自动创建草稿、发布文章、查询数据统计。

### 获取方式

1. 登录 [微信公众平台](https://mp.weixin.qq.com/)
2. 设置与开发 → 基本配置
3. 获取 **开发者ID(AppID)** 和 **开发者密码(AppSecret)**

### 填入配置

选择一个位置创建配置文件（二选一）：

**方式 A：放在项目目录**（推荐，方便管理）
```bash
cp config/wxmp.example.json config/wxmp.json
```

**方式 B：放在 skill 安装目录**（所有项目共享）
```bash
cp config/wxmp.example.json {skill安装目录}/config/wxmp.json
```

编辑 `config/wxmp.json`：
```json
{
  "appid": "你的AppID",
  "secret": "你的AppSecret"
}
```

### 验证

```bash
bash scripts/wx-auth.sh
```

输出 `✅ access_token 获取成功` 即配置正确。

### 常见问题

- `invalid appid` — AppID 填错了，检查是否有多余空格
- `invalid secret` — AppSecret 填错了
- `ip not in whitelist` — 需要在公众号后台配置 IP 白名单（设置与开发 → 基本配置 → IP白名单）

### 没有 API 也能用

不配置 API 时，写文章、打磨、排版都正常工作。只有发布环节需要手动操作：去公众号后台粘贴 HTML 内容。

## 2. Agnes AI（图片生成）

用于：根据文字描述自动生成配图。

### 获取方式

1. 访问 [Agnes AI](https://agnes-ai.com/)
2. 注册账号，获取 API Key

### 填入配置

编辑 `config/wxmp.json`，添加 `agnes_api_key`：
```json
{
  "appid": "...",
  "secret": "...",
  "agnes_api_key": "你的Agnes API Key"
}
```

### 验证

```bash
bash scripts/wx-generate-image.sh --prompt "一只猫" --size 512x512
```

输出图片路径即配置正确。

### 没有 Agnes 也能用

不配置时，配图环节需要用户自己提供图片，或手动在文章中标注图片位置后续补充。

## 3. Wechatsync（多平台同步）

用于：把公众号文章同步到知乎、掘金、CSDN 等 29+ 平台的草稿箱。

### 获取方式

**第一步：安装 CLI**
```bash
npm install -g @wechatsync/cli
```

**第二步：安装 Chrome 扩展**

在 Chrome 网上应用店搜索「文章同步助手」，或访问：
https://chrome.google.com/webstore/detail/hchobocdmclopcbnibdnoafilagadion

**第三步：登录目标平台**

在浏览器里正常登录你要同步的平台（知乎、掘金、CSDN 等）。Wechatsync 使用浏览器已有的 Cookie，不需要额外授权。

**第四步：获取 Token**

在 Chrome 扩展设置中启用「MCP 连接」，记下 Token。

### 配置同步平台

首次同步时告诉 AI 你想同步到哪些平台，会自动写入 `config/wxmp.json`：
```json
{
  "wechatsync_platforms": ["zhihu", "juejin", "csdn"]
}
```

后续说"加一个 XXX 平台"即可更新。

### 验证

```bash
export WECHATSYNC_TOKEN="你的token"
wechatsync platforms --auth
```

显示各平台登录状态即配置正确。

### 常见问题

- CLI 连不上扩展 → 确认 Chrome 扩展已安装且「MCP 连接」已开启
- 平台显示未登录 → 在浏览器里手动登录该平台
- Token 不一致 → CLI 的 `WECHATSYNC_TOKEN` 要和扩展里设置的一致

### 没有 Wechatsync 也能用

不配置时，文章只发布到公众号。想发到其他平台需要手动复制粘贴。

## 快速检查清单

告诉 AI "帮我检查配置" 时，按此清单逐项检查：

```
📋 配置检查

| 功能 | 状态 | 说明 |
|------|------|------|
| 公众号 API | ✅/❌ | 有 AppID + Secret 才能自动发布 |
| Agnes AI | ✅/❌ | 有 API Key 才能 AI 生图 |
| Wechatsync | ✅/❌ | 有 CLI + 扩展才能同步多平台 |
```

## 配置文件模板

完整的 `config/wxmp.json` 示例：

```json
{
  "appid": "wx1234567890abcdef",
  "secret": "your_app_secret_here",
  "author": "你的公众号名称",
  "default_comment": 1,
  "default_fans_only_comment": 0,
  "agnes_api_key": "your_agnes_api_key_here",
  "wechatsync_platforms": ["zhihu", "juejin", "csdn"]
}
```

只有 `appid` 和 `secret` 是发布必需的，其他都是可选功能。
