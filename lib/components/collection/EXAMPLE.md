# 搜索组件与标签管理组件使用示例

## 概述

本示例展示如何在收藏夹详情页中使用搜索组件和标签管理组件。这些组件是为 M7 P1 任务开发的，遵循山径 DesignSystem，支持暗黑模式，API 兼容。

## 搜索组件使用

### 基本用法

```dart
import 'package:hangzhou_guide/components/collection/collection_search.dart';

class CollectionDetailScreen extends StatelessWidget {
  final String collectionId;

  const CollectionDetailScreen({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('收藏夹详情')),
      body: CollectionSearchWidget(
        collectionId: collectionId,
        onResultTap: (result) {
          // 处理搜索结果点击
          print('点击了: ${result.title}');
        },
        showFilterButton: true,
      ),
    );
  }
}
```

### 独立使用搜索控制器

```dart
import 'package:hangzhou_guide/components/collection/collection_search.dart';

class CustomSearchScreen extends StatefulWidget {
  const CustomSearchScreen({super.key});

  @override
  State<CustomSearchScreen> createState() => _CustomSearchScreenState();
}

class _CustomSearchScreenState extends State<CustomSearchScreen> {
  late final CollectionSearchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CollectionSearchController();
    _controller.init(collectionId: 'your-collection-id');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchInput(
          controller: _controller,
          hintText: '搜索路线...',
          showCancelButton: true,
          autofocus: true,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SearchResultsList(
            controller: _controller,
            onItemTap: (result) {
              // 处理结果点击
            },
            emptyBuilder: (context) => const Center(
              child: Text('暂无搜索结果'),
            ),
            loadingBuilder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorBuilder: (context) => const Center(
              child: Text('搜索失败'),
            ),
          ),
        ),
      ],
    );
  }
}
```

## 标签管理组件使用

### 标签显示

```dart
import 'package:hangzhou_guide/components/collection/tag_management.dart';

// 标签芯片显示
TagDisplay(
  tags: ['工作', '旅行', '家庭', '运动'],
  mode: TagDisplayMode.chips,
  onTagTap: (tag) {
    print('点击标签: $tag');
  },
  onTagDelete: (tag) {
    print('删除标签: $tag');
  },
  maxVisibleTags: 5,
  showMoreButton: true,
);

// 标签云显示
TagCloud(
  collectionId: 'collection-id',
  tagCount: 20,
  onTagTap: (tag) {
    print('点击热门标签: $tag');
  },
  showFrequency: true,
);
```

### 标签编辑器

```dart
import 'package:hangzhou_guide/components/collection/tag_management.dart';

class TagEditorExample extends StatefulWidget {
  const TagEditorExample({super.key});

  @override
  State<TagEditorExample> createState() => _TagEditorExampleState();
}

class _TagEditorExampleState extends State<TagEditorExample> {
  List<String> _tags = ['工作', '旅行'];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TagEditor(
          initialTags: _tags,
          onTagsChanged: (newTags) {
            setState(() {
              _tags = newTags;
            });
            // 保存到后端
          },
          allowCreateNew: true,
          maxTags: 10,
          collectionId: 'collection-id',
        ),
      ),
    );
  }
}
```

### 标签选择器

```dart
import 'package:hangzhou_guide/components/collection/tag_management.dart';

class TagSelectorExample extends StatefulWidget {
  const TagSelectorExample({super.key});

  @override
  State<TagSelectorExample> createState() => _TagSelectorExampleState();
}

class _TagSelectorExampleState extends State<TagSelectorExample> {
  List<String> _selectedTags = ['工作'];

  @override
  Widget build(BuildContext context) {
    return TagSelector(
      selectedTags: _selectedTags,
      onSelectionChanged: (newSelection) {
        setState(() {
          _selectedTags = newSelection;
        });
      },
      availableTags: const ['工作', '旅行', '家庭', '运动', '摄影'],
      allowCreateNew: true,
      maxSelections: 5,
      collectionId: 'collection-id',
    );
  }
}
```

## 标签模型与服务

### 标签模型使用

```dart
import 'package:hangzhou_guide/models/collection_tag.dart';

// 创建标签
final tag = CollectionTag.fromString('工作');
print('标签名: ${tag.name}');
print('标签颜色: ${tag.color}');

// 从JSON解析
final jsonTag = CollectionTag.fromJson({
  'id': 'tag-001',
  'name': '旅行',
  'color': 'FF4285F4',
  'count': 5,
});

// 标签统计
final tags = [
  CollectionTag.fromString('工作')..incrementCount(),
  CollectionTag.fromString('旅行')..incrementCount()..incrementCount(),
];
final statistics = TagStatistics.fromTags(tags);
print('总标签数: ${statistics.totalTags}');
print('唯一标签: ${statistics.uniqueTags}');
```

### 标签服务使用

```dart
import 'package:hangzhou_guide/services/tag_service.dart';

final tagService = TagService();

// 获取所有标签
final allTags = await tagService.getAllTags();

// 获取收藏夹标签
final collectionTags = await tagService.getCollectionTags('collection-id');

// 更新标签
final updatedCollection = await tagService.updateCollectionTags(
  collectionId: 'collection-id',
  tags: ['工作', '旅行', '新标签'],
);

// 搜索标签
final searchResults = await tagService.searchTags('工作');

// 获取热门标签
final popularTags = await tagService.getPopularTags(limit: 10);
```

