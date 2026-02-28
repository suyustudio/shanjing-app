# Design Review: Flutter 页面设计审查报告

> **审查日期**: 2026-02-28  
> **审查人**: Design Agent  
> **审查对象**: Dev Agent 完成的 Flutter 页面设计  
> **参考文档**: design-system-v1.0.md, flutter-design-tokens.md, flutter-components-button.md

---

## 1. 发现页 (flutter-screen-discovery.md)

### 1.1 设计一致性评估

| 维度 | 状态 | 说明 |
|------|------|------|
| **色彩系统** | ⚠️ 部分偏离 | 设计使用了通用描述，未引用设计系统 Token。主色应使用 `#2D968A` (山青 500)，而非通用蓝色 |
| **字体系统** | ⚠️ 未定义 | 未明确字号、字重。路线名称应使用 16px Medium，评分/距离应使用 14px Regular |
| **间距系统** | ⚠️ 未定义 | 卡片间距、内边距未标注。应使用 8px 网格系统 |
| **圆角规范** | ✅ 基本符合 | 提及封面图圆角，但未明确是 8px 还是 12px |

**具体问题:**
- 搜索栏样式未定义（高度、圆角、背景色）
- 筛选标签选中态/未选中态颜色未指定
- 卡片阴影未定义（应使用 `shadow-md`）

### 1.2 可实现性评估

| 维度 | 状态 | 说明 |
|------|------|------|
| **代码结构** | ✅ 清晰 | 提供的代码骨架合理，使用 Column + Expanded 是 Flutter 列表页的标准做法 |
| **组件拆分** | ⚠️ 可优化 | 建议将 RouteList 进一步拆分为 RouteCard 组件 |
| **状态管理** | ✅ 合理 | 提及了必要的状态：选中标签、列表数据、加载状态 |

**建议改进:**
```dart
// 建议增加 RouteCard 组件定义
class RouteCard extends StatelessWidget {
  final Route route;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // 对应 shadow-md
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // radius-md
      ),
      child: Column(...),
    );
  }
}
```

### 1.3 用户体验评估

| 维度 | 状态 | 说明 |
|------|------|------|
| **信息层级** | ✅ 清晰 | 搜索 → 筛选 → 列表，层级合理 |
| **交互反馈** | ❌ 缺失 | 未定义：加载状态、空状态、错误状态、下拉刷新样式 |
| **可访问性** | ❌ 未考虑 | 未提及无障碍支持（如语义标签） |

**缺失的关键状态:**
1. **加载状态** - 首次进入、切换标签时的 loading
2. **空状态** - 无数据时的提示
3. **错误状态** - 网络错误、加载失败
4. **上拉加载更多** - 分页加载的触发条件和样式

### 1.4 遗漏清单

- [ ] 搜索栏具体样式（高度 44px、圆角 8px、背景色 #F5F7F6）
- [ ] 筛选标签样式（选中：主色背景+白字，未选中：灰底+深灰字）
- [ ] 卡片圆角（应为 8px）
- [ ] 卡片阴影（shadow-md: 0 4px 6px rgba(0,0,0,0.1)）
- [ ] 卡片内边距（16px）
- [ ] 图片与文字间距（12px）
- [ ] 评分图标样式（星星大小、颜色 #FFB800）
- [ ] 加载状态样式
- [ ] 空状态样式
- [ ] 错误重试机制

---

## 2. 详情页 (flutter-screen-trail-detail.md)

### 2.1 设计一致性评估

| 维度 | 状态 | 说明 |
|------|------|------|
| **色彩系统** | ❌ 严重偏离 | 使用了 `#4CAF50` 作为"品牌绿"，但设计系统主色是 `#2D968A` (山青) |
| **难度颜色** | ⚠️ 部分偏离 | 设计系统难度色：休闲 `#4CAF50`、轻度 `#8BC34A`、进阶 `#FF9800`、挑战 `#F44336`。文档只定义了简单/中等/困难 |
| **字体系统** | ⚠️ 未对齐 | 路线名称 24px 过大，设计系统 H1 为 24px，但路线详情标题建议 22px Semibold |
| **圆角规范** | ⚠️ 不一致 | 封面图圆角 12px，但设计系统卡片圆角为 8px |

**色彩偏差详细对比:**

| 元素 | 文档定义 | 设计系统 | 状态 |
|------|----------|----------|------|
| 主色 | `#4CAF50` | `#2D968A` | ❌ 不一致 |
| 背景 | `#FFFFFF` | `#FFFFFF` | ✅ 一致 |
| 主文字 | `#212121` | `#111827` | ⚠️ 接近但不一致 |
| 次要文字 | `#757575` | `#6B7280` | ⚠️ 接近但不一致 |
| 简单难度 | `#4CAF50` | `#4CAF50` | ✅ 一致 |
| 中等难度 | `#FFC107` | `#FF9800` | ⚠️ 不一致 |
| 困难难度 | `#F44336` | `#F44336` | ✅ 一致 |

### 2.2 可实现性评估

| 维度 | 状态 | 说明 |
|------|------|------|
| **布局结构** | ✅ 清晰 | 垂直布局，结构合理 |
| **组件定义** | ✅ 完整 | 列出了主要组件 |
| **交互说明** | ⚠️ 可补充 | 收藏切换、图片滑动有说明，但缺少细节 |

**潜在技术问题:**
1. **封面图 240px 固定高度** - 在不同屏幕尺寸上可能需要适配
2. **底部固定按钮** - 需要考虑安全区域（iPhone 底部横条）
3. **图片轮播** - 未说明指示器样式（dots 样式、位置）

