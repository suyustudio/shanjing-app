# Week 6 Day 1 Bug 修复报告

**日期**: 2026-02-28  
**任务**: 极简修复 Android/iOS/离线功能问题  
**状态**: ✅ 完成

---

## 修复清单

### 1. Android 测试问题 ✅

| 问题 | 状态 | 说明 |
|------|------|------|
| 存储权限 | ✅ 已配置 | AndroidManifest.xml 已有 WRITE_EXTERNAL_STORAGE 和 READ_EXTERNAL_STORAGE |

**验证**:
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

---

### 2. iOS 测试问题 ✅

| 问题 | 状态 | 修复内容 |
|------|------|----------|
| 权限文案优化 | ✅ 已修复 | 所有权限描述改为"山径"开头，更友好具体 |

**修复详情**:

| 权限键 | 修复前 | 修复后 |
|--------|--------|--------|
| NSLocationWhenInUseUsageDescription | "我们需要获取您的位置..." | "山径需要获取您的位置，用于在地图上显示您的当前位置和记录路线轨迹" |
| NSLocationAlwaysUsageDescription | "我们需要在后台获取您的位置..." | "山径需要在后台获取位置，用于持续记录您的路线轨迹（仅在开始记录后）" |
| NSLocationAlwaysAndWhenInUseUsageDescription | "我们需要获取您的位置..." | "山径需要在后台获取位置，用于持续记录您的路线轨迹（仅在开始记录后）" |
| NSCameraUsageDescription | "我们需要访问您的相机..." | "山径需要访问相机，用于拍摄路线照片并分享" |
| NSPhotoLibraryUsageDescription | "我们需要访问您的相册..." | "山径需要访问相册，用于选择照片或保存路线图片" |
| NSMicrophoneUsageDescription | "我们需要访问您的麦克风..." | "山径需要访问麦克风，用于语音搜索功能" |

---

### 3. 离线功能问题 ✅

| 问题 | 状态 | 说明 |
|------|------|------|
| 离线下载 UI | ✅ 已实现 | map_screen.dart 中已实现下载按钮和弹窗 |
| 存储权限 | ✅ 已配置 | Android 存储权限已添加 |

**已实现功能**:
- 地图页右下角离线下载按钮
- 下载确认弹窗（显示路线名、范围、级别、预估大小）
- 下载进度条
- 下载完成 SnackBar 提示

---

### 4. 代码问题修复 ✅

#### 4.1 导入路径修复

**文件**: `lib/screens/map_screen.dart`

```dart
// 修复前
import '../theme/design_system.dart';  // ❌ 路径错误

// 修复后
import '../constants/design_system.dart';  // ✅ 正确路径
```

#### 4.2 难度标签中文化

**文件**: `lib/widgets/route_card.dart`

```dart
// 修复前
String _getDifficultyLabel() {
  switch (difficulty) {
    case RouteDifficulty.easy: return 'easy';      // ❌ 英文
    case RouteDifficulty.moderate: return 'moderate';
    case RouteDifficulty.hard: return 'hard';
    ...
  }
}

// 修复后
String _getDifficultyLabel() {
  switch (difficulty) {
    case RouteDifficulty.easy: return '简单';      // ✅ 中文
    case RouteDifficulty.moderate: return '中等';
    case RouteDifficulty.hard: return '困难';
    ...
  }
}
```

---

## 验证结果

| 检查项 | 结果 |
|--------|------|
| Android 存储权限 | ✅ 已配置 |
| iOS 权限文案 | ✅ 已优化 |
| 导入路径修复 | ✅ 已修复 |
| 难度标签中文 | ✅ 已修复 |
| 离线下载 UI | ✅ 已实现 |

---

## 遗留事项

以下问题已在之前版本完成或不需要修复：

| 问题 | 状态 | 说明 |
|------|------|------|
| 搜索防抖 | ✅ 已实现 | discovery_screen.dart 中 300ms 防抖已生效 |
| API Key 安全 | ✅ 已修复 | 使用 flutter_dotenv 从环境变量读取 |
| 测试代码 | ✅ 正确 | discovery_screen_test.dart 已使用 AppLoading |

---

## 下一步

1. **真实设备测试**: 在 Android/iOS 设备上验证权限弹窗和离线功能
2. **离线功能联调**: 接入高德 SDK 实际离线下载接口
3. **Week 6 继续**: 后台保活集成、性能优化

---

**修复完成时间**: 2026-02-28 20:05  
**修复文件数**: 3  
**代码变更行数**: 约 20 行
