# 轨迹采集功能交叉 Review 报告

> **Review 类型**: Dev Review Product/Design  
> **Review 日期**: 2026-03-20  
> **Review 人员**: Dev Team  
> **文档版本**: v1.0

---

## 1. Review 概述

本次 Review 对比了以下文档与代码实现：
- **Product**: `TRAIL-RECORDING-PRD.md`
- **Design**: `TRAIL-RECORDING-DESIGN.md`, `TRAIL-RECORDING-UI.md`
- **Code**: `lib/screens/recording_screen.dart`, `lib/screens/recordings_list_screen.dart`, `lib/models/recording_model.dart`, `lib/services/recording_service.dart`, `lib/widgets/poi_marker_dialog.dart`

---

## 2. 不一致问题清单

### 2.1 P0 级别问题（必须修复）

| 序号 | 问题描述 | 严重程度 | 位置 | 建议修复 |
|------|----------|----------|------|----------|
| P0-1 | **入口位置不一致** | P0 | 代码/设计 | PRD 设计入口在"我的页面 - 我的采集"，但代码中入口为首页 FAB 按钮，需要统一 |
| P0-2 | **缺失录制前准备页面** | P0 | 代码 | PRD 和 Design 都要求有"路线信息预填写"页面（名称、城市、路线类型等），代码中直接进入录制，缺失此流程 |
| P0-3 | **缺失审核流程** | P0 | 代码 | PRD 明确要求"提交审核→审核中→已通过/未通过"流程，代码中 `uploadTrail` 后直接标记 `isUploaded=true`，无审核状态管理 |
| P0-4 | **采集资格验证缺失** | P0 | 代码 | PRD 要求所有用户可申请，需资格验证，代码中无此权限控制逻辑 |
| P0-5 | **缺失录制后编辑页面** | P0 | 代码 | PRD 和 Design 都有"录制后编辑"页面（封面图、路线描述、标签等），代码中直接使用 Dialog 上传，无此页面 |

### 2.2 P1 级别问题（建议修复）