### 2.3 用户体验评估

| 维度 | 状态 | 说明 |
|------|------|------|
| **信息架构** | ⚠️ 可优化 | 缺少关键信息：爬升高度、路线类型标签、起点/终点位置 |
| **交互流程** | ⚠️ 不完整 | "开始导航"后的流程未说明 |
| **视觉层次** | ✅ 合理 | 封面 → 标题 → 信息 → 简介 → 操作，层次清晰 |

**建议增加的信息:**
- 爬升高度（累计爬升）
- 路线类型标签（徒步/骑行/自驾）
- 起点/终点位置名称
- 最佳季节
- 用户评分数量（如：4.8 · 128人评价）

### 2.4 遗漏清单

- [ ] 设计系统主色 `#2D968A` 未使用
- [ ] 图片轮播指示器样式
- [ ] 收藏按钮的具体位置（距离边缘多少 px）
- [ ] 底部按钮安全区域处理
- [ ] 页面滚动行为（封面图是否随滚动缩小？）
- [ ] 返回按钮样式
- [ ] 分享按钮
- [ ] 加载状态（图片加载、页面数据加载）
- [ ] 错误状态（数据加载失败）
- [ ] 收藏状态持久化提示
- [ ] 导航前确认弹窗（可选）

---

## 3. 综合评估

### 3.1 设计系统一致性总结

```
一致性评分: 6.5/10

主要问题:
1. 色彩系统未严格遵循设计系统 Token
2. 字体、间距规范未明确标注
3. 组件状态定义不完整

优点:
1. 页面结构清晰，信息层级合理
2. 代码骨架简洁实用
3. 交互意图表达清楚
```

### 3.2 可实现性总结

```
可实现性评分: 8/10

Flutter 实现难度: 低
- 均为标准 UI 组件
- 无复杂自定义绘制
- 布局使用常规 Column/Row/Stack

需要注意:
- 图片轮播需要第三方库或自定义 PageView
- 底部固定按钮需处理安全区域
- 筛选标签横向滚动需要 SingleChildScrollView
```

### 3.3 用户体验总结

```
UX 评分: 7/10

优势:
- 信息架构清晰
- 操作流程直观

不足:
- 缺少边界状态设计
- 部分关键信息缺失（如爬升高度）
- 动效/过渡未定义
```

---

## 4. 建议修复清单

### 高优先级（必须修复）

1. **统一主色** - 将 `#4CAF50` 改为设计系统主色 `#2D968A`
2. **定义字体规范** - 明确各元素的字号、字重、行高
3. **定义间距规范** - 使用 8px 网格系统
4. **补充状态设计** - 加载、空状态、错误状态

### 中优先级（建议修复）

5. **增加图片轮播指示器** - 定义 dots 样式
6. **补充安全区域处理** - 底部按钮、顶部状态栏
7. **增加缺失信息字段** - 爬升高度、路线类型、评价数量
8. **定义筛选标签样式** - 选中/未选中态

### 低优先级（可选优化）

9. **增加页面转场动效** - 进入/退出动画
10. **增加微交互** - 收藏按钮动画、按钮按下反馈
11. **定义暗黑模式样式** - 跟随设计系统暗黑模式规范

---

## 5. 参考实现建议

### 5.1 色彩 Token 映射

```dart
// 应使用的设计系统颜色
class AppColors {
  // 主色
  static const primary = Color(0xFF2D968A);      // 山青 500
  static const primaryDark = Color(0xFF25877C);  // 山青 600
  
  // 功能色
  static const success = Color(0xFF4CAF50);      // 翠竹绿
  static const warning = Color(0xFFFFC107);      // 秋叶黄
  static const error = Color(0xFFEF5350);        // 枫叶红
  
  // 难度色
  static const difficultyEasy = Color(0xFF4CAF50);
  static const difficultyModerate = Color(0xFF8BC34A);
  static const difficultyAdvanced = Color(0xFFFF9800);
  static const difficultyChallenging = Color(0xFFF44336);
  
  // 文字色
  static const textPrimary = Color(0xFF111827);   // Gray-900
  static const textSecondary = Color(0xFF6B7280); // Gray-500
  static const textTertiary = Color(0xFF9CA3AF);  // Gray-400
  
  // 背景色
  static const background = Color(0xFFF9FAFB);    // Gray-50
  static const surface = Colors.white;
}
```

### 5.2 发现页卡片规范

```dart
class RouteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // space-4, space-2
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // radius-md
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面图 16:9
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(...),
            ),
          ),
          // 内容区
          Padding(
            padding: const EdgeInsets.all(12), // space-3
            child: Column(...),
          ),
        ],
      ),
    );
  }
}
```

---

## 6. 结论

Dev Agent 完成的 Flutter 页面设计在**结构层面**是合理的，但在**设计系统一致性**方面存在明显偏差。主要问题是：

1. **色彩未遵循设计系统** - 使用了错误的品牌色
2. **细节规范缺失** - 间距、字体、圆角等未明确标注
3. **边界状态遗漏** - 缺少加载、空状态、错误状态设计

**建议下一步行动:**
1. 根据本 review 修复色彩系统和规范定义
2. 补充缺失的状态设计
3. 与 Design System 文档对齐后进入开发阶段

---

> **Review 参考对象**: Dieter Rams（功能主义设计原则）- 好的设计是尽可能少的设计，但每个细节都必须精确。
