#!/usr/bin/env bash
# wx-articles.sh — 获取已发布文章列表
# 用法:
#   bash scripts/wx-articles.sh                   # 获取最近20篇
#   bash scripts/wx-articles.sh --count 20        # 获取20篇（单次上限）
#   bash scripts/wx-articles.sh --offset 20       # 跳过前20篇，获取下一批
#   bash scripts/wx-articles.sh --content         # 包含文章内容
#
# 参数:
#   --count    返回数量，1-20，默认20（可选）
#   --offset   偏移量，默认0（可选）
#   --content  是否返回文章内容，默认不返回（可选）
#
# 输出: 已发布文章列表（JSON）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 解析参数
COUNT=20
OFFSET=0
NO_CONTENT=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --count)   COUNT="$2"; shift 2 ;;
    --offset)  OFFSET="$2"; shift 2 ;;
    --content) NO_CONTENT=0; shift ;;
    *)
      echo "未知参数: $1" >&2
      exit 1
      ;;
  esac
done

# 参数校验
if [ "$COUNT" -lt 1 ] || [ "$COUNT" -gt 20 ]; then
  echo "❌ --count 取值范围 1-20" >&2
  exit 1
fi

# 获取 access_token
ACCESS_TOKEN=$(bash "$SCRIPT_DIR/wx-auth.sh")

# 查询已发布文章
RESPONSE=$(curl -sf \
  -X POST \
  "https://api.weixin.qq.com/cgi-bin/freepublish/batchget?access_token=${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"offset\": ${OFFSET}, \"count\": ${COUNT}, \"no_content\": ${NO_CONTENT}}")

# 检查错误
ERRCODE=$(echo "$RESPONSE" | jq -r '.errcode // empty')
if [ -n "$ERRCODE" ]; then
  ERRMSG=$(echo "$RESPONSE" | jq -r '.errmsg // "unknown error"')
  echo "❌ 查询失败: [$ERRCODE] $ERRMSG" >&2
  exit 1
fi

TOTAL=$(echo "$RESPONSE" | jq -r '.total_count // 0')
ITEM_COUNT=$(echo "$RESPONSE" | jq -r '.item_count // 0')

if [ "$ITEM_COUNT" -eq 0 ]; then
  echo "📭 没有已发布的文章" >&2
  exit 0
fi

echo "📚 已发布文章（共 ${TOTAL} 篇，本次返回 ${ITEM_COUNT} 篇）" >&2
echo "" >&2

# 输出文章列表
echo "$RESPONSE" | jq -r '
  .item[] |
  "ID: \(.article_id)
  更新时间: \(.update_time | todate)
  └─ 文章数: \(.content.news_item | length)
  \(.content.news_item | to_entries[] | "   \(.key + 1). \(.value.title)")
  "
'
