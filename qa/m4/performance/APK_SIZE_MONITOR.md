# APK_SIZE_MONITOR - APK 大小监控

> **文档版本**: v1.0  
> **制定日期**: 2026-03-19  > **优先级**: P1

---

## 测试目标

监控 APK 大小，确保用户在移动网络下可接受下载，控制存储占用。

## 测试指标

| 指标 | 目标值 | 警告阈值 | 失败阈值 | 说明 |
|------|--------|----------|----------|------|
| **APK 大小** | < 50MB | 50-80MB | > 80MB | 下载包大小 |
| **下载后大小** | < 80MB | 80-120MB | > 120MB | 安装后占用 |
| **用户数据** | < 100MB | 100-200MB | > 200MB | 离线包+缓存 |

## 包大小分析

### 目标构成

```
目标 APK: 50MB
├── Flutter Framework (约 15MB)
├── Dart Code (约 5MB)
├── Native Libraries (约 8MB)
│   └── 高德 SDK / 其他
├── Resources (约 15MB)
│   ├── 图片资源 (10MB)
│   ├── 字体文件 (3MB)
│   └── 其他资源 (2MB)
└── Assets (约 7MB)
    ├── 默认路线数据
    └── 配置文件
```

## 测试方法

### 1. 构建测量

```bash
# 清理并构建发布版
flutter clean
flutter build apk --release

# 查看 APK 大小
ls -lh build/app/outputs/flutter-apk/app-release.apk

# 详细分析
flutter build apk --release --analyze-size
```

### 2. 使用 Android Studio Analyzer

```bash
# 生成 app bundle 并分析
flutter build appbundle --release

# 使用 bundletool 分析
java -jar bundletool.jar build-apks \
  --bundle=build/app/outputs/bundle/release/app-release.aab \
  --output=app.apks
```

### 3. 安装后大小测量

```bash
# 安装 APK
adb install build/app/outputs/flutter-apk/app-release.apk

# 查看应用大小
adb shell dumpsys package com.shanjing.app | grep -A 5 "dataDir"

# 或查看设置中的应用信息
adb shell pm dump com.shanjing.app | grep -E "(codeSize|dataSize|cacheSize)"
```

## 监控脚本

```python
#!/usr/bin/env python3
# qa/m4/automation/apk_size_monitor.py

import subprocess
import json
import os
from dataclasses import dataclass
from typing import Dict

@dataclass
class APKSizeReport:
    build_number: str
    apk_size_mb: float
    download_size_mb: float
    install_size_mb: float
    components: Dict[str, float]
    status: str

def analyze_apk(build_number: str) -> APKSizeReport:
    """分析 APK 大小"""
    apk_path = "build/app/outputs/flutter-apk/app-release.apk"
    
    if not os.path.exists(apk_path):
        print("⚠️  APK 文件不存在，开始构建...")
        subprocess.run(["flutter", "clean"])
        subprocess.run(["flutter", "build", "apk", "--release"])
    
    # 获取 APK 大小
    apk_size = os.path.getsize(apk_path) / (1024 * 1024)
    
    # 使用 aapt 分析
    result = subprocess.run(
        ["aapt", "list", "-v", apk_path],
        capture_output=True, text=True
    )
    
    # 解析各组件大小
    components = {
        "lib/": 0,
        "assets/": 0,
        "res/": 0,
        "classes.dex": 0,
        "resources.arsc": 0,
        "META-INF/": 0,
    }
    
    for line in result.stdout.split('\n'):
        for prefix in components.keys():
            if prefix in line:
                # 简化的解析，实际应更精确
                parts = line.split()
                if len(parts) >= 3:
                    try:
                        size = int(parts[0])
                        components[prefix] += size / (1024 * 1024)
                    except:
                        pass
    
    # 估算安装后大小 (APK 解压后约 1.4x)
    install_size = apk_size * 1.4
    
    # 判定状态
    if apk_size < 50:
        status = "✅ PASS"
    elif apk_size < 80:
        status = "⚠️  WARN"
    else:
        status = "❌ FAIL"
    
    return APKSizeReport(
        build_number=build_number,
        apk_size_mb=round(apk_size, 2),
        download_size_mb=round(apk_size, 2),
        install_size_mb=round(install_size, 2),
        components={k: round(v, 2) for k, v in components.items()},
        status=status
    )

def generate_report(report: APKSizeReport):
    """生成报告"""
    print("\n" + "=" * 60)
    print("📦 APK 大小监控报告")
    print("=" * 60)
    print(f"构建版本: {report.build_number}")
    print(f"APK 大小: {report.apk_size_mb} MB {report.status}")
    print(f"预估安装: {report.install_size_mb} MB")
    print("\n组件分析:")
    for component, size in report.components.items():
        if size > 0:
            percentage = (size / report.apk_size_mb) * 100
            print(f"  {component}: {size:.2f} MB ({percentage:.1f}%)")
    
    # 保存 JSON
    with open(f"apk_size_{report.build_number}.json", "w") as f:
        json.dump({
            "build_number": report.build_number,
            "apk_size_mb": report.apk_size_mb,
            "install_size_mb": report.install_size_mb,
            "components": report.components,
            "status": report.status,
            "timestamp": subprocess.run(["date", "+%Y-%m-%d %H:%M:%S"], 
                                       capture_output=True, text=True).stdout.strip()
        }, f, indent=2)
    
    print(f"\n📄 报告已保存至 apk_size_{report.build_number}.json")

if __name__ == "__main__":
    import sys
    build_num = sys.argv[1] if len(sys.argv) > 1 else "unknown"
    report = analyze_apk(build_num)
    generate_report(report)
```

