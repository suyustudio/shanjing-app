# M7 P1 收藏夹增强功能设计资产清单

## 一、需要新增/修改的组件列表

### 1.1 新增组件（7个）

| 组件名称 | 文件路径 | 功能描述 | 优先级 |
|----------|----------|----------|--------|
| `CollectionCategoryChip` | `lib/widgets/collections/collection_category_chip.dart` | 分类标签组件，支持选中状态、自定义颜色/图标 | P0 |
| `BatchActionToolbar` | `lib/widgets/collections/batch_action_toolbar.dart` | 批量操作工具栏，显示选中数量、操作按钮组 | P0 |
| `SelectableCollectionCard` | `lib/widgets/collections/selectable_collection_card.dart` | 可多选的收藏夹卡片，集成复选框 | P0 |
| `SelectableTrailCard` | `lib/widgets/collections/selectable_trail_card.dart` | 可多选的路线卡片，集成复选框 | P0 |
| `CategoryManagerDialog` | `lib/widgets/collections/category_manager_dialog.dart` | 分类管理弹窗，创建/编辑/删除分类 | P1 |
| `SearchFilterPanel` | `lib/widgets/collections/search_filter_panel.dart` | 搜索筛选面板，集成筛选条件和搜索 | P1 |
| `BulkMoveDialog` | `lib/widgets/collections/bulk_move_dialog.dart` | 批量移动弹窗，选择目标分类 | P1 |

### 1.2 修改组件（5个）

| 组件名称 | 文件路径 | 修改内容 | 优先级 |
|----------|----------|----------|--------|
| `CollectionCard` | `lib/widgets/collections/collection_card.dart` | 1. 移除硬编码颜色<br>2. 支持多选模式包装<br>3. 集成`SelectableCollectionCard` | P0 |
| `CollectionTrailCard` | `lib/widgets/collections/collection_trail_card.dart` | 1. 移除硬编码颜色<br>2. 支持多选模式包装<br>3. 集成`SelectableTrailCard` | P0 |
| `CollectionsListScreen` | `lib/screens/collections/collections_list_screen.dart` | 1. 添加分类标签栏<br>2. 集成搜索筛选<br>3. 添加批量操作模式<br>4. 响应式布局适配 | P0 |
| `CollectionDetailScreen` | `lib/screens/collections/collection_detail_screen.dart` | 1. 添加路线多选模式<br>2. 批量操作集成<br>3. 空状态更新 | P0 |
| `CollectionSelectorDialog` | `lib/widgets/collections/collection_selector_dialog.dart` | 1. 添加分类筛选<br>2. 视觉样式更新 | P1 |

## 二、需要更新的设计系统令牌

### 2.1 新增设计Token（需更新`lib/constants/design_system.dart`）

```dart
// ==================== 分类系统颜色 ====================
static const Color categoryDefaultColor = Color(0xFF2D968A);      // 默认分类色
static const Color categoryPersonalColor = Color(0xFF60A5FA);     // 个人分类色
static const Color categoryThemeColor = Color(0xFF9C27B0);        // 主题分类色
static const Color categorySystemColor = Color(0xFF4CAF50);       // 系统分类色

// ==================== 批量操作颜色 ====================
static const Color batchSelectionOverlay = Color(0x1A2D968A);     // 选中遮罩色 (10%)
static const Color batchSelectionBorder = Color(0xFF4DB6AC);      // 选中边框色

// ==================== 触摸目标尺寸 ====================
static const double touchTargetMin = 44.0;                        // 最小触摸目标
static const double categoryChipHeight = 44.0;                    // 分类标签高度

// ==================== 搜索筛选面板 ====================
static const double searchFilterPanelWidth = 320.0;               // 筛选面板宽度
static const double searchFilterItemHeight = 48.0;                // 筛选项高度

// ==================== 获取方法（主题适配） ====================
static Color getCategoryDefault(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark 
      ? Color(0xFF4DB6AC)  // 暗黑模式
      : categoryDefaultColor;
}

static Color getBatchSelectionOverlay(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark 
      ? Color(0x1A4DB6AC)  // 暗黑模式
      : batchSelectionOverlay;
}
```

### 2.2 需要统一的硬编码颜色替换

| 当前代码中的颜色 | 替换为DesignSystem方法 | 涉及文件 |
|------------------|------------------------|----------|
| `Colors.green.shade50` | `DesignSystem.primary.withOpacity(0.1)` 或 `DesignSystem.getBackgroundSecondary(context)` | collection_card.dart等 |
| `Colors.green.shade300` | `DesignSystem.primaryLight` | collection_card.dart等 |
| `Colors.grey.shade200` | `DesignSystem.getBorder(context)` | collection_selector_dialog.dart |
| `Colors.grey.shade300` | `DesignSystem.getTextTertiary(context)` | 多个文件 |
| `Color(0xFFE8F5F3)` | `DesignSystem.primary.withOpacity(0.05)` | collection_card.dart |

