# Design Review QA - 交叉评审报告

> **评审日期**: 2026-03-19  
> **评审人**: Design Agent  
> **评审对象**: QA Agent 产出（测试用例、自动化脚本、测试计划）  
> **设计规范依据**: design-hifi-v1.0.md, design-system-dark-mode-v1.0.md, shanjing-share-design.md

---

## 1. 评审概述

### 1.1 QA Agent 产出清单

| 产出项 | 文档路径 | 主要内容 |
|--------|----------|----------|
| 测试用例 | `test-cases-trails.md` | 路线收藏、异常场景 API 测试 |
| 自动化框架 | `test-automation-setup.md` | Jest 基础配置 |
| 性能基准 | `TEST-REPORT-v1.0.0+1.md` | 静态分析、代码审查 |
| 实地测试计划 | `M4-FIELD-TEST-PLAN.md` | 西湖环湖线功能验证 |
| 导航测试计划 | `flutter-navigation-test-plan.md` | 单元/集成测试方案 |
| 埋点规范测试 | `data-tracking-spec-v1.2.md` | 事件触发验证 |
| 暗黑模式测试 | `test/widgets/dark_mode_test.dart` | 组件暗黑模式渲染 |
| 设计系统测试 | `test/constants/design_system_test.dart` | 设计 Token 单元测试 |

### 1.2 评审结论总览

| 评审维度 | 覆盖率 | 状态 | 主要问题 |
|----------|--------|------|----------|
| UI/UX 视觉测试 | **45%** | ⚠️ 部分覆盖 | 缺少高保真设计规范对照测试 |
| 暗黑模式测试 | **60%** | ⚠️ 基础覆盖 | 缺少对比度自动化检查 |
| 动画/交互测试 | **20%** | ❌ 严重不足 | 无动画测试方法 |
| 设计一致性 | **70%** | ✅ 基本覆盖 | 缺少设计走查环节 |

**总体评价**: QA 产出在功能测试层面完整，但在**视觉验收、动画交互、暗黑模式深度测试**方面存在明显缺失。

---

## 2. UI/UX 测试覆盖评估

### 2.1 视觉验收测试分析

#### ✅ 已覆盖项目

| 测试项 | 测试文件 | 覆盖内容 | 评价 |
|--------|----------|----------|------|
| 颜色常量定义 | `design_system_test.dart` | 验证 DesignSystem 颜色常量存在 | ✅ 基础覆盖 |
| 字体常量定义 | `design_system_test.dart` | 验证字号常量定义 | ✅ 基础覆盖 |
| 间距常量定义 | `design_system_test.dart` | 验证 spacing 常量定义 | ✅ 基础覆盖 |
| 圆角常量定义 | `design_system_test.dart` | 验证 radius 常量定义 | ✅ 基础覆盖 |
| 主题数据定义 | `design_system_test.dart` | 验证 lightTheme/darkTheme 存在 | ✅ 基础覆盖 |

#### ❌ 缺失的视觉测试项

| 缺失测试项 | 设计规范来源 | 重要性 | 建议优先级 |
|------------|--------------|--------|------------|
| **精确色值验证** | design-hifi-v1.0.md | P0 | 高 |
| **字体渲染测试** | design-hifi-v1.0.md (1.4.1) | P1 | 高 |
| **精确间距测量** | design-hifi-v1.0.md (1.5) | P1 | 中 |
| **组件尺寸验证** | design-hifi-v1.0.md | P1 | 中 |
| **图片圆角验证** | design-hifi-v1.0.md (1.3.1) | P2 | 中 |
| **阴影效果验证** | design-system-dark-mode-v1.0.md | P2 | 低 |

#### 🔍 详细缺失分析

**1. 精确色值验证（关键缺失）**

设计规范定义了精确颜色值，但测试仅验证常量存在，未验证实际色值：

```dart
// 设计规范定义 (design-hifi-v1.0.md)
// 难度标签背景色: 休闲:#4CAF50 / 轻度:#8BC34A / 进阶:#FF9800 / 挑战:#F44336
// 路线名称颜色: #111827
// 评分图标颜色: #FFB800

// 当前测试仅验证:
expect(DesignSystem.primary, isA<Color>()); // ❌ 未验证具体色值
```

