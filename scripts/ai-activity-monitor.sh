#!/usr/bin/env bash
# AI 助手活动监控 - 追踪 OpenClaw 的 AI 对话和使用情况

FEISHU_WEBHOOK="${FEISHU_WEBHOOK_URL:-https://open.feishu.cn/open-apis/bot/v2/hook/aee95710-e795-4946-ac4e-07aeec5d7e04}"
STATE_DIR="$HOME/.openclaw-dev"

# 统计会话数量
sessions=$(find "$STATE_DIR/agents/dev/sessions" -name "*.json" 2>/dev/null | wc -l | tr -d ' ')

# 统计今日消息数（从日志）
today_messages=0
if [ -f "/tmp/openclaw-gateway.log" ]; then
  today_messages=$(grep "$(date '+%Y-%m-%d')" /tmp/openclaw-gateway.log | grep -c "message" || echo "0")
fi

# 检查最近使用的频道
active_channels=$(pnpm openclaw --dev status 2>&1 | grep "│.*│.*enabled" | wc -l | tr -d ' ')

report="🤖 AI 助手活动报告\n\n"
report+="💬 活跃会话: $sessions 个\n"
report+="📨 今日消息: $today_messages 条\n"
report+="🔌 活跃频道: $active_channels 个\n\n"
report+="⏰ $(date '+%Y-%m-%d %H:%M:%S')"

curl -s -X POST "$FEISHU_WEBHOOK" \
  -H "Content-Type: application/json" \
  -d "{\"msg_type\":\"text\",\"content\":{\"text\":\"$report\"}}" >/dev/null
