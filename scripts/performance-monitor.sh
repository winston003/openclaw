#!/usr/bin/env bash
# 性能监控 - 追踪构建时间和测试速度

FEISHU_WEBHOOK="${FEISHU_WEBHOOK_URL:-https://open.feishu.cn/open-apis/bot/v2/hook/aee95710-e795-4946-ac4e-07aeec5d7e04}"
REPO_DIR="/Users/whilewon/workspace/openclaw"

cd "$REPO_DIR"

# 测量构建时间
start=$(date +%s)
pnpm build:strict-smoke >/dev/null 2>&1
end=$(date +%s)
build_time=$((end - start))

# 测量测试时间
start=$(date +%s)
pnpm test:fast >/dev/null 2>&1
end=$(date +%s)
test_time=$((end - start))

report="⚡ 性能监控报告\n\n"
report+="🏗️ 构建时间: ${build_time}s\n"
report+="🧪 测试时间: ${test_time}s\n"

if [ "$build_time" -gt 60 ]; then
  report+="\n⚠️ 构建时间较长，考虑优化"
fi

curl -s -X POST "$FEISHU_WEBHOOK" \
  -H "Content-Type: application/json" \
  -d "{\"msg_type\":\"text\",\"content\":{\"text\":\"$report\"}}" >/dev/null