**建议增加测试**:
```dart
test('难度标签颜色符合规范', () {
  expect(DesignSystem.difficultyEasy, equals(Color(0xFF4CAF50)));
  expect(DesignSystem.difficultyMedium, equals(Color(0xFF8BC34A)));
  expect(DesignSystem.difficultyHard, equals(Color(0xFFFF9800)));
  expect(DesignSystem.difficultyExtreme, equals(Color(0xFFF44336)));
});
```

**2. 字体渲染测试（关键缺失）**

设计规范定义了精确字体规格，但无对应测试：

| 规范项 | 设计值 | 测试覆盖 |
|--------|--------|----------|
| 路线名称字号 | 22px, Semibold | ❌ 未测试 |
| 评分数值字号 | 16px, Semibold | ❌ 未测试 |
| 核心数据数字 | 具体数值展示 | ❌ 未测试 |
| 正文内容字号 | 14px, Regular | ❌ 未测试 |

**3. 精确间距测量（重要缺失）**

设计规范定义了详细间距系统：

```
// design-hifi-v1.0.md 定义
封面图区域高度: 200px (固定)
左右边距: 16px
路线名称上边距: 16px
核心数据区高度: 88px
```

当前测试仅验证 `spacingSmall=8` 等常量，未验证实际应用间距。

---

### 2.2 动画/交互测试分析

#### ❌ 动画测试严重缺失

| 动画场景 | 设计规范定义 | 测试覆盖 | 状态 |
|----------|--------------|----------|------|
| 页面切换动画 | FadeTransition, 300ms | ❌ 无测试 | 🔴 缺失 |
| 列表加载动画 | 渐入动画，交错效果 | ❌ 无测试 | 🔴 缺失 |
| 卡片点击反馈 | 缩放反馈(0.95) | ❌ 无测试 | 🔴 缺失 |
| 封面图加载动画 | shimmer, 1.5s | ❌ 无测试 | 🔴 缺失 |
| 底部导航切换 | 状态保持，无闪烁 | ❌ 无测试 | 🔴 缺失 |
| 收藏按钮动画 | 心形图标变化 | ❌ 无测试 | 🔴 缺失 |
| SOS 倒计时动画 | 5秒倒计时动画 | ❌ 无测试 | 🔴 缺失 |

#### 📝 建议增加的动画测试

```dart
// test/animations/page_transition_test.dart
testWidgets('页面切换使用 FadeTransition 300ms', (tester) async {
  await tester.pumpWidget(TestApp());
  
  // 触发页面切换
  await tester.tap(find.text('开始导航'));
  await tester.pump();
  
  // 验证动画类型和时长
  final fadeTransition = find.byType(FadeTransition);
  expect(fadeTransition, findsOneWidget);
  
  // 验证动画时长
  await tester.pump(Duration(milliseconds: 300));
  // 验证动画完成状态
});

// test/animations/loading_shimmer_test.dart
testWidgets('封面图加载显示 shimmer 动画', (tester) async {
  await tester.pumpWidget(TrailDetailPage());
  
  // 模拟加载状态
  await tester.pump(Duration.zero);
  
  // 验证 shimmer 动画存在
  expect(find.byType(Shimmer), findsOneWidget);
  
  // 验证动画循环
  await tester.pump(Duration(seconds: 2));
  // 验证动画持续存在
});
```

#### ❌ 交互手势测试缺失

| 交互场景 | 设计定义 | 测试覆盖 |
|----------|----------|----------|
| 列表滚动惯性 | 流畅滚动 | ❌ 未测试 |
| 卡片拖拽排序 | 可拖拽交互 | ❌ 未测试 |
| 地图缩放手势 | 双指缩放 | ❌ 未测试 |
| 图片查看手势 | 双击放大 | ❌ 未测试 |
| 下拉刷新 | 弹性回弹 | ❌ 未测试 |

---

## 3. 暗黑模式测试评估

### 3.1 已覆盖项目

| 测试项 | 测试文件 | 覆盖内容 | 评价 |
|--------|----------|----------|------|
| 组件暗黑模式渲染 | `dark_mode_test.dart` | 11个组件暗黑模式 widget 测试 | ✅ 组件级覆盖 |
| 暗黑模式颜色常量 | `design_system_test.dart` | primaryDarkMode 等常量存在 | ✅ 基础覆盖 |
| 主题亮度设置 | `design_system_test.dart` | brightness: Brightness.dark | ✅ 基础覆盖 |
| Material3 启用 | `design_system_test.dart` | useMaterial3: true | ✅ 基础覆盖 |

