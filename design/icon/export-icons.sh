#!/bin/bash
# 山径 APP 图标导出脚本
# 需要安装: Inkscape 或 ImageMagick

set -e

SRC_DIR="."
OUTPUT_DIR="./exports"

mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/ios"
mkdir -p "$OUTPUT_DIR/android"
mkdir -p "$OUTPUT_DIR/android/mipmap-xxxhdpi"
mkdir -p "$OUTPUT_DIR/android/mipmap-xxhdpi"
mkdir -p "$OUTPUT_DIR/android/mipmap-xhdpi"
mkdir -p "$OUTPUT_DIR/android/mipmap-hdpi"
mkdir -p "$OUTPUT_DIR/android/mipmap-mdpi"
mkdir -p "$OUTPUT_DIR/play-store"

echo "🎨 导出山径 APP 图标..."

# 检查 inkscape
if command -v inkscape &> /dev/null; then
    CONVERT_CMD="inkscape"
elif command -v convert &> /dev/null; then
    CONVERT_CMD="convert"
else
    echo "⚠️  未找到 inkscape 或 imagemagick，请手动导出 SVG"
    exit 1
fi

# iOS 图标尺寸
# App Store
inkscape "icon-ios.svg" --export-filename="$OUTPUT_DIR/ios/AppStore-1024x1024.png" --export-width=1024 --export-height=1024 2>/dev/null || \
convert "icon-ios.svg" -resize 1024x1024 "$OUTPUT_DIR/ios/AppStore-1024x1024.png"

# iPhone
for size in 180 120 87 60 40; do
    scale=$((size * 3))
    inkscape "icon-ios.svg" --export-filename="$OUTPUT_DIR/ios/iPhone-${size}pt@${scale}x.png" --export-width=$scale --export-height=$scale 2>/dev/null || \
    convert "icon-ios.svg" -resize ${scale}x${scale} "$OUTPUT_DIR/ios/iPhone-${size}pt@${scale}x.png"
done

# iPad
for size in 167 152 76; do
    inkscape "icon-ios.svg" --export-filename="$OUTPUT_DIR/ios/iPad-${size}pt@2x.png" --export-width=$((size*2)) --export-height=$((size*2)) 2>/dev/null || \
    convert "icon-ios.svg" -resize $((size*2))x$((size*2)) "$OUTPUT_DIR/ios/iPad-${size}pt@2x.png"
done

# Android 图标尺寸
# 自适应图标前景
inkscape "icon-adaptive-fg.svg" --export-filename="$OUTPUT_DIR/android/mipmap-xxxhdpi/ic_launcher_foreground.png" --export-width=432 --export-height=432 2>/dev/null || \
convert "icon-adaptive-fg.svg" -resize 432x432 "$OUTPUT_DIR/android/mipmap-xxxhdpi/ic_launcher_foreground.png"

inkscape "icon-adaptive-fg.svg" --export-filename="$OUTPUT_DIR/android/mipmap-xxhdpi/ic_launcher_foreground.png" --export-width=324 --export-height=324 2>/dev/null || \
convert "icon-adaptive-fg.svg" -resize 324x324 "$OUTPUT_DIR/android/mipmap-xxhdpi/ic_launcher_foreground.png"

inkscape "icon-adaptive-fg.svg" --export-filename="$OUTPUT_DIR/android/mipmap-xhdpi/ic_launcher_foreground.png" --export-width=216 --export-height=216 2>/dev/null || \
convert "icon-adaptive-fg.svg" -resize 216x216 "$OUTPUT_DIR/android/mipmap-xhdpi/ic_launcher_foreground.png"

inkscape "icon-adaptive-fg.svg" --export-filename="$OUTPUT_DIR/android/mipmap-hdpi/ic_launcher_foreground.png" --export-width=162 --export-height=162 2>/dev/null || \
convert "icon-adaptive-fg.svg" -resize 162x162 "$OUTPUT_DIR/android/mipmap-hdpi/ic_launcher_foreground.png"

inkscape "icon-adaptive-fg.svg" --export-filename="$OUTPUT_DIR/android/mipmap-mdpi/ic_launcher_foreground.png" --export-width=108 --export-height=108 2>/dev/null || \
convert "icon-adaptive-fg.svg" -resize 108x108 "$OUTPUT_DIR/android/mipmap-mdpi/ic_launcher_foreground.png"

# 自适应图标背景
inkscape "icon-adaptive-bg.svg" --export-filename="$OUTPUT_DIR/android/mipmap-xxxhdpi/ic_launcher_background.png" --export-width=432 --export-height=432 2>/dev/null || \
convert "icon-adaptive-bg.svg" -resize 432x432 "$OUTPUT_DIR/android/mipmap-xxxhdpi/ic_launcher_background.png"

inkscape "icon-adaptive-bg.svg" --export-filename="$OUTPUT_DIR/android/mipmap-xxhdpi/ic_launcher_background.png" --export-width=324 --export-height=324 2>/dev/null || \
convert "icon-adaptive-bg.svg" -resize 324x324 "$OUTPUT_DIR/android/mipmap-xxhdpi/ic_launcher_background.png"

