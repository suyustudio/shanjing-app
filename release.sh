#!/bin/bash
# 发布新版本脚本

set -e

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Usage: ./release.sh <version>"
    echo "Example: ./release.sh v1.0.0"
    exit 1
fi

echo "🚀 准备发布山径APP $VERSION"

# 1. 检查工作目录是否干净
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ 工作目录有未提交的更改，请先提交"
    git status --short
    exit 1
fi

# 2. 更新版本号
echo "📋 更新版本号..."
sed -i "s/versionName = \"[^\"]*\"/versionName = \"$VERSION\"/" android/app/build.gradle || true

# 3. 提交版本更新
git add -A
git commit -m "release: bump version to $VERSION" || true

# 4. 创建标签
echo "🏷️ 创建标签 $VERSION..."
git tag -a "$VERSION" -m "Release $VERSION"

# 5. 推送到远程
echo "📤 推送到远程..."
git push origin main
git push origin "$VERSION"

echo "✅ 发布完成！"
echo ""
echo "GitHub Actions 将自动构建并发布 APK"
echo "查看构建状态: https://github.com/suyustudio/shanjing-app/actions"
