#!/bin/bash
# GitHub Watch - Monitor OpenClaw repository

CACHE_DIR="${HOME}/.openclaw-dev/github-cache"
FEISHU_WEBHOOK="${FEISHU_WEBHOOK_URL:-https://open.feishu.cn/open-apis/bot/v2/hook/aee95710-e795-4946-ac4e-07aeec5d7e04}"
SILICONFLOW_KEY="sk-etdxbplklpnodggbjjhivuxgnoltvduqlzhcjhrdhucqgulq"

mkdir -p "${CACHE_DIR}"

if [[ "$1" == "daily-summary" ]]; then
    today=$(date +"%Y-%m-%d")
    commits=$(curl -s "https://api.github.com/repos/openclaw/openclaw/commits?since=${today}T00:00:00Z")
    count=$(echo "${commits}" | jq 'length')
    
    [[ ${count} -gt 0 ]] && {
        messages=$(echo "${commits}" | jq -r '.[].commit.message' | head -5)
        summary=$(curl -s https://api.siliconflow.cn/v1/chat/completions \
            -H "Authorization: Bearer ${SILICONFLOW_KEY}" \
            -H "Content-Type: application/json" \
            -d "{\"model\":\"Qwen/Qwen2.5-7B-Instruct\",\"messages\":[{\"role\":\"user\",\"content\":\"总结以下提交，中文，3句话：\n${messages}\"}],\"max_tokens\":200}" \
            | jq -r '.choices[0].message.content')
        
        [[ -n "${FEISHU_WEBHOOK}" ]] && curl -s -X POST "${FEISHU_WEBHOOK}" \
            -H "Content-Type: application/json" \
            -d "{\"msg_type\":\"text\",\"content\":{\"text\":\"📊 OpenClaw 今日汇总 (${count} commits)\n\n${summary}\"}}"
    }
else
    since=$(cat "${CACHE_DIR}/last-check.txt" 2>/dev/null || date -u -v-2H +"%Y-%m-%dT%H:%M:%SZ")
    commits=$(curl -s "https://api.github.com/repos/openclaw/openclaw/commits?since=${since}&per_page=10")
    count=$(echo "${commits}" | jq 'length')
    
    [[ ${count} -gt 0 ]] && {
        date -u +"%Y-%m-%dT%H:%M:%SZ" > "${CACHE_DIR}/last-check.txt"
        messages=$(echo "${commits}" | jq -r '.[].commit.message' | head -5)
        summary=$(curl -s https://api.siliconflow.cn/v1/chat/completions \
            -H "Authorization: Bearer ${SILICONFLOW_KEY}" \
            -H "Content-Type: application/json" \
            -d "{\"model\":\"Qwen/Qwen2.5-7B-Instruct\",\"messages\":[{\"role\":\"user\",\"content\":\"总结以下提交，中文，3句话：\n${messages}\"}],\"max_tokens\":200}" \
            | jq -r '.choices[0].message.content')
        
        [[ -n "${FEISHU_WEBHOOK}" ]] && curl -s -X POST "${FEISHU_WEBHOOK}" \
            -H "Content-Type: application/json" \
            -d "{\"msg_type\":\"text\",\"content\":{\"text\":\"🔔 OpenClaw 更新 (${count} commits)\n\n${summary}\"}}"
        
        echo "✅ Found ${count} updates"
    }
fi
