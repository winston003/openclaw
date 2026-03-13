#!/usr/bin/env bash

cd "$(dirname "$0")/.."

# Configuration
DEV_PORT=19001
STATE_DIR="$HOME/.openclaw-dev"
CONFIG_FILE="$STATE_DIR/openclaw.json"
HEALTH_TIMEOUT=30
PORT_FREE_TIMEOUT=3

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
  echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

backup_state() {
  log "Creating backup..."
  local output=$(pnpm openclaw --dev backup create --verify 2>&1)
  local backup_file=$(echo "$output" | grep -o '/[^ ]*\.tar\.gz' | head -1)

  if [ -z "$backup_file" ] || [ ! -f "$backup_file" ]; then
    error "Backup failed"
    return 1
  fi

  echo "$backup_file"
}

kill_gateway() {
  local pids=$(lsof -ti :$DEV_PORT 2>/dev/null)
  if [ -z "$pids" ]; then
    log "No gateway process found on port $DEV_PORT"
    return 0
  fi

  log "Terminating gateway PIDs: $pids"
  kill -TERM $pids 2>/dev/null || true
  sleep 1

  pids=$(lsof -ti :$DEV_PORT 2>/dev/null)
  if [ -n "$pids" ]; then
    warn "Force killing PIDs: $pids"
    kill -KILL $pids 2>/dev/null || true
    sleep 0.5
  fi
}

wait_port_free() {
  local elapsed=0
  while [ $elapsed -lt $PORT_FREE_TIMEOUT ]; do
    if ! lsof -ti :$DEV_PORT >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.5
    elapsed=$((elapsed + 1))
  done
  return 1
}

wait_healthy() {
  local elapsed=0
  log "Waiting for gateway to become healthy..."
  while [ $elapsed -lt $HEALTH_TIMEOUT ]; do
    if pnpm openclaw --dev health >/dev/null 2>&1; then
      log "Gateway is healthy"
      return 0
    fi
    sleep 2
    elapsed=$((elapsed + 2))
  done
  return 1
}

get_token() {
  if [ -n "$OPENCLAW_GATEWAY_TOKEN" ]; then
    echo "$OPENCLAW_GATEWAY_TOKEN"
    return 0
  fi

  if [ -f "$CONFIG_FILE" ]; then
    local token=$(grep -o '"token"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
    if [ -n "$token" ]; then
      echo "$token"
      return 0
    fi
  fi

  return 1
}

notify_feishu() {
  local token="$1"
  local webhook="$FEISHU_WEBHOOK_URL"

  if [ -z "$webhook" ]; then
    warn "FEISHU_WEBHOOK_URL not set, skipping notification"
    return 0
  fi

  local message="{\"msg_type\":\"text\",\"content\":{\"text\":\"🦞 OpenClaw Gateway 已重启\\n\\n🔑 Token: $token\\n📍 地址: http://127.0.0.1:$DEV_PORT\\n⏰ 时间: $(date '+%Y-%m-%d %H:%M:%S')\"}}"

  curl -s -X POST "$webhook" \
    -H "Content-Type: application/json" \
    -d "$message" >/dev/null 2>&1 || warn "Failed to send Feishu notification"
}

restore_backup() {
  local backup_file="$1"
  if [ -z "$backup_file" ] || [ ! -f "$backup_file" ]; then
    error "Backup file not found: $backup_file"
    return 1
  fi

  log "Restoring from backup: $backup_file"
  tar -xzf "$backup_file" -C "$STATE_DIR" --strip-components=1 2>/dev/null
}

main() {
  local retry_count=0
  local max_retries=1
  local backup_file=""

  echo "🦞 OpenClaw Dev Gateway Restart Script"
  echo ""

  while [ $retry_count -le $max_retries ]; do
    log "=== Attempt $((retry_count + 1)) ==="

    if [ $retry_count -eq 0 ]; then
      backup_file=$(backup_state)
      if [ $? -ne 0 ]; then
        error "Cannot proceed without backup"
        exit 1
      fi
      log "Backup created: $backup_file"
    fi

    kill_gateway

    if ! wait_port_free; then
      error "Port $DEV_PORT still in use after kill"
      exit 1
    fi
    log "Port $DEV_PORT is free"

    log "Starting gateway..."
    nohup pnpm openclaw --dev gateway --force > /tmp/openclaw-gateway.log 2>&1 &
    local gateway_pid=$!
    sleep 3

    if wait_healthy; then
      local token=$(get_token)
      if [ -n "$token" ]; then
        echo ""
        echo -e "${GREEN}✅ Gateway started successfully!${NC}"
        echo -e "${GREEN}🔑 Token:${NC} $token"
        echo -e "${GREEN}📍 Dashboard:${NC} http://127.0.0.1:$DEV_PORT"
        echo ""
        notify_feishu "$token"
      else
        warn "Could not retrieve token"
      fi
      exit 0
    else
      error "Gateway failed to become healthy"
      kill $gateway_pid 2>/dev/null

      if [ $retry_count -lt $max_retries ]; then
        log "Restoring backup and retrying..."
        restore_backup "$backup_file"
        retry_count=$((retry_count + 1))
      else
        error "Max retries reached. Gateway failed to start."
        exit 1
      fi
    fi
  done
}

main "$@"

