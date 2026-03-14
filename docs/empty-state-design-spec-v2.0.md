# 山径APP - M2 空状态设计规范 v2.0

> **文档版本**: v2.0  
> **更新日期**: 2026-03-14  
> **文档状态**: M2完成  
> **适用范围**: 山径APP全功能空状态与加载状态

---

## 更新记录

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| v2.0 | 2026-03-14 | M2迭代：完善空状态组件、新增字体层级、优化骨架屏 |
| v1.0 | 2026-02-28 | 初版空状态设计规范 |

---

## 1. 空状态设计规范

### 1.1 设计理念

空状态不是"没有内容"，而是与用户沟通的重要触点。

**设计原则:**
1. **清晰传达** - 让用户明白发生了什么
2. **提供指引** - 告诉用户下一步可以做什么
3. **保持品牌调性** - 传递自然、诗意的设计语言
4. **减少焦虑** - 温和文案，安抚插画

### 1.2 插画风格

**风格定位**: 简约、户外主题

| 元素 | 规范 |
|------|------|
| **线条** | 简洁轮廓，2px描边 |
| **颜色** | 主色Primary-300~500，中性灰 |
| **尺寸** | 插画80-120px，图标容器80px |
| **形状** | 圆形或圆角矩形背景 |

**内置插画:**
- `EmptyBoxIllustration` - 空盒子（收藏为空）
- `EmptyMapIllustration` - 空地图（下载为空）
- `WeakSignalIllustration` - 弱信号（GPS信号弱）

### 1.3 文案规范

**标题规范:**
- 长度：不超过10个字
- 语气：温和鼓励
- 字体：18px, FontWeight.w600

**描述规范:**
- 长度：不超过30个字
- 内容：解释原因或提供建议
- 字体：14px, FontWeight.w400

**按钮文案:**
- 主操作：动词开头，如"去发现"、"重新加载"
- 次操作：辅助性动作，如"清空筛选"、"检查设置"

---

## 2. 空状态预设类型

### 2.1 无网络连接 (Network)

```dart
AppEmpty.network(
  onRetry: () => loadData(),
  onOpenSettings: () => openSettings(),
)
```

**设计要素:**
- 图标：WiFi断开图标（圆形背景）
- 标题："网络好像断开了"
- 描述："请检查网络设置后重试"
- 按钮：主操作"重新加载" + 次操作"检查设置"

### 2.2 无搜索结果 (Search)

```dart
AppEmpty.search(
  keyword: '西湖',
  onClearFilter: () => clearFilters(),
  onBrowseRecommended: () => showRecommended(),
)
```

**设计要素:**
- 图标：搜索关闭图标
- 标题："没有找到相关路线" / "没有找到\"xxx\""
- 描述："换个关键词试试，或浏览推荐路线"
- 按钮：主操作"查看推荐" + 次操作"清空筛选"

### 2.3 收藏为空 (Favorite)

```dart
AppEmpty.favorite(
  onExplore: () => goToDiscovery(),
)
```

**设计要素:**
- 插画：空盒子 + 星星
- 标题："还没有收藏任何路线"
- 描述："收藏喜欢的路线，随时查看和导航"
- 按钮：主操作"去发现"

### 2.4 下载列表为空 (Download)

```dart
AppEmpty.download(
  onGoDownload: () => goToDownloadPage(),
)
```

**设计要素:**
- 插画：折叠地图
- 标题："还没有下载离线地图"
- 描述："下载离线地图，无网络也能导航"
- 按钮：主操作"去下载"

### 2.5 GPS信号弱 (Location)

```dart
AppEmpty.location(
  onCheckSettings: () => openLocationSettings(),
)
```

**设计要素:**
- 插画：定位图标 + 警告
- 标题："GPS信号较弱"
- 描述："请检查定位设置，或移动到开阔地带"
- 按钮：主操作"检查设置"

### 2.6 权限请求 (Permission)

```dart
AppEmpty.permission(
  permissionName: '位置权限',
  permissionDescription: '开启位置权限后，才能使用导航和路线推荐功能',
  onRequestPermission: () => requestPermission(),
  icon: Icons.location_off_outlined,
)
```

**设计要素:**
- 图标：对应权限图标（定位、相机、存储等）
- 标题："需要{权限名称}"
- 描述：说明权限用途
- 按钮：主操作"开启权限"

---

## 3. 组件使用指南

### 3.1 快速使用预设

```dart
// 网络错误
AppEmpty.network(onRetry: () {})

// 搜索为空
AppEmpty.search(onClearFilter: () {})

// 收藏为空
AppEmpty.favorite(onExplore: () {})

// 下载为空
AppEmpty.download(onGoDownload: () {})

// GPS信号弱
AppEmpty.location(onCheckSettings: () {})

// 权限请求
AppEmpty.permission(
  permissionName: '位置权限',
  permissionDescription: '...',
  onRequestPermission: () {},
)

// 通用错误
AppEmpty.error(title: '出错了', onRetry: () {})

// 无数据
AppEmpty.data(title: '暂无数据', onRefresh: () {})
```

### 3.2 自定义空状态

```dart
AppEmpty(
  illustration: MyCustomIllustration(),
  icon: Icons.my_icon,
  title: '自定义标题',
  description: '自定义描述文字',
  primaryAction: AppEmptyAction(
    label: '主操作',
    onPressed: () {},
    type: AppEmptyActionType.primary,
  ),
  secondaryAction: AppEmptyAction(
    label: '次操作',
    onPressed: () {},
    type: AppEmptyActionType.secondary,
  ),
)
```

