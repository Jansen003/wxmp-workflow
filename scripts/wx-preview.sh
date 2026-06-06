#!/usr/bin/env bash
# wx-preview.sh — 发送草稿预览到指定微信号
# 用法: bash scripts/wx-preview.sh --media-id DRAFT_MEDIA_ID --wx-name 微信号
#
# 参数:
#   --media-id  草稿的 media_id（必填）
#   --wx-name   接收预览的微信号（必填）
#
# 说明: 调用微信 message/mass/preview 接口，将草稿发送到指定微信号预览。
#       需要公众号有消息推送权限（个人订阅号可能无此权限，需引导用户手动预览）。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 解析参数
MEDIA_ID=""
WX_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --media-id) MEDIA_ID="$2"; shift 2 ;;
    --wx-name)  WX_NAME="$2"; shift 2 ;;
    *)
      echo "未知参数: $1" >&2
      exit 1
      ;;
  esac
done

# 验证必填参数
if [ -z "$MEDIA_ID" ]; then
  echo "❌ 缺少必填参数: --media-id" >&2
  exit 1
fi
if [ -z "$WX_NAME" ]; then
  echo "❌ 缺少必填参数: --wx-name" >&2
  echo "用法: bash scripts/wx-preview.sh --media-id MEDIA_ID --wx-name 微信号" >&2
  exit 1
fi

# 获取 access_token
ACCESS_TOKEN=$(bash "$SCRIPT_DIR/wx-auth.sh")

# 发送预览
RESPONSE=$(curl -s \
  -X POST \
  "https://api.weixin.qq.com/cgi-bin/message/mass/preview?access_token=${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"towxname\": \"${WX_NAME}\", \"msgtype\": \"mpnews\", \"mpnews\": {\"media_id\": \"${MEDIA_ID}\"}}")

if [ -z "$RESPONSE" ]; then
  echo "❌ 预览发送失败: 服务器无响应" >&2
  exit 1
fi

# 检查错误
ERRCODE=$(echo "$RESPONSE" | jq -r '.errcode // empty')
if [ -n "$ERRCODE" ] && [ "$ERRCODE" != "0" ]; then
  ERRMSG=$(echo "$RESPONSE" | jq -r '.errmsg // "unknown error"')
  echo "❌ 预览发送失败: [$ERRCODE] $ERRMSG" >&2
  if [ "$ERRCODE" = "48001" ]; then
    echo "提示: 该公众号无消息推送权限，请到公众号后台手动预览" >&2
  fi
  exit 1
fi

echo "✅ 预览已发送到微信号: $WX_NAME" >&2
echo "请在微信中查看并确认文章效果" >&2