inkscape "icon-adaptive-bg.svg" --export-filename="$OUTPUT_DIR/android/mipmap-xhdpi/ic_launcher_background.png" --export-width=216 --export-height=216 2>/dev/null || \
convert "icon-adaptive-bg.svg" -resize 216x216 "$OUTPUT_DIR/android/mipmap-xhdpi/ic_launcher_background.png"

inkscape "icon-adaptive-bg.svg" --export-filename="$OUTPUT_DIR/android/mipmap-hdpi/ic_launcher_background.png" --export-width=162 --export-height=162 2>/dev/null || \
convert "icon-adaptive-bg.svg" -resize 162x162 "$OUTPUT_DIR/android/mipmap-hdpi/ic_launcher_background.png"

inkscape "icon-adaptive-bg.svg" --export-filename="$OUTPUT_DIR/android/mipmap-mdpi/ic_launcher_background.png" --export-width=108 --export-height=108 2>/dev/null || \
convert "icon-adaptive-bg.svg" -resize 108x108 "$OUTPUT_DIR/android/mipmap-mdpi/ic_launcher_background.png"

# 传统图标（方形圆角）
inkscape "icon-main.svg" --export-filename="$OUTPUT_DIR/android/mipmap-xxxhdpi/ic_launcher.png" --export-width=192 --export-height=192 2>/dev/null || \
convert "icon-main.svg" -resize 192x192 "$OUTPUT_DIR/android/mipmap-xxxhdpi/ic_launcher.png"

inkscape "icon-main.svg" --export-filename="$OUTPUT_DIR/android/mipmap-xxhdpi/ic_launcher.png" --export-width=144 --export-height=144 2>/dev/null || \
convert "icon-main.svg" -resize 144x144 "$OUTPUT_DIR/android/mipmap-xxhdpi/ic_launcher.png"

inkscape "icon-main.svg" --export-filename="$OUTPUT_DIR/android/mipmap-xhdpi/ic_launcher.png" --export-width=96 --export-height=96 2>/dev/null || \
convert "icon-main.svg" -resize 96x96 "$OUTPUT_DIR/android/mipmap-xhdpi/ic_launcher.png"

inkscape "icon-main.svg" --export-filename="$OUTPUT_DIR/android/mipmap-hdpi/ic_launcher.png" --export-width=72 --export-height=72 2>/dev/null || \
convert "icon-main.svg" -resize 72x72 "$OUTPUT_DIR/android/mipmap-hdpi/ic_launcher.png"

inkscape "icon-main.svg" --export-filename="$OUTPUT_DIR/android/mipmap-mdpi/ic_launcher.png" --export-width=48 --export-height=48 2>/dev/null || \
convert "icon-main.svg" -resize 48x48 "$OUTPUT_DIR/android/mipmap-mdpi/ic_launcher.png"

# Play Store 图标
inkscape "icon-main.svg" --export-filename="$OUTPUT_DIR/play-store/play-store-icon.png" --export-width=512 --export-height=512 2>/dev/null || \
convert "icon-main.svg" -resize 512x512 "$OUTPUT_DIR/play-store/play-store-icon.png"

# 单色图标
inkscape "icon-monochrome-white.svg" --export-filename="$OUTPUT_DIR/android/mipmap-xxxhdpi/ic_notification.png" --export-width=96 --export-height=96 2>/dev/null || \
convert "icon-monochrome-white.svg" -resize 96x96 "$OUTPUT_DIR/android/mipmap-xxxhdpi/ic_notification.png"

inkscape "icon-monochrome-white.svg" --export-filename="$OUTPUT_DIR/android/mipmap-xxhdpi/ic_notification.png" --export-width=72 --export-height=72 2>/dev/null || \
convert "icon-monochrome-white.svg" -resize 72x72 "$OUTPUT_DIR/android/mipmap-xxhdpi/ic_notification.png"

inkscape "icon-monochrome-white.svg" --export-filename="$OUTPUT_DIR/android/mipmap-xhdpi/ic_notification.png" --export-width=48 --export-height=48 2>/dev/null || \
convert "icon-monochrome-white.svg" -resize 48x48 "$OUTPUT_DIR/android/mipmap-xhdpi/ic_notification.png"

inkscape "icon-monochrome-white.svg" --export-filename="$OUTPUT_DIR/android/mipmap-hdpi/ic_notification.png" --export-width=36 --export-height=36 2>/dev/null || \
convert "icon-monochrome-white.svg" -resize 36x36 "$OUTPUT_DIR/android/mipmap-hdpi/ic_notification.png"

inkscape "icon-monochrome-white.svg" --export-filename="$OUTPUT_DIR/android/mipmap-mdpi/ic_notification.png" --export-width=24 --export-height=24 2>/dev/null || \
convert "icon-monochrome-white.svg" -resize 24x24 "$OUTPUT_DIR/android/mipmap-mdpi/ic_notification.png"

echo "✅ 图标导出完成！"
echo ""
echo "📁 输出目录: $OUTPUT_DIR"
echo ""
echo "iOS 图标: $OUTPUT_DIR/ios/"
echo "Android 图标: $OUTPUT_DIR/android/"
echo "Play Store: $OUTPUT_DIR/play-store/"