### 3.2 暗黑模式专项测试缺失

#### 🔴 关键缺失：对比度检查

设计规范要求对比度 ≥ 4.5:1，但无自动化测试：

| 文字层级 | 设计色值 | 背景色值 | 预期对比度 | 测试覆盖 |
|----------|----------|----------|------------|----------|
| 主文字 `--dark-text-primary` | #F0F6FC | #0A0F14 | 15.8:1 | ❌ 未自动测试 |
| 次文字 `--dark-text-secondary` | #C9D1D9 | #0A0F14 | 10.2:1 | ❌ 未自动测试 |
| 三级文字 `--dark-text-tertiary` | #8B949E | #0A0F14 | 6.1:1 | ❌ 未自动测试 |
| 禁用文字 `--dark-text-disabled` | #484F58 | #0A0F14 | 2.8:1 | ❌ 未自动测试 |

**建议增加 WCAG 对比度自动化检查**:

```dart
// test/accessibility/contrast_test.dart
test('暗黑模式主文字对比度符合 WCAG AA', () {
  final textColor = DesignSystem.darkTextPrimary;
  final bgColor = DesignSystem.darkBgPrimary;
  final contrast = calculateContrast(textColor, bgColor);
  
  expect(contrast, greaterThanOrEqualTo(4.5)); // WCAG AA 标准
});

test('暗黑模式按钮文字对比度符合 WCAG AA', () {
  final buttonText = DesignSystem.darkBgPrimary; // 深色背景上
  final buttonBg = DesignSystem.darkPrimary; // 品牌色按钮
  final contrast = calculateContrast(buttonText, buttonBg);
  
  expect(contrast, greaterThanOrEqualTo(4.5));
});
```

#### 🔴 关键缺失：暗黑模式可读性测试

| 可读性场景 | 设计规范 | 测试覆盖 |
|------------|----------|----------|
| 文字在图片上的可读性 | 渐变遮罩确保可读性 | ❌ 未测试 |
| 小字号文字可读性 | 12px 文字清晰 | ❌ 未测试 |
| 禁用状态可识别性 | 禁用状态明显区分 | ❌ 未测试 |
| 链接文字可识别性 | 链接色与正文区分 | ❌ 未测试 |

#### 🟡 部分缺失：暗黑模式组件状态

设计规范定义了完整的组件状态样式，但测试覆盖不完整：

| 组件 | 状态 | 设计定义 | 测试覆盖 |
|------|------|----------|----------|
| 主按钮 | Default/Hover/Pressed/Disabled | 完整色值定义 | ⚠️ 仅测试 Default |
| 次按钮 | Default/Hover/Pressed/Disabled | 完整色值定义 | ⚠️ 仅测试 Default |
| 输入框 | Default/Focus/Error/Disabled | 完整样式定义 | ⚠️ 仅测试 Default |
| 卡片 | Default/Hover | 背景/边框变化 | ⚠️ 仅测试 Default |

**建议增加状态测试**:

```dart
// test/widgets/button_states_dark_test.dart
testWidgets('主按钮暗黑模式悬浮状态', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: DesignSystem.darkTheme,
      home: Scaffold(
        body: AppButton(label: '测试', onPressed: () {}),
      ),
    ),
  );
  
  // 获取按钮初始背景色
  final initialBg = findButtonBgColor(tester);
  expect(initialBg, equals(DesignSystem.darkPrimary));
  
  // 模拟悬浮
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: tester.getCenter(find.byType(AppButton)));
  await tester.pump();
  
  // 验证悬浮状态背景色
  final hoverBg = findButtonBgColor(tester);
  expect(hoverBg, equals(DesignSystem.darkPrimaryLight));
});
```

### 3.3 暗黑模式地图适配测试缺失

设计规范定义了地图暗黑模式配色，但无测试覆盖：

```dart
// 设计规范 (design-system-dark-mode-v1.0.md)
// 路线轨迹: #2D968A (浅色) -> #4DB6AC (暗黑)
// 当前位置: #2D968A -> #4DB6AC
// 起点标记: #4CAF50 -> #66BB6A
// 终点标记: #EF5350 -> #F87171

// 建议增加测试:
test('地图路线暗黑模式颜色映射正确', () {
  expect(MapStyles.darkMode.routeColor, equals(Color(0xFF4DB6AC)));
  expect(MapStyles.darkMode.currentLocationColor, equals(Color(0xFF4DB6AC)));
  expect(MapStyles.darkMode.startPointColor, equals(Color(0xFF66BB6A)));
  expect(MapStyles.darkMode.endPointColor, equals(Color(0xFFF87171)));
});
```

