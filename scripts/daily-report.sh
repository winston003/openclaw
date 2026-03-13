#!/usr/bin/env bash
# 每日开发报告 - 汇总一天的开发活动

FEISHU_WEBHOOK="${FEISHU_WEBHOOK_URL:-https://open.feishu.cn/open-apis/bot/v2/hook/aee95710-e795-4946-ac4e-07aeec5d7e04}"
REPO_DIR="/Users/whilewon/workspace/openclaw"

cd "$REPO_DIR"

# 今日提交统计
today_commits=$(git log --since="midnight" --oneline | wc -l | tr -d ' ')
today_files=$(git log --since="midnight" --name-only --pretty=format: | sort -u | wc -l | tr -d ' ')

# 代码行数变化
lines_added=$(git log --since="midnight" --numstat --pretty="%H" | awk '{add+=$1} END {print add+0}')
lines_deleted=$(git log --since="midnight" --numstat --pretty="%H" | awk '{del+=$2} END {print del+0}')

# Gateway 运行时长
gateway_pid=$(lsof -ti :19001 2>/dev/null)
uptime="未运行"
if [ -n "$gateway_pid" ]; then
  uptime=$(ps -o etime= -p "$gateway_pid" | tr -d ' ')
fi

# 构建报告
report="📊 OpenClaw 每日开发报告\n"
report+="📅 日期: $(date '+%Y-%m-%d')\n\n"
report+="💻 代码统计:\n"
report+="  • 提交次数: $today_commits\n"
report+="  • 修改文件: $today_files\n"
report+="  • 新增代码: +$lines_added 行\n"
report+="  • 删除代码: -$lines_deleted 行\n\n"
report+="🚀 Gateway 状态:\n"
report+="  • 运行时长: $uptime\n\n"
report+="💪 继续加油！"

curl -s -X POST "$FEISHU_WEBHOOK" \
  -H "Content-Type: application/json" \
  -d "{\"msg_type\":\"text\",\"content\":{\"text\":\"$report\"}}" >/dev/null

echo "✅ 每日报告已发送"
