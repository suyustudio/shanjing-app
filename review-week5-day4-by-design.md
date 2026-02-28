# Design Review Report - Week 5 Day 4

**Review Date**: 2026-02-28  
**Reviewer**: Design Agent  
**Review Scope**: UI Implementation Review  
**Files Reviewed**:
1. `lib/screens/discovery_screen.dart`
2. `lib/screens/map_screen.dart`
3. `lib/screens/profile_screen.dart`

**Reference Design**: `design-hifi-v1.0.md` (高保真设计文档)

---

## 1. Discovery Screen (发现页)

### 1.1 设计还原度 ✅ 良好

| 检查项 | 状态 | 备注 |
|--------|------|------|
| 页面结构 | ✅ | 搜索栏 + FilterTags + 路线列表，符合设计稿布局 |
| 搜索栏 | ✅ | 使用 SearchBar 组件，带阴影效果 |
| 筛选标签 | ✅ | FilterTags 组件，支持全部/简单/中等/困难筛选 |
| 路线卡片 | ✅ | RouteCard 组件，图片+名称+距离/时长信息 |
| 列表滚动 | ✅ | ListView.builder 实现，性能良好 |

### 1.2 设计一致性 ⚠️ 部分问题

| 检查项 | 当前实现 | 设计规范 | 问题等级 |
|--------|----------|----------|----------|
| AppBar 样式 | 默认 Material AppBar | 需要自定义样式 | 🟡 Low |
| 页面边距 | 16px (硬编码) | 应使用 DesignSystem.spacingMedium | 🟡 Low |
| 列表项间距 | 12px (硬编码) | 应使用 DesignSystem.spacingSmall | 🟡 Low |
| 空状态样式 | 简单 Text | 需要设计空状态 UI | 🟡 Low |

### 1.3 视觉细节 ⚠️ 需改进

| 检查项 | 当前 | 设计规范 | 建议 |
|--------|------|----------|------|
| 搜索栏圆角 | `DesignSystem.spacingLarge` (24px) | 设计稿为 22px (胶囊形) | 保持一致性 |
| 筛选标签圆角 | 16px | 符合设计 | ✅ |
| 路线卡片阴影 | `opacity(0.05), blurRadius: 4` | 轻微，可接受 | ✅ |
| 加载状态 | `CircularProgressIndicator` | 需要骨架屏 shimmer 效果 | 🟡 建议优化 |

### 1.4 遗漏检查

| 功能 | 状态 | 说明 |
|------|------|------|
| 难度标签颜色 | ❌ 缺失 | RouteCard 未显示难度标签及颜色 |
| 评分显示 | ❌ 缺失 | 设计稿要求显示 ⭐4.8 评分 |
| 浏览量 | ❌ 缺失 | 设计稿要求显示 👁️ 浏览数 |
| 封面图加载状态 | ⚠️ 基础 | 有 loadingBuilder 但缺少 shimmer 骨架屏 |
| 空状态设计 | ❌ 缺失 | 需要专门的空状态 UI |

---

## 2. Map Screen (地图页)

### 2.1 设计还原度 ⚠️ 中等

| 检查项 | 状态 | 备注 |
|--------|------|------|
| 高德地图集成 | ✅ | AMapWidget 正常显示 |
| 轨迹绘制 | ✅ | Polyline 绘制 33 个坐标点 |
| 标记点 | ✅ | Marker 显示 3 个测试路线 |
| 路线卡片浮层 | ⚠️ 基础 | 有 Card 但样式较简单 |
| 搜索栏 | ⚠️ 部分 | 使用了 SearchBar 但缺少视图切换 Tab |
| 筛选标签 | ✅ | FilterTags 集成 |

### 2.2 设计一致性 ❌ 多处不符

| 检查项 | 当前实现 | 设计规范 | 问题等级 |
|--------|----------|----------|----------|
| AppBar 背景色 | `Colors.green` | 应为透明/白色，滚动渐变 | 🔴 High |
| AppBar 标题 | "杭州西湖" | 应为 "发现" 或当前区域名 | 🟡 Medium |
| 轨迹颜色 | `Colors.green` | 应根据难度使用不同颜色 | 🟡 Medium |
| 搜索栏位置 | 浮动在地图上方 | 设计稿在顶部，带视图切换 | 🟡 Medium |
| 地图控制按钮 | ❌ 缺失 | 定位/图层/缩放按钮缺失 | 🔴 High |

### 2.3 视觉细节 ❌ 需大幅改进

| 检查项 | 当前 | 设计规范 | 建议 |
|--------|------|----------|------|
| AppBar 颜色 | 绿色 | 应透明，滚动后变白 | 实现滚动渐变效果 |
| 轨迹线条宽度 | 5px | 设计稿为 2px | 调整宽度 |
| 路线卡片样式 | 基础 Card | 需要圆角 12px，阴影更明显 | 参考设计稿 3.6 节 |
| 标记点样式 | 默认 Marker | 需要水滴形难度色标记 | 自定义 Marker 图标 |
| 用户位置标记 | 默认蓝点 | 需要外圈+内圈+方向箭头 | 自定义定位样式 |

