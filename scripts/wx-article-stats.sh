#!/usr/bin/env bash
# wx-article-stats.sh — 查询单篇文章详细数据统计
# 用法:
#   bash scripts/wx-article-stats.sh --date 2026-06-05
#   bash scripts/wx-article-stats.sh --recent 7
#
# 参数:
#   --date    指定日期 YYYY-MM-DD（可选）
#   --recent  最近N天（可选，与 date 互斥）
#
# 注意: 微信 API 单次最多查询 7 天的数据，数据有约1天延迟

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 解析参数
TARGET_DATE=""
RECENT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --date)   TARGET_DATE="$2"; shift 2 ;;
    --recent) RECENT="$2"; shift 2 ;;
    *)
      echo "未知参数: $1" >&2
      exit 1
      ;;
  esac
done

# 计算日期范围
if [ -n "$RECENT" ]; then
  END_DATE=$(date +%Y-%m-%d)
  # macOS: date -v; Linux: date -d
  # --recent 7 表示最近 7 天：今天到 6 天前（与 wx-stats.sh 语义一致）
  BEGIN_DATE=$(date -v-"$((RECENT - 1))"d +%Y-%m-%d 2>/dev/null || date -d "-$((RECENT - 1)) days" +%Y-%m-%d 2>/dev/null)
elif [ -n "$TARGET_DATE" ]; then
  BEGIN_DATE="$TARGET_DATE"
  END_DATE="$TARGET_DATE"
else
  echo "❌ 请指定日期: --date YYYY-MM-DD 或 --recent N" >&2
  exit 1
fi

# 校验时间跨度（最多7天）
BEGIN_TS=$(date -jf "%Y-%m-%d" "$BEGIN_DATE" +%s 2>/dev/null || date -d "$BEGIN_DATE" +%s 2>/dev/null)
END_TS=$(date -jf "%Y-%m-%d" "$END_DATE" +%s 2>/dev/null || date -d "$END_DATE" +%s 2>/dev/null)
DIFF_DAYS=$(( (END_TS - BEGIN_TS) / 86400 ))

if [ "$DIFF_DAYS" -gt 7 ]; then
  echo "❌ 时间跨度不能超过7天（当前: ${DIFF_DAYS} 天）" >&2
  exit 1
fi

echo "📊 查询单篇文章数据: ${BEGIN_DATE} ~ ${END_DATE}" >&2
echo "" >&2

# 获取 access_token
ACCESS_TOKEN=$(bash "$SCRIPT_DIR/wx-auth.sh")

# 查询单篇文章详细数据
RESPONSE=$(curl -sf \
  -X POST \
  "https://api.weixin.qq.com/datacube/getarticletotal?access_token=${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"begin_date\": \"${BEGIN_DATE}\", \"end_date\": \"${END_DATE}\"}")

# 检查错误
ERRCODE=$(echo "$RESPONSE" | jq -r '.errcode // empty')
if [ -n "$ERRCODE" ]; then
  ERRMSG=$(echo "$RESPONSE" | jq -r '.errmsg // "unknown error"')
  echo "❌ 查询失败: [$ERRCODE] $ERRMSG" >&2
  echo "注意：统计数据通常有1天延迟，且最多查询7天范围" >&2
  exit 1
fi

ITEM_COUNT=$(echo "$RESPONSE" | jq '.list | length')
if [ "$ITEM_COUNT" -eq 0 ]; then
  echo "📭 该时间段内没有数据" >&2
  exit 0
fi

# 输出文章列表和最新数据
echo "$RESPONSE" | jq -r '
  .list[] |
  "────────────────────────
  文章ID: \(.msgid)
  标题: \(.title)
  \(
    .details | last |
    "├─ 送达人数: \(.target_user // 0)
    ├─ 阅读人数: \(.int_page_read_user // 0)
    ├─ 阅读次数: \(.int_page_read_count // 0)
    ├─ 分享人数: \(.share_user // 0)
    ├─ 分享次数: \(.share_count // 0)
    ├─ 收藏人数: \(.add_to_fav_user // 0)
    └─ 收藏次数: \(.add_to_fav_count // 0)"
  )
  "'
