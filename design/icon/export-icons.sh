#!/bin/bash
# 山径 APP 图标导出脚本
# 生成所有平台所需的 PNG 尺寸

set -e

echo "🎨 山径 APP 图标导出工具"
echo "=========================="

# 检查依赖
if ! command -v rsvg-convert &> /dev/null; then
    echo "❌ 需要安装 rsvg-convert (librsvg2-bin)"
    echo "   Ubuntu/Debian: sudo apt-get install librsvg2-bin"
    echo "   macOS: brew install librsvg"
    exit 1
fi

# 创建输出目录
mkdir -p exports/ios
mkdir -p exports/android/mipmap-mdpi
mkdir -p exports/android/mipmap-hdpi
mkdir -p exports/android/mipmap-xhdpi
mkdir -p exports/android/mipmap-xxhdpi
mkdir -p exports/android/mipmap-xxxhdpi
mkdir -p exports/play-store

echo "📁 输出目录已创建"

# 导出函数
export_icon() {
    local input=$1
    local output=$2
    local size=$3
    rsvg-convert -w $size -h $size "$input" -o "$output"
    echo "   ✓ $output (${size}x${size})"
}

# ==================== iOS 图标 ====================
echo ""
echo "📱 导出 iOS 图标..."

# App Store
export_icon icon-ios.svg exports/ios/AppStore-1024x1024.png 1024

# iPhone
export_icon icon-ios.svg exports/ios/Icon-60@2x.png 120
export_icon icon-ios.svg exports/ios/Icon-60@3x.png 180
export_icon icon-ios.svg exports/ios/Icon-40@2x.png 80
export_icon icon-ios.svg exports/ios/Icon-40@3x.png 120
export_icon icon-ios.svg exports/ios/Icon-29@2x.png 58
export_icon icon-ios.svg exports/ios/Icon-29@3x.png 87

# iPad
export_icon icon-ios.svg exports/ios/Icon-76@2x.png 152
export_icon icon-ios.svg exports/ios/Icon-83.5@2x.png 167
export_icon icon-ios.svg exports/ios/Icon-76.png 76
export_icon icon-ios.svg exports/ios/Icon-40.png 40

# ==================== Android 图标 ====================
echo ""
echo "🤖 导出 Android 图标..."

# 自适应图标前景
export_icon icon-adaptive-fg.svg exports/android/mipmap-mdpi/ic_launcher_foreground.png 108
export_icon icon-adaptive-fg.svg exports/android/mipmap-hdpi/ic_launcher_foreground.png 162
export_icon icon-adaptive-fg.svg exports/android/mipmap-xhdpi/ic_launcher_foreground.png 216
export_icon icon-adaptive-fg.svg exports/android/mipmap-xxhdpi/ic_launcher_foreground.png 324
export_icon icon-adaptive-fg.svg exports/android/mipmap-xxxhdpi/ic_launcher_foreground.png 432

# 自适应图标背景
export_icon icon-adaptive-bg.svg exports/android/mipmap-mdpi/ic_launcher_background.png 108
export_icon icon-adaptive-bg.svg exports/android/mipmap-hdpi/ic_launcher_background.png 162
export_icon icon-adaptive-bg.svg exports/android/mipmap-xhdpi/ic_launcher_background.png 216
export_icon icon-adaptive-bg.svg exports/android/mipmap-xxhdpi/ic_launcher_background.png 324
export_icon icon-adaptive-bg.svg exports/android/mipmap-xxxhdpi/ic_launcher_background.png 432

# 传统图标 (mdpi 48dp)
export_icon icon-main.svg exports/android/mipmap-mdpi/ic_launcher.png 48
export_icon icon-main.svg exports/android/mipmap-hdpi/ic_launcher.png 72
export_icon icon-main.svg exports/android/mipmap-xhdpi/ic_launcher.png 96
export_icon icon-main.svg exports/android/mipmap-xxhdpi/ic_launcher.png 144
export_icon icon-main.svg exports/android/mipmap-xxxhdpi/ic_launcher.png 192

# ==================== Play Store ====================
echo ""
echo "🛒 导出 Play Store 图标..."
export_icon icon-main.svg exports/play-store/play-store-icon.png 512

# ==================== 预览图 ====================
echo ""
echo "👁️  导出预览图..."

export_icon icon-main.svg exports/preview-main-1024.png 1024
export_icon icon-main.svg exports/preview-main-512.png 512
export_icon icon-ios.svg exports/preview-ios-180.png 180
export_icon icon-adaptive-fg.svg exports/preview-adaptive-fg.png 108
export_icon icon-adaptive-bg.svg exports/preview-adaptive-bg.png 108

echo ""
echo "✅ 所有图标导出完成！"
echo ""
echo "📂 输出文件:"
echo "   exports/ios/          - iOS 图标"
echo "   exports/android/      - Android 图标"
echo "   exports/play-store/   - Play Store 图标"
echo "   exports/preview-*.png - 预览图"
echo ""