### 3.3 使用自定义构建器

```dart
AppEmptyBuilder(
  illustration: MyIllustration(),
  title: '标题',
  description: '描述',
  primaryActionLabel: '操作',
  onPrimaryAction: () {},
)
```

---

## 4. 设计系统优化

### 4.1 字体层级 (Typography)

新增 Material Design 3 字体层级：

```dart
// Display - 大标题
DesignSystem.getDisplayLarge(context)
DesignSystem.getDisplayMedium(context)
DesignSystem.getDisplaySmall(context)

// Headline - 页面主标题
DesignSystem.getHeadlineLarge(context)
DesignSystem.getHeadlineMedium(context)
DesignSystem.getHeadlineSmall(context)

// Title - 区块标题
DesignSystem.getTitleLarge(context)
DesignSystem.getTitleMedium(context)
DesignSystem.getTitleSmall(context)

// Body - 正文
DesignSystem.getBodyLarge(context)
DesignSystem.getBodyMedium(context)
DesignSystem.getBodySmall(context)

// Label - 标签
DesignSystem.getLabelLarge(context)
DesignSystem.getLabelMedium(context)
DesignSystem.getLabelSmall(context)
```

**字号规范:**

| 层级 | 大小 | 字重 | 用途 |
|------|------|------|------|
| Display Large | 57 | 400 | 品牌展示 |
| Display Medium | 45 | 400 | 欢迎页标题 |
| Headline Large | 32 | 400 | 页面大标题 |
| Title Large | 22 | 500 | 区块标题 |
| Body Large | 16 | 400 | 重要正文 |
| Body Medium | 14 | 400 | 默认正文 |
| Label Large | 14 | 500 | 按钮文字 |

### 4.2 骨架屏组件 (Skeleton)

**基础骨架屏:**
```dart
// 通用骨架
Skeleton(width: 100, height: 20)

// 圆形骨架
Skeleton.circle(size: 48)

// 文本骨架
Skeleton.text(width: 200, height: 16)

// 卡片骨架
Skeleton.card(width: 300, height: 120)

// 头像骨架
Skeleton.avatar(size: 48)
```

**列表骨架屏:**
```dart
SkeletonList(
  itemCount: 5,
  itemHeight: 80,
  hasLeading: true,
  hasSubtitle: true,
)
```

**页面骨架屏:**
```dart
// 发现页
SkeletonDiscovery()

// 路线详情
SkeletonTrailDetail()

// 离线地图
SkeletonOfflineMap()

// 个人中心
SkeletonProfile()

// 路线卡片
SkeletonRouteCard()
```

---

## 5. 暗色模式适配

### 5.1 颜色适配

| 元素 | 亮色模式 | 暗色模式 |
|------|----------|----------|
| 背景 | White | Gray-900 |
| 图标背景 | Primary-100 | Primary-900 |
| 图标色 | Primary-500 | Primary-400 |
| 标题 | Gray-900 | Gray-100 |
| 描述 | Gray-500 | Gray-400 |
| 按钮背景 | Primary-500 | Primary-600 |
| 次按钮边框 | Gray-200 | Gray-700 |

### 5.2 骨架屏暗色模式

```dart
// 自动适配暗色模式
Skeleton(
  width: 100,
  height: 20,
  baseColor: isDark ? Color(0xFF2C2C2C) : Color(0xFFF0F0F0),
  highlightColor: isDark ? Color(0xFF3C3C3C) : Color(0xFFE8E8E8),
)
```

---

## 6. 实现文件清单

### 6.1 组件文件

| 文件 | 说明 |
|------|------|
| `lib/widgets/app_empty.dart` | 空状态组件（更新） |
| `lib/widgets/app_skeleton.dart` | 骨架屏组件（新增） |
| `lib/constants/design_system.dart` | 设计系统常量（更新） |

### 6.2 使用示例文件

| 文件 | 说明 |
|------|------|
| `lib/screens/discovery_screen.dart` | 发现页空状态使用 |
| `lib/screens/offline_map_screen.dart` | 离线地图空状态使用 |
| `lib/screens/empty_state_showcase.dart` | 空状态展示页 |

---

## 7. 页面空状态映射

| 页面 | 空状态场景 | 使用组件 |
|------|-----------|----------|
| 发现页 | 搜索无结果 | `AppEmpty.search()` |
| 发现页 | 筛选无结果 | `AppEmpty.search()` |
| 收藏页 | 收藏为空 | `AppEmpty.favorite()` |
| 离线地图 | 下载列表为空 | `AppEmpty.download()` |
| 离线地图 | 搜索城市无结果 | `AppEmpty.data()` |
| 导航页 | GPS信号弱 | `AppEmpty.location()` |
| 导航页 | 无定位权限 | `AppEmpty.permission()` |
| 路线详情 | 加载失败 | `AppEmpty.error()` |
| 历史记录 | 记录为空 | `AppEmpty.data()` |

---

## 8. 检查清单

### 8.1 交付标准检查

- [x] 所有空状态场景有设计稿或参考
- [x] `app_empty.dart` 组件完整实现
- [x] 空状态在相应页面正确使用
- [x] 字体层级完善（display/headline/title/label）
- [x] 骨架屏组件添加
- [x] 加载状态一致性优化
- [x] 暗色模式适配

### 8.2 代码规范检查

- [x] 组件API设计一致
- [x] 预设类型覆盖主要场景
- [x] 支持自定义扩展
- [x] 暗色模式自动适配
- [x] 文档注释完整

---

> **"即使在没有数据的时候，也要给用户温暖的陪伴"** - 山径APP设计哲学
