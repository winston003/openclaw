# OpenClaw Dev Restart Script

健壮的 OpenClaw 开发模式启动脚本，支持自动备份、故障恢复和飞书通知。

## 使用方法

```bash
# 设置飞书 webhook（可选）
export FEISHU_WEBHOOK_URL="https://open.feishu.cn/open-apis/bot/v2/hook/aee95710-e795-4946-ac4e-07aeec5d7e04"

# 运行脚本
./scripts/dev-restart.sh
```

## 功能特性

- ✅ 优雅终止现有进程（SIGTERM → SIGKILL）
- ✅ 启动前自动创建备份
- ✅ 健康检查（30秒超时）
- ✅ 失败自动恢复备份并重试
- ✅ Token 自动获取
- ✅ 飞书 webhook 通知
- ✅ 详细日志输出

## 环境变量

```bash
# 飞书 webhook URL（可选）
export FEISHU_WEBHOOK_URL="https://open.feishu.cn/open-apis/bot/v2/hook/YOUR_WEBHOOK_ID"

# Gateway token（可选，优先级高于配置文件）
export OPENCLAW_GATEWAY_TOKEN="your-token"
```

## 工作流程

1. 创建状态备份
2. 终止现有 gateway 进程
3. 等待端口释放
4. 启动新的 gateway
5. 等待健康检查通过
6. 获取 token 并发送通知
7. 如果失败：恢复备份并重试一次