### 2.4 遗漏检查 (严重)

| 功能 | 状态 | 优先级 |
|------|------|--------|
| 视图切换 Tab (列表/地图) | ❌ 缺失 | 🔴 P0 |
| 地图控制按钮组 | ❌ 缺失 | 🔴 P0 |
| 底部筛选栏 | ❌ 缺失 | 🔴 P0 |
| 难度颜色标记点 | ❌ 缺失 | 🟡 P1 |
| 聚合标记点 | ❌ 缺失 | 🟡 P1 |
| 路线卡片箭头指向 | ❌ 缺失 | 🟡 P1 |
| 用户位置脉冲动画 | ❌ 缺失 | 🟢 P2 |

---

## 3. Profile Screen (我的页面)

### 3.1 设计还原度 ⚠️ 中等

| 检查项 | 状态 | 备注 |
|--------|------|------|
| 页面结构 | ✅ | 用户信息 + 统计 + 设置列表 |
| 用户头像 | ⚠️ 基础 | 使用 Icon，缺少真实头像支持 |
| 统计区域 | ⚠️ 部分 | 只有 1 个统计项，设计稿有 3 个 |
| 设置列表 | ⚠️ 基础 | 缺少图标背景和分类 |

### 3.2 设计一致性 ❌ 多处不符

| 检查项 | 当前实现 | 设计规范 | 问题等级 |
|--------|----------|----------|----------|
| 头像尺寸 | 80px | 符合设计 | ✅ |
| 头像边框 | 无 | 应有 2px 浅品牌色边框 | 🟡 Medium |
| 统计区域样式 | 简单 Row | 应为卡片样式，带阴影 | 🔴 High |
| 统计数值颜色 | `Colors.green` | 应为 `DesignSystem.primary` #2D968A | 🔴 High |
| 功能列表图标 | 默认灰色 | 应有彩色背景图标 | 🔴 High |
| 设置项分隔线 | 默认 Divider | 应有缩进分隔线 | 🟡 Medium |

### 3.3 视觉细节 ❌ 需改进

| 检查项 | 当前 | 设计规范 | 建议 |
|--------|------|----------|------|
| 用户昵称字号 | 20px | 符合设计 | ✅ |
| 用户 ID 显示 | ❌ 缺失 | 应显示 "ID: 128392" | 添加用户 ID |
| 编辑资料入口 | ❌ 缺失 | 应有 "编辑资料 >" | 添加编辑入口 |
| 统计数值字体 | 默认 | 应为 DIN Alternate | 使用数字字体 |
| 统计数值字号 | 24px | 设计稿为 28px | 调大字号 |
| 统计标签颜色 | `Colors.grey.shade600` | 应为 #9CA3AF | 使用设计系统颜色 |
| 功能图标背景 | 无 | 40px 圆形彩色背景 | 添加图标容器 |

### 3.4 遗漏检查

| 功能 | 状态 | 优先级 |
|------|------|--------|
| 用户 ID 显示 | ❌ 缺失 | 🟡 P1 |
| 编辑资料入口 | ❌ 缺失 | 🟡 P1 |
| 统计卡片样式 | ❌ 缺失 | 🔴 P0 |
| 三列统计数据 | ❌ 缺失 (只有1列) | 🔴 P0 |
| 功能图标彩色背景 | ❌ 缺失 | 🔴 P0 |
| 版本信息 | ❌ 缺失 | 🟢 P2 |
| 未登录状态 | ❌ 缺失 | 🟡 P1 |

---

## 4. 组件级 Review

### 4.1 SearchBar 组件

| 检查项 | 状态 | 备注 |
|--------|------|------|
| 使用 DesignSystem | ✅ | `DesignSystem.background`, `DesignSystem.spacingLarge` |
| 阴影效果 | ✅ | 有轻微阴影 |
| 清除按钮 | ✅ | 输入后显示清除 |
| 圆角 | ⚠️ | 使用 `spacingLarge` (24px)，设计稿为 22px |

### 4.2 FilterTags 组件

| 检查项 | 状态 | 备注 |
|--------|------|------|
| 标签列表 | ✅ | 全部/简单/中等/困难 |
| ChoiceChip 使用 | ✅ | 符合 Material 规范 |
| 选中样式 | ⚠️ | `selectedColor: Theme.of(context).primaryColor`，应使用 DesignSystem.primary |
| 圆角 | ✅ | 16px 符合设计 |

### 4.3 RouteCard 组件

| 检查项 | 状态 | 备注 |
|--------|------|------|
| 图片加载 | ✅ | 有 loadingBuilder 和 errorBuilder |
| 信息展示 | ⚠️ | 缺少难度标签、评分 |
| 阴影 | ✅ | 轻微阴影 |
| 圆角 | ✅ | 8px 符合设计 |
| 点击反馈 | ❌ | 无视觉反馈 |