---

## 4. 设计一致性评估

### 4.1 设计规范引用情况

#### ✅ 已引用设计规范

| 规范文档 | 引用方式 | 评价 |
|----------|----------|------|
| design-system-dark-mode-v1.0.md | 通过 DesignSystem 常量引用 | ✅ 正确引用 |
| shanjing-share-design.md | 实地测试计划中分享测试步骤引用 | ✅ 功能引用 |
| design-hifi-v1.0.md | 未直接引用 | ❌ 缺失 |

#### ❌ 缺失的设计规范引用

**1. 高保真设计规范未映射到测试**

设计规范定义了精确的像素级规范，但测试用例未引用：

| 设计规范章节 | 规范内容 | 测试映射 |
|--------------|----------|----------|
| 1.3.1 封面图区域 | 高度 200px, 圆角 0 0 12px 12px | ❌ 未映射 |
| 1.3.3 难度标签 | 内边距 4px 8px, 圆角 4px | ❌ 未映射 |
| 1.4.1 路线名称 | 字号 22px, 字重 600, 行高 30px | ❌ 未映射 |
| 1.5 核心数据区 | 高度 88px | ❌ 未映射 |

**建议增加像素级测试**:

```dart
// test/visual/pixel_perfect_test.dart
testWidgets('路线详情页封面图区域符合设计规范', (tester) async {
  await tester.pumpWidget(TrailDetailPage());
  
  final coverImage = find.byType(CoverImage);
  final size = tester.getSize(coverImage);
  
  // 验证高度
  expect(size.height, equals(200.0));
  
  // 验证圆角（通过 Container decoration）
  final container = tester.widget<Container>(coverImage);
  final decoration = container.decoration as BoxDecoration;
  final borderRadius = decoration.borderRadius as BorderRadius;
  expect(borderRadius.bottomLeft.x, equals(12.0));
  expect(borderRadius.bottomRight.x, equals(12.0));
});
```

### 4.2 设计走查环节缺失

#### ❌ 缺少设计走查清单

建议 QA 测试计划中增加**设计走查环节**：

```markdown
## 设计走查检查清单

### 视觉走查
- [ ] 所有页面与设计稿对比，像素级检查
- [ ] 颜色使用符合设计规范，无自定义色值
- [ ] 字体使用符合规范，无系统默认字体
- [ ] 间距使用 DesignSystem 常量
- [ ] 圆角使用 DesignSystem 常量
- [ ] 阴影效果符合规范

### 暗黑模式走查
- [ ] 所有页面支持暗黑模式
- [ ] 图片在暗黑模式下有适当遮罩
- [ ] 对比度符合 WCAG AA 标准
- [ ] 地图使用暗黑主题

### 动画走查
- [ ] 页面切换动画符合规范(300ms, ease-in-out)
- [ ] 列表加载动画流畅
- [ ] 按钮点击反馈明显
- [ ] 加载状态有动画指示

### 交互走查
- [ ] 按钮可点击区域 >= 44x44pt
- [ ] 列表滚动流畅，无卡顿
- [ ] 手势操作响应及时
```

#### ❌ 缺少视觉回归测试

建议增加视觉回归测试方案：

```dart
// 使用 golden_toolkit 进行视觉回归测试
testGoldens('路线详情页视觉回归测试', (tester) async {
  final builder = DeviceBuilder()
    ..overrideDevicesForAllScenarios(devices: [
      Device.phone,
      Device.iphone11,
    ])
    ..addScenario(
      widget: TrailDetailPage(),
      name: 'trail_detail_light',
    )
    ..addScenario(
      widget: TrailDetailPage(themeMode: ThemeMode.dark),
      name: 'trail_detail_dark',
    );
    
  await tester.pumpDeviceBuilder(builder);
  await screenMatchesGolden(tester, 'trail_detail');
});
```

---

## 5. 建议增加的测试场景

### 5.1 高优先级补充测试

#### 1. 像素级视觉回归测试