## 优化策略

### 1. 图片优化

```yaml
# pubspec.yaml
flutter:
  assets:
    # 使用 WebP 格式
    - images/route_default.webp
    
  # 启用资源压缩
  uses-material-design: true
```

```dart
// 使用压缩图片
Image.asset(
  'images/route.jpg',
  cacheWidth: 1080, // 限制缓存大小
)
```

### 2. 代码优化

```bash
# 启用代码混淆和压缩
flutter build apk --release --obfuscate --split-debug-info=symbols

# 使用 split-per-abi 减少体积
flutter build apk --release --split-per-abi
```

### 3. 资源清理

```bash
# 检查未使用的资源
flutter pub run flutter_launcher_icons:main

# 移除调试资源
# 确保 release 构建不包含测试数据
```

### 4. Native 库优化

```gradle
// android/app/build.gradle
android {
    defaultConfig {
        ndk {
            // 只包含必要的 ABI
            abiFilters 'armeabi-v7a', 'arm64-v8a'
        }
    }
    
    buildTypes {
        release {
            // 启用资源压缩
            shrinkResources true
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt')
        }
    }
}
```

## CI/CD 集成

```yaml
# .github/workflows/apk-size-check.yml
name: APK Size Check

on: [push, pull_request]

jobs:
  check-size:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        
      - name: Build APK
        run: flutter build apk --release
        
      - name: Check Size
        run: |
          SIZE=$(stat -c%s build/app/outputs/flutter-apk/app-release.apk)
          SIZE_MB=$((SIZE / 1024 / 1024))
          echo "APK Size: ${SIZE_MB}MB"
          
          if [ $SIZE_MB -gt 80 ]; then
            echo "❌ APK too large!"
            exit 1
          elif [ $SIZE_MB -gt 50 ]; then
            echo "⚠️  APK size warning"
          else
            echo "✅ APK size OK"
          fi
```

## 报告模板

```markdown
## APK 大小监控报告 - Build #XXX

### 概览
| 指标 | 目标 | 实际 | 状态 |
|------|------|------|------|
| APK 大小 | < 50MB | 48MB | ✅ PASS |
| 安装大小 | < 80MB | 67MB | ✅ PASS |

### 组件分析
| 组件 | 大小 | 占比 |
|------|------|------|
| lib/ | 8MB | 16.7% |
| assets/ | 7MB | 14.6% |
| res/ | 15MB | 31.3% |
| classes.dex | 5MB | 10.4% |
| 其他 | 13MB | 27.0% |

### 趋势
- 较上版本: +2MB
- 主要增长: 新增路线图片资源

### 行动项
- [ ] 优化图片资源压缩
- [ ] 考虑 CDN 加载大图
```

## 版本记录

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| v1.0 | 2026-03-19 | 初版完成 |
