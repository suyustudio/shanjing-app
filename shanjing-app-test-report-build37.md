# 山径APP Build #37 测试报告

## 测试任务概述
- **测试版本**: v1.0.0+1 (Build #37)
- **APK大小**: 20.2 MB
- **测试日期**: 2026-03-04
- **已知问题**: 真机启动白屏/黑屏（界面展不开）

## APK 获取状态

### 问题
GitHub Actions 工件下载需要身份验证。直接访问 `https://api.github.com/repos/suyustudio/shanjing-app/actions/artifacts/5742837216/zip` 返回 401 错误：
```json
{
  "message": "Requires authentication",
  "documentation_url": "https://docs.github.com/rest",
  "status": "401"
}
```

### 获取 APK 的替代方案
1. **GitHub Personal Access Token**: 使用具有 `actions:read` 权限的 PAT
2. **手动下载**: 从 GitHub Actions 页面手动下载工件
3. **Release 页面**: 如果 APK 已发布到 Release 页面

## 测试用例准备

### 1. 安装测试
| 测试项 | 预期结果 | 优先级 |
|--------|----------|--------|
| 正常安装 | 安装成功，无报错 | P0 |
| 覆盖安装 | 升级成功，数据保留 | P1 |
| 存储空间不足 | 提示存储不足 | P2 |

### 2. 启动测试
| 测试项 | 预期结果 | 优先级 |
|--------|----------|--------|
| 冷启动 | 3秒内显示主界面 | P0 |
| 热启动 | 1秒内恢复界面 | P0 |
| 白屏/黑屏检测 | 无白屏/黑屏 | P0 |
| 后台恢复 | 正常恢复界面 | P1 |

### 3. 权限测试
| 测试项 | 预期结果 | 优先级 |
|--------|----------|--------|
| 定位权限申请 | 首次启动时申请 | P0 |
| 权限拒绝处理 | 优雅降级或提示 | P0 |
| 权限设置跳转 | 可跳转系统设置 | P1 |

### 4. 功能测试
| 测试项 | 预期结果 | 优先级 |
|--------|----------|--------|
| 地图加载 | 地图正常显示 | P0 |
| 定位功能 | 获取当前位置 | P0 |
| 导航功能 | 路径规划正常 | P0 |
| 离线地图 | 缓存功能正常 | P1 |

## 云真机测试方案

### 方案一：Firebase Test Lab
```bash
# 安装 gcloud CLI
curl https://sdk.cloud.google.com | bash

# 运行测试
gcloud firebase test android run \
  --type robo \
  --app app-release.apk \
  --device model=redfin,version=30,locale=zh_CN,orientation=portrait \
  --device model=oriole,version=33,locale=zh_CN,orientation=portrait \
  --timeout 10m
```

### 方案二：AWS Device Farm
```bash
# 使用 AWS CLI 上传 APK
aws devicefarm create-upload \
  --project-arn arn:aws:devicefarm:us-west-2:account:project:xxx \
  --name shanjing-app-build37.apk \
  --type ANDROID_APP
```

### 方案三：本地模拟器测试
```bash
# 创建模拟器
avdmanager create avd -n test_device -k "system-images;android-30;google_apis;x86_64"

# 启动模拟器
emulator -avd test_device -no-window -gpu swiftshader_indirect

# 安装 APK
adb install app-release.apk

# 启动应用并收集日志
adb logcat -c
adb shell am start -n com.suyustudio.shanjing/.MainActivity
adb logcat -d > logcat.txt
```

## 日志收集要点

### Flutter 相关日志
```bash
# 过滤 Flutter 引擎日志
adb logcat -s flutter:D

# 完整日志
adb logcat -v threadtime > full_logcat.txt
```

### 关键检查项
1. `FlutterEngine` 初始化日志
2. `Surface` 创建和渲染日志
3. `Activity` 生命周期回调
4. 权限申请日志
5. 地图 SDK 初始化日志

## 下一步行动

### 需要用户协助
1. **提供 APK 文件**: 由于 GitHub Actions 工件需要认证，请提供以下之一：
   - GitHub Personal Access Token (具有 `actions:read` 权限)
   - 直接上传 APK 文件
   - 发布到 GitHub Release 页面

2. **选择测试平台**: 
   - Firebase Test Lab (推荐，免费额度充足)
   - AWS Device Farm
   - 本地 Android 模拟器

### 测试环境准备
- [ ] 获取 APK 文件
- [ ] 配置云测试平台
- [ ] 准备测试设备列表
- [ ] 编写自动化测试脚本

---
**报告生成时间**: 2026-03-04 12:30 GMT+8
**状态**: 等待 APK 文件以继续测试
