#!/usr/bin/env bash
# 一键设置所有监控任务

REPO_DIR="/Users/whilewon/workspace/openclaw"
cd "$REPO_DIR"

echo "🔧 设置 OpenClaw 监控任务..."

# 使用 OpenClaw 内置 cron
pnpm openclaw --dev cron add \
  --name "github-monitor" \
  --schedule "0 * * * *" \
  --command "$REPO_DIR/scripts/github-monitor.sh" 2>/dev/null

pnpm openclaw --dev cron add \
  --name "smart-monitor" \
  --schedule "0 */6 * * *" \
  --command "$REPO_DIR/scripts/smart-monitor.sh all" 2>/dev/null

pnpm openclaw --dev cron add \
  --name "daily-report" \
  --schedule "0 21 * * *" \
  --command "$REPO_DIR/scripts/daily-report.sh" 2>/dev/null

echo ""
echo "✅ 监控任务已设置："
echo "  • GitHub 更新监控 - 每小时"
echo "  • 智能监控套件 - 每6小时"
echo "  • 每日开发报告 - 每晚9点"
echo ""
echo "查看任务: pnpm openclaw --dev cron list"