| 序号 | 问题描述 | 严重程度 | 位置 | 建议修复 |
|------|----------|----------|------|----------|
| P1-1 | **POI 类型不一致** | P1 | 代码/Design | Design 规范 POI 类型：起点(#4CAF50)、终点(#2D968A)、路口(#FF9800)、观景点(#3B9EFF)、卫生间(#8B7355)、补给点(#FFB800)、危险点(#EF5350)、休息点(#9C27B0)；代码中颜色实现与规范不符，且部分图标使用 Flutter 默认图标而非设计图标 |
| P1-2 | **深色模式支持不完整** | P1 | 代码 | Design 要求默认深色模式，代码中 `recording_screen.dart` 使用 `Colors.white` 硬编码，未使用 Design System Token |
| P1-3 | **按钮布局不一致** | P1 | 代码/Design | Design 要求底部操作栏：[标记POI][拍照][暂停][结束]，72px 圆形按钮；代码中为 [列表][主控制][标记]，布局与规格不符 |
| P1-4 | **缺失照片独立标记功能** | P1 | 代码 | PRD 区分"POI照片"和"轨迹照片"，代码中只能给 POI 添加照片，无法独立拍摄轨迹照片 |
| P1-5 | **省电模式未实现** | P1 | 代码 | Design 要求电量<20%时提示省电模式，代码中无此功能 |
| P1-6 | **GPS 信号弱处理不完整** | P1 | 代码 | PRD 要求 GPS 信号弱时顶部状态栏变红、数据区显示"--"、标记低精度点；代码中仅有过滤逻辑，无 UI 反馈 |
| P1-7 | **数据面板字体不一致** | P1 | 代码/Design | Design 要求数值使用 DIN Alternate Bold 32px，代码中使用默认字体 |
| P1-8 | **录制状态指示器动画不符** | P1 | 代码/Design | Design 要求录制指示器为"呼吸灯效果"(1.5s循环)，代码中使用 FadeTransition 但频率和效果与规范不符 |

### 2.3 P2 级别问题（优化建议）

| 序号 | 问题描述 | 严重程度 | 位置 | 建议修复 |
|------|----------|----------|------|----------|
| P2-1 | **缺失首次引导流程** | P2 | 代码 | PRD 要求 3 步引导页（功能介绍、POI标记、审核说明），代码中缺失 |
| P2-2 | **缺失草稿箱功能** | P2 | 代码 | PRD 要求草稿箱管理（自动保存、草稿列表、继续编辑），代码中仅有本地存储，无草稿箱 UI |
| P2-3 | **轨迹回放功能缺失** | P2 | 代码 | PRD 要求录制后支持轨迹回放动画，代码中无此功能 |
| P2-4 | **准备页面 GPS/电量状态检测** | P2 | 代码/PRD | PRD 要求开始录制前检测 GPS/电量/存储空间，代码中无此准备页面 |
| P2-5 | **自动检测停留标记 POI** | P2 | 代码 | PRD 要求系统检测停留(>5分钟, <50m)自动提示添加 POI，代码中未实现 |
| P2-6 | **状态栏信息不完整** | P2 | 代码/Design | Design 要求状态栏显示：GPS信号、录制状态、时间、电量、存储；代码中缺失存储空间显示 |
| P2-7 | **拍照无压缩处理** | P2 | 代码 | PRD 要求照片压缩最大 1080px 宽、JPEG 80%质量；代码中 `imageQuality: 85`，但无尺寸限制 |
| P2-8 | **缺失重新编辑提交限制** | P2 | 代码 | PRD 要求最多重新编辑提交 3 次，代码中无此限制 |

---

## 3. 详细分析

### 3.1 Product PRD 审查

#### 3.1.1 已实现功能 ✓

| 功能点 | 代码位置 | 实现程度 |
|--------|----------|----------|
| GPS 轨迹记录 | `recording_service.dart` | 已实现（1秒采样） |
| 实时数据显示 | `recording_screen.dart` | 已实现（距离、时长、爬升） |
| POI 标记 | `poi_marker_dialog.dart` | 基本实现（8种类型） |
| 暂停/继续/结束 | `recording_service.dart` | 已实现 |
| 本地存储 | `recording_service.dart` | 已实现（SharedPreferences） |
| 轨迹上传 | `recording_service.dart` | 基本实现 |

#### 3.1.2 未实现/不一致功能 ✗

| 功能点 | PRD 要求 | 代码现状 | 差距 |
|--------|----------|----------|------|
| 采集资格申请 | 需申请审核 | 无此逻辑 | 完全缺失 |
| 录制前准备页 | 必填：路线名称、城市、路线类型 | 直接进入录制 | 完全缺失 |
| 审核流程 | 提交→审核中→通过/拒绝 | 直接标记已上传 | 完全缺失 |
| 录制后编辑页 | 封面图、描述、标签、提交审核 | Dialog 直接上传 | 流程缺失 |
| 我的采集列表 | 按状态分类（草稿/审核中/已通过/未通过） | 仅显示未完成录制 | 状态不全 |
| 首次引导 | 3步引导页 | 无 | 完全缺失 |
| 草稿箱 | 自动保存、草稿列表 | 仅有本地存储 | UI 缺失 |
| 轨迹回放 | 支持播放动画 | 无 | 完全缺失 |

### 3.2 Design 设计审查

#### 3.2.1 界面还原度评估

| 页面 | 设计规格 | 代码实现 | 还原度 |
|------|----------|----------|--------|
| 录制中主界面 | 深色模式、底部4按钮(72px)、数据面板(DIN字体) | 浅色、3按钮布局、默认字体 | 60% |
| POI标记弹窗 | 底部滑出、8类型图标、56px圆形背景 | 基本实现，但图标颜色不符 | 70% |
| 我的采集列表 | 卡片高度100px、状态标签、缩略图 | 基本实现，状态显示不全 | 75% |
| 顶部状态栏 | GPS信号、录制状态、时间、电量、存储 | 缺失存储显示 | 80% |

#### 3.2.2 设计 Token 使用检查

| Token 类型 | 设计规范 | 代码使用 | 状态 |
|------------|----------|----------|------|
| `--recording-active` | `#2D968A` | `Colors.red` (硬编码) | ❌ 不一致 |
| `--recording-paused` | `#FFC107` | `Colors.orange` | ⚠️ 近似 |
| `--recording-ended` | `#EF5350` | `Colors.red` | ⚠️ 近似 |
| `--data-number` | `#2D968A` / `#4DB6AC` | `Colors.black` | ❌ 不一致 |
| `--gps-strong` | `#4CAF50` | 未明确使用 | ⚠️ 缺失 |
| `--gps-weak` | `#EF5350` | 未明确使用 | ⚠️ 缺失 |
| `--poi-start` | `#4CAF50` | `Colors.green` | ⚠️ 近似 |
| `--poi-end` | `#2D968A` | `Colors.red` | ❌ 不一致 |
| `--poi-danger` | `#EF5350` | `Colors.red.shade700` | ⚠️ 近似 |
| `--dark-bg` | `#0F1419` | `Colors.white` | ❌ 不一致 |

#### 3.2.3 交互逻辑一致性

| 交互 | 设计规范 | 代码实现 | 状态 |
|------|----------|----------|------|
| 按钮按下反馈 | scale(0.95) + 背景加深 | 无明确反馈 | ❌ 缺失 |
| 按钮释放反馈 | 弹性恢复 200ms | 无动画 | ❌ 缺失 |
| 录制指示器呼吸 | 1.5s 循环 | 1s 循环 | ⚠️ 不符 |
| 位置脉冲效果 | 2s 扩散波纹 | 未实现 | ❌ 缺失 |
| 结束录制确认 | 弹窗显示数据概览 | 简单 AlertDialog | ⚠️ 简化 |

### 3.3 代码与设计一致性详细对比

#### 3.3.1 录制中页面布局对比

**设计规范 (TRAIL-RECORDING-UI.md):**
```
┌─────────────────────────────┐
│ 44px  状态栏 (GPS/录制状态/电量/存储)  │
├─────────────────────────────┤
│                             │
│         地图区域 (占剩余空间)  │
│                             │
├─────────────────────────────┤
│ 80px  数据面板 (DIN字体 32px) │
├─────────────────────────────┤
│ 122px 底部操作栏             │
│ [标记POI][拍照]  [暂停][结束]│
│   72px    72px   72px  72px  │
└─────────────────────────────┘
```

**代码实现 (recording_screen.dart):**
```
┌─────────────────────────────┐
│ 状态栏 (毛玻璃效果卡片)        │
├─────────────────────────────┤
│                             │
│         地图区域              │
│                             │
├─────────────────────────────┤
│ 底部控制面板 (白色背景)        │
│ [列表][主控制按钮][标记]      │
│   56px   80px      56px     │
└─────────────────────────────┘
```

**差异分析:**
1. 按钮数量和布局不符：设计4个按钮，代码3个按钮
2. 按钮尺寸不符：设计72px，代码56px/80px混用
3. 背景颜色不符：设计深色模式优先，代码使用白色
4. 数据面板位置：设计在地图下方，代码集成在顶部卡片

#### 3.3.2 POI 类型颜色对比

| 类型 | 设计 Token | 设计颜色 | 代码颜色 | 状态 |
|------|------------|----------|----------|------|
| 起点 | `--poi-start` | `#4CAF50` | `Colors.green` | ⚠️ 近似 |
| 终点 | `--poi-end` | `#2D968A` | `Colors.red` | ❌ 错误 |
| 路口 | `--poi-junction` | `#FF9800` | `Colors.blue` | ❌ 错误 |
| 观景点 | `--poi-viewpoint` | `#3B9EFF` | `Colors.purple` | ❌ 错误 |
| 卫生间 | `--poi-restroom` | `#8B7355` | `Colors.cyan` | ❌ 错误 |
| 补给点 | `--poi-supply` | `#FFB800` | `Colors.orange` | ⚠️ 近似 |
| 危险点 | `--poi-danger` | `#EF5350` | `Colors.red.shade700` | ⚠️ 近似 |
| 休息点 | `--poi-rest` | `#9C27B0` | `Colors.teal` | ❌ 错误 |

---

## 4. 用户故事验收检查

| 用户故事 | 验收标准 | 实现状态 | 备注 |
|----------|----------|----------|------|
| US-001 | 采集资格申请 | ❌ 未实现 | 无申请表单和审核流程 |
| US-002 | 录制轨迹 | ✓ 已实现 | 基础功能完成 |
| US-003 | POI标记 | ⚠️ 部分实现 | 缺少自动检测停留 |
| US-004 | 轨迹预览 | ⚠️ 部分实现 | 无回放动画功能 |
| US-005 | 提交审核 | ❌ 未实现 | 无审核流程 |
| US-006 | 查看记录和状态 | ⚠️ 部分实现 | 状态分类不完整 |
| US-007 | 查看拒绝原因 | ❌ 未实现 | 无审核流程 |
| US-008 | 保存草稿 | ⚠️ 部分实现 | 有本地存储但无草稿箱UI |

---

## 5. 推荐修复优先级

### 5.1 Sprint 1 (必须完成)

1. **P0-2**: 实现录制前准备页面（路线信息预填写）
2. **P0-5**: 实现录制后编辑页面（封面图、描述、标签）
3. **P0-3**: 实现审核流程（提交审核、审核状态跟踪）
4. **P1-1**: 统一 POI 类型颜色与 Design Token 一致
5. **P1-3**: 调整底部操作栏布局与 Design 一致

### 5.2 Sprint 2 (建议完成)

1. **P0-1**: 统一入口位置（与 Product 确认最终方案）
2. **P0-4**: 实现采集资格验证流程
3. **P1-2**: 完成深色模式支持
4. **P1-4**: 实现独立轨迹照片拍摄
5. **P1-7**: 使用 DIN Alternate 字体显示数据

### 5.3 Sprint 3 (优化项)

1. **P2-1**: 实现首次引导流程
2. **P2-2**: 实现草稿箱功能
3. **P2-3**: 实现轨迹回放功能
4. **P2-5**: 实现自动检测停留标记 POI
5. 完善异常处理（GPS弱、电量低、存储不足）

---

## 6. 技术建议

### 6.1 代码结构建议

```
lib/
├── screens/
│   ├── recording/
│   │   ├── recording_entry_screen.dart      # 入口（资格检查）
│   │   ├── recording_preparation_screen.dart # 准备页面（P0-2）
│   │   ├── recording_screen.dart            # 录制中（需重构）
│   │   ├── recording_edit_screen.dart       # 编辑页面（P0-5）
│   │   └── recording_preview_screen.dart    # 预览/回放（P2-3）
│   └── my_recordings/
│       ├── my_recordings_screen.dart        # 我的采集列表
│       ├── draft_box_screen.dart            # 草稿箱（P2-2）
│       └── recording_detail_screen.dart     # 详情/审核状态
├── widgets/
│   ├── recording/
│   │   ├── recording_status_bar.dart        # 状态栏组件
│   │   ├── recording_data_panel.dart        # 数据面板组件
│   │   ├── recording_controls.dart          # 底部控制栏
│   │   └── poi/
│   │       ├── poi_selector.dart            # POI选择器
│   │       ├── poi_type_chip.dart           # POI类型芯片
│   │       └── poi_marker_card.dart         # POI卡片
├── models/
│   └── recording/
│       ├── recording_session.dart           # 录制会话模型
│       ├── poi_marker.dart                  # POI模型
│       └── trail_submission.dart            # 提交流程模型
└── services/
    └── recording/
        ├── recording_service.dart           # 录制核心服务
        ├── draft_service.dart               # 草稿服务（P2-2）
        └── submission_service.dart          # 提交流程服务
```

### 6.2 状态管理建议

当前代码使用 `ChangeNotifier` 进行状态管理，建议：

1. **审核状态枚举扩展:**
```dart
enum RecordingStatus {
  idle,
  recording,
  paused,
  finished,
  draft,           // 草稿
  pendingReview,   // 审核中
  approved,        // 已通过
  rejected,        // 未通过
}
```

2. **独立状态管理:**
   - 录制状态（RecordingService）
   - 草稿状态（DraftService）
   - 提交流程状态（SubmissionService）

### 6.3 Design Token 应用建议

创建 `recording_theme.dart`：

```dart
class RecordingTheme {
  // 录制专用颜色
  static const Color recordingActive = Color(0xFF2D968A);
  static const Color recordingPaused = Color(0xFFFFC107);
  static const Color recordingEnded = Color(0xFFEF5350);
  
  // POI 类型颜色
  static const Map<PoiType, Color> poiColors = {
    PoiType.start: Color(0xFF4CAF50),
    PoiType.end: Color(0xFF2D968A),
    PoiType.junction: Color(0xFFFF9800),
    // ...
  };
  
  // 数据字体
  static const TextStyle dataValueStyle = TextStyle(
    fontFamily: 'DIN Alternate',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Color(0xFF4DB6AC),
  );
}
```

---

## 7. 结论

### 7.1 总体评估

| 维度 | 评分 | 说明 |
|------|------|------|
| 功能完整性 | 60% | 核心录制功能完成，但审核流程、准备/编辑页面缺失 |
| 设计还原度 | 65% | 基础布局实现，但颜色、字体、交互细节与规范不符 |
| 代码质量 | 75% | 结构清晰，但部分硬编码颜色需要提取到 Design System |
| PRD 符合度 | 55% | 主要流程缺失（申请、审核、编辑） |

### 7.2 风险点

1. **审核流程缺失** (P0-3)：Product 核心要求未实现，影响发布
2. **入口位置争议** (P0-1)：Product 和 Design 方案不一致，需产品决策
3. **深色模式缺失** (P1-2)：Design 要求默认深色模式，当前为浅色

### 7.3 下一步行动

1. **产品确认**：确认入口位置方案（首页 FAB vs 我的页面）
2. **优先级排序**：按 Sprint 计划修复 P0/P1 问题
3. **设计走查**：修复后邀请 Design 团队进行视觉走查
4. **测试覆盖**：补充录制流程的集成测试

---

**报告完成**  
*生成时间: 2026-03-20*
