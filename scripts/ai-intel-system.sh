#!/bin/bash
# AI技术情报系统 - 方案A最小可行版本

set -e

VAULT_PATH="${OBSIDIAN_VAULT:-$HOME/Documents/AI-Intel}"
mkdir -p "$VAULT_PATH"

echo "🦞 AI技术情报系统启动"
echo "知识库: $VAULT_PATH"
echo ""

# 1. GitHub Trending 采集（需要先运行 gh auth login）
echo "📊 采集 GitHub Trending..."
if gh auth status &>/dev/null; then
  gh search repos --sort stars --order desc --limit 10 --created ">$(date -v-7d +%Y-%m-%d)" \
    --json name,owner,stargazersCount,description,url \
    --jq '.[] | "- [\(.owner.login)/\(.name)](\(.url)) ⭐️\(.stargazersCount)\n  \(.description // "无描述")\n"' \
    > "$VAULT_PATH/github-trending-$(date +%Y%m%d).md"
  echo "✅ GitHub采集完成"
else
  echo "⚠️  请先运行: gh auth login"
  echo "📝 手动访问: https://github.com/trending"
fi

# 2. 技术卡片模板
cat > "$VAULT_PATH/技术卡片模板.md" <<'EOF'
# {{技术名称}}

## 基本信息
- 一句话定义:
- 成熟度: [ ] 论文 [ ] Demo [ ] 框架 [ ] 生产级
- 关注度: ⭐️⭐️⭐️☆☆
- 发现日期: {{日期}}

## 核心创新
-

## 架构要点
-

## 生态
- GitHub:
- 关键人物:
- 相关项目:

## 应用场景
-

## 机会判断
-
EOF

# 3. RSS源配置（手动）
cat > "$VAULT_PATH/RSS源列表.md" <<'EOF'
# AI技术情报源

## GitHub
- Trending: https://github.com/trending
- Awesome AI: https://github.com/topics/artificial-intelligence

## 论文
- arXiv AI: https://arxiv.org/list/cs.AI/recent
- arXiv ML: https://arxiv.org/list/cs.LG/recent

## 社区
- Hacker News: https://news.ycombinator.com/
- Reddit ML: https://www.reddit.com/r/MachineLearning/

## Newsletter
- The Batch: https://www.deeplearning.ai/the-batch/
- Import AI: https://jack-clark.net/
EOF

echo "✅ 系统初始化完成"
echo ""
echo "📁 知识库位置: $VAULT_PATH"
echo "📝 今日GitHub采集: $VAULT_PATH/github-trending-$(date +%Y%m%d).md"
