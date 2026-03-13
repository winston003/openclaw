#!/usr/bin/env bash
# AI 驱动的代码质量监控

FEISHU_WEBHOOK="${FEISHU_WEBHOOK_URL:-https://open.feishu.cn/open-apis/bot/v2/hook/aee95710-e795-4946-ac4e-07aeec5d7e04}"
REPO_DIR="/Users/whilewon/workspace/openclaw"

cd "$REPO_DIR"

# 检查 TODO/FIXME 注释
todos=$(grep -r "TODO\|FIXME" src/ --include="*.ts" 2>/dev/null | wc -l | tr -d ' ')

# 检查测试覆盖率（如果有）
coverage=""
if [ -f "coverage/coverage-summary.json" ]; then
  coverage=$(cat coverage/coverage-summary.json | grep -o '"lines":{"total":[0-9]*,"covered":[0-9]*' | head -1)
fi

# 检查 TypeScript 错误
ts_errors=$(pnpm tsgo 2>&1 | grep -c "error TS")

# 构建报告
report="🤖 AI 代码质量报告\n\n"
report+="📝 待办事项: $todos 个 TODO/FIXME\n"
report+="❌ TypeScript 错误: $ts_errors 个\n"

if [ "$todos" -gt 20 ]; then
  report+="\n💡 建议: 清理一些 TODO 注释"
fi

if [ "$ts_errors" -gt 0 ]; then
  report+="\n⚠️ 建议: 修复 TypeScript 错误"
fi

curl -s -X POST "$FEISHU_WEBHOOK" \
  -H "Content-Type: application/json" \
  -d "{\"msg_type\":\"text\",\"content\":{\"text\":\"$report\"}}" >/dev/null
