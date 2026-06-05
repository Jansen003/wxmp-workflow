#!/usr/bin/env bash
# wx-publish.sh — 发布微信公众号草稿
# 用法: bash scripts/wx-publish.sh --media-id DRAFT_MEDIA_ID
#
# 参数:
#   --media-id   草稿的 media_id（必填）
#   --wait       是否等待发布完成，默认 true
#   --timeout    等待超时秒数，默认 120
#
# 输出: 文章 URL（发布成功后）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 解析参数
MEDIA_ID=""
WAIT="true"
TIMEOUT=120

while [[ $# -gt 0 ]]; do
  case "$1" in
    --media-id) MEDIA_ID="$2"; shift 2 ;;
    --wait)     WAIT="$2"; shift 2 ;;
    --timeout)  TIMEOUT="$2"; shift 2 ;;
    *)
      echo "未知参数: $1" >&2
      exit 1
      ;;
  esac
done

if [ -z "$MEDIA_ID" ]; then
  echo "❌ 缺少必填参数: --media-id" >&2
  exit 1
fi

# 获取 access_token
ACCESS_TOKEN=$(bash "$SCRIPT_DIR/wx-auth.sh")

# 提交发布
RESPONSE=$(curl -sf \
  -X POST \
  "https://api.weixin.qq.com/cgi-bin/freepublish/submit?access_token=${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"media_id\": \"${MEDIA_ID}\"}")

ERRCODE=$(echo "$RESPONSE" | jq -r '.errcode // empty')
if [ -n "$ERRCODE" ]; then
  ERRMSG=$(echo "$RESPONSE" | jq -r '.errmsg // "unknown error"')
  echo "❌ 提交发布失败: [$ERRCODE] $ERRMSG" >&2
  exit 1
fi

PUBLISH_ID=$(echo "$RESPONSE" | jq -r '.publish_id')
if [ -z "$PUBLISH_ID" ] || [ "$PUBLISH_ID" = "null" ]; then
  echo "❌ 响应中未包含 publish_id" >&2
  echo "$RESPONSE" >&2
  exit 1
fi

echo "📤 发布已提交，publish_id: $PUBLISH_ID" >&2

# 等待发布完成
if [ "$WAIT" != "true" ]; then
  echo "$PUBLISH_ID"
  exit 0
fi

ELAPSED=0
INTERVAL=5

while [ "$ELAPSED" -lt "$TIMEOUT" ]; do
  sleep "$INTERVAL"
  ELAPSED=$((ELAPSED + INTERVAL))

  STATUS_RESPONSE=$(curl -sf \
    -X POST \
    "https://api.weixin.qq.com/cgi-bin/freepublish/get?access_token=${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"publish_id\": \"${PUBLISH_ID}\"}")

  PUBLISH_STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.publish_status // -1')

  case "$PUBLISH_STATUS" in
    0)
      # 发布成功
      ARTICLE_URL=$(echo "$STATUS_RESPONSE" | jq -r '.article_detail.item[0].article_url // empty')
      ARTICLE_ID=$(echo "$STATUS_RESPONSE" | jq -r '.article_id // empty')
      echo "✅ 发布成功！" >&2
      if [ -n "$ARTICLE_ID" ]; then
        echo "   文章 ID: $ARTICLE_ID" >&2
      fi
      if [ -n "$ARTICLE_URL" ]; then
        echo "   文章链接: $ARTICLE_URL" >&2
      fi
      echo "$ARTICLE_URL"
      exit 0
      ;;
    1)
      echo "⏳ 发布中... (${ELAPSED}s)" >&2
      ;;
    *)
      # 发布失败
      ERRMSG=$(echo "$STATUS_RESPONSE" | jq -r '.errmsg // "unknown error"')
      echo "❌ 发布失败: $ERRMSG" >&2
      echo "$STATUS_RESPONSE" >&2
      exit 1
      ;;
  esac
done

echo "⏰ 等待超时（${TIMEOUT}s），请稍后手动检查发布状态" >&2
echo "   publish_id: $PUBLISH_ID" >&2
exit 1