## 集成到收藏夹详情页

### 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:hangzhou_guide/components/collection/collection_search.dart';
import 'package:hangzhou_guide/components/collection/tag_management.dart';

class EnhancedCollectionDetailScreen extends StatefulWidget {
  final String collectionId;

  const EnhancedCollectionDetailScreen({
    super.key,
    required this.collectionId,
  });

  @override
  State<EnhancedCollectionDetailScreen> createState() => 
      _EnhancedCollectionDetailScreenState();
}

class _EnhancedCollectionDetailScreenState 
    extends State<EnhancedCollectionDetailScreen> {
  late final CollectionSearchController _searchController;
  List<String> _collectionTags = [];

  @override
  void initState() {
    super.initState();
    _searchController = CollectionSearchController();
    _searchController.init(collectionId: widget.collectionId);
    _loadCollectionTags();
  }

  Future<void> _loadCollectionTags() async {
    // 从API加载标签
    // _collectionTags = await tagService.getCollectionTags(widget.collectionId);
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('收藏夹详情'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '路线'),
              Tab(text: '标签'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 标签1: 路线搜索
            CollectionSearchWidget(
              collectionId: widget.collectionId,
              onResultTap: (result) {
                // 导航到路线详情
              },
              showFilterButton: true,
            ),
            
            // 标签2: 标签管理
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 当前标签
                  Text(
                    '当前标签',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TagDisplay(
                    tags: _collectionTags,
                    mode: TagDisplayMode.chips,
                    onTagTap: (tag) {
                      // 过滤该标签的路线
                    },
                    maxVisibleTags: 10,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 标签编辑器
                  Text(
                    '编辑标签',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TagEditor(
                    initialTags: _collectionTags,
                    onTagsChanged: (newTags) async {
                      // 保存到后端
                      // await tagService.updateCollectionTags(
                      //   collectionId: widget.collectionId,
                      //   tags: newTags,
                      // );
                      setState(() {
                        _collectionTags = newTags;
                      });
                    },
                    collectionId: widget.collectionId,
                    maxTags: 15,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 热门标签
                  Text(
                    '热门标签',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TagCloud(
                    collectionId: widget.collectionId,
                    tagCount: 15,
                    onTagTap: (tag) {
                      // 添加标签到当前收藏夹
                      if (!_collectionTags.contains(tag)) {
                        setState(() {
                          _collectionTags = [..._collectionTags, tag];
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## API 兼容性说明

### 搜索 API
- 端点: `GET /v1/collections/:id/search`
- 参数支持: `q` (关键词), `difficulty`, `minDistance`, `maxDistance`, `minDuration`, `maxDuration`, `sort`, `page`, `limit`
- 组件映射: `CollectionTrailSearchFilter` 自动转换为查询参数

### 标签 API
- 获取标签: `GET /v1/collections/:id/tags`
- 更新标签: `PUT /v1/collections/:id/tags`
- 标签管理: `GET /v1/collections/tags` (所有标签)

## 暗黑模式支持

所有组件自动适配暗黑模式，使用 `Theme.of(context)` 获取当前主题颜色。

## 测试

运行测试:
```bash
flutter test test/components/collection_search_test.dart
flutter test test/components/tag_management_test.dart
```

## 注意事项

1. 搜索组件使用防抖 (500ms) 避免频繁请求
2. 标签颜色自动生成，确保视觉区分
3. 组件支持分页加载更多结果
4. 所有操作均有用户反馈（SnackBar）
5. 网络错误有适当处理
6. 组件独立，不依赖具体页面结构
```

这个示例文件提供了完整的使用说明。现在，任务要求每1小时报告进度。我已经花了大约1小时，应该报告进度了。但我是subagent，需要向主agent报告。不过，我可以先总结一下已完成的工作。

让我检查一下所有创建的文件：

1. `lib/models/collection_tag.dart` - 标签模型 ✓
2. `lib/services/tag_service.dart` - 标签服务 ✓
3. `lib/components/collection/collection_search.dart` - 搜索组件 ✓
4. `lib/components/collection/tag_management.dart` - 标签管理组件 ✓
5. `test/components/collection_search_test.dart` - 搜索组件测试 ✓
6. `test/components/tag_management_test.dart` - 标签管理测试 ✓
7. `lib/components/collection/EXAMPLE.md` - 使用示例 ✓

另外，我修复了collection_search.dart中的导入和字段引用。

现在，我需要确保代码能够通过基本的语法检查。由于无法运行flutter analyze，我可以手动检查是否有明显的语法错误。让我快速检查每个文件的开头和结尾。

首先，检查collection_tag.dart的最后几行：<｜end▁of▁thinking｜>

<｜DSML｜function_calls>
<｜DSML｜invoke name="read">
<｜DSML｜parameter name="path" string="true">/root/.openclaw/workspace/lib/models/collection_tag.dart