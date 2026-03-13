# 🎉 OpenClaw 智能监控系统

已为你创建了完整的飞书通知监控系统！

## 📦 已创建的脚本

### 核心脚本

1. **dev-restart.sh** - 健壮的 Gateway 重启脚本
2. **quick-restart.sh** - 快速重启（已配置飞书）

### 监控脚本

3. **github-monitor.sh** - GitHub 更新监控
4. **smart-monitor.sh** - 智能监控套件（依赖/磁盘/内存/错误）
5. **daily-report.sh** - 每日开发报告
6. **performance-monitor.sh** - 性能监控（构建/测试时间）
7. **code-quality-monitor.sh** - 代码质量监控（TODO/错误）
8. **ai-activity-monitor.sh** - AI 助手活动监控

### 工具脚本

9. **setup-monitors.sh** - 一键设置所有定时任务

## 🚀 快速开始

```bash
# 1. 设置环境变量（添加到 ~/.zshrc）
export FEISHU_WEBHOOK_URL="https://open.feishu.cn/open-apis/bot/v2/hook/aee95710-e795-4946-ac4e-07aeec5d7e04"

# 2. 一键设置所有监控
./scripts/setup-monitors.sh

# 3. 测试监控
./scripts/daily-report.sh
```

## 📊 监控场景

| 监控类型    | 频率    | 功能                |
| ----------- | ------- | ------------------- |
| GitHub 更新 | 每小时  | 检测新提交并通知    |
| 智能监控    | 每6小时 | 依赖/磁盘/内存/错误 |
| 每日报告    | 每晚9点 | 代码统计和运行状态  |
| 性能监控    | 按需    | 构建和测试时间      |
| 代码质量    | 按需    | TODO 和 TS 错误     |
| AI 活动     | 按需    | 会话和消息统计      |

## 💡 创意用法

### 自动化工作流

```bash
# 每次提交后自动通知
git commit && ./scripts/github-monitor.sh

# 每周代码质量报告
0 9 * * 1 /path/to/code-quality-monitor.sh
```

### 与 OpenClaw 集成

所有监控都可以通过 OpenClaw 的 cron 系统管理：

```bash
pnpm openclaw --dev cron list
pnpm openclaw --dev cron remove <name>
```

## 📝 文档

- MONITORS.md - 详细使用指南
- dev-restart.README.md - 重启脚本说明

查看飞书群聊接收实时通知！
