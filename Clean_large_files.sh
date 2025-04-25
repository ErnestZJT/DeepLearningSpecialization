#!/bin/bash

echo "🚀 开始自动清理大于 100MB 的文件..."

# 1. 找出所有 >100MB 的文件（单位 M = Mebibytes）
large_files=$(find . -type f -size +100M)

if [ -z "$large_files" ]; then
  echo "✅ 没有超过 100MB 的文件，无需处理。"
  exit 0
fi

echo "🧠 发现以下大文件："
echo "$large_files"
echo ""

# 2. 创建 .gitignore 文件（如不存在）
touch .gitignore

# 3. 遍历每个大文件：从 Git 缓存中移除，并添加到 .gitignore
while read -r file; do
  # 去除前面的 ./ 前缀
  clean_path=$(echo "$file" | sed 's|^\./||')
  echo "⚙️ 处理：$clean_path"

  # 从 Git 缓存移除（不删除本地文件）
  git rm --cached "$clean_path"

  # 添加到 .gitignore（如果还没被忽略）
  if ! grep -Fxq "$clean_path" .gitignore; then
    echo "$clean_path" >> .gitignore
  fi
done <<< "$large_files"

# 4. 添加 .gitignore 到 Git
git add .gitignore
git commit -m "Remove large files from Git tracking and ignore them"
echo "✅ 清理完成！你现在可以安全地 push 了："
echo ""
echo "👉 git push -f origin main"
