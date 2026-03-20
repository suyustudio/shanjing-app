# M5 成就系统设计评审报告

> **评审对象**: Dev Agent UI 实现  
> **评审日期**: 2026-03-20  
> **评审人**: Design Agent  
> **版本**: v1.0

---

## 1. 视觉还原评分

| 评审维度 | 评分 | 权重 | 加权得分 | 说明 |
|---------|------|------|---------|------|
| 徽章视觉还原 | 4/10 | 30% | 1.2 | 严重偏离设计稿 |
| 色彩系统 | 5/10 | 20% | 1.0 | 未使用 DesignSystem |
| 字体层级 | 6/10 | 15% | 0.9 | 部分正确 |
| 间距布局 | 5/10 | 15% | 0.75 | 网格不匹配 |
| 暗黑模式 | 3/10 | 10% | 0.3 | 硬编码颜色 |
| 动效实现 | 4/10 | 10% | 0.4 | 未使用 Lottie |
| **总分** | - | 100% | **4.55/10** | **未达标** |

**评分结论**: 当前实现评分为 **4.55/10**，未达到验收标准 (≥7.0)，需要大幅修改。

---

## 2. 问题列表

### 🔴 P0 - 阻塞问题 (必须修复)

| # | 问题描述 | 位置 | 设计规范 | 当前实现 | 修复建议 |
|---|---------|------|---------|---------|---------|
| P0-001 | **徽章使用 Icon 而非 SVG** | `achievement_screen.dart` `_AchievementBadgeCard` | 40个 SVG 徽章文件 | 使用 Flutter `Icons.xxx` | 接入 `flutter_svg` 包，使用 `design/M5-achievement-system/badges/` 下的 SVG 文件 |
| P0-002 | **解锁动画未使用 Lottie** | `achievement_unlock_dialog.dart` | `achievement_unlock.json` + `confetti.json` | 基础 Flutter 动画 | 集成 `lottie` 包，使用设计提供的 Lottie 文件 |
| P0-003 | **徽章形状错误** | 全部徽章展示 | 钻石徽章应为六边形 | 全部为圆形 | 钻石等级使用 ClipPath 或六边形 SVG |
| P0-004 | **硬编码颜色无暗黑模式适配** | 全部文件 | 使用 `DesignSystem.getXxx(context)` | 使用 `Colors.xxx` | 全部替换为 DesignSystem 动态获取方法 |

### 🟡 P1 - 重要问题 (建议修复)

| # | 问题描述 | 位置 | 设计规范 | 当前实现 | 修复建议 |
|---|---------|------|---------|---------|---------|
| P1-001 | 网格列数错误 | `achievement_screen.dart` | 4列网格 | 3列 (`crossAxisCount: 3`) | 改为 4 列，间距 16dp |
| P1-002 | 分类 Tab 样式不符 | `achievement_screen.dart` `TabBar` | Pill 形状 (圆角 20px) | 标准 TabBar | 自定义 Tab 样式为 pill shape |
| P1-003 | 徽章等级颜色错误 | `_getCategoryColor` | 铜/银/金/钻石定义色 | 使用分类色 (蓝/橙/紫) | 按等级返回定义色，非分类色 |
| P1-004 | 动画时长错误 | `achievement_unlock_dialog.dart` | 500ms + spring | 600ms + elasticOut | 调整为设计规范时长和曲线 |
| P1-005 | 分享卡片设计不符 | `achievement_share_card.dart` | 设计稿布局 | 简化版布局 | 参考 `SHARE-CARD-DESIGN.md` 调整 |
| P1-006 | 缺少光效扩散效果 | `achievement_unlock_dialog.dart` | 背景光晕扩散动画 | 仅有徽章发光 | 添加设计稿中的光晕扩散效果 |
| P1-007 | 未解锁状态样式错误 | `_AchievementBadgeCard` | 灰色蒙版 + 🔒 图标 | 浅灰背景 + lock 图标 | 使用灰度滤镜或灰色蒙版 |

### 🟢 P2 - 优化建议 (可选修复)

| # | 问题描述 | 位置 | 建议 |
|---|---------|------|------|
| P2-001 | 缺少 "New" 标签样式优化 | `_AchievementBadgeCard` | 添加发光动画效果 |
| P2-002 | 统计卡片背景渐变不符 | `_buildStatsCard` | 使用品牌渐变而非绿色 |
| P2-003 | 空状态页面未实现 | `achievement_screen.dart` | 参考 `EMPTY-STATE-DESIGN.md` 实现 |
| P2-004 | 徽章卡片点击反馈不明显 | `_AchievementBadgeCard` | 添加 Ripple 效果或缩放反馈 |
| P2-005 | 进度条颜色不一致 | 多处 | 统一使用品牌色渐变 |
| P2-006 | 分享功能未完成 | `achievement_share_card.dart` | 多个 TODO 待实现 |
| P2-007 | 缺少徽章悬停/长按预览 | 成就网格 | 添加长按预览详情功能 |

---

## 3. 设计走查建议

### 3.1 徽章组件重构建议

当前徽章实现过于简化，建议重构为独立 `AchievementBadge` 组件：

