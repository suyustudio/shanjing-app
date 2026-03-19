# 山径APP - 图标系统设计规范 v1.0

> **文档版本**: v1.0  
> **制定日期**: 2026-03-19
> **文档状态**: M4 阶段 - **P0** [已升级]  
> **适用范围**: 山径APP全功能图标
> **基于**: 设计系统 v1.0, 品牌视觉体系
> **优先级调整说明**: 图标系统为基础依赖，其他规范需要，故从 P1 升级至 P0

---

## 目录

1. [设计概述](#1-设计概述)
2. [图标风格指南](#2-图标风格指南)
3. [图标尺寸规范](#3-图标尺寸规范)
4. [功能图标库](#4-功能图标库)
5. [安全提醒图标](#5-安全提醒图标)
6. [地图标记图标](#6-地图标记图标)
7. [社交媒体图标](#7-社交媒体图标)
8. [技术规范](#8-技术规范)
9. [切图与交付](#9-切图与交付)
10. [暗黑模式适配](#10-暗黑模式适配)

---

## 1. 设计概述

### 1.1 设计目标

建立一套完整、一致、易扩展的图标系统：

| 目标 | 说明 | 实现方式 |
|------|------|----------|
| **品牌一致性** | 图标风格符合山径品牌调性 | 自然、简洁、圆润 |
| **识别清晰** | 图标含义明确，易理解 | 行业通用隐喻 |
| **扩展性强** | 支持未来功能扩展 | 系统化设计方法 |
| **技术可行** | 支持多平台开发 | 矢量格式 + 规范命名 |

### 1.2 图标分类

| 类别 | 数量 | 用途 | 优先级 |
|------|------|------|--------|
| **基础功能图标** | ~30个 | 通用操作 | P0 |
| **导航图标** | ~10个 | 底部导航、页面切换 | P0 |
| **安全提醒图标** | ~15个 | SOS、安全中心 | P0 |
| **地图标记图标** | ~20个 | 地图POI、导航 | P1 |
| **社交媒体图标** | ~10个 | 分享、登录 | P1 |
| **状态图标** | ~15个 | 成功、警告、加载 | P1 |
| **装饰图标** | ~10个 | 装饰、空状态 | P2 |

---

## 2. 图标风格指南

### 2.1 风格定义

#### 整体风格

| 属性 | 定义 | 说明 |
|------|------|------|
| **风格类型** | 线性图标 (Outline) | 简洁现代，易于识别 |
| **线条粗细** | 2px 标准 | 统一视觉重量 |
| **端点样式** | 圆角 (Round Cap) | 柔和友好 |
| **拐角样式** | 圆角 (Round Join) | 统一风格 |
| **图标形状** | 圆角矩形外框 | 统一容器 |

#### 视觉语言

```
图标风格关键词：
┌────────────────────────────────────────┐
│  简洁  ·  圆润  ·  自然  ·  清晰      │
│                                        │
│  Clean  ·  Soft  ·  Natural  ·  Clear │
└────────────────────────────────────────┘
```

### 2.2 网格系统

#### 基础网格

```
24×24 图标网格:

┌────────────────────────┐
│  ┌──────────────────┐  │
│  │                  │  │
│  │    ┌────────┐    │  │  ← 内容区域
│  │    │        │    │  │     20×20px
│  │    │   ●    │    │  │     居中对齐
│  │    │        │    │  │
│  │    └────────┘    │  │
│  │                  │  │
│  └──────────────────┘  │
│                        │
│  ◄── 2px 安全边距 ──►  │
└────────────────────────┘

关键线条位置:
- 中心点: (12, 12)
- 内容区: 2px ~ 22px
- 关键节点: 4px, 8px, 12px, 16px, 20px
```

#### 网格规范

| 参数 | 值 | 说明 |
|------|-----|------|
| **画布尺寸** | 24×24px | 标准尺寸 |
| **内容区域** | 20×20px | 实际绘制区域 |
| **安全边距** | 2px | 四周留白 |
| **关键节点** | 4px 网格 | 对齐基准 |
| **线条粗细** | 2px | 标准描边 |
| **圆角半径** | 2px | 拐角圆角 |

### 2.3 线条规范

#### 描边设置

| 属性 | 值 | 说明 |
|------|-----|------|
| **描边宽度** | 2px | 标准粗细 |
| **端点样式** | Round | 圆头端点 |
| **拐角样式** | Round Join | 圆角连接 |
| **对齐方式** | Center | 中心对齐 |

#### 线条示例

```
线条端点样式对比:

Butt (平头):      Round (圆头):
┌─────────┐       ┌─────────┐
│         │       │  ╭───╮  │
│   ───   │   →   │  │ ─ │  │  ✅ 使用
│         │       │  ╰───╯  │
└─────────┘       └─────────┘

Miter (尖角):     Round (圆角):
┌─────────┐       ┌─────────┐
│    ┌    │       │   ╭─╮   │
│   / \   │   →   │  ╱   ╲  │  ✅ 使用
│  /   \  │       │ ╱     ╲ │
└─────────┘       └─────────┘
```

### 2.4 形状规范

#### 基本形状

| 形状 | 尺寸 | 用途 |
|------|------|------|
| **圆** | 20×20px 外圆 | 头像、状态 |
| **圆** | 4×4px 小圆点 | 指示点 |
| **正方形** | 18×18px 圆角2px | 容器、按钮 |
| **矩形** | 20×14px 圆角2px | 标签、卡片 |
| **线条** | 长度 8-16px | 连接、分隔 |

#### 图标构成示例

```
首页图标构成:

┌────────────────────────┐
│                        │
│     ╭──────────╮       │
│     │          │       │
│     │   ╭──╮   │       │  ← 房屋主体
│     │   │  │   │       │     圆角矩形
│     │   │  │   │       │
│     │   ╰──╯   │       │
│     │          │       │
│     ╰──────────╯       │
│                        │
│  整体: 20×20px         │
│  线条: 2px             │
│  圆角: 2px             │
└────────────────────────┘
```

---

## 3. 图标尺寸规范

### 3.1 尺寸体系

| 尺寸名称 | 尺寸值 | 使用场景 | 线条粗细 |
|----------|--------|----------|----------|
| **XS** | 16×16px | 内联文字、小标签 | 1.5px |
| **SM** | 20×20px | 按钮内、列表项 | 1.5px |
| **MD** | 24×24px | 标准导航栏 | 2px |
| **LG** | 32×32px | 大按钮、功能入口 | 2.5px |
| **XL** | 48×48px | 主要功能、空状态 | 3px |
| **XXL** | 64×64px | 首页功能、特色入口 | 4px |

### 3.2 尺寸对照表

```
图标尺寸展示:

XS (16px):    SM (20px):    MD (24px):
┌────┐        ┌──────┐      ┌────────┐
│ 🏠 │        │  🏠  │      │   🏠   │
└────┘        └──────┘      └────────┘
内联使用       按钮内        导航栏

LG (32px):    XL (48px):    XXL (64px):
┌────────┐    ┌──────────┐  ┌────────────┐
│   🏠   │    │    🏠    │  │     🏠     │
└────────┘    └──────────┘  └────────────┘
功能入口       主要功能      首页特色
```

### 3.3 响应式缩放

#### 缩放规则

| 原始尺寸 | 缩放比例 | 目标尺寸 | 线条调整 |
|----------|----------|----------|----------|
| 24px | 0.67× | 16px | 2px → 1.5px |
| 24px | 0.83× | 20px | 2px → 1.5px |
| 24px | 1.0× | 24px | 2px |
| 24px | 1.33× | 32px | 2px → 2.5px |
| 24px | 2.0× | 48px | 2px → 3px |
| 24px | 2.67× | 64px | 2px → 4px |

---

## 4. 功能图标库

### 4.1 基础操作图标

| 图标 | 名称 | 用途 | 优先级 |
|------|------|------|--------|
| ✕ | close | 关闭、删除 | P0 |
| ← | arrow_back | 返回 | P0 |
| → | arrow_forward | 前进、下一步 | P0 |
| ↑ | arrow_up | 向上、收起 | P0 |
| ↓ | arrow_down | 向下、展开 | P0 |
| + | add | 添加、新建 | P0 |
| − | remove | 减少、删除 | P0 |
| ✓ | check | 确认、选中 | P0 |
| ⋯ | more | 更多选项 | P0 |
| 🔍 | search | 搜索 | P0 |
| 🔔 | notification | 通知 | P0 |
| ⚙️ | settings | 设置 | P0 |
| 👤 | account | 个人中心 | P0 |
| 📍 | location | 定位 | P0 |
| 🗺️ | map | 地图 | P0 |

### 4.2 导航图标

| 图标 | 名称 | 用途 | 优先级 |
|------|------|------|--------|
| 🏠 | home | 首页 | P0 |
| 🧭 | explore | 发现 | P0 |
| 🥾 | trail | 路线 | P0 |
| 🧭 | navigation | 导航 | P0 |
| 👤 | profile | 我的 | P0 |
| ⭐ | favorites | 收藏 | P0 |
| 📜 | history | 历史 | P0 |

### 4.3 社交功能图标

| 图标 | 名称 | 用途 | 优先级 |
|------|------|------|--------|
| ↗️ | share | 分享 | P0 |
| 💬 | comment | 评论 | P1 |
| ❤️ | like | 点赞 | P0 |
| ⭐ | star | 收藏 | P0 |
| ↩️ | reply | 回复 | P1 |
| 📤 | send | 发送 | P1 |

---

## 5. 安全提醒图标

### 5.1 SOS 相关图标

| 图标 | 名称 | 用途 | 说明 |
|------|------|------|------|
| 🆘 | sos | SOS紧急按钮 | 红色圆形背景，白色文字 |
| 📞 | phone | 紧急呼叫 | 电话图标 |
| 🚑 | ambulance | 医疗救援 | 救护车图标 |
| 🚔 | police | 报警 | 警察图标 |
| 🔥 | fire | 火警 | 火焰图标 |

#### SOS 按钮图标规范

```
SOS 图标设计:

┌────────────────────────┐
│                        │
│     ╭──────────╮       │
│     │          │       │
│     │   🆘    │       │  ← 红色圆形背景
│     │   SOS    │       │     #EF5350
│     │          │       │
│     ╰──────────╯       │
│                        │
│  尺寸: 64×64px         │
│  背景: #EF5350         │
│  文字: White, Bold     │
│  圆角: 32px (全圆)     │
└────────────────────────┘
```

### 5.2 安全状态图标

| 图标 | 名称 | 用途 | 颜色 |
|------|------|------|------|
| ✓ | safety_ok | 安全正常 | 绿色 #4CAF50 |
| ⚠️ | warning | 警告提醒 | 黄色 #FFC107 |
| 🚫 | danger | 危险禁止 | 红色 #EF5350 |
| ℹ️ | info | 信息提示 | 蓝色 #3B9EFF |
| 🛡️ | protection | 防护措施 | 青色 #2D968A |

### 5.3 安全设备图标

| 图标 | 名称 | 用途 |
|------|------|------|
| 🔋 | battery | 电量提醒 |
| 📶 | signal | 信号强度 |
| 🛰️ | gps | GPS状态 |
| 🔔 | alert | 安全警报 |
| ⏱️ | timer | 定时提醒 |
| 👥 | contacts | 紧急联系人 |

### 5.4 天气/环境图标

| 图标 | 名称 | 用途 |
|------|------|------|
| ☀️ | sunny | 晴天 |
| ☁️ | cloudy | 多云 |
| 🌧️ | rainy | 雨天 |
| ⛈️ | storm | 雷雨 |
| 🌫️ | foggy | 雾天 |
| ❄️ | snowy | 雪天 |
| 🌡️ | temperature | 温度 |
| 💨 | wind | 风力 |
| 💧 | humidity | 湿度 |

### 5.5 地形/风险图标

| 图标 | 名称 | 用途 |
|------|------|------|
| ⛰️ | mountain | 山峰 |
| 🧗 | cliff | 悬崖 |
| 💧 | water | 水域 |
| 🌿 | vegetation | 植被 |
| 🐍 | animal | 野生动物 |
| 🪨 | rock | 落石 |
| 🌊 | flood | 洪水 |

---

## 6. 地图标记图标

### 6.1 基础标记

| 图标 | 名称 | 用途 | 尺寸 |
|------|------|------|------|
| 📍 | marker_default | 默认标记 | 36×48px |
| 📍 | marker_start | 起点 | 36×48px |
| 📍 | marker_end | 终点 | 36×48px |
| 📍 | marker_current | 当前位置 | 40×40px (脉冲) |
| 📍 | marker_waypoint | 途经点 | 32×40px |

#### 地图标记设计规范

```
默认地图标记:

       ╭──╮
      ╱    ╲
     │  📍  │    ← 图标区域
      ╲    ╱
       ╰──╯
         │
         ▼        ← 锚点
         ●

尺寸: 36×48px
锚点: 底部中心
图标: 内部 20×20px
背景: 根据类型变化
```

### 6.2 POI 标记

| 类型 | 图标 | 颜色 | 用途 |
|------|------|------|------|
| 起点 | 🚩 | 绿色 #4CAF50 | 路线起点 |
| 终点 | 🏁 | 红色 #EF5350 | 路线终点 |
| 观景台 | 👁️ | 蓝色 #3B9EFF | 观景点 |
| 休息点 | 🪑 | 棕色 #8B7355 | 休息区 |
| 水源 | 💧 | 青色 #2D968A | 水源点 |
| 危险 | ⚠️ | 橙色 #FF9800 | 危险区域 |
| 厕所 | 🚻 | 紫色 #9C27B0 | 卫生间 |
| 停车场 | 🅿️ | 蓝色 #2196F3 | 停车场 |

### 6.3 导航标记

| 图标 | 名称 | 用途 |
|------|------|------|
| ⬆️ | direction_straight | 直行 |
| ↱ | direction_right | 右转 |
| ↰ | direction_left | 左转 |
| ⤴️ | direction_uturn | 掉头 |
| ↗️ | direction_slight_right | 稍向右 |
| ↘️ | direction_slight_left | 稍向左 |

---

## 7. 社交媒体图标

### 7.1 登录/分享图标

| 平台 | 图标 | 颜色 | 用途 |
|------|------|------|------|
| 微信 | 🟢 | #07C160 | 微信登录/分享 |
| 微博 | 🔴 | #E6162D | 微博登录/分享 |
| QQ | 🔵 | #12B7F5 | QQ登录/分享 |
| 苹果 | ⬛ | #000000 | Apple登录 |

### 7.2 分享平台图标

| 平台 | 图标 | 用途 |
|------|------|------|
| 微信朋友圈 | ⭕ | 分享到朋友圈 |
| 微信好友 | 💬 | 分享给好友 |
| 复制链接 | 🔗 | 复制链接 |
| 更多 | ⋯ | 更多选项 |

---

## 8. 技术规范

### 8.1 文件格式

| 用途 | 格式 | 说明 |
|------|------|------|
| **设计源文件** | Figma / Sketch / AI | 可编辑源文件 |
| **开发交付** | SVG | 矢量，可代码调整 |
| **Flutter** | IconFont / SVG | 字体或矢量 |
| **iOS** | PDF / SF Symbols | 系统兼容 |
| **Android** | Vector Drawable | XML矢量 |
| **备用** | PNG @1x, @2x, @3x | 位图备用 |

### 8.2 SVG 规范

#### 兼容性风险缓解方案

**问题**: 部分旧版本系统或 WebView 对 SVG 支持不完善

**解决方案**:

1. **PNG 备用方案**
   - 所有图标同时提供 PNG @1x, @2x, @3x 版本
   - 运行时检测 SVG 支持情况，自动降级到 PNG
   - 优先使用 SVG，PNG 作为兜底

2. **SVG 最低版本要求**
   - iOS: 13.0+ (支持 SF Symbols 和自定义 SVG)
   - Android: API 24+ (Android 7.0+)
   - Flutter: 使用 `flutter_svg` 插件，支持全版本

3. **SVG 优化清单**
   - 所有路径转为标准 SVG 路径命令
   - 避免使用 CSS 动画和外部样式
   - 字体需转为路径，避免字体缺失

#### 标准结构

```xml
<svg xmlns="http://www.w3.org/2000/svg" 
     width="24" 
     height="24" 
     viewBox="0 0 24 24" 
     fill="none"
     stroke="currentColor"
     stroke-width="2"
     stroke-linecap="round"
     stroke-linejoin="round">
  
  <!-- 图标路径 -->
  <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
  <polyline points="9 22 9 12 15 12 15 22"/>
  
</svg>
```

#### 命名规范

```
文件命名: [类别]_[功能]_[变体].svg

示例:
- ic_home_default.svg
- ic_navigation_back.svg
- ic_sos_emergency.svg
- ic_marker_start.svg
- ic_weather_sunny.svg
- ic_social_wechat.svg
```

### 8.3 IconFont 规范

#### 字体制作

| 参数 | 值 | 说明 |
|------|-----|------|
| **字体名称** | ShanjingIcons | 品牌字体名 |
| **字体格式** | TTF, WOFF, WOFF2 | 多格式支持 |
| **字符编码** | Private Use Area | 避免冲突 |
| **基础尺寸** | 24px | 标准尺寸 |

#### 使用示例

```dart
// Flutter IconFont 使用
Icon(
  IconData(
    0xe001,  // Unicode 编码
    fontFamily: 'ShanjingIcons',
    fontPackage: null,
  ),
  size: 24,
  color: Color(0xFF2D968A),
)

// 或使用预定义
Icon(ShanjingIcons.home, size: 24)
Icon(ShanjingIcons.navigation, size: 24)
Icon(ShanjingIcons.sos, size: 64, color: Colors.red)
```

### 8.4 Flutter 实现

#### 自定义图标类

```dart
// lib/icons/shanjing_icons.dart

import 'package:flutter/widgets.dart';

class ShanjingIcons {
  ShanjingIcons._();
  
  static const _fontFamily = 'ShanjingIcons';
  
  // 导航图标
  static const IconData home = IconData(0xe001, fontFamily: _fontFamily);
  static const IconData explore = IconData(0xe002, fontFamily: _fontFamily);
  static const IconData trail = IconData(0xe003, fontFamily: _fontFamily);
  static const IconData navigation = IconData(0xe004, fontFamily: _fontFamily);
  static const IconData profile = IconData(0xe005, fontFamily: _fontFamily);
  
  // 操作图标
  static const IconData close = IconData(0xe010, fontFamily: _fontFamily);
  static const IconData back = IconData(0xe011, fontFamily: _fontFamily);
  static const IconData search = IconData(0xe012, fontFamily: _fontFamily);
  static const IconData more = IconData(0xe013, fontFamily: _fontFamily);
  
  // SOS 图标
  static const IconData sos = IconData(0xe020, fontFamily: _fontFamily);
  static const IconData emergency = IconData(0xe021, fontFamily: _fontFamily);
  static const IconData phone = IconData(0xe022, fontFamily: _fontFamily);
  
  // 安全图标
  static const IconData safety_ok = IconData(0xe030, fontFamily: _fontFamily);
  static const IconData warning = IconData(0xe031, fontFamily: _fontFamily);
  static const IconData danger = IconData(0xe032, fontFamily: _fontFamily);
  
  // 天气图标
  static const IconData sunny = IconData(0xe040, fontFamily: _fontFamily);
  static const IconData cloudy = IconData(0xe041, fontFamily: _fontFamily);
  static const IconData rainy = IconData(0xe042, fontFamily: _fontFamily);
  static const IconData foggy = IconData(0xe043, fontFamily: _fontFamily);
}
```

---

### 8.5 图标尺寸枚举 (新增)

#### Dart 枚举定义

```dart
// lib/icons/icon_sizes.dart

/// 图标尺寸枚举
/// 使用示例: Icon(ShanjingIcons.home, size: IconSize.md.value)
enum IconSize {
  /// 16px - 内联文字、小标签
  xs(16),
  
  /// 20px - 按钮内、列表项
  sm(20),
  
  /// 24px - 标准导航栏 (默认)
  md(24),
  
  /// 32px - 大按钮、功能入口
  lg(32),
  
  /// 48px - 主要功能、空状态
  xl(48),
  
  /// 64px - 首页功能、特色入口、SOS按钮
  xxl(64);
  
  final double value;
  const IconSize(this.value);
  
  /// 线条粗细对应值
  double get strokeWidth {
    switch (this) {
      case IconSize.xs:
      case IconSize.sm:
        return 1.5;
      case IconSize.md:
      case IconSize.lg:
        return 2.0;
      case IconSize.xl:
        return 3.0;
      case IconSize.xxl:
        return 4.0;
    }
  }
  
  /// 获取缩放比例 (相对于 24px)
  double get scale => value / 24;
}

/// 使用扩展示例
extension IconDataExtension on IconData {
  /// 获取指定尺寸的图标数据
  IconData sized(IconSize size) {
    return IconData(
      codePoint,
      fontFamily: fontFamily,
      fontPackage: fontPackage,
      matchTextDirection: matchTextDirection,
    );
  }
}
```

#### 使用示例

```dart
// 基础使用
Icon(ShanjingIcons.home, size: IconSize.md.value)

// 带动画的图标
AnimatedIcon(
  icon: ShanjingIcons.navigation,
  size: IconSize.lg.value,
  color: Theme.of(context).primaryColor,
)

// SOS 大按钮
IconButton(
  icon: Icon(ShanjingIcons.sos),
  iconSize: IconSize.xxl.value,
  color: Colors.white,
  onPressed: () => showSOSDialog(),
)
```

---

## 9. 切图与交付

### 9.1 切图清单

#### 基础图标 (24px)

| 图标 | SVG | PNG @1x | PNG @2x | PNG @3x |
|------|-----|---------|---------|---------|
| home | ✓ | ✓ | ✓ | ✓ |
| explore | ✓ | ✓ | ✓ | ✓ |
| trail | ✓ | ✓ | ✓ | ✓ |
| navigation | ✓ | ✓ | ✓ | ✓ |
| profile | ✓ | ✓ | ✓ | ✓ |
| close | ✓ | ✓ | ✓ | ✓ |
| back | ✓ | ✓ | ✓ | ✓ |
| search | ✓ | ✓ | ✓ | ✓ |
| more | ✓ | ✓ | ✓ | ✓ |

#### SOS 图标 (64px)

| 图标 | SVG | PNG @1x | PNG @2x | PNG @3x |
|------|-----|---------|---------|---------|
| sos_button | ✓ | ✓ | ✓ | ✓ |
| emergency | ✓ | ✓ | ✓ | ✓ |
| phone | ✓ | ✓ | ✓ | ✓ |

#### 地图标记 (36-48px)

| 图标 | SVG | PNG @1x | PNG @2x | PNG @3x |
|------|-----|---------|---------|---------|
| marker_start | ✓ | ✓ | ✓ | ✓ |
| marker_end | ✓ | ✓ | ✓ | ✓ |
| marker_current | ✓ | ✓ | ✓ | ✓ |

### 9.2 交付结构

```
shanjing-icons/
├── README.md                    # 使用说明
├── source/                      # 设计源文件
│   └── shanjing-icons.fig
├── svg/                         # SVG格式
│   ├── 24px/                    # 标准图标
│   ├── 32px/                    # 大图标
│   ├── 48px/                    # 功能图标
│   └── 64px/                    # SOS图标
├── png/                         # PNG格式
│   ├── 1x/
│   ├── 2x/
│   └── 3x/
├── font/                        # IconFont
│   ├── ShanjingIcons.ttf
│   ├── ShanjingIcons.woff
│   └── ShanjingIcons.woff2
├── flutter/                     # Flutter资源
│   └── shanjing_icons.dart
├── preview/                     # 预览图
│   └── icon-preview.png
└── changelog.md                 # 更新日志
```

---

## 10. 暗黑模式适配

### 10.1 颜色映射

| 图标类型 | 浅色模式 | 暗黑模式 | 说明 |
|----------|----------|----------|------|
| **默认图标** | Gray-600 | Gray-300 | 正常状态 |
| **选中图标** | Primary-500 | Primary-400 | 选中状态 |
| **禁用图标** | Gray-300 | Gray-600 | 禁用状态 |
| **SOS图标** | Error-500 | Error-400 | 保持醒目 |
| **成功图标** | Success-500 | Success-400 | 明亮可见 |
| **警告图标** | Warning-500 | Warning-400 | 柔和但可见 |

### 10.2 实现方式

```dart
// Flutter 暗黑模式图标
Icon(
  ShanjingIcons.home,
  size: 24,
  color: isDarkMode 
    ? (isSelected ? Color(0xFF4DB6AC) : Color(0xFFC9D1D9))
    : (isSelected ? Color(0xFF2D968A) : Color(0xFF4B5563)),
)

// 或使用 Theme
Icon(
  ShanjingIcons.home,
  color: Theme.of(context).iconTheme.color,
)
```

---

## 附录

### A. 参考资源

- [Material Design Icons](https://material.io/resources/icons/)
- [Feather Icons](https://feathericons.com/)
- [Heroicons](https://heroicons.com/)
- [SF Symbols](https://developer.apple.com/sf-symbols/)

### B. 更新记录

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| v1.0 | 2026-03-19 | M4 阶段初版，完整图标系统 |

### C. 设计团队

- 图标设计: [待填写]
- 视觉审核: [待填写]
- 开发对接: [待填写]

---

> **"简洁的图标，清晰的指引"** - 山径APP图标设计哲学