```dart
// test/visual/golden_test.dart
group('路线详情页像素级测试', () {
  testGoldens('封面图区域', (tester) async {
    await tester.pumpWidget(TrailDetailPage());
    await screenMatchesGolden(tester, 'trail_detail_cover');
  });
  
  testGoldens('核心数据区', (tester) async {
    await tester.pumpWidget(TrailDetailPage());
    await screenMatchesGolden(tester, 'trail_detail_stats');
  });
});
```

#### 2. WCAG 对比度自动化检查

```dart
// test/accessibility/wcag_contrast_test.dart
group('WCAG 对比度检查', () {
  test('所有文字对比度符合 AA 标准', () {
    final colorPairs = [
      (DesignSystem.darkTextPrimary, DesignSystem.darkBgPrimary),
      (DesignSystem.darkTextSecondary, DesignSystem.darkBgPrimary),
      (DesignSystem.darkTextTertiary, DesignSystem.darkBgPrimary),
      (DesignSystem.darkBgPrimary, DesignSystem.darkPrimary), // 按钮
    ];
    
    for (final (text, bg) in colorPairs) {
      final contrast = calculateContrast(text, bg);
      expect(contrast, greaterThanOrEqualTo(4.5),
        reason: 'Contrast between $text and $bg is $contrast, should be >= 4.5');
    }
  });
});
```

#### 3. 动画时长和曲线测试

```dart
// test/animations/timing_test.dart
group('动画规范测试', () {
  testWidgets('页面切换动画时长 300ms', (tester) async {
    await tester.pumpWidget(TestApp());
    
    final stopwatch = Stopwatch()..start();
    await tester.tap(find.text('开始导航'));
    await tester.pumpAndSettle();
    stopwatch.stop();
    
    expect(stopwatch.elapsedMilliseconds, closeTo(300, 50));
  });
});
```

### 5.2 中优先级补充测试

#### 4. 组件状态全面测试

```dart
// test/widgets/component_states_test.dart
group('组件状态样式测试', () {
  testWidgets('按钮所有状态颜色正确', (tester) async {
    final states = [
      (WidgetState.hovered, DesignSystem.darkPrimaryLight),
      (WidgetState.pressed, DesignSystem.darkPrimaryDark),
      (WidgetState.disabled, DesignSystem.darkPrimary.withOpacity(0.38)),
    ];
    
    for (final (state, expectedColor) in states) {
      // 测试各状态颜色
    }
  });
});
```

#### 5. 设计 Token 应用验证

```dart
// test/design/token_application_test.dart
testWidgets('RouteCard 使用正确的设计 Token', (tester) async {
  await tester.pumpWidget(RouteCard(...));
  
  final card = tester.widget<Container>(find.byType(Container));
  final decoration = card.decoration as BoxDecoration;
  
  // 验证使用设计 Token 而非硬编码
  expect(decoration.borderRadius, equals(DesignSystem.radiusLarge));
  expect(decoration.color, equals(DesignSystem.surfacePrimary));
});
```

### 5.3 低优先级补充测试

#### 6. 字体渲染测试

```dart
// test/visual/typography_test.dart
testWidgets('路线名称字体规格正确', (tester) async {
  await tester.pumpWidget(TrailDetailPage());
  
  final title = find.text('九溪十八涧');
  final textWidget = tester.widget<Text>(title);
  final style = textWidget.style;
  
  expect(style.fontSize, equals(22));
  expect(style.fontWeight, equals(FontWeight.w600));
  expect(style.height, equals(30 / 22));
});
```

#### 7. 分享海报视觉测试

```dart
// test/visual/share_poster_test.dart
testGoldens('分享海报生成符合设计规范', (tester) async {
  final poster = await generateSharePoster(
    template: 'xiaohongshu',
    trailData: testTrail,
  );
  
  await tester.pumpWidget(poster);
  await screenMatchesGolden(tester, 'share_poster_xiaohongshu');
});
```

---

## 6. 设计走查检查清单（建议纳入 QA 流程）

### 6.1 视觉验收清单

