# OpenClaw 监控脚本使用指南

## 已创建的监控脚本

### 1. GitHub 更新监控 (`github-monitor.sh`)

检查仓库是否有新提交并通知

```bash
# 手动运行
./scripts/github-monitor.sh

# 定时任务（每小时检查）
crontab -e
# 添加: 0 * * * * /Users/whilewon/workspace/openclaw/scripts/github-monitor.sh
```

### 2. 智能监控套件 (`smart-monitor.sh`)

多种监控场景：依赖更新、磁盘空间、内存、错误日志

```bash
# 运行所有检查
./scripts/smart-monitor.sh all

# 单独检查
./scripts/smart-monitor.sh deps     # 依赖更新
./scripts/smart-monitor.sh disk     # 磁盘空间
./scripts/smart-monitor.sh memory   # Gateway 内存
./scripts/smart-monitor.sh errors   # 错误日志
./scripts/smart-monitor.sh git      # 未提交代码

# 定时任务（每6小时）
0 */6 * * * /Users/whilewon/workspace/openclaw/scripts/smart-monitor.sh all
```

### 3. 每日开发报告 (`daily-report.sh`)

汇总每天的开发活动统计

```bash
# 手动运行
./scripts/daily-report.sh

# 定时任务（每晚9点）
0 21 * * * /Users/whilewon/workspace/openclaw/scripts/daily-report.sh
```

## 更多创意监控场景

### 4. 使用 OpenClaw 的 cron 功能

OpenClaw 内置了 cron 调度器，可以直接使用：

```bash
# 添加 GitHub 监控任务
pnpm openclaw --dev cron add \
  --name "github-monitor" \
  --schedule "0 * * * *" \
  --command "/Users/whilewon/workspace/openclaw/scripts/github-monitor.sh"

# 添加智能监控任务
pnpm openclaw --dev cron add \
  --name "smart-monitor" \
  --schedule "0 */6 * * *" \
  --command "/Users/whilewon/workspace/openclaw/scripts/smart-monitor.sh all"

# 添加每日报告任务
pnpm openclaw --dev cron add \
  --name "daily-report" \
  --schedule "0 21 * * *" \
  --command "/Users/whilewon/workspace/openclaw/scripts/daily-report.sh"

# 查看所有任务
pnpm openclaw --dev cron list
```

## 环境变量配置

在 `~/.zshrc` 或 `~/.bashrc` 中添加：

```bash
export FEISHU_WEBHOOK_URL="https://open.feishu.cn/open-apis/bot/v2/hook/aee95710-e795-4946-ac4e-07aeec5d7e04"
```

## 快速设置所有监控

```bash
# 一键设置所有定时任务
./scripts/setup-monitors.sh
```