## 三、需要制作的设计稿

### 3.1 高保真设计稿（建议使用Figma）

| 设计稿名称 | 尺寸 | 包含状态 | 交付格式 |
|------------|------|----------|----------|
| **分类管理流程** | 375x812 (iPhone 13) | 1. 分类标签栏<br>2. 创建分类弹窗<br>3. 编辑分类菜单<br>4. 删除分类确认 | Figma组件 + PNG导出 |
| **批量操作流程** | 375x812 (iPhone 13) | 1. 多选模式激活<br>2. 批量选择状态<br>3. 操作菜单<br>4. 移动流程<br>5. 完成反馈 | Figma组件 + PNG导出 |
| **搜索筛选交互** | 375x812 (iPhone 13) | 1. 搜索栏状态<br>2. 搜索建议<br>3. 筛选面板展开<br>4. 筛选条件应用<br>5. 空搜索结果 | Figma组件 + PNG导出 |
| **响应式布局** | 多种尺寸 | 1. 手机竖屏<br>2. 手机横屏<br>3. 平板竖屏<br>4. 平板横屏<br>5. 桌面端 | Figma自适应布局 |
| **空状态全集** | 375x812 (iPhone 13) | 1. 无分类空状态<br>2. 搜索无结果<br>3. 批量选择空<br>4. 分类为空<br>5. 批量操作中 | Figma组件 + PNG导出 |

### 3.2 设计稿规范要求

1. **使用设计系统**:
   - 字体: 使用DesignSystem字体层级
   - 颜色: 使用DesignSystem颜色Token
   - 间距: 使用DesignSystem间距Token (spacingSmall/Medium/Large)
   - 圆角: 使用DesignSystem圆角Token (radius/radiusLarge)

2. **暗黑模式适配**:
   - 每个设计稿需提供亮色/暗色双版本
   - 使用DesignSystem暗黑模式颜色
   - 确保对比度符合WCAG AA标准

3. **交互状态完整**:
   - 默认状态
   - 悬浮/按压状态
   - 选中状态
   - 禁用状态
   - 加载状态
   - 错误状态

## 四、动效设计规范

### 4.1 核心动效参数

| 动效名称 | 用途 | 持续时间 | 缓动曲线 | 属性变化 |
|----------|------|----------|----------|----------|
| **分类切换** | 切换分类时内容更新 | 300ms | `easeInOutCubic` | 透明度 + 位置 |
| **多选模式激活** | 进入/退出多选模式 | 250ms | `easeOutCubic` | 复选框缩放 + 遮罩透明度 |
| **批量操作进度** | 显示操作进度 | 400ms | `linear` | 进度条宽度 |
| **搜索筛选展开** | 展开/收起筛选面板 | 300ms | `easeInOutCubic` | 面板位置 + 背景遮罩 |
| **空状态出现** | 数据加载完成后显示 | 400ms | `easeOutCubic` | 缩放 + 透明度 |

### 4.2 Flutter实现参考

```dart
// 分类切换动效示例
AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  switchInCurve: Curves.easeInOutCubic,
  switchOutCurve: Curves.easeInOutCubic,
  child: KeyedSubtree(
    key: ValueKey(currentCategoryId),
    child: _buildCollectionList(),
  ),
)

// 多选模式动效示例
AnimatedContainer(
  duration: Duration(milliseconds: 250),
  curve: Curves.easeOutCubic,
  decoration: BoxDecoration(
    color: isSelected 
        ? DesignSystem.getBatchSelectionOverlay(context)
        : Colors.transparent,
  ),
  child: // 卡片内容
)
```

## 五、移动端适配规范

### 5.1 触摸目标尺寸

| 元素类型 | 最小尺寸 | 建议尺寸 | 备注 |
|----------|----------|----------|------|
| 分类标签 | 44x44px | 60x44px | 高度固定44px，宽度自适应 |
| 复选框 | 44x44px | 44x44px | 保证足够点击区域 |
| 操作按钮 | 44x44px | 44x44px | 图标按钮最小尺寸 |
| 文字按钮 | 44x28px | 44x36px | 高度至少28px，有足够内边距 |

### 5.2 响应式断点布局

