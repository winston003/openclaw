#!/bin/bash
# 快速技术笔记

VAULT_PATH="${OBSIDIAN_VAULT:-$HOME/Documents/AI-Intel}"
TECH_NAME="$1"

if [ -z "$TECH_NAME" ]; then
  echo "用法: $0 <技术名称>"
  exit 1
fi

FILENAME="$TECH_NAME-$(date +%Y%m%d).md"

cat > "$VAULT_PATH/$FILENAME" <<EOF
# $TECH_NAME

发现日期: $(date +%Y-%m-%d)

## 基本信息
- 一句话定义:
- 成熟度: [ ] 论文 [ ] Demo [ ] 框架 [ ] 生产级
- 关注度: ⭐️⭐️⭐️☆☆

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

## 商业价值
-

## 机会判断
-
EOF

echo "✅ 笔记创建: $VAULT_PATH/$FILENAME"
open "$VAULT_PATH/$FILENAME" 2>/dev/null || echo "📝 请手动打开编辑"
