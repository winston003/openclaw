#!/bin/bash
FEISHU_WEBHOOK="${FEISHU_WEBHOOK_URL:-https://open.feishu.cn/open-apis/bot/v2/hook/aee95710-e795-4946-ac4e-07aeec5d7e04}"
SILICONFLOW_KEY="sk-etdxbplklpnodggbjjhivuxgnoltvduqlzhcjhrdhucqgulq"

# Fetch GitHub data
issues=$(curl -s "https://api.github.com/repos/openclaw/openclaw/issues?state=open&per_page=3" | jq -r '.[].title' | head -3 | tr '\n' ' ')
commits=$(curl -s "https://api.github.com/repos/openclaw/openclaw/commits?per_page=3" | jq -r '.[].commit.message' | head -3 | cut -d$'\n' -f1 | tr '\n' ' ')

# Call LLM
content="用中文总结以下 OpenClaw 动态，分3点：Issues: ${issues}. Commits: ${commits}"
payload=$(jq -n --arg c "$content" '{model:"Qwen/Qwen2.5-7B-Instruct",messages:[{role:"user",content:$c}],max_tokens:300}')

summary=$(echo "$payload" | curl -s https://api.siliconflow.cn/v1/chat/completions \
    -H "Authorization: Bearer ${SILICONFLOW_KEY}" \
    -H "Content-Type: application/json" \
    -d @- | jq -r '.choices[0].message.content // "无摘要"')

# Send to Feishu
msg="📰 OpenClaw 新闻播报\n━━━━━━━━━━━━━━━━━━━━\n\n${summary}\n\n━━━━━━━━━━━━━━━━━━━━\n⏰ $(date '+%Y-%m-%d %H:%M')"

curl -s -X POST "${FEISHU_WEBHOOK}" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg t "$msg" '{msg_type:"text",content:{text:$t}}')"

echo "✅ Sent"
