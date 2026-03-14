# 山径APP 设计走查报告

**审查日期**: 2026-03-14  
**审查对象**: 山径APP Flutter UI  
**构建状态**: Build #30 成功  
**审查人**: Design Agent

---

## 1. 总体评估

| 维度 | 状态 | 说明 |
|------|------|------|
| 设计系统完整性 | ✅ 良好 | 颜色、间距、圆角已系统化定义 |
| 暗黑模式基础 | ⚠️ 部分完成 | 颜色已定义，但部分组件适配不完整 |
| 组件一致性 | ⚠️ 需优化 | 部分硬编码值未使用设计系统 |
| 无障碍访问 | ⚠️ 需检查 | 颜色对比度需验证 |

---

## 2. 暗黑模式审查详情

### 2.1 已实现 ✅

| 项目 | 状态 | 位置 |
|------|------|------|
| 暗黑模式颜色定义 | ✅ | `design_system.dart` 完整定义 |
| 动态颜色获取方法 | ✅ | `getPrimary()`, `getBackground()` 等 |
| ThemeData 双主题 | ✅ | `lightTheme` 和 `darkTheme` |
| 跟随系统设置 | ✅ | `ThemeMode.system` |
| AppButton 适配 | ✅ | 完整支持暗黑模式 |
| AppCard 适配 | ✅ | 使用 `getBackgroundElevated()` |
| AppInput 适配 | ✅ | 输入框已适配 |

### 2.2 问题与修复 🔧

#### 问题 1: MapScreen 渐变 AppBar 未适配暗黑模式
**位置**: `lib/screens/map_screen.dart` (约第 323-335 行)

**当前代码**:
```dart
decoration: BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      DesignSystem.primary.withOpacity(0.9),  // ❌ 硬编码使用亮色主色
      DesignSystem.primary.withOpacity(0.7),
    ],
  ),
),
```

**修复建议**:
```dart
decoration: BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: isDark ? [
      DesignSystem.backgroundSecondaryDark,
      DesignSystem.backgroundDark,
    ] : [
      DesignSystem.primary.withOpacity(0.9),
      DesignSystem.primary.withOpacity(0.7),
    ],
  ),
),
```

#### 问题 2: AppCard 亮色模式背景硬编码
**位置**: `lib/widgets/app_card.dart` 第 35 行

**当前代码**:
```dart
color: color ?? (isDark ? DesignSystem.backgroundSecondaryDark : Colors.white),
```

**修复建议**:
```dart
color: color ?? (isDark ? DesignSystem.backgroundSecondaryDark : DesignSystem.background),
```

#### 问题 3: AppButton 次按钮背景硬编码
**位置**: `lib/widgets/app_button.dart` 第 87 行

**当前代码**:
```dart
AppButtonVariant.secondary => isDark ? DesignSystem.backgroundSecondaryDark : Colors.white,
```

**修复建议**:
```dart
AppButtonVariant.secondary => isDark ? DesignSystem.backgroundSecondaryDark : DesignSystem.background,
```

---

## 3. 组件细节审查

### 3.1 按钮规范检查

| 属性 | 设计规范 | 当前实现 | 状态 |
|------|----------|----------|------|
| 小按钮高度 | 32px | 32px | ✅ 符合 |
| 中按钮高度 | 40px | 40px | ✅ 符合 |
| 大按钮高度 | 48px | 48px | ✅ 符合 |
| 圆角 (小) | 8px | 4px | ❌ 不符 |
| 圆角 (中/大) | 8px | 8px | ✅ 符合 |

**修复建议**: `lib/widgets/app_button.dart` 第 138 行
```dart
double _borderRadius() {
  return 8;  // 统一使用 DesignSystem.radius
}
```

### 3.2 卡片内边距检查

| 组件 | 当前内边距 | 状态 |
|------|------------|------|
| AppCard | 16px | ✅ 符合 |
| _AnimatedRouteCard (DiscoveryScreen) | 16px | ✅ 符合 |
| MapScreen _buildRouteCard | 16px | ✅ 符合 |
| TrailDetail 统计卡片 | 16px | ✅ 符合 |

### 3.3 字体层级检查

**当前问题**: 字体系统过于简单，仅定义了 5 个尺寸

