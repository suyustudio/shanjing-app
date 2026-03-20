# 轨迹采集功能 P0 问题修复报告

**修复日期:** 2026-03-21  
**修复人:** AI Assistant  
**状态:** ✅ 已完成

---

## 修复清单完成情况

### 1. 入口位置修复 ✅
**问题:** PRD要求"我的页面-我的采集"，代码中为首页FAB

**修复内容:**
- 移除 `discovery_screen.dart` 中的FAB入口
- 在 `profile_screen.dart` 中添加"我的采集"入口
- 入口权限控制：
  - 未登录用户显示登录引导
  - 已登录用户直接进入采集列表

**文件修改:**
- `lib/screens/discovery_screen.dart` - 移除FAB
- `lib/screens/profile_screen.dart` - 添加入口和权限检查

---

### 2. 录制前准备页面 ✅
**问题:** 缺少路线信息预填写页面

**修复内容:**
- 创建 `RecordingPreparationScreen`
- 功能包括：
  - 路线名称输入（必填）
  - 城市/区域输入（必填）
  - 路线类型选择（徒步/登山/骑行）
  - 难度预估（休闲/轻度/进阶/挑战）带颜色标识
  - GPS/电量/存储检测
  - 设备就绪状态显示

**新增文件:**
- `lib/screens/recording_preparation_screen.dart`

---

### 3. 审核流程实现 ✅
**问题:** 代码中直接标记isUploaded，无审核状态

**修复内容:**
- 修改 `RecordingStatus` 枚举，添加提交审核相关状态
- 新增 `SubmissionStatus` 枚举：draft/submitted/reviewing/approved/rejected
- 录制列表按状态分Tab筛选（草稿/审核中/已通过/已拒绝）
- 审核详情页面显示拒绝原因
- 重新编辑功能（最多3次提交限制）
- 状态徽章颜色区分

**文件修改:**
- `lib/models/recording_model.dart` - 新增状态枚举和字段
- `lib/screens/recordings_list_screen.dart` - 完整重写支持审核流程
- `lib/services/recording_service.dart` - 添加提交审核方法

---

### 4. 采集资格验证 ✅
**问题:** 无权限控制逻辑

**修复内容:**
- 创建采集资格申请页面 `RecordingQualificationScreen`
- 申请状态管理：未申请/审核中/已通过/已拒绝
- 申请表单（申请原因、户外经验）
- 入口根据资格状态控制
- 状态视觉反馈

**新增文件:**
- `lib/screens/recording_qualification_screen.dart`
- `lib/models/recording_model.dart` - 添加 `CollectorQualificationStatus` 枚举

---

### 5. 录制后编辑页面 ✅
**问题:** 使用Dialog直接上传，无编辑页面

**修复内容:**
- 创建 `RecordingEditScreen`
- 功能包括：
  - 轨迹预览（占位，可扩展）
  - 路线信息编辑（名称、城市、描述）
  - 标签管理（添加/删除，最多10个）
  - 封面图选择（从POI照片中选择）
  - POI列表管理（删除）
  - 统计信息展示
  - 保存草稿按钮
  - 提交审核按钮（带确认对话框）

**新增文件:**
- `lib/screens/recording_edit_screen.dart`

---

### 6. 颜色系统统一 ✅
**问题:** 大量使用硬编码Colors.white/Colors.red等

**修复内容:**
- 统一使用 DesignSystem 方法：
  - `getPrimary()`, `getBackground()`, `getSurface()`
  - `getTextPrimary()`, `getTextSecondary()`, `getTextTertiary()`
  - `getSuccess()`, `getWarning()`, `getError()`, `getInfo()`
  - `getDivider()`, `getBorder()`
- 修复所有硬编码颜色

**文件修改:**
- `lib/screens/recording_screen.dart` - 全面颜色统一
- `lib/widgets/poi_marker_dialog.dart` - 颜色统一
- `lib/screens/recordings_list_screen.dart` - 颜色统一

---

### 7. 深色模式支持 ✅
**问题:** Design要求深色模式优先，代码使用浅色主题

**修复内容:**
- 所有背景色使用 `DesignSystem.getBackground(context)`
- 所有文字色使用 `DesignSystem.getTextPrimary(context)` 等方法
- 面板使用 `DesignSystem.getSurface(context)`
- 阴影使用 `DesignSystem.getShadow(context)`