```markdown
### 路线详情页视觉验收

#### 封面图区域
- [ ] 高度 200px
- [ ] 底部圆角 12px
- [ ] 渐变遮罩存在
- [ ] 难度标签位置正确（左下 16px, 12px）
- [ ] 距离标签位置正确（右下 16px, 12px）

#### 路线名称区
- [ ] 字号 22px
- [ ] 字重 Semibold (600)
- [ ] 行高 30px
- [ ] 上边距 16px
- [ ] 最大 2 行，超出省略

#### 核心数据区
- [ ] 区域高度 88px
- [ ] 三列等分布局
- [ ] 数字字号统一
- [ ] 单位字号正确

#### 底部操作栏
- [ ] 按钮高度 48px
- [ ] 按钮圆角 12px
- [ ] 主按钮颜色正确
- [ ] 按钮间距 12px
```

### 6.2 暗黑模式验收清单

```markdown
### 暗黑模式验收

#### 色彩
- [ ] 背景色: #0A0F14
- [ ] 卡片背景: #141C24
- [ ] 主文字: #F0F6FC (对比度 15.8:1)
- [ ] 次文字: #C9D1D9 (对比度 10.2:1)
- [ ] 按钮主色: #3DAB9E

#### 组件
- [ ] 按钮悬浮状态有光晕效果
- [ ] 输入框聚焦边框: #58A6FF
- [ ] 卡片悬浮背景: #1E2730
- [ ] 导航栏半透明模糊

#### 地图
- [ ] 使用暗黑主题
- [ ] 路线轨迹: #4DB6AC
- [ ] 定位点脉冲动画
```

### 6.3 动画验收清单

```markdown
### 动画验收

#### 时长
- [ ] 页面切换: 300ms
- [ ] 按钮反馈: 150ms
- [ ] 加载 shimmer: 1.5s 循环

#### 曲线
- [ ] 默认动画: ease-in-out
- [ ] 按钮按下: ease-out
- [ ] 弹窗出现: ease-out

#### 效果
- [ ] 页面切换无闪烁
- [ ] 列表加载流畅
- [ ] 按钮点击有明显反馈
```

---

## 7. 总结与行动建议

### 7.1 关键发现

| 类别 | 发现 | 风险等级 |
|------|------|----------|
| 视觉测试 | 仅验证常量存在，未验证实际应用 | 🔴 高 |
| 暗黑模式 | 无对比度自动化检查 | 🔴 高 |
| 动画交互 | 完全缺失 | 🔴 高 |
| 设计一致性 | 无高保真设计映射 | 🟡 中 |
| 设计走查 | 无走查环节 | 🟡 中 |

### 7.2 建议行动

#### 短期（本周）
1. **增加 WCAG 对比度测试**: 添加到 `test/accessibility/contrast_test.dart`
2. **增加关键组件像素测试**: 封面图、核心数据区
3. **增加动画时长测试**: 页面切换、按钮反馈

#### 中期（两周内）
4. **建立视觉回归测试**: 使用 golden_toolkit
5. **完善组件状态测试**: 所有组件状态样式
6. **增加设计 Token 应用验证**: 确保无硬编码

#### 长期（一个月内）
7. **建立设计走查流程**: 纳入 QA 测试计划
8. **完善分享海报视觉测试**: 多平台模板验证
9. **增加地图样式测试**: 暗黑模式配色验证

### 7.3 测试优先级建议

```
P0 (必须补充):
├── WCAG 对比度自动化检查
├── 关键页面像素级视觉回归测试
└── 动画时长和曲线验证

P1 (建议补充):
├── 组件状态全面测试
├── 设计 Token 应用验证
└── 分享海报视觉测试

P2 (可选补充):
├── 字体渲染测试
├── 地图样式测试
└── 手势交互测试
```

---

## 附录

### 参考文档

| 文档 | 路径 | 用途 |
|------|------|------|
| 高保真设计规范 | `design-hifi-v1.0.md` | 像素级规范 |
| 暗黑模式规范 | `design-system-dark-mode-v1.0.md` | 色彩、对比度规范 |
| 分享设计规范 | `shanjing-share-design.md` | 分享功能规范 |
| 设计系统测试 | `test/constants/design_system_test.dart` | 现有测试参考 |
| 暗黑模式测试 | `test/widgets/dark_mode_test.dart` | 现有测试参考 |

### 评审人签名

**Design Agent**  
日期: 2026-03-19

---

> **备注**: 本 Review 基于 QA Agent 截至 2026-03-19 的产出。建议 QA 和 Design 团队召开会议，讨论本报告中提出的缺失项，并制定补充测试计划。
