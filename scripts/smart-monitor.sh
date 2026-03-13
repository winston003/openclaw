#!/usr/bin/env bash
# OpenClaw 智能监控套件 - 多种监控场景

FEISHU_WEBHOOK="${FEISHU_WEBHOOK_URL:-https://open.feishu.cn/open-apis/bot/v2/hook/aee95710-e795-4946-ac4e-07aeec5d7e04}"
REPO_DIR="/Users/whilewon/workspace/openclaw"

send_feishu() {
  local message="$1"
  curl -s -X POST "$FEISHU_WEBHOOK" \
    -H "Content-Type: application/json" \
    -d "{\"msg_type\":\"text\",\"content\":{\"text\":\"$message\"}}" >/dev/null
}

# 1. 依赖更新监控
check_dependencies() {
  cd "$REPO_DIR"
  local outdated=$(pnpm outdated --format json 2>/dev/null | grep -c '"current"')

  if [ "$outdated" -gt 0 ]; then
    send_feishu "📦 发现 $outdated 个依赖包有更新\n运行: pnpm outdated"
  fi
}

# 2. 磁盘空间监控
check_disk_space() {
  local usage=$(df -h "$HOME" | awk 'NR==2 {print $5}' | sed 's/%//')

  if [ -n "$usage" ] && [ "$usage" -gt 80 ]; then
    send_feishu "⚠️ 磁盘空间不足\n使用率: ${usage}%\n建议清理"
  fi
}

# 3. Gateway 内存监控
check_gateway_memory() {
  local pid=$(lsof -ti :19001 2>/dev/null)
  if [ -n "$pid" ]; then
    local mem=$(ps -o rss= -p "$pid" 2>/dev/null | awk '{print int($1/1024)}')
    if [ -n "$mem" ] && [ "$mem" -gt 500 ]; then
      send_feishu "🧠 Gateway 内存使用: ${mem}MB\n建议重启"
    fi
  fi
}

# 4. 错误日志监控
check_error_logs() {
  local log_file="/tmp/openclaw-gateway.log"
  if [ -f "$log_file" ]; then
    local errors=$(tail -100 "$log_file" | grep -i "error" | wc -l | tr -d ' ')
    if [ "$errors" -gt 5 ]; then
      send_feishu "❌ 检测到 $errors 个错误日志\n查看: $log_file"
    fi
  fi
}

# 5. 未提交代码提醒
check_uncommitted_changes() {
  cd "$REPO_DIR"
  if [ -n "$(git status --porcelain)" ]; then
    local files=$(git status --porcelain | wc -l | tr -d ' ')
    send_feishu "📝 有 $files 个文件未提交\n记得保存工作进度"
  fi
}

case "${1:-all}" in
  deps) check_dependencies ;;
  disk) check_disk_space ;;
  memory) check_gateway_memory ;;
  errors) check_error_logs ;;
  git) check_uncommitted_changes ;;
  all)
    check_dependencies
    check_disk_space
    check_gateway_memory
    check_error_logs
    ;;
esac
