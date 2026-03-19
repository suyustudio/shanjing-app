# 山径APP - 暗黑模式设计规范 v1.0

> **文档版本**: v1.0  
> **制定日期**: 2026-03-19  
> **文档状态**: M4 阶段 - P0  
> **适用范围**: 山径APP全功能暗黑模式适配  
> **基于**: 设计系统 v1.0, M3 暗黑模式基础

---

## 目录

1. [设计概述](#1-设计概述)
2. [色彩系统](#2-色彩系统)
3. [组件规范](#3-组件规范)
4. [页面适配](#4-页面适配)
5. [地图适配](#5-地图适配)
6. [插画/图片适配](#6-插画图片适配)
7. [动效适配](#7-动效适配)
8. [开发规范](#8-开发规范)
9. [设计Token](#9-设计token)
10. [验收标准](#10-验收标准)

---

## 1. 设计概述

### 1.1 设计目标

为山径APP构建完整、一致的暗黑模式体验，确保：

| 目标 | 说明 | 关键指标 |
|------|------|----------|
| **视觉舒适** | 降低夜间/低光环境下的视觉疲劳 | 背景亮度 < 10% |
| **层级清晰** | 保持信息层级，不打乱用户认知 | 对比度 ≥ 4.5:1 |
| **品牌一致** | 保持山径自然清新的品牌调性 | 色相保持，明度调整 |
| **无缝切换** | 支持跟随系统/手动切换 | 切换动画 300ms |

### 1.2 设计理念

**"夜色山径"** - 暗黑模式不是简单的反色，而是营造月光下的山野氛围：

- **深邃背景** - 如夜空般深邃的背景色
- **柔和层次** - 如月光般柔和的层级区分
- **保持生机** - 品牌色保持活力，如夜间的萤火
- **降低刺激** - 避免纯白和纯黑，使用柔和色调

### 1.3 适配范围

| 优先级 | 页面/模块 | 状态 |
|--------|-----------|------|
| P0 | 首页/发现页 | 已完成 |
| P0 | 路线详情页 | 已完成 |
| P0 | 导航页 | 已完成 |
| P0 | 用户中心 | 已完成 |
| P0 | 设置页 | 已完成 |
| P0 | 登录/注册页 | 已完成 |
| P0 | 空状态/异常状态 | 待完善 |
| P1 | 分享海报 | 需单独设计 |
| P1 | SOS页面 | 需单独设计 |

---

## 2. 色彩系统

### 2.1 色彩策略

#### 基础策略

| 策略 | 浅色模式 → 暗黑模式 | 说明 |
|------|---------------------|------|
| **背景反转** | White → Dark BG | 主背景使用深色调 |
| **卡片提升** | Gray-50 → Dark Card | 卡片比背景稍亮 |
| **文字反转** | Gray-900 → White | 主文字使用白色系 |
| **强调保持** | Primary-500 → Primary-400 | 品牌色保持色相，调整明度 |
| **功能色提升** | Success-500 → Success-400 | 功能色提高明度保证可见 |

### 2.2 背景色系统

#### 页面背景

| Token | 色值 | 用途 | 使用场景 |
|-------|------|------|----------|
| `--dark-bg-primary` | `#0A0F14` | 最深层背景 | 页面底色、底层背景 |
| `--dark-bg-secondary` | `#111820` | 次级背景 | 分组背景、列表底色 |
| `--dark-bg-tertiary` | `#1A222C` | 三级背景 | 悬浮区域、选中项 |

#### 卡片/容器背景

| Token | 色值 | 用途 | 使用场景 |
|-------|------|------|----------|
| `--dark-surface-primary` | `#141C24` | 默认卡片 | 普通卡片、面板 |
| `--dark-surface-secondary` | `#1E2730` | 次级卡片 | 悬浮卡片、展开项 |
| `--dark-surface-tertiary` | `#28323D` | 三级卡片 | 选中状态、高亮卡片 |
| `--dark-surface-elevated` | `#2A3540` | 提升层级 | 模态框、下拉菜单 |

#### 背景色使用层次

```
页面层级示意（从上到下）：

┌─────────────────────────────────────┐
│  --dark-surface-elevated            │  ← 模态/弹层
│  ┌───────────────────────────────┐  │
│  │  --dark-surface-tertiary      │  │  ← 选中/高亮
│  │  ┌─────────────────────────┐  │  │
│  │  │ --dark-surface-secondary│  │  │  ← 悬浮/展开
│  │  │  ┌───────────────────┐  │  │  │
│  │  │  │--dark-surface-primary│ │  │  │  ← 默认卡片
│  │  │  │  ┌─────────────┐  │  │  │  │
│  │  │  │  │--dark-bg-tertiary│ │  │  │  ← 三级背景
│  │  │  │  │  ┌───────┐  │  │  │  │
│  │  │  │  │  │--dark-bg-secondary│  │  │  ← 次级背景
│  │  │  │  │  │ ┌───┐ │  │  │  │
│  │  │  │  │  │ │Base│ │  │  │  │  ← 页面底色
│  └─────────────────────────────────────┘
```

### 2.3 文字色系统

#### 文字色层级

| Token | 色值 | 对比度 | 用途 |
|-------|------|--------|------|
| `--dark-text-primary` | `#F0F6FC` | 15.8:1 | 主标题、重要文字 |
| `--dark-text-secondary` | `#C9D1D9` | 10.2:1 | 正文、描述 |
| `--dark-text-tertiary` | `#8B949E` | 6.1:1 | 辅助说明、时间 |
| `--dark-text-quaternary` | `#6E7681` | 4.6:1 | 占位符、禁用提示 |
| `--dark-text-disabled` | `#484F58` | 2.8:1 | 禁用状态 |

#### 文字色使用规范

| 场景 | 文字色 | 字号/字重 | 示例 |
|------|--------|-----------|------|
| **页面标题** | `--dark-text-primary` | 20px/Semibold | "路线详情" |
| **卡片标题** | `--dark-text-primary` | 16px/Medium | "九溪烟树" |
| **正文内容** | `--dark-text-secondary` | 14px/Regular | "这是一条美丽的路线..." |
| **辅助信息** | `--dark-text-tertiary` | 12px/Regular | "3.2公里 · 休闲" |
| **占位符** | `--dark-text-quaternary` | 16px/Regular | "请输入搜索内容" |
| **禁用文字** | `--dark-text-disabled` | 14px/Regular | 不可点击的选项 |

### 2.4 品牌色适配

#### 主色调映射

| 浅色模式 | 暗黑模式 | 色值 | 用途 |
|----------|----------|------|------|
| Primary-50 | Dark-Primary-50 | `#0D2B28` | 极浅背景 |
| Primary-100 | Dark-Primary-100 | `#143D38` | 浅色背景 |
| Primary-200 | Dark-Primary-200 | `#1E524B` | 禁用背景 |
| Primary-300 | Dark-Primary-300 | `#2D968A` | 次要元素 |
| Primary-400 | Dark-Primary-400 | `#3DAB9E` | **主按钮默认** |
| Primary-500 | Dark-Primary-500 | `#4DB6AC` | 高亮强调 |
| Primary-600 | Dark-Primary-600 | `#6BC4BC` | 文字链接 |
| Primary-700 | Dark-Primary-700 | `#8DD4CE` | 悬浮文字 |

#### 品牌色使用示例

```
主按钮（暗黑模式）：
┌─────────────────────────────┐
│  背景: #3DAB9E              │
│  文字: #0A0F14 (深色背景上) │
│  边框: 无                   │
└─────────────────────────────┘

次按钮（暗黑模式）：
┌─────────────────────────────┐
│  背景: transparent          │
│  文字: #4DB6AC              │
│  边框: 1px #3DAB9E          │
└─────────────────────────────┘
```

### 2.5 功能色适配

#### 功能色映射表

| 功能 | 浅色模式 | 暗黑模式 | 调整说明 |
|------|----------|----------|----------|
| **成功** | `#4CAF50` | `#66BB6A` | 明度+15%，保持可见 |
| **警告** | `#FFC107` | `#FFD54F` | 明度+20%，避免刺眼 |
| **错误** | `#EF5350` | `#F87171` | 明度+10%，保持醒目 |
| **信息** | `#3B9EFF` | `#60A5FA` | 明度+15%，柔和呈现 |

#### 功能色色阶（暗黑模式）

**成功色 - 翠竹绿**

| 色阶 | 色值 | 用途 |
|------|------|------|
| 50 | `#0D2810` | 成功状态浅背景 |
| 100 | `#143D18` | 成功提示背景 |
| 500 | `#66BB6A` | **成功主色** |
| 600 | `#81C784` | 悬浮状态 |

**警告色 - 秋叶黄**

| 色阶 | 色值 | 用途 |
|------|------|------|
| 50 | `#2D2408` | 警告状态浅背景 |
| 100 | `#45360C` | 警告提示背景 |
| 500 | `#FFD54F` | **警告主色** |
| 600 | `#FFE082` | 悬浮状态 |

**错误色 - 枫叶红**

| 色阶 | 色值 | 用途 |
|------|------|------|
| 50 | `#2D0D0D` | 错误状态浅背景 |
| 100 | `#451414` | 错误提示背景 |
| 500 | `#F87171` | **错误主色** |
| 600 | `#FCA5A5` | 悬浮状态 |

**信息色 - 天空蓝**

| 色阶 | 色值 | 用途 |
|------|------|------|
| 50 | `#0D2438` | 信息状态浅背景 |
| 100 | `#143852` | 信息提示背景 |
| 500 | `#60A5FA` | **信息主色** |
| 600 | `#7EB8FF` | 悬浮状态 |

### 2.6 边框与分割线

#### 边框色

| Token | 色值 | 用途 |
|-------|------|------|
| `--dark-border-default` | `#30363D` | 默认边框、分割线 |
| `--dark-border-subtle` | `#21262D` | 微妙边框、内部分割 |
| `--dark-border-hover` | `#3D444D` | 悬浮状态边框 |
| `--dark-border-focus` | `#58A6FF` | 聚焦状态边框 |

#### 使用规范

```
卡片边框：
┌─────────────────────────────┐ ← 1px #30363D
│                             │
│      卡片内容               │
│                             │
└─────────────────────────────┘

内部分割线：
┌─────────────────────────────┐
│  第一部分                   │
├─────────────────────────────┤ ← 1px #21262D
│  第二部分                   │
└─────────────────────────────┘
```

---

## 3. 组件规范

### 3.1 按钮组件

#### 主按钮 (Primary Button)

| 状态 | 背景色 | 文字色 | 阴影 |
|------|--------|--------|------|
| **Default** | `#3DAB9E` | `#0A0F14` | `0 2px 4px rgba(61, 171, 158, 0.2)` |
| **Hover** | `#4DB6AC` | `#0A0F14` | `0 4px 8px rgba(61, 171, 158, 0.3)` |
| **Pressed** | `#2D968A` | `#0A0F14` | `0 1px 2px rgba(61, 171, 158, 0.2)` |
| **Disabled** | `#1E524B` | `#6E7681` | 无 |
| **Loading** | `#3DAB9E` | `#0A0F14` | 同Default + 加载动画 |

#### 次按钮 (Secondary Button)

| 状态 | 背景色 | 文字色 | 边框 |
|------|--------|--------|------|
| **Default** | `transparent` | `#4DB6AC` | `1px solid #3DAB9E` |
| **Hover** | `rgba(61, 171, 158, 0.1)` | `#6BC4BC` | `1px solid #4DB6AC` |
| **Pressed** | `rgba(61, 171, 158, 0.2)` | `#2D968A` | `1px solid #2D968A` |
| **Disabled** | `transparent` | `#484F58` | `1px solid #30363D` |

#### 幽灵按钮 (Ghost Button)

| 状态 | 背景色 | 文字色 |
|------|--------|--------|
| **Default** | `transparent` | `#C9D1D9` |
| **Hover** | `#1E2730` | `#F0F6FC` |
| **Pressed** | `#28323D` | `#F0F6FC` |
| **Disabled** | `transparent` | `#484F58` |

#### 危险按钮 (Danger Button)

| 状态 | 背景色 | 文字色 |
|------|--------|--------|
| **Default** | `#F87171` | `#0A0F14` |
| **Hover** | `#FCA5A5` | `#0A0F14` |
| **Pressed** | `#EF4444` | `#0A0F14` |

### 3.2 输入框组件

#### 文本输入框

| 状态 | 背景色 | 边框色 | 文字色 | 占位符色 |
|------|--------|--------|--------|----------|
| **Default** | `#0A0F14` | `#30363D` | `#C9D1D9` | `#6E7681` |
| **Focus** | `#0A0F14` | `#58A6FF` | `#F0F6FC` | - |
| **Error** | `#0A0F14` | `#F87171` | `#F87171` | - |
| **Disabled** | `#111820` | `#21262D` | `#484F58` | `#484F58` |
| **Filled** | `#0A0F14` | `#3DAB9E` | `#C9D1D9` | - |

#### 输入框聚焦光晕

```css
/* Focus状态光晕 */
input:focus {
  border-color: #58A6FF;
  box-shadow: 0 0 0 3px rgba(88, 166, 255, 0.15);
}
```

### 3.3 卡片组件

#### 标准卡片

| 元素 | 属性 | 值 |
|------|------|-----|
| **背景** | 颜色 | `#141C24` |
| **边框** | 样式 | `1px solid #30363D` |
| **圆角** | 半径 | `12px` |
| **阴影** | 默认 | 无（使用边框区分） |
| **悬浮** | 背景 | `#1E2730` |
| **悬浮** | 边框 | `#3D444D` |

#### 卡片层级示例

```
默认卡片:
┌─────────────────────────────┐
│  ┌───────────────────────┐  │
│  │                       │  │
│  │     图片区域          │  │  ← 16:9比例
│  │                       │  │
│  └───────────────────────┘  │
│  标题文字                   │  ← #F0F6FC, 16px, Medium
│  描述内容...                │  ← #C9D1D9, 14px, Regular
│                    [操作]   │  ← #4DB6AC, 14px
└─────────────────────────────┘

悬浮卡片:
┌─────────────────────────────┐
│  ┌───────────────────────┐  │
│  │                       │  │
│  │     图片区域          │  │
│  │                       │  │
│  └───────────────────────┘  │
│  标题文字                   │
│  描述内容...                │
│                    [操作]   │
└─────────────────────────────┘
背景: #1E2730, 边框: #3D444D
```

### 3.4 列表组件

#### 标准列表项

| 元素 | 属性 | 值 |
|------|------|-----|
| **背景** | 默认 | `transparent` |
| **背景** | 悬浮 | `#1E2730` |
| **背景** | 选中 | `#28323D` |
| **边框** | 底部 | `1px solid #21262D` |
| **内边距** | 垂直 | `16px` |
| **内边距** | 水平 | `16px` |

### 3.5 标签/徽章

#### 标准标签

| 类型 | 背景色 | 文字色 |
|------|--------|--------|
| **默认** | `#28323D` | `#C9D1D9` |
| **主色** | `#1E524B` | `#4DB6AC` |
| **成功** | `#0D2810` | `#66BB6A` |
| **警告** | `#2D2408` | `#FFD54F` |
| **错误** | `#2D0D0D` | `#F87171` |
| **信息** | `#0D2438` | `#60A5FA` |

### 3.6 导航栏

#### 顶部导航栏

| 元素 | 属性 | 值 |
|------|------|-----|
| **背景** | 颜色 | `#0A0F14` |
| **背景** | 模糊 | `backdrop-filter: blur(20px)` |
| **背景** | 透明度 | `rgba(10, 15, 20, 0.85)` |
| **边框** | 底部 | `1px solid #21262D` |
| **标题** | 颜色 | `#F0F6FC` |
| **图标** | 颜色 | `#C9D1D9` |

#### 导航栏滚动效果

**设计目标**: 页面滚动时导航栏平滑过渡，增强空间感和沉浸体验。

##### 滚动状态定义

| 状态 | 触发条件 | 视觉效果 |
|------|----------|----------|
| **初始状态** | 滚动位置 = 0 | 透明/半透明背景，大标题 |
| **滚动中** | 0 < 滚动位置 < 临界点 | 动态过渡效果 |
| **固定状态** | 滚动位置 ≥ 临界点 | 实色背景，小标题 |

##### 滚动效果参数

| 属性 | 初始值 | 固定值 | 过渡曲线 | 说明 |
|------|--------|--------|----------|------|
| **背景透明度** | 0% | 95% | `ease-out` | 滚动时背景渐显 |
| **背景模糊** | `blur(0px)` | `blur(20px)` | `ease-in-out` | 毛玻璃效果渐显 |
| **标题字号** | 20px | 17px | `ease-out` | 标题轻微缩小 |
| **标题字重** | 600 (Semibold) | 600 (Semibold) | - | 字重保持不变 |
| **阴影** | 无 | `0 2px 8px rgba(0,0,0,0.3)` | `ease-out` | 底部投影增加层次 |
| **边框透明度** | 0% | 100% | `linear` | 底边框渐显 |
| **导航栏高度** | 56px | 48px | `ease-in-out` | 轻微压缩 |

##### 滚动效果实现 (Flutter)

```dart
// lib/widgets/scrollable_app_bar.dart

class ScrollableAppBar extends StatefulWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final ScrollController? scrollController;
  final double expandedHeight;
  
  const ScrollableAppBar({
    Key? key,
    required this.title,
    this.leading,
    this.actions,
    this.scrollController,
    this.expandedHeight = 200,
  }) : super(key: key);

  @override
  State<ScrollableAppBar> createState() => _ScrollableAppBarState();
}

class _ScrollableAppBarState extends State<ScrollableAppBar> {
  double _scrollOffset = 0;
  final double _threshold = 100; // 临界点
  
  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
  }
  
  void _onScroll() {
    setState(() {
      _scrollOffset = widget.scrollController?.offset ?? 0;
    });
  }
  
  // 计算插值
  double _lerp(double start, double end) {
    final t = (_scrollOffset / _threshold).clamp(0.0, 1.0);
    return start + (end - start) * t;
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0F14) : Colors.white;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(_lerp(0, 0.95)),
        border: Border(
          bottom: BorderSide(
            color: isDark 
              ? const Color(0xFF21262D).withOpacity(_lerp(0, 1))
              : Colors.grey.shade200.withOpacity(_lerp(0, 1)),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_lerp(0, 0.3)),
            blurRadius: _lerp(0, 8),
            offset: Offset(0, _lerp(0, 2)),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _lerp(0, 20),
            sigmaY: _lerp(0, 20),
          ),
          child: Container(
            height: _lerp(56, 48) + MediaQuery.of(context).padding.top,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Row(
              children: [
                if (widget.leading != null) widget.leading!,
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: isDark ? const Color(0xFFF0F6FC) : Colors.black87,
                      fontSize: _lerp(20, 17),
                      fontWeight: FontWeight.w600,
                    ),
                    child: Text(widget.title),
                  ),
                ),
                if (widget.actions != null) ...widget.actions!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

##### 滚动效果实现 (CSS)

```css
/* 滚动导航栏样式 */
.scrollable-navbar {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 100;
  transition: all 0.3s ease-out;
  
  /* 初始状态 */
  background: transparent;
  backdrop-filter: blur(0px);
  height: 56px;
  box-shadow: none;
  border-bottom: 1px solid transparent;
}

/* 滚动后状态 */
.scrollable-navbar.scrolled {
  background: rgba(10, 15, 20, 0.95);
  backdrop-filter: blur(20px);
  height: 48px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
  border-bottom: 1px solid #21262D;
}

/* 标题缩放 */
.scrollable-navbar .title {
  font-size: 20px;
  font-weight: 600;
  transition: font-size 0.3s ease-out;
}

.scrollable-navbar.scrolled .title {
  font-size: 17px;
}

/* 暗黑模式适配 */
@media (prefers-color-scheme: dark) {
  .scrollable-navbar.scrolled {
    background: rgba(10, 15, 20, 0.95);
    border-bottom-color: #21262D;
  }
  
  .scrollable-navbar .title {
    color: #F0F6FC;
  }
}
```

##### 页面使用示例

```dart
// 路线详情页使用滚动导航栏
class TrailDetailPage extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 可滚动内容
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 头部大图
              SliverToBoxAdapter(
                child: Hero(
                  tag: 'trail_image',
                  child: Image.network(
                    trail.imageUrl,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // 内容区域
              SliverToBoxAdapter(
                child: TrailContent(trail: trail),
              ),
            ],
          ),
          // 滚动导航栏
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ScrollableAppBar(
              title: trail.name,
              scrollController: _scrollController,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _shareTrail(context),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () => _toggleFavorite(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

##### 效果预览

```
初始状态 (滚动位置 = 0):
┌─────────────────────────────────────────┐
│                                         │ ← 完全透明背景
│  ← 路线详情                    [☆] [↗] │
│         (20px, 字重600)                 │ ← 大标题
│                                         │
├─────────────────────────────────────────┤
│                                         │
│          [路线图片]                     │
│                                         │
└─────────────────────────────────────────┘

滚动中 (0 < 滚动位置 < 100):
┌─────────────────────────────────────────┐
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│ ← 半透明背景
│▓ ← 路线详情              [☆] [↗] ▓▓▓▓▓│
│▓▓▓▓   (18px, 过渡中)   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│ ← 标题缩小中
└─────────────────────────────────────────┘

固定状态 (滚动位置 ≥ 100):
┌─────────────────────────────────────────┐
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│ ← 实色背景 95%透明度
│▓ ← 路线详情              [☆] [↗] ▓▓▓▓▓│
│▓▓▓▓   (17px, 字重600)   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│ ← 小标题
├─────────────────────────────────────────┤ ← 底边框显示
│  ...                                    │
└─────────────────────────────────────────┘
```

#### 底部导航栏

| 元素 | 属性 | 值 |
|------|------|-----|
| **背景** | 颜色 | `#0A0F14` |
| **背景** | 模糊 | `backdrop-filter: blur(20px)` |
| **边框** | 顶部 | `1px solid #21262D` |
| **图标-默认** | 颜色 | `#6E7681` |
| **图标-选中** | 颜色 | `#4DB6AC` |
| **文字-默认** | 颜色 | `#6E7681` |
| **文字-选中** | 颜色 | `#4DB6AC` |

### 3.7 弹窗/模态框

#### 标准模态框

| 元素 | 属性 | 值 |
|------|------|-----|
| **遮罩** | 颜色 | `rgba(0, 0, 0, 0.7)` |
| **容器** | 背景 | `#141C24` |
| **容器** | 边框 | `1px solid #30363D` |
| **容器** | 圆角 | `16px` |
| **标题** | 颜色 | `#F0F6FC` |
| **内容** | 颜色 | `#C9D1D9` |
| **分割线** | 颜色 | `#21262D` |

---

## 4. 页面适配

### 4.1 首页/发现页

#### 页面结构

```
┌─────────────────────────────────────────┐
│ 状态栏                                  │
├─────────────────────────────────────────┤
│ 导航栏 (#0A0F14)                        │
│ [菜单]  探索山径  [搜索]                │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ 搜索栏                          │    │
│  │ #141C24 bg, #30363D border      │    │
│  └─────────────────────────────────┘    │
│                                         │
│  推荐路线                               │
│  ┌─────────────────────────────────┐    │
│  │ ┌─────────────┐ ┌─────────────┐ │    │
│  │ │             │ │             │ │    │
│  │ │   卡片1     │ │   卡片2     │ │    │
│  │ │ #141C24 bg  │ │ #141C24 bg  │ │    │
│  │ └─────────────┘ └─────────────┘ │    │
│  └─────────────────────────────────┘    │
│                                         │
│  分类筛选                               │
│  [全部] [休闲] [轻度] [进阶] [挑战]     │
│  选中: #1E524B bg, #4DB6AC text         │
│                                         │
└─────────────────────────────────────────┘
│ 底部导航栏 (#0A0F14)                    │
└─────────────────────────────────────────┘
```

### 4.2 路线详情页

#### 页面结构

```
┌─────────────────────────────────────────┐
│ 状态栏                                  │
├─────────────────────────────────────────┤
│ 导航栏 (透明 → 滚动后 #0A0F14)          │
│ [返回]                [分享] [收藏]     │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │                                     │ │
│ │        路线头图                     │ │
│ │        底部渐变遮罩                 │ │
│ │        rgba(10,15,20,0.7)           │ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │ 路线名称                            │ │
│ │ #F0F6FC, 22px, Semibold             │ │
│ │                                     │ │
│ │ [休闲] 3.2km · 1.5小时 · 西湖区     │ │
│ │ #66BB6A tag, #8B949E info           │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ 路线介绍                                │
│ #C9D1D9, 14px, Regular                  │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 路线数据卡片 #141C24                │ │
│ │ ┌──────┬──────┬──────┐              │ │
│ │ │ 5.2  │ 2.5  │ 180  │              │ │
│ │ │公里  │小时  │爬升  │              │ │
│ │ └──────┴──────┴──────┘              │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ [开始导航] 主按钮                       │
│                                         │
└─────────────────────────────────────────┘
```

### 4.3 导航页

#### 页面结构

```
┌─────────────────────────────────────────┐
│ 状态栏                                  │
├─────────────────────────────────────────┤
│ 导航栏 (#0A0F14)                        │
│ [退出]  九溪烟树导航  [设置]            │
├─────────────────────────────────────────┤
│                                         │
│                                         │
│              地图区域                   │
│         (使用高德暗黑主题)              │
│                                         │
│              ● 当前位置                 │
│              #4DB6AC 定位点             │
│                                         │
│                                         │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ 导航信息卡片 #141C24                │ │
│ │                                     │ │
│ │ 前方 50 米 右转                     │ │
│ │ #F0F6FC, 20px, Semibold             │ │
│ │                                     │ │
│ │ 沿九溪路前行                        │ │
│ │ #C9D1D9, 14px                       │ │
│ │                                     │ │
│ ├─────────────────────────────────────┤ │
│ │ 剩余: 2.3km    时间: 45分钟         │ │
│ │ #8B949E, 14px                       │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ [SOS紧急求助] 危险按钮                  │
│                                         │
└─────────────────────────────────────────┘
```

### 4.4 用户中心

#### 页面结构

```
┌─────────────────────────────────────────┐
│ 状态栏                                  │
├─────────────────────────────────────────┤
│ 导航栏 (#0A0F14)                        │
│ 个人中心                      [设置]    │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ 用户信息卡片 #141C24                │ │
│ │                                     │ │
│ │   ┌─────┐                         │ │
│ │   │头像 │  用户名                  │ │
│ │   │     │  #F0F6FC, 18px          │ │
│ │   └─────┘  ID: 12345678            │ │
│ │            #8B949E, 12px           │ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ 我的数据                                │
│ ┌─────────────────────────────────────┐ │
│ │  ┌─────┬─────┬─────┐                │ │
│ │  │ 12  │ 56  │ 128 │                │ │
│ │  │路线 │公里 │小时 │                │ │
│ │  └─────┴─────┴─────┘                │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ 功能列表                                │
│ ┌─────────────────────────────────────┐ │
│ │ 我的收藏              >  #C9D1D9    │ │
│ ├─────────────────────────────────────┤ │
│ │ 历史记录              >  #C9D1D9    │ │
│ ├─────────────────────────────────────┤ │
│ │ 离线地图              >  #C9D1D9    │ │
│ ├─────────────────────────────────────┤ │
│ │ 安全中心              >  #C9D1D9    │ │
│ └─────────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
│ 底部导航栏                              │
└─────────────────────────────────────────┘
```

---

## 5. 地图适配

### 5.1 高德地图暗黑模式

#### 高德地图暗黑主题风险缓解方案

**问题**: 高德地图官方暗黑主题可能与山径品牌色不协调，或部分区域显示不佳。

**解决方案**:

1. **自定义样式覆盖方案**
```javascript
// 山径APP 自定义地图暗黑主题
const shanjingDarkMapStyle = {
  // 基础配置
  "styleJson": [
    // 背景
    {
      "featureType": "background",
      "elementType": "geometry",
      "stylers": {
        "color": "#0A0F14"
      }
    },
    // 陆地
    {
      "featureType": "land",
      "elementType": "geometry",
      "stylers": {
        "color": "#111820"
      }
    },
    // 水域
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": {
        "color": "#0D2438"
      }
    },
    // 主要道路 - 使用品牌色
    {
      "featureType": "road",
      "elementType": "geometry.fill",
      "stylers": {
        "color": "#30363D"
      }
    },
    // 高速/快速路
    {
      "featureType": "highway",
      "elementType": "geometry.fill",
      "stylers": {
        "color": "#3D444D"
      }
    },
    // 高速边框
    {
      "featureType": "highway",
      "elementType": "geometry.stroke",
      "stylers": {
        "color": "#4DB6AC",  // 品牌色
        "weight": "0.5"
      }
    },
    // 公园/绿地
    {
      "featureType": "green",
      "elementType": "geometry",
      "stylers": {
        "color": "#0D2810"
      }
    },
    // 建筑物
    {
      "featureType": "building",
      "elementType": "geometry.fill",
      "stylers": {
        "color": "#1A222C"
      }
    },
    // POI 文字
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": {
        "color": "#C9D1D9"
      }
    },
    // POI 文字描边
    {
      "featureType": "poi",
      "elementType": "labels.text.stroke",
      "stylers": {
        "color": "#0A0F14"
      }
    },
    // 行政边界
    {
      "featureType": "boundary",
      "elementType": "geometry",
      "stylers": {
        "color": "#4DB6AC",  // 品牌色
        "weight": "0.5"
      }
    },
    // 取消不必要的 POI 显示，减少视觉干扰
    {
      "featureType": "poilabel",
      "elementType": "labels",
      "stylers": {
        "visibility": "off"
      }
    }
  ]
};

// Flutter 中使用
// 加载自定义样式文件
mapController.setMapCustomEnable(true);
mapController.setCustomMapStylePath('assets/map/dark_style.json');
```

2. **动态主题切换**
```dart
// lib/map/map_theme_manager.dart

class MapThemeManager {
  static String? _currentStylePath;
  
  /// 应用主题到地图
  static Future<void> applyTheme(
    AMapController controller, 
    bool isDarkMode
  ) async {
    if (isDarkMode) {
      // 使用自定义暗黑主题
      await controller.setMapCustomEnable(true);
      await controller.setCustomMapStylePath(
        'assets/map/shanjing_dark.json'
      );
      _currentStylePath = 'assets/map/shanjing_dark.json';
    } else {
      // 使用标准主题
      await controller.setMapCustomEnable(false);
      _currentStylePath = null;
    }
  }
  
  /// 刷新地图主题 (主题切换后调用)
  static Future<void> refreshTheme(AMapController controller) async {
    if (_currentStylePath != null) {
      await controller.setMapCustomEnable(false);
      await Future.delayed(Duration(milliseconds: 100));
      await controller.setMapCustomEnable(true);
      await controller.setCustomMapStylePath(_currentStylePath!);
    }
  }
}

// 在主题切换时调用
void onThemeChanged(bool isDarkMode) {
  MapThemeManager.applyTheme(mapController, isDarkMode);
}
```

3. **备用方案**
- 如自定义样式加载失败，自动降级到官方 `amap://styles/dark`
- 提供"简化地图"选项，使用标准地图+半透明遮罩

#### API 调用

```javascript
// 初始化暗黑模式地图
const map = new AMap.Map('container', {
  mapStyle: 'amap://styles/dark',  // 官方暗黑主题
  zoom: 15,
  center: [120.12, 30.28]
});

// 动态切换
function setDarkMode(isDark) {
  const style = isDark ? 'amap://styles/dark' : 'amap://styles/normal';
  map.setMapStyle(style);
}
```

#### 自定义地图样式

针对山径APP品牌色，自定义地图样式：

```javascript
// 自定义暗黑主题配置
const customDarkStyle = {
  // 背景
  "background": "#0A0F14",
  
  // 陆地
  "land": "#141C24",
  
  // 水域
  "water": "#0D2438",
  
  // 道路
  "road": {
    "main": "#30363D",      // 主干道
    "secondary": "#252B32", // 次干道
    "path": "#3DAB9E"       // 步道/山径 - 使用品牌色
  },
  
  // 建筑物
  "building": "#1A222C",
  
  // 兴趣点
  "poi": {
    "text": "#C9D1D9",
    "icon": "#8B949E"
  },
  
  // 标签
  "label": {
    "text": "#C9D1D9",
    "stroke": "#0A0F14"
  }
};
```

### 5.2 地图元素配色

| 地图元素 | 浅色模式 | 暗黑模式 |
|----------|----------|----------|
| **路线轨迹** | `#2D968A` | `#4DB6AC` |
| **当前位置** | `#2D968A` | `#4DB6AC` |
| **起点标记** | `#4CAF50` | `#66BB6A` |
| **终点标记** | `#EF5350` | `#F87171` |
| **关键点** | `#FFC107` | `#FFD54F` |
| **选中POI** | `#2D968A` | `#4DB6AC` |
| **路径方向** | `#FFFFFF` | `#0A0F14` |

### 5.3 路线覆盖物样式

```dart
// Flutter 地图路线样式（暗黑模式）
Polyline darkModePolyline = Polyline(
  polylineId: PolylineId('trail_route'),
  points: routePoints,
  color: Color(0xFF4DB6AC),        // 品牌色-暗黑模式
  width: 6,
  jointType: JointType.round,
  endCap: Cap.roundCap,
  startCap: Cap.roundCap,
);

// 已走过路线（半透明）
Polyline completedPolyline = Polyline(
  polylineId: PolylineId('completed_route'),
  points: completedPoints,
  color: Color(0x804DB6AC),        // 50%透明度
  width: 6,
);

// 剩余路线（虚线）
Polyline remainingPolyline = Polyline(
  polylineId: PolylineId('remaining_route'),
  points: remainingPoints,
  color: Color(0xFF4DB6AC),
  width: 6,
  patterns: [PatternItem.dash(20), PatternItem.gap(10)],
);
```

---

## 6. 插画/图片适配

### 6.1 空状态插画

#### 插画调色规则

| 元素 | 浅色模式 | 暗黑模式调整 |
|------|----------|--------------|
| **主色调** | `#2D968A` | `#4DB6AC` |
| **辅助色1** | `#72C0B5` | `#6BC4BC` |
| **辅助色2** | `#9DD6CE` | `#8DD4CE` |
| **背景元素** | `#E8F5F3` | `#1E524B` |
| **中性色** | `#E5E7EB` | `#30363D` |

#### 无网络状态插画

```
暗黑模式版本：
- 背景: 透明（使用页面背景）
- WiFi图标: #6E7681 → #8B949E
- 断开线条: #F87171
- 装饰元素: #1E524B
```

#### 无数据状态插画

```
暗黑模式版本：
- 盒子主体: #1E2730
- 盒子阴影: #0A0F14
- 内部装饰: #4DB6AC
- 飘落的叶子: #6E7681
```

### 6.2 图片处理

#### 图片遮罩

```css
/* 图片容器添加渐变遮罩，适配暗黑模式 */
.image-container::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 60%;
  background: linear-gradient(
    to top,
    rgba(10, 15, 20, 0.9) 0%,
    rgba(10, 15, 20, 0.5) 50%,
    transparent 100%
  );
}
```

#### 图片亮度调整

```dart
// Flutter 图片亮度调整
ColorFiltered(
  colorFilter: ColorFilter.matrix([
    0.9, 0, 0, 0, 0,   // R
    0, 0.9, 0, 0, 0,   // G
    0, 0, 0.9, 0, 0,   // B
    0, 0, 0, 1, 0,     // A
  ]),
  child: Image.network(imageUrl),
)
```

---

## 7. 动效适配

### 7.1 切换动画

#### 主题切换过渡

```dart
// Flutter 主题切换动画
AnimatedTheme(
  data: isDarkMode ? darkTheme : lightTheme,
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  child: child,
)
```

#### 颜色过渡动画

```css
/* CSS 颜色过渡 */
.theme-transition {
  transition: background-color 300ms ease-in-out,
              color 300ms ease-in-out,
              border-color 300ms ease-in-out;
}
```

### 7.2 暗黑模式特殊动效

#### 发光效果

```css
/* 主按钮悬浮发光 */
.dark-mode .primary-button:hover {
  box-shadow: 0 0 20px rgba(61, 171, 158, 0.4);
}

/* 定位点脉冲 */
.dark-mode .location-pulse {
  box-shadow: 0 0 0 0 rgba(77, 182, 172, 0.7);
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0% {
    box-shadow: 0 0 0 0 rgba(77, 182, 172, 0.7);
  }
  70% {
    box-shadow: 0 0 0 20px rgba(77, 182, 172, 0);
  }
  100% {
    box-shadow: 0 0 0 0 rgba(77, 182, 172, 0);
  }
}
```

---

## 8. 开发规范

### 8.1 Flutter 实现

#### 完整 ThemeData 配置 (含 ColorScheme 新属性)

```dart
// lib/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // ===== 暗黑模式颜色定义 =====
  static const Color darkBgPrimary = Color(0xFF0A0F14);
  static const Color darkBgSecondary = Color(0xFF111820);
  static const Color darkBgTertiary = Color(0xFF1A222C);
  
  static const Color darkSurfacePrimary = Color(0xFF141C24);
  static const Color darkSurfaceSecondary = Color(0xFF1E2730);
  static const Color darkSurfaceTertiary = Color(0xFF28323D);
  static const Color darkSurfaceElevated = Color(0xFF2A3540);
  
  static const Color darkTextPrimary = Color(0xFFF0F6FC);
  static const Color darkTextSecondary = Color(0xFFC9D1D9);
  static const Color darkTextTertiary = Color(0xFF8B949E);
  static const Color darkTextQuaternary = Color(0xFF6E7681);
  static const Color darkTextDisabled = Color(0xFF484F58);
  
  static const Color darkBorderDefault = Color(0xFF30363D);
  static const Color darkBorderSubtle = Color(0xFF21262D);
  
  static const Color darkPrimary = Color(0xFF3DAB9E);
  static const Color darkPrimaryLight = Color(0xFF4DB6AC);
  static const Color darkPrimaryDark = Color(0xFF2D968A);
  
  static const Color darkSuccess = Color(0xFF66BB6A);
  static const Color darkWarning = Color(0xFFFFD54F);
  static const Color darkError = Color(0xFFF87171);
  static const Color darkInfo = Color(0xFF60A5FA);

  // ===== 完整暗黑模式 ThemeData =====
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBgPrimary,
      
      // ===== ColorScheme - 完整配置 (Flutter 3.x) =====
      colorScheme: ColorScheme.dark(
        // 主要品牌色
        primary: darkPrimary,
        onPrimary: darkBgPrimary,
        primaryContainer: darkPrimaryLight,
        onPrimaryContainer: darkBgPrimary,
        
        // 次要色
        secondary: darkSurfaceSecondary,
        onSecondary: darkTextPrimary,
        secondaryContainer: darkSurfaceTertiary,
        onSecondaryContainer: darkTextPrimary,
        
        // 第三色
        tertiary: darkInfo,
        onTertiary: darkBgPrimary,
        tertiaryContainer: Color(0xFF0D2438),
        onTertiaryContainer: darkInfo,
        
        // 错误色
        error: darkError,
        onError: darkBgPrimary,
        errorContainer: Color(0xFF2D0D0D),
        onErrorContainer: darkError,
        
        // 表面色
        surface: darkSurfacePrimary,
        onSurface: darkTextPrimary,
        surfaceVariant: darkSurfaceSecondary,
        onSurfaceVariant: darkTextSecondary,
        
        // 背景色
        background: darkBgPrimary,
        onBackground: darkTextSecondary,
        
        // 轮廓
        outline: darkBorderDefault,
        outlineVariant: darkBorderSubtle,
        
        // 阴影
        shadow: Colors.black,
        
        // 反色 (用于对比)
        inverseSurface: Colors.white,
        onInverseSurface: darkBgPrimary,
        inversePrimary: darkPrimaryLight,
        
        // 表面色调
        surfaceTint: darkPrimary.withOpacity(0.1),
        
        // 亮度 (Material 3)
        brightness: Brightness.dark,
      ),
      
      // ===== 扩展颜色 (Material 3) =====
      // 表面容器色
      canvasColor: darkSurfacePrimary,
      cardColor: darkSurfacePrimary,
      dialogBackgroundColor: darkSurfacePrimary,
      
      // 禁用色
      disabledColor: darkTextDisabled,
      hintColor: darkTextQuaternary,
      indicatorColor: darkPrimary,
      
      // ===== AppBar 主题 =====
      appBarTheme: AppBarTheme(
        backgroundColor: darkBgPrimary.withOpacity(0.85),
        foregroundColor: darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        surfaceTintColor: darkPrimary.withOpacity(0.1),
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: darkTextSecondary),
        actionsIconTheme: IconThemeData(color: darkTextSecondary),
      ),
      
      // ===== Card 主题 (Material 3) =====
      cardTheme: CardTheme(
        color: darkSurfacePrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: darkBorderDefault),
        ),
        margin: EdgeInsets.all(8),
      ),
      
      // ===== 按钮主题 =====
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: darkBgPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return darkBgPrimary.withOpacity(0.2);
            }
            if (states.contains(MaterialState.hovered)) {
              return darkBgPrimary.withOpacity(0.1);
            }
            return null;
          }),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimaryLight,
          side: BorderSide(color: darkPrimary),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPrimaryLight,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: darkBgPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // ===== 输入框主题 =====
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkBgPrimary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkBorderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkBorderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkInfo, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkError, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkError, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: darkTextQuaternary),
        labelStyle: TextStyle(color: darkTextSecondary),
        prefixIconColor: darkTextTertiary,
        suffixIconColor: darkTextTertiary,
      ),
      
      // ===== 底部导航栏主题 =====
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkBgPrimary.withOpacity(0.85),
        selectedItemColor: darkPrimaryLight,
        unselectedItemColor: darkTextQuaternary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
      
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkBgPrimary.withOpacity(0.85),
        indicatorColor: darkPrimary.withOpacity(0.2),
        labelTextStyle: MaterialStateProperty.all(
          TextStyle(fontSize: 12, color: darkTextSecondary),
        ),
        iconTheme: MaterialStateProperty.all(
          IconThemeData(color: darkTextTertiary),
        ),
      ),
      
      // ===== 分割线主题 =====
      dividerTheme: DividerThemeData(
        color: darkBorderSubtle,
        thickness: 1,
        space: 1,
      ),
      
      // ===== 弹窗主题 =====
      dialogTheme: DialogTheme(
        backgroundColor: darkSurfacePrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: darkBorderDefault),
        ),
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: darkTextSecondary,
          fontSize: 16,
        ),
      ),
      
      // ===== SnackBar 主题 =====
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurfaceTertiary,
        contentTextStyle: TextStyle(color: darkTextPrimary),
        actionTextColor: darkPrimaryLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // ===== Chip 主题 =====
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceSecondary,
        selectedColor: darkPrimary.withOpacity(0.2),
        disabledColor: darkBgSecondary,
        labelStyle: TextStyle(color: darkTextSecondary),
        secondaryLabelStyle: TextStyle(color: darkPrimaryLight),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: darkBorderDefault),
        ),
      ),
      
      // ===== 开关主题 =====
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return darkPrimary;
          }
          return darkTextQuaternary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return darkPrimary.withOpacity(0.5);
          }
          return darkSurfaceTertiary;
        }),
      ),
      
      // ===== 滑块主题 =====
      sliderTheme: SliderThemeData(
        activeTrackColor: darkPrimary,
        inactiveTrackColor: darkSurfaceTertiary,
        thumbColor: darkPrimary,
        overlayColor: darkPrimary.withOpacity(0.2),
        valueIndicatorColor: darkSurfaceTertiary,
        valueIndicatorTextStyle: TextStyle(color: darkTextPrimary),
      ),
      
      // ===== 文字主题 =====
      textTheme: TextTheme(
        displayLarge: TextStyle(color: darkTextPrimary),
        displayMedium: TextStyle(color: darkTextPrimary),
        displaySmall: TextStyle(color: darkTextPrimary),
        headlineLarge: TextStyle(color: darkTextPrimary),
        headlineMedium: TextStyle(color: darkTextPrimary),
        headlineSmall: TextStyle(color: darkTextPrimary),
        titleLarge: TextStyle(color: darkTextPrimary),
        titleMedium: TextStyle(color: darkTextPrimary),
        titleSmall: TextStyle(color: darkTextSecondary),
        bodyLarge: TextStyle(color: darkTextSecondary),
        bodyMedium: TextStyle(color: darkTextSecondary),
        bodySmall: TextStyle(color: darkTextTertiary),
        labelLarge: TextStyle(color: darkTextSecondary),
        labelMedium: TextStyle(color: darkTextTertiary),
        labelSmall: TextStyle(color: darkTextTertiary),
      ),
      
      // ===== 图标主题 =====
      iconTheme: IconThemeData(
        color: darkTextSecondary,
        size: 24,
      ),
      primaryIconTheme: IconThemeData(
        color: darkPrimary,
        size: 24,
      ),
    );
  }
}
```

#### 主题切换 Provider

```dart
// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeType {
  light,
  dark,
  system,
}

class ThemeProvider extends ChangeNotifier {
  ThemeModeType _themeMode = ThemeModeType.system;
  
  ThemeModeType get themeMode => _themeMode;
  
  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case ThemeModeType.light:
        return ThemeMode.light;
      case ThemeModeType.dark:
        return ThemeMode.dark;
      case ThemeModeType.system:
        return ThemeMode.system;
    }
  }
  
  bool get isDarkMode {
    if (_themeMode == ThemeModeType.dark) return true;
    if (_themeMode == ThemeModeType.light) return false;
    // system 模式需要获取系统亮度
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == 
           Brightness.dark;
  }
  
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString('theme_mode') ?? 'system';
    _themeMode = ThemeModeType.values.firstWhere(
      (e) => e.name == mode,
      orElse: () => ThemeModeType.system,
    );
    notifyListeners();
  }
  
  Future<void> setThemeMode(ThemeModeType mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
    notifyListeners();
  }
  
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeModeType.dark) {
      await setThemeMode(ThemeModeType.light);
    } else {
      await setThemeMode(ThemeModeType.dark);
    }
  }
}
```

### 8.2 iOS 原生适配

#### iOS 13+ 自动适配

```swift
// AppDelegate.swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // 启用暗黑模式自动适配
    if #available(iOS 13.0, *) {
      window?.overrideUserInterfaceStyle = .unspecified
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

#### Flutter 与 iOS 原生通信

```dart
// 获取系统暗黑模式状态
import 'package:flutter/services.dart';

class SystemTheme {
  static const platform = MethodChannel('com.shanjing/theme');
  
  static Future<bool> get isSystemDarkMode async {
    try {
      final bool result = await platform.invokeMethod('getSystemDarkMode');
      return result;
    } catch (e) {
      return false;
    }
  }
}
```

---

## 9. 设计Token

### 9.1 完整 Token 列表

#### 字体层级规范 (Typography Scale)

山径APP采用 Material Design 3 字体层级系统，分为 Display、Headline、Title、Body、Label 五个层级，每个层级包含 Large、Medium、Small 三种规格。

##### 字体层级定义表

| 层级 | 规格 | 字号 | 字重 | 行高 | 字间距 | 用途 |
|------|------|------|------|------|--------|------|
| **Display** | Large | 57px | 400 (Regular) | 64px | -0.25px | 启动页大标题、空状态主标题 |
| **Display** | Medium | 45px | 400 (Regular) | 52px | 0px | 首页欢迎语、Hero区域 |
| **Display** | Small | 36px | 400 (Regular) | 44px | 0px | 页面顶部大标题、数值展示 |
| **Headline** | Large | 32px | 400 (Regular) | 40px | 0px | 页面标题、模态框标题 |
| **Headline** | Medium | 28px | 400 (Regular) | 36px | 0px | 卡片大标题、章节标题 |
| **Headline** | Small | 24px | 400 (Regular) | 32px | 0px | 列表项标题、弹窗标题 |
| **Title** | Large | 22px | 500 (Medium) | 28px | 0px | 导航栏标题、列表头 |
| **Title** | Medium | 16px | 500 (Medium) | 24px | 0.15px | 卡片标题、列表项主标题 |
| **Title** | Small | 14px | 500 (Medium) | 20px | 0.1px | 小卡片标题、标签组标题 |
| **Body** | Large | 16px | 400 (Regular) | 24px | 0.5px | 正文内容、段落文字 |
| **Body** | Medium | 14px | 400 (Regular) | 20px | 0.25px | 默认正文、描述文字 |
| **Body** | Small | 12px | 400 (Regular) | 16px | 0.4px | 辅助说明、次要信息 |
| **Label** | Large | 14px | 500 (Medium) | 20px | 0.1px | 按钮文字、标签 |
| **Label** | Medium | 12px | 500 (Medium) | 16px | 0.5px | 小按钮、导航标签 |
| **Label** | Small | 11px | 500 (Medium) | 16px | 0.5px | 徽章、小标签、时间戳 |

##### 字体层级视觉示意

```
Display Large      山径探索  (57px/Regular)
Display Medium     山径探索  (45px/Regular)
Display Small      山径探索  (36px/Regular)

Headline Large     路线详情  (32px/Regular)
Headline Medium    九溪烟树  (28px/Regular)
Headline Small     九溪烟树  (24px/Regular)

Title Large        导航栏标题 (22px/Medium)
Title Medium       卡片标题   (16px/Medium)
Title Small        小卡片标题 (14px/Medium)

Body Large         这是一段正文的示例文字 (16px/Regular)
Body Medium        这是一段正文的示例文字 (14px/Regular)
Body Small         这是一段辅助说明文字 (12px/Regular)

Label Large        主要按钮 (14px/Medium)
Label Medium       标签文字 (12px/Medium)
Label Small        徽章文字 (11px/Medium)
```

##### Flutter TextTheme 配置

```dart
// lib/theme/app_typography.dart

class AppTypography {
  // 基准字体
  static const String fontFamily = 'PingFang SC';
  static const String fallbackFont = 'SF Pro Display';
  
  // ===== Display 层级 =====
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    height: 64 / 57,  // 行高系数
    letterSpacing: -0.25,
    fontFamily: fontFamily,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    height: 52 / 45,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 44 / 36,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );
  
  // ===== Headline 层级 =====
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 40 / 32,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 36 / 28,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 32 / 24,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );
  
  // ===== Title 层级 =====
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 28 / 22,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    letterSpacing: 0.15,
    fontFamily: fontFamily,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: 0.1,
    fontFamily: fontFamily,
  );
  
  // ===== Body 层级 =====
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    letterSpacing: 0.5,
    fontFamily: fontFamily,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    letterSpacing: 0.25,
    fontFamily: fontFamily,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 0.4,
    fontFamily: fontFamily,
  );
  
  // ===== Label 层级 =====
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: 0.1,
    fontFamily: fontFamily,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.5,
    fontFamily: fontFamily,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 16 / 11,
    letterSpacing: 0.5,
    fontFamily: fontFamily,
  );
  
  // ===== 完整 TextTheme =====
  static TextTheme get textTheme {
    return const TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );
  }
}
```

##### 使用示例

```dart
// 页面标题使用 Headline Medium
Text(
  '九溪烟树',
  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
    color: AppTheme.darkTextPrimary,
  ),
);

// 正文使用 Body Medium
Text(
  '这是一条非常适合新手徒步的路线...',
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: AppTheme.darkTextSecondary,
  ),
);

// 按钮文字使用 Label Large
ElevatedButton(
  onPressed: () {},
  child: Text(
    '开始导航',
    style: Theme.of(context).textTheme.labelLarge?.copyWith(
      color: AppTheme.darkBgPrimary,
    ),
  ),
);

// 辅助信息使用 Body Small
Text(
  '3.2公里 · 休闲 · 西湖区',
  style: Theme.of(context).textTheme.bodySmall?.copyWith(
    color: AppTheme.darkTextTertiary,
  ),
);
```

#### 圆角层级规范 (Radius Scale)

山径APP采用五级圆角系统，从锐利到圆润，满足不同组件的视觉需求。

##### 圆角层级定义表

| Token | 圆角值 | 使用场景 | 视觉特点 | 示例组件 |
|-------|--------|----------|----------|----------|
| `--radius-none` | 0px | 分割线、全宽列表、表格 | 锐利专业 | 列表分割线、表格行 |
| `--radius-sm` | 4px | 小按钮、标签、徽章、紧凑输入框 | 微圆角，精致小巧 | 小按钮、标签、复选框 |
| `--radius-md` | 8px | 卡片、输入框、标准按钮、列表项 | 标准圆角，通用平衡 | 卡片、输入框、主按钮 |
| `--radius-lg` | 12px | 大卡片、模态框、浮层面板、图片容器 | 较大圆角，柔和友好 | 路线卡片、图片容器、弹窗 |
| `--radius-xl` | 16px | 底部弹窗、大模态框、侧边面板 | 大圆角，现代感强 | 底部弹窗、设置面板 |
| `--radius-full` | 999px | 胶囊按钮、标签页、搜索栏、头像 | 全圆角，完全圆润 | 胶囊按钮、搜索栏、徽章 |

##### 圆角层级使用规范

```
圆角层级示意:

none (0px)      sm (4px)        md (8px)        lg (12px)       xl (16px)       full (999px)
┌────────┐     ┌──────┐        ┌──────┐        ┌──────┐        ┌──────┐        ╭──────╮
│        │     │      │        │      │        │      │        ╭      ╮       (      )
│ 列表项  │     │ 标签 │        │ 卡片 │        │ 大卡片│        │ 弹窗  │        胶囊按钮
│        │     │      │        │      │        │      │        ╰      ╯       ╰──────╯
└────────┘     └──────┘        └──────┘        └──────┘        └──────┘
```

##### 圆角组合使用原则

| 场景 | 外层组件 | 内层组件 | 说明 |
|------|----------|----------|------|
| 标准卡片 | `radius-md` (8px) | - | 通用卡片 |
| 图片卡片 | `radius-lg` (12px) | 图片 `radius-md` (8px) | 外层更圆，内层稍锐 |
| 按钮组 | `radius-full` | - | 胶囊按钮组合 |
| 输入框+按钮 | `radius-md` (8px) | - | 统一圆角 |
| 底部弹窗 | `radius-xl` (16px) | 内容区 `radius-md` (8px) | 层次分明 |

##### Flutter 圆角配置

```dart
// lib/theme/app_radius.dart

class AppRadius {
  // 无圆角 - 列表、分割线
  static const double none = 0;
  
  // 小圆角 - 小按钮、标签
  static const double sm = 4;
  
  // 中圆角 - 卡片、输入框、标准按钮
  static const double md = 8;
  
  // 大圆角 - 大卡片、模态框、图片容器
  static const double lg = 12;
  
  // 超大圆角 - 底部弹窗、大模态框
  static const double xl = 16;
  
  // 全圆角 - 胶囊按钮、搜索栏
  static const double full = 999;
  
  // ===== 预定义 BorderRadius =====
  static const BorderRadius noneRadius = BorderRadius.zero;
  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlRadius = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius fullRadius = BorderRadius.all(Radius.circular(full));
  
  // 顶部圆角 (底部弹窗用)
  static const BorderRadius topRadius = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );
  
  // 左右圆角 (标签用)
  static const BorderRadius horizontalRadius = BorderRadius.only(
    topLeft: Radius.circular(full),
    topRight: Radius.circular(full),
    bottomLeft: Radius.circular(full),
    bottomRight: Radius.circular(full),
  );
}
```

##### 圆角使用示例

```dart
// 小按钮 - radius-sm
TextButton(
  style: TextButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.smRadius,
    ),
  ),
  onPressed: () {},
  child: Text('标签'),
);

// 标准卡片 - radius-md
Card(
  shape: RoundedRectangleBorder(
    borderRadius: AppRadius.mdRadius,
  ),
  child: Container(...),
);

// 路线图片卡片 - radius-lg
ClipRRect(
  borderRadius: AppRadius.lgRadius,
  child: Image.network(...),
);

// 底部弹窗 - radius-xl (仅顶部)
showModalBottomSheet(
  shape: const RoundedRectangleBorder(
    borderRadius: AppRadius.topRadius,
  ),
  context: context,
  builder: (context) => ...,  
);

// 胶囊按钮 - radius-full
ElevatedButton(
  style: ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.fullRadius,
    ),
  ),
  onPressed: () {},
  child: Text('开始导航'),
);
```

```json
{
  "darkMode": {
    "color": {
      "background": {
        "primary": "#0A0F14",
        "secondary": "#111820",
        "tertiary": "#1A222C"
      },
      "surface": {
        "primary": "#141C24",
        "secondary": "#1E2730",
        "tertiary": "#28323D",
        "elevated": "#2A3540"
      },
      "text": {
        "primary": "#F0F6FC",
        "secondary": "#C9D1D9",
        "tertiary": "#8B949E",
        "quaternary": "#6E7681",
        "disabled": "#484F58"
      },
      "border": {
        "default": "#30363D",
        "subtle": "#21262D",
        "hover": "#3D444D",
        "focus": "#58A6FF"
      },
      "primary": {
        "50": "#0D2B28",
        "100": "#143D38",
        "200": "#1E524B",
        "300": "#2D968A",
        "400": "#3DAB9E",
        "500": "#4DB6AC",
        "600": "#6BC4BC",
        "700": "#8DD4CE"
      },
      "semantic": {
        "success": "#66BB6A",
        "warning": "#FFD54F",
        "error": "#F87171",
        "info": "#60A5FA"
      }
    },
    "typography": {
      "display": {
        "large": {"size": "57px", "weight": 400, "lineHeight": "64px", "letterSpacing": "-0.25px"},
        "medium": {"size": "45px", "weight": 400, "lineHeight": "52px", "letterSpacing": "0px"},
        "small": {"size": "36px", "weight": 400, "lineHeight": "44px", "letterSpacing": "0px"}
      },
      "headline": {
        "large": {"size": "32px", "weight": 400, "lineHeight": "40px", "letterSpacing": "0px"},
        "medium": {"size": "28px", "weight": 400, "lineHeight": "36px", "letterSpacing": "0px"},
        "small": {"size": "24px", "weight": 400, "lineHeight": "32px", "letterSpacing": "0px"}
      },
      "title": {
        "large": {"size": "22px", "weight": 500, "lineHeight": "28px", "letterSpacing": "0px"},
        "medium": {"size": "16px", "weight": 500, "lineHeight": "24px", "letterSpacing": "0.15px"},
        "small": {"size": "14px", "weight": 500, "lineHeight": "20px", "letterSpacing": "0.1px"}
      },
      "body": {
        "large": {"size": "16px", "weight": 400, "lineHeight": "24px", "letterSpacing": "0.5px"},
        "medium": {"size": "14px", "weight": 400, "lineHeight": "20px", "letterSpacing": "0.25px"},
        "small": {"size": "12px", "weight": 400, "lineHeight": "16px", "letterSpacing": "0.4px"}
      },
      "label": {
        "large": {"size": "14px", "weight": 500, "lineHeight": "20px", "letterSpacing": "0.1px"},
        "medium": {"size": "12px", "weight": 500, "lineHeight": "16px", "letterSpacing": "0.5px"},
        "small": {"size": "11px", "weight": 500, "lineHeight": "16px", "letterSpacing": "0.5px"}
      }
    },
    "spacing": {
      "xs": "4px",
      "sm": "8px",
      "md": "16px",
      "lg": "24px",
      "xl": "32px",
      "2xl": "48px"
    },
    "radius": {
      "none": "0px",
      "sm": "4px",
      "md": "8px",
      "lg": "12px",
      "xl": "16px",
      "full": "999px"
    },
    "elevation": {
      "none": "none",
      "low": "0 2px 8px rgba(0, 0, 0, 0.3)",
      "medium": "0 4px 16px rgba(0, 0, 0, 0.4)",
      "high": "0 8px 32px rgba(0, 0, 0, 0.5)"
    },
    "animation": {
      "duration": {
        "fast": "150ms",
        "normal": "300ms",
        "slow": "500ms"
      },
      "easing": {
        "default": "ease-in-out",
        "enter": "ease-out",
        "exit": "ease-in"
      }
    }
  }
}
```

### 9.2 Token 使用示例

```dart
// 使用 Token 构建组件
Container(
  decoration: BoxDecoration(
    color: AppTheme.darkSurfacePrimary,  // Token: surface.primary
    borderRadius: BorderRadius.circular(12),  // Token: radius.lg
    border: Border.all(
      color: AppTheme.darkBorderDefault,  // Token: border.default
    ),
  ),
  padding: EdgeInsets.all(16),  // Token: spacing.md
  child: Text(
    '卡片内容',
    style: TextStyle(
      color: AppTheme.darkTextSecondary,  // Token: text.secondary
      fontSize: 14,
    ),
  ),
);
```

---

## 10. 验收标准

### 10.1 色彩验收

| 检查项 | 标准 | 检查方法 |
|--------|------|----------|
| **对比度** | 文字与背景对比度 ≥ 4.5:1 | 使用 contrast checker 工具 |
| **品牌色一致性** | 品牌色相保持一致 | 视觉检查 |
| **功能色可见性** | 成功/警告/错误色清晰可见 | 视觉检查 |
| **层级区分** | 不同层级背景可区分 | 视觉检查 |

### 10.2 组件验收

| 检查项 | 标准 | 检查方法 |
|--------|------|----------|
| **按钮状态** | 各状态样式正确 | 交互测试 |
| **输入框焦点** | 聚焦状态清晰可见 | 交互测试 |
| **卡片悬浮** | 悬浮效果正确 | 交互测试 |
| **禁用状态** | 禁用元素明显可辨识 | 视觉检查 |

### 10.3 页面验收

| 检查项 | 标准 | 检查方法 |
|--------|------|----------|
| **页面完整性** | 所有页面支持暗黑模式 | 逐页检查 |
| **图片适配** | 图片显示正常，有适当遮罩 | 视觉检查 |
| **地图适配** | 地图使用暗黑主题 | 功能测试 |
| **切换流畅** | 主题切换无闪烁，动画流畅 | 交互测试 |

### 10.4 性能验收

| 检查项 | 标准 | 检查方法 |
|--------|------|----------|
| **切换性能** | 主题切换 < 300ms | 性能测试 |
| **内存占用** | 无明显增加 | 内存监控 |
| **渲染性能** | 无掉帧 | 性能测试 |

---

## 附录

### A. 参考资源

- [Material Design Dark Theme](https://material.io/design/color/dark-theme.html)
- [Apple Human Interface Guidelines - Dark Mode](https://developer.apple.com/design/human-interface-guidelines/ios/overview/themes/)
- [WCAG 2.2 Contrast Guidelines](https://www.w3.org/WAI/WCAG22/quickref/#contrast-minimum)

### B. 更新记录

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| v1.0 | 2026-03-19 | M4 阶段初版，完整暗黑模式规范 |
| v1.1 | 2026-03-19 | M4 P2 更新：新增字体层级规范、圆角层级规范、导航栏滚动效果 |

### C. 设计团队

- 设计负责人: [待填写]
- 视觉设计: [待填写]
- 开发对接: [待填写]

---

> **"夜色中的山径，依然清晰可见"** - 山径APP暗黑模式设计哲学