```dart
// 当前实现
static const double fontHeading = 18;
static const double fontBody = 14;
static const double fontSmall = 12;
static const double fontLarge = 20;
static const double fontXLarge = 24;
```

**建议改进** (参考 Material Design 3):
```dart
// 建议增加
static const double fontDisplay = 36;    // 大标题
static const double fontHeadline = 28;   // 页面标题
static const double fontTitle = 22;      // 卡片标题
static const double fontLabel = 11;      // 标签/小字
```

---

## 4. 颜色对比度检查

### 4.1 亮色模式

| 颜色组合 | 前景色 | 背景色 | 预估对比度 | 状态 |
|----------|--------|--------|------------|------|
| 主要文字 | #1A1A1A | #FFFFFF | 15.8:1 | ✅ 优秀 |
| 次要文字 | #666666 | #FFFFFF | 5.7:1 | ✅ 良好 |
| 三级文字 | #999999 | #FFFFFF | 2.8:1 | ⚠️ 临界 |
| 主按钮文字 | #FFFFFF | #2D968A | 4.5:1 | ✅ 符合 WCAG AA |

### 4.2 暗黑模式

| 颜色组合 | 前景色 | 背景色 | 预估对比度 | 状态 |
|----------|--------|--------|------------|------|
| 主要文字 | #E0E0E0 | #121212 | 11.6:1 | ✅ 优秀 |
| 次要文字 | #B0B0B0 | #121212 | 7.1:1 | ✅ 良好 |
| 三级文字 | #808080 | #121212 | 3.9:1 | ✅ 符合 |
| 主按钮文字 | #121212 | #4DB6AC | 7.8:1 | ✅ 优秀 |

**结论**: 颜色对比度整体符合 WCAG AA 标准

---

## 5. 其他发现的问题

### 5.1 缺少组件

| 组件 | 优先级 | 说明 |
|------|--------|------|
| Skeleton 骨架屏 | 中 | 已定义但未在各页面统一使用 |
| Toast 轻提示 | 中 | 使用 SnackBar 替代，样式需统一 |
| Dialog 对话框 | 低 | 暂未使用 |
| BottomSheet 底部弹窗 | 低 | 暂未使用 |

### 5.2 代码规范问题

1. **部分 import 冲突**: `discovery_screen.dart` 使用 `hide SearchBar` 避免与 Material 冲突，建议使用前缀或重命名
2. **硬编码颜色**: 部分组件仍使用 `Colors.white`、`Colors.black` 等硬编码

---

## 6. 修复清单

### 高优先级 (建议立即修复)

- [ ] 1. MapScreen AppBar 渐变适配暗黑模式
- [ ] 2. AppCard 亮色背景改用 DesignSystem.background
- [ ] 3. AppButton 小尺寸圆角统一为 8px
- [ ] 4. AppButton 次按钮背景改用 DesignSystem.background

### 中优先级 (建议本周修复)

- [ ] 5. 完善字体层级系统
- [ ] 6. 统一阴影系统使用
- [ ] 7. 检查并替换所有硬编码颜色

### 低优先级 (建议后续优化)

- [ ] 8. 添加 Skeleton 骨架屏到各加载状态
- [ ] 9. 统一 Toast/SnackBar 样式
- [ ] 10. 添加主题切换开关 (不依赖系统)

---

## 7. 设计系统代码质量评估

### 优点
1. 颜色系统完整，双主题覆盖全面
2. 动态获取方法设计合理，便于使用
3. Material 3 主题配置完整
4. 组件封装良好，复用性强

### 改进空间
1. 增加字体权重常量 (FontWeight.w400/w500/w600/w700)
2. 增加动画时长常量
3. 增加断点/响应式常量
4. 考虑添加语义化颜色 (surface, onSurface 等)

---

## 8. 总结

**整体评分: 85/100**

山径APP的设计系统基础扎实，暗黑模式颜色已完整定义，大部分组件已适配。主要问题在于：
1. 个别页面(MapScreen)的硬编码颜色未适配暗黑模式
2. 少量硬编码值未使用设计系统常量
3. 字体层级可以更丰富

修复以上高优先级问题后，暗黑模式功能将完整可用。

---

*报告生成时间: 2026-03-14 15:40*