```dart
// 建议的组件结构
class AchievementBadge extends StatelessWidget {
  final String badgeSvgPath;  // SVG 路径
  final BadgeLevel level;      // 等级 (bronze/silver/gold/diamond)
  final BadgeState state;      // 状态 (locked/unlocked/new)
  final double size;           // 尺寸 (80/120/160/200)
  final bool enableAnimation;  // 是否启用动画
  
  // 根据等级返回对应颜色
  Color get levelColor => switch(level) {
    BadgeLevel.bronze => const Color(0xFFCD7F32),
    BadgeLevel.silver => const Color(0xFFC0C0C0),
    BadgeLevel.gold => const Color(0xFFFFD700),
    BadgeLevel.diamond => const Color(0xFF00CED1),
  };
}
```

### 3.2 SVG 资源接入

设计团队已提供 40 个 SVG 徽章文件，路径如下：
```
assets/badges/
├── first-hike/badge_first_[level]_[size].svg
├── distance/badge_distance_[level]_[size].svg
├── trail/badge_trail_[level]_[size].svg
├── streak/badge_streak_[level]_[size].svg
└── share/badge_share_[level]_[size].svg
```

**接入步骤：**
1. 将 `design/M5-achievement-system/badges/` 复制到 `assets/badges/`
2. 在 `pubspec.yaml` 中添加 assets 声明
3. 使用 `flutter_svg` 包渲染

### 3.3 Lottie 动画集成

设计提供的 Lottie 文件：
- `achievement_unlock.json` - 解锁弹窗主动画
- `badge_shine.json` - 徽章光晕效果
- `confetti.json` - 庆祝粒子效果

**集成建议：**
```dart
// 解锁弹窗使用 Lottie
Lottie.asset(
  'assets/lottie/achievement_unlock.json',
  width: 200,
  height: 200,
  repeat: false,
)

// 徽章光晕叠加
Stack(
  children: [
    SvgPicture.asset(badgePath),
    Lottie.asset('assets/lottie/badge_shine.json'),
  ],
)
```

### 3.4 暗黑模式适配

当前实现大量使用硬编码颜色，应全部替换为 DesignSystem：

| 当前代码 | 建议替换为 |
|---------|-----------|
| `Colors.white` | `DesignSystem.getBackground(context)` |
| `Colors.grey.shade100` | `DesignSystem.getBackgroundSecondary(context)` |
| `Colors.black87` | `DesignSystem.getTextPrimary(context)` |
| `Colors.grey.shade600` | `DesignSystem.getTextSecondary(context)` |

### 3.5 动画参数调整

根据设计规范调整动画参数：

| 动画 | 当前 | 设计规范 | 建议 |
|-----|------|---------|------|
| 解锁缩放 | 600ms, elasticOut | 500ms, spring(1, 0.5) | 使用 `SpringCurve` |
| 光晕呼吸 | 1500ms | 1000ms, ease-in-out | 缩短时长 |
| 遮罩淡入 | 未明确 | 300ms | 添加明确时长 |
| 粒子效果 | 无 | confetti.json | 集成 Lottie |

---

## 4. 验收结论

### 4.1 验收结果: **❌ 不通过**

当前 Dev Agent 的成就系统 UI 实现存在以下关键问题：

1. **核心视觉元素缺失** - 未使用设计提供的 40 个 SVG 徽章，仅用 Flutter 图标替代
2. **动画系统不符** - 未集成 Lottie 动画，基础动画与设计稿差距较大
3. **暗黑模式未适配** - 硬编码颜色无法适配暗黑模式
4. **布局网格错误** - 3列网格与设计规范的4列不符

### 4.2 返工清单

**必须完成 (Blocking):**
- [ ] 接入 SVG 徽章资源，替换所有 Icon 使用
- [ ] 集成 Lottie 动画 (unlock + confetti)
- [ ] 钻石等级徽章使用六边形形状
- [ ] 全局替换硬编码颜色为 DesignSystem 方法

**强烈建议 (High Priority):**
- [ ] 调整网格为 4 列
- [ ] 修复 Tab 样式为 Pill 形状
- [ ] 徽章颜色按等级而非分类
- [ ] 调整动画时长和曲线
- [ ] 添加光晕扩散效果

**优化项 (Nice to have):**
- [ ] 完善空状态页面
- [ ] 完成分享功能
- [ ] 添加点击反馈动画
- [ ] 优化 New 标签效果

### 4.3 预计返工时间

| 任务 | 预估时间 |
|-----|---------|
| SVG 资源接入 + 徽章组件重构 | 4h |
| Lottie 动画集成 | 2h |
| 暗黑模式适配 | 2h |
| 布局和样式调整 | 2h |
| 分享功能完善 | 2h |
| **总计** | **~12h** |

### 4.4 设计团队支持

如需设计支持，请联系：
- 徽章 SVG 导出调整
- Lottie 动画参数调优
- 暗黑模式色彩微调
- 分享卡片设计细化

---

## 附录

### 参考文档
- 设计规范: `design/M5-achievement-system/DESIGN-SPEC-v1.0.md`
- 徽章资源: `design/M5-achievement-system/badges/`
- 动画资源: `design/M5-achievement-system/lottie/`
- DesignSystem: `lib/constants/design_system.dart`

### 评审代码范围
- `lib/screens/achievements/achievement_screen.dart`
- `lib/screens/achievements/achievement_detail_page.dart`
- `lib/screens/achievements/achievement_unlock_dialog.dart`
- `lib/screens/achievements/achievement_share_card.dart`

### 版本记录
| 版本 | 日期 | 修改内容 |
|-----|------|---------|
| v1.0 | 2026-03-20 | 初始评审报告 |

---

*评审完成时间: 2026-03-20*  
*评审人: Design Agent*
