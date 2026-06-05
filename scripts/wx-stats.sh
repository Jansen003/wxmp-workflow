#!/usr/bin/env bash
# wx-stats.sh — 查询微信公众号文章数据统计
# 用法:
#   bash scripts/wx-stats.sh --date 2026-06-05          # 指定某天
#   bash scripts/wx-stats.sh --recent 7                  # 最近7天（逐天查询）
#
# 参数:
#   --date    指定日期 YYYY-MM-DD（可选）
#   --recent  最近N天（可选，与 date 互斥）
#
# 注意: 微信 API 单次最多查询 1 天的数据，脚本会自动按天循环查询

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

# 计算日期列表
DATES=()
if [ -n "$RECENT" ]; then
  for i in $(seq 0 $((RECENT - 1))); do
    DATES+=("$(date -v-"${i}"d +%Y-%m-%d 2>/dev/null || date -d "-${i} days" +%Y-%m-%d 2>/dev/null)")
  done
elif [ -n "$TARGET_DATE" ]; then
  DATES+=("$TARGET_DATE")
else
  echo "❌ 请指定日期: --date YYYY-MM-DD 或 --recent N" >&2
  exit 1
fi

# 获取 access_token
ACCESS_TOKEN=$(bash "$SCRIPT_DIR/wx-auth.sh")

# 逐天查询
echo "📊 查询数据统计: ${DATES[-1]} ~ ${DATES[0]}" >&2
echo "" >&2

TOTAL_READS=0
TOTAL_SHARES=0
TOTAL_FAVS=0
HAS_DATA=false

for DATE in "${DATES[@]}"; do
  RESPONSE=$(curl -sf \
    -X POST \
    "https://api.weixin.qq.com/datacube/getarticlesummary?access_token=${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"begin_date\": \"${DATE}\", \"end_date\": \"${DATE}\"}")

  ERRCODE=$(echo "$RESPONSE" | jq -r '.errcode // empty')
  if [ -n "$ERRCODE" ]; then
    ERRMSG=$(echo "$RESPONSE" | jq -r '.errmsg // "unknown error"')
    echo "⚠️  查询 ${DATE} 失败: [$ERRCODE] $ERRMSG" >&2
    continue
  fi

  ITEM_COUNT=$(echo "$RESPONSE" | jq '.list | length')
  if [ "$ITEM_COUNT" -eq 0 ]; then
    continue
  fi

  HAS_DATA=true

  # 输出当天数据
  echo "$RESPONSE" | jq -r '
    .list[] |
    "日期: \(.ref_date)
    ├─ 阅读人数: \(.int_page_read_user // 0)
    ├─ 阅读次数: \(.int_page_read_count // 0)
    ├─ 分享人数: \(.share_user // 0)
    ├─ 分享次数: \(.share_count // 0)
    ├─ 收藏人数: \(.add_to_fav_user // 0)
    └─ 收藏次数: \(.add_to_fav_count // 0)
    "'

  # 累加汇总
  DAY_READS=$(echo "$RESPONSE" | jq '[.list[].int_page_read_user // 0] | add')
  DAY_SHARES=$(echo "$RESPONSE" | jq '[.list[].share_user // 0] | add')
  DAY_FAVS=$(echo "$RESPONSE" | jq '[.list[].add_to_fav_user // 0] | add')
  TOTAL_READS=$((TOTAL_READS + DAY_READS))
  TOTAL_SHARES=$((TOTAL_SHARES + DAY_SHARES))
  TOTAL_FAVS=$((TOTAL_FAVS + DAY_FAVS))
done

if [ "$HAS_DATA" = false ]; then
  echo "📭 该时间段内没有数据" >&2
  echo "注意：统计数据通常有1天延迟" >&2
  exit 0
fi

echo "────────────────────────"
echo "汇总:
├─ 总阅读人数: ${TOTAL_READS}
├─ 总分享人数: ${TOTAL_SHARES}
└─ 总收藏人数: ${TOTAL_FAVS}"
