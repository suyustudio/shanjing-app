#!/bin/bash
# Firebase Test Lab 自动化测试脚本

# 配置
PROJECT_ID="shanjing-app"
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

echo "=== Firebase Test Lab 自动化测试 ==="

# 检查APK是否存在
if [ ! -f "$APK_PATH" ]; then
    echo "错误: APK文件不存在: $APK_PATH"
    echo "请先运行: flutter build apk --release"
    exit 1
fi

# 上传到Firebase Test Lab
echo "上传APK到Firebase Test Lab..."
gcloud firebase test android run \
    --type robo \
    --app "$APK_PATH" \
    --device model=redfin,version=30,locale=zh_CN,orientation=portrait \
    --device model=oriole,version=33,locale=zh_CN,orientation=portrait \
    --timeout 5m \
    --project $PROJECT_ID

echo "测试完成！"
echo "查看结果: https://console.firebase.google.com/project/$PROJECT_ID/testlab/histories"
