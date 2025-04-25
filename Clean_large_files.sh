#!/bin/bash

echo "🚀 开始智能清理大于 100MB 的文件..."

# 1. 找出所有 >100MB 的文件
large_files=$(find . -type f -size +100M)

# 如果没有大文件，直接退出
if [ -z "$large_files" ]; then
  echo "✅ 没有大于 100MB 的文件，无需处理。"
  exit 0
fi

# 打印找到的大文件
echo "🧠 发现以下大文件："
echo "$large_files"
echo ""

# 2. 确保 .gitignore 存在
touch .gitignore

# 3. 遍历每一个大文件进行处理
while read -r file; do
  # 去掉路径前缀 ./
  clean_path=$(echo "$file" | sed 's|^\./||')
  echo "⚙️ 正在处理：$clean_path"

  # 检查文件是否已经被 Git 跟踪（即存在于 staging area 或历史记录中）
  if git ls-files --error-unmatch "$clean_path" > /dev/null 2>&1; then
    echo "🔎 文件已被 Git 跟踪，执行 git rm --cached..."
    git rm --cached "$clean_path"
  else
    echo "📂 文件未被 Git 跟踪，只加入 .gitignore。"
  fi

  # 把文件路径加到 .gitignore（如果没有加过）
  if ! grep -Fxq "$clean_path" .gitignore; then
    echo "$clean_path" >> .gitignore
    echo "✍️ 已添加到 .gitignore"
  fi

done <<< "$large_files"

# 4. 将更新后的 .gitignore 添加到 Git
if git diff --cached --quiet -- .gitignore; then
  echo "🛡️ .gitignore 未变化，无需添加。"
else
  git add .gitignore
  git commit -m "Update .gitignore: ignore large files (>100MB)"
  echo "✅ 已提交更新后的 .gitignore。"
fi

# 最后提示用户
echo "\n🚀 大文件清理完成！"
echo "👉 接下来你可以继续 git add / git commit / git push。"
echo "👉 如果刚才已经 git add . 过，需要重新 git add . （确保新的 .gitignore 生效）"
