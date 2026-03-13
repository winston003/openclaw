#!/usr/bin/env bash
# OpenClaw 自愈系统 - 检测问题并自动修复

FEISHU_WEBHOOK="${FEISHU_WEBHOOK_URL}"
REPO_DIR="/Users/whilewon/workspace/openclaw"

send_alert() {
  curl -s -X POST "$FEISHU_WEBHOOK" \
    -H "Content-Type: application/json" \
    -d "{\"msg_type\":\"text\",\"content\":{\"text\":\"🚨 自愈系统\n\n$1\"}}" >/dev/null
}

# 检测 Gateway 是否挂掉
if ! lsof -ti :19001 >/dev/null 2>&1; then
  send_alert "Gateway 已停止，正在重启..."
  cd "$REPO_DIR" && ./scripts/dev-restart.sh
  exit 0
fi

# 检测内存是否过高
pid=$(lsof -ti :19001 2>/dev/null)
if [ -n "$pid" ]; then
  mem=$(ps -o rss= -p "$pid" 2>/dev/null | awk '{print int($1/1024)}')
  if [ -n "$mem" ] && [ "$mem" -gt 1000 ]; then
    send_alert "内存使用 ${mem}MB，正在重启..."
    cd "$REPO_DIR" && ./scripts/dev-restart.sh
  fi
fi
