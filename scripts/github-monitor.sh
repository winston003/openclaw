#!/usr/bin/env bash
# GitHub 更新监控脚本 - 检查新的 commits 并通过飞书通知

REPO_DIR="/Users/whilewon/workspace/openclaw"
FEISHU_WEBHOOK="${FEISHU_WEBHOOK_URL:-https://open.feishu.cn/open-apis/bot/v2/hook/aee95710-e795-4946-ac4e-07aeec5d7e04}"
STATE_FILE="$HOME/.openclaw-dev/github-monitor-state.txt"

cd "$REPO_DIR" || exit 1

# 获取当前 HEAD
current_head=$(git rev-parse HEAD)

# 读取上次检查的 HEAD
if [ -f "$STATE_FILE" ]; then
  last_head=$(cat "$STATE_FILE")
else
  last_head="$current_head"
  echo "$current_head" > "$STATE_FILE"
  echo "首次运行，已记录当前状态"
  exit 0
fi

# 拉取最新代码
git fetch origin main >/dev/null 2>&1

# 检查是否有新提交
new_commits=$(git log --oneline "$last_head..origin/main" 2>/dev/null)

if [ -z "$new_commits" ]; then
  echo "没有新的提交"
  exit 0
fi

# 构建通知消息
commit_count=$(echo "$new_commits" | wc -l | tr -d ' ')
message="📢 OpenClaw 有 $commit_count 个新提交\n\n"
message+="$new_commits\n\n"
message+="🔗 查看: https://github.com/openclaw/openclaw/commits/main"

# 发送飞书通知
curl -s -X POST "$FEISHU_WEBHOOK" \
  -H "Content-Type: application/json" \
  -d "{\"msg_type\":\"text\",\"content\":{\"text\":\"$message\"}}" >/dev/null

# 更新状态
git rev-parse origin/main > "$STATE_FILE"

echo "✅ 已通知 $commit_count 个新提交"
