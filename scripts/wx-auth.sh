#!/usr/bin/env bash
# wx-auth.sh — 获取并缓存微信公众号 access_token
# 用法: bash scripts/wx-auth.sh
# 输出: access_token 字符串（stdout）
# 缓存: /tmp/wxmp-token.json（2小时有效）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_DIR/config/wxmp.json"
TOKEN_CACHE="/tmp/wxmp-token.json"

# 读取配置
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ 配置文件不存在: $CONFIG_FILE" >&2
  echo "请复制 config/wxmp.example.json 为 config/wxmp.json 并填入 AppID 和 Secret" >&2
  exit 1
fi

APPID=$(jq -r '.appid' "$CONFIG_FILE")
SECRET=$(jq -r '.secret' "$CONFIG_FILE")

if [ "$APPID" = "YOUR_APPID_HERE" ] || [ "$SECRET" = "YOUR_SECRET_HERE" ]; then
  echo "❌ 请先在 config/wxmp.json 中填入真实的 AppID 和 Secret" >&2
  exit 1
fi

# 检查缓存是否有效
if [ -f "$TOKEN_CACHE" ]; then
  CACHED_TIME=$(jq -r '.cached_at // 0' "$TOKEN_CACHE" 2>/dev/null || echo 0)
  NOW=$(date +%s)
  ELAPSED=$((NOW - CACHED_TIME))

  # token 有效期 7200 秒，提前 300 秒刷新
  if [ "$ELAPSED" -lt 6900 ]; then
    TOKEN=$(jq -r '.access_token' "$TOKEN_CACHE" 2>/dev/null)
    if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
      echo "$TOKEN"
      exit 0
    fi
  fi
fi

# 请求新 token
RESPONSE=$(curl -sf "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=${APPID}&secret=${SECRET}")

# 检查错误
ERRCODE=$(echo "$RESPONSE" | jq -r '.errcode // empty')
if [ -n "$ERRCODE" ]; then
  ERRMSG=$(echo "$RESPONSE" | jq -r '.errmsg // "unknown error"')
  echo "❌ 获取 token 失败: [$ERRCODE] $ERRMSG" >&2
  exit 1
fi

TOKEN=$(echo "$RESPONSE" | jq -r '.access_token')
if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  echo "❌ 响应中未包含 access_token" >&2
  echo "$RESPONSE" >&2
  exit 1
fi

# 写入缓存
NOW=$(date +%s)
echo "$RESPONSE" | jq --arg ts "$NOW" '. + {cached_at: ($ts | tonumber)}' > "$TOKEN_CACHE"

echo "$TOKEN"