---

## 5. 设计系统使用情况

### 5.1 DesignSystem 常量定义

```dart
// lib/constants/design_system.dart
static const Color primary = Color(0xFF2D968A);
static const Color background = Color(0xFFFFFFFF);
static const Color textPrimary = Color(0xFF1A1A1A);
static const Color textSecondary = Color(0xFF666666);

static const double fontHeading = 18;
static const double fontBody = 14;
static const double fontSmall = 12;

static const double spacingSmall = 8;
static const double spacingMedium = 16;
static const double spacingLarge = 24;

static const double radius = 8;
```

### 5.2 使用情况统计

| 文件 | 使用 DesignSystem | 硬编码值 | 覆盖率 |
|------|-------------------|----------|--------|
| discovery_screen.dart | 部分 | 多处 16, 12 等 | ~30% |
| map_screen.dart | 极少 | Colors.green 等 | ~10% |
| profile_screen.dart | 极少 | Colors.green, grey 等 | ~10% |
| search_bar.dart | 较好 | 使用 background, spacing | ~70% |
| filter_tags.dart | 无 | 全部硬编码 | 0% |
| route_card.dart | 无 | 全部硬编码 | 0% |

---

## 6. 优先级修复清单

### 🔴 P0 - 必须修复 (阻塞发布)

| 序号 | 问题 | 文件 | 建议方案 |
|------|------|------|----------|
| 1 | MapScreen AppBar 颜色错误 | map_screen.dart | 改为透明背景，实现滚动渐变 |
| 2 | 缺少视图切换 Tab | map_screen.dart | 添加 "列表/地图" 切换 Tab |
| 3 | 缺少地图控制按钮 | map_screen.dart | 添加定位/图层/缩放按钮 |
| 4 | Profile 统计区域样式错误 | profile_screen.dart | 改为卡片样式，3列布局 |
| 5 | 功能列表缺少彩色图标 | profile_screen.dart | 添加 40px 圆形彩色背景图标 |

### 🟡 P1 - 建议修复 (影响体验)

| 序号 | 问题 | 文件 | 建议方案 |
|------|------|------|----------|
| 6 | RouteCard 缺少难度标签 | route_card.dart | 添加难度标签及颜色 |
| 7 | RouteCard 缺少评分 | route_card.dart | 添加 ⭐ 评分显示 |
| 8 | Profile 缺少用户 ID | profile_screen.dart | 添加 "ID: xxx" 显示 |
| 9 | Profile 缺少编辑资料入口 | profile_screen.dart | 添加 "编辑资料 >" |
| 10 | 地图轨迹颜色固定 | map_screen.dart | 根据难度动态设置颜色 |
| 11 | 筛选标签未使用 DesignSystem | filter_tags.dart | 替换为 DesignSystem 常量 |
| 12 | 路线卡片未使用 DesignSystem | route_card.dart | 替换为 DesignSystem 常量 |

### 🟢 P2 - 优化建议 (提升品质)

| 序号 | 问题 | 文件 | 建议方案 |
|------|------|------|----------|
| 13 | 添加骨架屏加载效果 | discovery_screen.dart | 使用 shimmer 骨架屏 |
| 14 | 添加空状态 UI | discovery_screen.dart | 设计专门的空状态页面 |
| 15 | 地图标记点自定义 | map_screen.dart | 使用水滴形难度色标记 |
| 16 | 添加版本信息 | profile_screen.dart | 底部显示 "山径 v1.0.0" |
| 17 | 添加未登录状态 | profile_screen.dart | 设计游客模式 UI |

---

## 7. 总结

### 整体评估

| 维度 | 评分 | 说明 |
|------|------|------|
| 设计还原度 | 6/10 | 基础结构正确，但细节差距较大 |
| 设计一致性 | 4/10 | DesignSystem 使用率偏低 |
| 视觉细节 | 5/10 | 主要功能实现，但缺少精细打磨 |
| 完整性 | 5/10 | 多个关键元素遗漏 |

### 主要问题

1. **DesignSystem 使用率低**: 大量硬编码颜色、间距值，需要全面替换
2. **MapScreen 差距最大**: AppBar 颜色、视图切换、控制按钮等关键元素缺失
3. **Profile 统计区域**: 与设计稿差距较大，需要重新实现
4. **组件级细节**: RouteCard 缺少难度、评分等关键信息

### 下一步建议

1. **立即修复 P0 问题**: 特别是 MapScreen 的 AppBar 和视图切换
2. **全面应用 DesignSystem**: 创建 lint 规则或代码审查清单
3. **补充遗漏元素**: 按 P1 清单逐项补充
4. **设计走查流程**: 建立设计-开发对照检查机制

---

**Report Generated**: 2026-02-28  
**Next Review**: Week 5 Day 5
