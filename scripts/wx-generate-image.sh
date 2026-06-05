#!/usr/bin/env bash
# wx-generate-image.sh — 使用 Agnes AI 生成图片
# 用法:
#   bash scripts/wx-generate-image.sh --prompt "提示词"
#   bash scripts/wx-generate-image.sh --prompt "提示词" --size 1024x768
#   bash scripts/wx-generate-image.sh --prompt "提示词" --output /path/to/output.png
#
# 参数:
#   --prompt   图片生成提示词（必填）
#   --size     输出尺寸，默认 1024x768（可选）
#   --output   输出文件路径，默认 output/agnes-{timestamp}.png（可选）
#
# 配置: 需要在 config/wxmp.json 中配置 agnes_api_key
#
# 输出: 图片文件路径（stdout）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# 配置文件查找：当前目录优先，skill 目录兜底
if [ -f "$PWD/config/wxmp.json" ]; then
  CONFIG_FILE="$PWD/config/wxmp.json"
else
  CONFIG_FILE="$PROJECT_DIR/config/wxmp.json"
fi

# 解析参数
PROMPT=""
SIZE="1024x768"
OUTPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prompt) PROMPT="$2"; shift 2 ;;
    --size)   SIZE="$2"; shift 2 ;;
    --output) OUTPUT="$2"; shift 2 ;;
    *)
      echo "未知参数: $1" >&2
      exit 1
      ;;
  esac
done

# 验证必填参数
if [ -z "$PROMPT" ]; then
  echo "❌ 缺少必填参数: --prompt" >&2
  echo "用法: bash scripts/wx-generate-image.sh --prompt \"图片描述\"" >&2
  exit 1
fi

# 读取配置
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ 配置文件不存在: $CONFIG_FILE" >&2
  exit 1
fi

API_KEY=$(jq -r '.agnes_api_key // empty' "$CONFIG_FILE")
if [ -z "$API_KEY" ]; then
  echo "❌ 未配置 Agnes API Key" >&2
  echo "请在 config/wxmp.json 中添加 agnes_api_key 字段" >&2
  echo "获取方式: https://agnes-ai.com" >&2
  exit 1
fi

# 设置默认输出路径
if [ -z "$OUTPUT" ]; then
  TIMESTAMP=$(date +%Y%m%d%H%M%S)
  OUTPUT="$PROJECT_DIR/output/agnes-${TIMESTAMP}.png"
fi

# 确保输出目录存在
mkdir -p "$(dirname "$OUTPUT")"

echo "🎨 正在生成图片..." >&2
echo "   提示词: $PROMPT" >&2
echo "   尺寸: $SIZE" >&2

# 调用 Agnes API
RESPONSE=$(curl -sf \
  --max-time 120 \
  -X POST \
  "https://apihub.agnes-ai.com/v1/images/generations" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$(jq -n \
    --arg model "agnes-image-2.1-flash" \
    --arg prompt "$PROMPT" \
    --arg size "$SIZE" \
    '{
      model: $model,
      prompt: $prompt,
      size: $size,
      extra_body: {
        response_format: "url"
      }
    }')")

# 检查错误
if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
  ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error.message // .error // "unknown error"')
  echo "❌ 生成失败: $ERROR_MSG" >&2
  exit 1
fi

# 提取图片 URL
IMAGE_URL=$(echo "$RESPONSE" | jq -r '.data[0].url // empty')
if [ -z "$IMAGE_URL" ]; then
  echo "❌ 响应中未包含图片 URL" >&2
  echo "$RESPONSE" >&2
  exit 1
fi

# 下载图片
echo "📥 下载图片..." >&2
curl -sf -o "$OUTPUT" "$IMAGE_URL"

if [ ! -f "$OUTPUT" ]; then
  echo "❌ 图片下载失败" >&2
  exit 1
fi

FILE_SIZE=$(stat -f%z "$OUTPUT" 2>/dev/null || stat --printf="%s" "$OUTPUT" 2>/dev/null)
echo "✅ 图片已生成: $OUTPUT (${FILE_SIZE} bytes)" >&2

echo "$OUTPUT"