**已修复文件:**
- `lib/screens/recording_screen.dart`
- `lib/screens/recording_preparation_screen.dart`
- `lib/screens/recording_edit_screen.dart`
- `lib/screens/recording_onboarding_screen.dart`
- `lib/screens/recording_qualification_screen.dart`
- `lib/screens/recordings_list_screen.dart`
- `lib/widgets/poi_marker_dialog.dart`

---

### 8. 权限引导完善 ✅
**问题:** 只申请了定位权限

**修复内容:**
- 创建 `PermissionService` 统一管理权限
- 顺序申请：位置 → 相机 → 存储
- 每个权限都有引导说明
- 权限拒绝引导弹窗（可跳转到设置）
- 首次使用权限引导

**新增文件:**
- `lib/services/permission_service.dart`

---

### 9. 首次使用引导 ✅
**问题:** 缺少3步引导页

**修复内容:**
- 创建 `RecordingOnboardingScreen`
- 第1步：功能介绍（GPS定位、海拔统计、时长记录）
- 第2步：POI标记说明（观景点、补给点、危险点等）
- 第3步：审核流程说明（提交→审核→发布）
- 本地标记是否已引导（SharedPreferences）
- 可跳过引导

**新增文件:**
- `lib/screens/recording_onboarding_screen.dart`

---

## 文件修改清单

### 修改文件
1. `lib/screens/recording_screen.dart` - 颜色、深色模式
2. `lib/screens/recordings_list_screen.dart` - 审核状态、完整重写
3. `lib/screens/discovery_screen.dart` - 移除FAB
4. `lib/screens/profile_screen.dart` - 添加入口
5. `lib/widgets/poi_marker_dialog.dart` - 颜色统一
6. `lib/models/recording_model.dart` - 状态枚举更新、新增字段
7. `lib/services/recording_service.dart` - 审核流程、新增方法

### 新增文件
1. `lib/screens/recording_preparation_screen.dart` - 录制前准备
2. `lib/screens/recording_edit_screen.dart` - 录制后编辑
3. `lib/screens/recording_onboarding_screen.dart` - 首次使用引导
4. `lib/screens/recording_qualification_screen.dart` - 采集资格申请
5. `lib/services/permission_service.dart` - 权限引导

---

## 新增模型和枚举

### 枚举
- `SubmissionStatus` - 提交审核状态：draft/submitted/reviewing/approved/rejected
- `TrailType` - 路线类型：hiking/mountaineering/cycling
- `DifficultyLevel` - 难度级别：casual/easy/moderate/hard
- `CollectorQualificationStatus` - 采集资格状态：notApplied/pending/approved/rejected

### 数据类
- `RecordingPreparationData` - 录制准备数据
- `CollectorQualification` - 采集资格申请
- `SubmissionResult` - 提交审核结果

---

## 用户流程

```
1. 用户点击"我的采集"
   ↓
2. 检查登录状态
   ↓ 未登录
   └── 显示登录引导
   ↓ 已登录
3. 检查采集资格
   ↓ 未申请/已拒绝
   └── 显示资格申请页面
   ↓ 审核中
   └── 显示等待页面
   ↓ 已通过
4. 首次使用？
   ↓ 是
   └── 显示3步引导页
5. 进入录制列表
   ↓
6. 点击"新建采集"
   ↓
7. 显示准备页面（填写信息+设备检测）
   ↓
8. 进入录制页面
   ↓
9. 结束录制
   ↓
10. 显示编辑页面
    ↓
11. 保存草稿 / 提交审核
    ↓
12. 录制列表显示审核状态
```

---

## 后续建议

### P1 待修复项
1. 轨迹地图预览组件实现
2. 录制服务与准备页面的数据传递
3. 实际API对接（目前使用模拟数据）
4. 电池和存储检测的实际实现
5. 采集资格的API对接

### P2 待修复项
1. POI编辑功能完善
2. 封面图裁剪功能
3. 轨迹回放功能
4. 批量删除功能
5. 搜索和筛选功能

---

## 依赖说明

修复过程中使用的依赖包：
- `shared_preferences` - 本地存储（已存在）
- `permission_handler` - 权限管理（已存在）
- `app_settings` - 跳转到系统设置（可能需要添加）

如需添加缺失依赖：
```yaml
dependencies:
  app_settings: ^5.1.1
```

---

**修复完成，准备进入P1修复阶段。**