```dart
// 布局断点定义
enum LayoutBreakpoint {
  mobile,     // < 600px
  tablet,     // 600px - 840px  
  desktop,    // > 840px
}

// 响应式布局实现
LayoutBuilder(
  builder: (context, constraints) {
    final screenWidth = constraints.maxWidth;
    LayoutBreakpoint breakpoint;
    
    if (screenWidth < 600) {
      breakpoint = LayoutBreakpoint.mobile;
    } else if (screenWidth < 840) {
      breakpoint = LayoutBreakpoint.tablet;
    } else {
      breakpoint = LayoutBreakpoint.desktop;
    }
    
    return _buildLayoutForBreakpoint(breakpoint);
  },
)
```

### 5.3 手势交互规范

| 手势 | 操作 | 视觉反馈 | 注意事项 |
|------|------|----------|----------|
| **长按** | 激活多选模式 | 震动反馈 + 复选框出现 | 持续时间500ms |
| **左滑** | 显示快速操作 | 操作按钮滑出 | 仅在列表项支持 |
| **右滑** | 返回/取消 | 标准返回动效 | 系统级手势 |
| **下拉** | 刷新列表 | 刷新指示器 | 遵循平台规范 |
| **双指缩放** | 切换视图模式 | 平滑过渡 | 仅平板端支持 |

## 六、开发对接清单

### 6.1 API接口需求

| 接口名称 | 方法 | 请求参数 | 响应数据 | 优先级 |
|----------|------|----------|----------|--------|
| `GET /collections/categories` | GET | - | 分类列表 | P0 |
| `POST /collections/categories` | POST | name, color, icon | 新分类ID | P0 |
| `PUT /collections/categories/:id` | PUT | name, color, icon | 更新结果 | P0 |
| `DELETE /collections/categories/:id` | DELETE | - | 删除结果 | P0 |
| `POST /collections/batch/move` | POST | collectionIds, targetCategoryId | 操作结果 | P1 |
| `POST /collections/batch/delete` | POST | collectionIds | 操作结果 | P0 |
| `GET /collections/search` | GET | query, filters, categoryId | 搜索结果 | P1 |
| `PUT /collections/batch/visibility` | PUT | collectionIds, isPublic | 更新结果 | P1 |

### 6.2 数据模型更新

```dart
// 新增模型: lib/models/collection_category_model.dart
class CollectionCategory {
  final String id;
  final String name;
  final String? icon;
  final Color color;
  final int sortOrder;
  final bool isSystem; // 系统分类不可删除
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // 工厂方法、toJson/fromJson等
}

// 更新现有模型: lib/models/collection_model.dart
class Collection {
  // 现有字段...
  String categoryId; // 新增：所属分类
  List<String> tags; // 新增：标签系统
  int customSortOrder; // 新增：用户自定义排序
  // ...
}

// 批量操作请求模型
class BatchOperationRequest {
  final List<String> collectionIds;
  final String? targetCategoryId;
  final bool? isPublic;
  // ...
}
```

### 6.3 性能优化建议

1. **虚拟滚动**: 收藏夹超过50个时启用`ListView.builder`或第三方虚拟滚动库
2. **图片懒加载**: 收藏夹封面图使用`cached_network_image` + 懒加载
3. **批量操作分批**: 一次批量操作超过20项时，自动分批处理并显示进度
4. **搜索防抖**: 搜索输入防抖300ms，减少请求频率
5. **本地缓存**: 分类数据和用户偏好本地缓存，减少重复请求

## 七、验收标准

### 7.1 视觉验收标准

- [ ] 所有颜色使用DesignSystem Token，无硬编码颜色
- [ ] 暗黑模式完整适配，无颜色对比度问题
- [ ] 触摸目标尺寸符合最小44px要求
- [ ] 动效流畅，无卡顿或跳帧
- [ ] 空状态设计符合规范，提供明确操作指引

### 7.2 功能验收标准

- [ ] 分类管理功能完整：创建、编辑、删除、排序
- [ ] 批量操作功能完整：多选、移动、删除、修改隐私
- [ ] 搜索筛选功能完整：实时搜索、条件筛选、结果展示
- [ ] 响应式布局适配：手机、平板、桌面端布局正确
- [ ] 手势交互支持：长按、左滑等手势正常工作

### 7.3 性能验收标准

- [ ] 收藏夹列表加载时间 < 1秒
- [ ] 搜索响应时间 < 300ms
- [ ] 批量操作（20项）完成时间 < 3秒
- [ ] 内存使用正常，无内存泄漏
- [ ] 滚动性能 > 55fps（快速滚动时）

---

**设计资产交付状态**: ✅ 已完成  
**最后更新**: 2026-03-21 15:45  
**下一阶段**: 高保真设计稿制作 + 开发实现