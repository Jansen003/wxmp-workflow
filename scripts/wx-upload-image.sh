#!/usr/bin/env bash
# wx-upload-image.sh — 上传图片素材到微信公众号
# 用法: bash scripts/wx-upload-image.sh <image_path> [type]
#   type: image (默认，正文图片) 或 thumb (封面图)
# 输出: media_id (stdout)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

IMAGE_PATH="${1:-}"
TYPE="${2:-image}"

if [ -z "$IMAGE_PATH" ]; then
  echo "用法: bash scripts/wx-upload-image.sh <图片路径> [image|thumb]" >&2
  exit 1
fi

if [ ! -f "$IMAGE_PATH" ]; then
  echo "❌ 文件不存在: $IMAGE_PATH" >&2
  exit 1
fi

# 检查文件大小（微信限制 10MB）
FILE_SIZE=$(stat -f%z "$IMAGE_PATH" 2>/dev/null || stat --printf="%s" "$IMAGE_PATH" 2>/dev/null)
if [ "$FILE_SIZE" -gt 10485760 ]; then
  echo "❌ 图片文件超过 10MB 限制: ${FILE_SIZE} bytes" >&2
  exit 1
fi

# 获取 access_token
ACCESS_TOKEN=$(bash "$SCRIPT_DIR/wx-auth.sh")

# 上传素材
RESPONSE=$(curl -sf \
  -X POST \
  "https://api.weixin.qq.com/cgi-bin/material/add_material?access_token=${ACCESS_TOKEN}&type=${TYPE}" \
  -F "media=@${IMAGE_PATH}")

# 检查错误
ERRCODE=$(echo "$RESPONSE" | jq -r '.errcode // empty')
if [ -n "$ERRCODE" ]; then
  ERRMSG=$(echo "$RESPONSE" | jq -r '.errmsg // "unknown error"')
  echo "❌ 上传失败: [$ERRCODE] $ERRMSG" >&2
  exit 1
fi

MEDIA_ID=$(echo "$RESPONSE" | jq -r '.media_id')
if [ -z "$MEDIA_ID" ] || [ "$MEDIA_ID" = "null" ]; then
  echo "❌ 响应中未包含 media_id" >&2
  echo "$RESPONSE" >&2
  exit 1
fi

# 如果是正文图片，同时输出 url
if [ "$TYPE" = "image" ]; then
  URL=$(echo "$RESPONSE" | jq -r '.url // empty')
  if [ -n "$URL" ]; then
    echo "📎 图片已上传: $URL" >&2
  fi
fi

echo "$MEDIA_ID"
