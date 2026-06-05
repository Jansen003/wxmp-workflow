#!/usr/bin/env bash
# wx-draft.sh — 创建微信公众号草稿
# 用法:
#   bash scripts/wx-draft.sh --title "标题" --content article.html --thumb MEDIA_ID
#   bash scripts/wx-draft.sh --title "标题" --content article.html --thumb MEDIA_ID --author "作者" --digest "摘要"
#
# 参数:
#   --title    文章标题（必填）
#   --content  HTML 文件路径（必填）
#   --thumb    封面图 media_id（必填）
#   --author   作者名（可选，默认读取配置文件）
#   --digest   摘要，120字以内（可选）
#   --comment  是否开启评论 0|1（可选，默认1）
#   --fans-only 仅粉丝可评论 0|1（可选，默认0）
#
# 输出: draft media_id (stdout)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_DIR/config/wxmp.json"

# 解析参数
TITLE=""
CONTENT_FILE=""
THUMB_MEDIA_ID=""
AUTHOR=""
DIGEST=""
COMMENT=1
FANS_ONLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title)     TITLE="$2"; shift 2 ;;
    --content)   CONTENT_FILE="$2"; shift 2 ;;
    --thumb)     THUMB_MEDIA_ID="$2"; shift 2 ;;
    --author)    AUTHOR="$2"; shift 2 ;;
    --digest)    DIGEST="$2"; shift 2 ;;
    --comment)   COMMENT="$2"; shift 2 ;;
    --fans-only) FANS_ONLY="$2"; shift 2 ;;
    *)
      echo "未知参数: $1" >&2
      exit 1
      ;;
  esac
done

# 验证必填参数
if [ -z "$TITLE" ]; then
  echo "❌ 缺少必填参数: --title" >&2
  exit 1
fi
if [ -z "$CONTENT_FILE" ]; then
  echo "❌ 缺少必填参数: --content" >&2
  exit 1
fi
if [ ! -f "$CONTENT_FILE" ]; then
  echo "❌ HTML 文件不存在: $CONTENT_FILE" >&2
  exit 1
fi
if [ -z "$THUMB_MEDIA_ID" ]; then
  echo "❌ 缺少必填参数: --thumb (封面图 media_id)" >&2
  echo "请先用 wx-upload-image.sh 上传封面图获取 media_id" >&2
  exit 1
fi

# 从配置文件读取默认作者
if [ -z "$AUTHOR" ] && [ -f "$CONFIG_FILE" ]; then
  AUTHOR=$(jq -r '.author // ""' "$CONFIG_FILE")
fi

# 读取 HTML 内容
CONTENT=$(cat "$CONTENT_FILE")

# 构建请求 JSON
REQUEST_JSON=$(jq -n \
  --arg title "$TITLE" \
  --arg author "$AUTHOR" \
  --arg digest "$DIGEST" \
  --arg content "$CONTENT" \
  --arg thumb "$THUMB_MEDIA_ID" \
  --argjson comment "$COMMENT" \
  --argjson fans_only "$FANS_ONLY" \
  '{
    articles: [{
      title: $title,
      author: $author,
      content: $content,
      thumb_media_id: $thumb,
      need_open_comment: $comment,
      only_fans_can_comment: $fans_only
    }]
    + (if $digest != "" then {digest: $digest} else {} end)
  }')

# 获取 access_token
ACCESS_TOKEN=$(bash "$SCRIPT_DIR/wx-auth.sh")

# 创建草稿
RESPONSE=$(curl -sf \
  -X POST \
  "https://api.weixin.qq.com/cgi-bin/draft/add?access_token=${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$REQUEST_JSON")

# 检查错误
ERRCODE=$(echo "$RESPONSE" | jq -r '.errcode // empty')
if [ -n "$ERRCODE" ]; then
  ERRMSG=$(echo "$RESPONSE" | jq -r '.errmsg // "unknown error"')
  echo "❌ 创建草稿失败: [$ERRCODE] $ERRMSG" >&2
  exit 1
fi

MEDIA_ID=$(echo "$RESPONSE" | jq -r '.media_id')
if [ -z "$MEDIA_ID" ] || [ "$MEDIA_ID" = "null" ]; then
  echo "❌ 响应中未包含 media_id" >&2
  echo "$RESPONSE" >&2
  exit 1
fi

echo "✅ 草稿已创建" >&2
echo "$MEDIA_ID"
