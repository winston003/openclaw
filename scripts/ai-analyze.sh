#!/bin/bash
# AI技术分析助手

URL="$1"
VAULT_PATH="${OBSIDIAN_VAULT:-$HOME/Documents/AI-Intel}"

if [ -z "$URL" ]; then
  echo "用法: $0 <URL或GitHub仓库>"
  exit 1
fi

echo "🔍 分析: $URL"

# 检测是否为GitHub仓库
if [[ "$URL" =~ github\.com/([^/]+)/([^/]+) ]]; then
  OWNER="${BASH_REMATCH[1]}"
  REPO="${BASH_REMATCH[2]}"

  echo "📦 GitHub仓库: $OWNER/$REPO"

  # 获取仓库信息
  REPO_INFO=$(gh repo view "$OWNER/$REPO" --json name,description,stargazersCount,forksCount,primaryLanguage,createdAt,pushedAt,url 2>/dev/null)

  if [ $? -eq 0 ]; then
    NAME=$(echo "$REPO_INFO" | jq -r '.name')
    DESC=$(echo "$REPO_INFO" | jq -r '.description // "无描述"')
    STARS=$(echo "$REPO_INFO" | jq -r '.stargazersCount')
    FORKS=$(echo "$REPO_INFO" | jq -r '.forksCount')
    LANG=$(echo "$REPO_INFO" | jq -r '.primaryLanguage.name // "未知"')

    FILENAME="$NAME-$(date +%Y%m%d-%H%M%S).md"

    cat > "$VAULT_PATH/$FILENAME" <<EOF
# $NAME

来源: $URL
日期: $(date +%Y-%m-%d)

## 基本信息
- ⭐️ Stars: $STARS
- 🍴 Forks: $FORKS
- 💻 语言: $LANG
- 📝 描述: $DESC

## 核心创新
-

## 架构要点
-

## 生态
- GitHub: $URL
- 关键人物: $OWNER
- 相关项目:

## 应用场景
-

## 机会判断
-
EOF

    echo "✅ 分析完成: $VAULT_PATH/$FILENAME"
  else
    echo "⚠️  无法获取GitHub信息，请先运行: gh auth login"
  fi
else
  # 非GitHub链接，使用summarize
  echo "📄 网页分析中..."
  SUMMARY=$(timeout 30 summarize "$URL" --length short --model google/gemini-3-flash-preview 2>/dev/null || echo "分析超时，请手动查看")

  FILENAME="分析-$(date +%Y%m%d-%H%M%S).md"
  cat > "$VAULT_PATH/$FILENAME" <<EOF
# 技术分析

来源: $URL
日期: $(date +%Y-%m-%d)

## 摘要
$SUMMARY

## 待补充
- [ ] 核心技术
- [ ] 应用场景
- [ ] 商业价值
EOF

  echo "✅ 分析完成: $VAULT_PATH/$FILENAME"
fi
