// tag_management.dart
// 山径APP - 标签管理组件（M7 P1）
// 提供标签的显示、编辑、选择、创建等功能

import 'package:flutter/material.dart';
import '../../models/collection_tag.dart';
import '../../services/tag_service.dart';
import '../widgets/collections/tag_chip.dart';

/// 标签显示模式
enum TagDisplayMode {
  chips,      // 标签芯片
  list,       // 列表
  cloud,      // 标签云
  grid,       // 网格
}

/// 标签编辑器状态
class TagEditorState {
  final List<String> tags;
  final List<String> availableTags;
  final bool isLoading;

  TagEditorState({
    required this.tags,
    required this.availableTags,
    this.isLoading = false,
  });

  TagEditorState copyWith({
    List<String>? tags,
    List<String>? availableTags,
    bool? isLoading,
  }) {
    return TagEditorState(
      tags: tags ?? this.tags,
      availableTags: availableTags ?? this.availableTags,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 标签显示组件
class TagDisplay extends StatelessWidget {
  final List<String> tags;
  final TagDisplayMode mode;
  final Function(String)? onTagTap;
  final Function(String)? onTagDelete;
  final Color? defaultColor;
  final int maxVisibleTags;
  final bool showMoreButton;
  final bool showIcons;

  const TagDisplay({
    Key? key,
    required this.tags,
    this.mode = TagDisplayMode.chips,
    this.onTagTap,
    this.onTagDelete,
    this.defaultColor,
    this.maxVisibleTags = 10,
    this.showMoreButton = true,
    this.showIcons = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayedTags = maxVisibleTags > 0 && tags.length > maxVisibleTags
        ? tags.sublist(0, maxVisibleTags)
        : tags;
    final remainingCount = tags.length - displayedTags.length;

    Widget content;
    
    switch (mode) {
      case TagDisplayMode.chips:
        content = Wrap(
          spacing: 4,
          runSpacing: 4,
          children: displayedTags.map((tag) {
            return TagChip(
              tag: tag,
              style: onTagDelete != null ? TagChipStyle.editable : TagChipStyle.normal,
              onTap: onTagTap != null ? () => onTagTap!(tag) : null,
              onDelete: onTagDelete != null ? () => onTagDelete!(tag) : null,
              color: defaultColor,
              showIcon: showIcons,
            );
          }).toList(),
        );
        break;
        
      case TagDisplayMode.list:
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: displayedTags.map((tag) {
            return ListTile(
              leading: showIcons
                  ? Icon(_getTagIcon(tag), color: defaultColor)
                  : null,
              title: Text(tag),
              trailing: onTagDelete != null
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => onTagDelete!(tag),
                    )
                  : null,
              onTap: onTagTap != null ? () => onTagTap!(tag) : null,
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        );
        break;
        
      case TagDisplayMode.grid:
        content = GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio: 2.5,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: displayedTags.map((tag) {
            return Card(
              child: InkWell(
                onTap: onTagTap != null ? () => onTagTap!(tag) : null,
                child: Center(
                  child: Text(
                    tag,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: defaultColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
        break;
        
      case TagDisplayMode.cloud:
        content = _buildTagCloud(context, displayedTags);
        break;
    }

    if (remainingCount > 0 && showMoreButton) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          content,
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              _showAllTagsDialog(context);
            },
            icon: const Icon(Icons.more_horiz, size: 16),
            label: Text('还有 $remainingCount 个标签'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
            ),
          ),
        ],
      );
    }

    return content;
  }

  Widget _buildTagCloud(BuildContext context, List<String> tags) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // 计算标签大小（基于索引，模拟频率）
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.asMap().entries.map((entry) {
        final index = entry.key;
        final tag = entry.value;
        
        // 根据索引计算字体大小（前面的标签更大）
        final fontSize = 12.0 + (tags.length - index) * 0.8;
        final opacity = 0.6 + (index / tags.length) * 0.4;
        final color = defaultColor?.withOpacity(opacity) ?? 
            colorScheme.primary.withOpacity(opacity);
        
        return GestureDetector(
          onTap: onTagTap != null ? () => onTagTap!(tag) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: fontSize,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showAllTagsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('所有标签'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                return ListTile(
                  leading: showIcons
                      ? Icon(_getTagIcon(tag), color: defaultColor)
                      : null,
                  title: Text(tag),
                  trailing: onTagDelete != null
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () {
                            onTagDelete!(tag);
                            Navigator.of(context).pop();
                          },
                        )
                      : null,
                  onTap: onTagTap != null
                      ? () {
                          onTagTap!(tag);
                          Navigator.of(context).pop();
                        }
                      : null,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  IconData _getTagIcon(String tag) {
    // 复用 TagChip 中的图标逻辑
    final lowerTag = tag.toLowerCase();
    
    if (lowerTag.contains('工作') || lowerTag.contains('办公')) {
      return Icons.work_outline;
    } else if (lowerTag.contains('旅行') || lowerTag.contains('旅游')) {
      return Icons.flight_takeoff_outlined;
    } else if (lowerTag.contains('周末') || lowerTag.contains('假日')) {
      return Icons.weekend_outlined;
    } else if (lowerTag.contains('家庭') || lowerTag.contains('亲子')) {
      return Icons.family_restroom_outlined;
    } else if (lowerTag.contains('运动') || lowerTag.contains('健身')) {
      return Icons.sports_outlined;
    } else if (lowerTag.contains('探索') || lowerTag.contains('冒险')) {
      return Icons.explore_outlined;
    } else if (lowerTag.contains('摄影') || lowerTag.contains('拍照')) {
      return Icons.camera_alt_outlined;
    } else if (lowerTag.contains('放松') || lowerTag.contains('休闲')) {
      return Icons.spa_outlined;
    } else if (lowerTag.contains('美食') || lowerTag.contains('餐厅')) {
      return Icons.restaurant_outlined;
    } else if (lowerTag.contains('购物') || lowerTag.contains('买')) {
      return Icons.shopping_bag_outlined;
    } else if (lowerTag.contains('学习') || lowerTag.contains('教育')) {
      return Icons.school_outlined;
    } else {
      return Icons.tag_outlined;
    }
  }
}

/// 标签编辑器组件
class TagEditor extends StatefulWidget {
  final List<String> initialTags;
  final Function(List<String>)? onTagsChanged;
  final bool allowCreateNew;
  final int maxTags;
  final String? collectionId;

  const TagEditor({
    Key? key,
    required this.initialTags,
    this.onTagsChanged,
    this.allowCreateNew = true,
    this.maxTags = 10,
    this.collectionId,
  }) : super(key: key);

  @override
  State<TagEditor> createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  late List<String> _tags;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final TagService _tagService = TagService();
  List<String> _availableTags = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialTags);
    _loadAvailableTags();
  }

  Future<void> _loadAvailableTags() async {
    if (widget.collectionId == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final collectionTags = await _tagService.getCollectionTags(
        widget.collectionId!,
      );
      final allTags = await _tagService.getAllTags();
      
      final availableTagNames = [
        ...collectionTags.map((tag) => tag.name),
        ...allTags.map((tag) => tag.name),
      ].toSet().toList();
      
      setState(() {
        _availableTags = availableTagNames;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isEmpty) return;
    
    if (_tags.length >= widget.maxTags) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('最多只能添加 ${widget.maxTags} 个标签')),
      );
      return;
    }
    
    if (_tags.contains(trimmedTag)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('标签 "$trimmedTag" 已存在')),
      );
      return;
    }
    
    setState(() {
      _tags.add(trimmedTag);
    });
    
    _textController.clear();
    widget.onTagsChanged?.call(_tags);
    
    // 如果标签不在可用列表中，添加进去
    if (!_availableTags.contains(trimmedTag)) {
      setState(() {
        _availableTags.add(trimmedTag);
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onTagsChanged?.call(_tags);
  }

  void _selectTag(String tag) {
    if (!_tags.contains(tag)) {
      _addTag(tag);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 当前标签
        TagDisplay(
          tags: _tags,
          mode: TagDisplayMode.chips,
          onTagDelete: _removeTag,
          maxVisibleTags: 0,
        ),
        
        const SizedBox(height: 16),
        
        // 标签输入和选择
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 输入框
                TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: '输入标签名...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _addTag(_textController.text),
                      tooltip: '添加标签',
                    ),
                  ),
                  onSubmitted: (_) => _addTag(_textController.text),
                ),
                
                const SizedBox(height: 16),
                
                // 可用标签
                Text(
                  '推荐标签',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _availableTags.isEmpty
                        ? Text(
                            '暂无可用标签',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableTags.map((tag) {
                              final isSelected = _tags.contains(tag);
                              return ChoiceChip(
                                label: Text(tag),
                                selected: isSelected,
                                onSelected: (_) => _selectTag(tag),
                              );
                            }).toList(),
                          ),
              ],
            ),
          ),
        ),
        
        // 标签限制提示
        if (_tags.length >= widget.maxTags * 0.8)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '标签数量：${_tags.length}/${widget.maxTags}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _tags.length >= widget.maxTags
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.warning,
              ),
            ),
          ),
      ],
    );
  }
}

/// 标签选择器组件（多选）
class TagSelector extends StatefulWidget {
  final List<String> selectedTags;
  final Function(List<String>)? onSelectionChanged;
  final List<String>? availableTags;
  final bool allowCreateNew;
  final int maxSelections;
  final String? collectionId;

  const TagSelector({
    Key? key,
    required this.selectedTags,
    this.onSelectionChanged,
    this.availableTags,
    this.allowCreateNew = true,
    this.maxSelections = 5,
    this.collectionId,
  }) : super(key: key);

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  late List<String> _selectedTags;
  final TagService _tagService = TagService();
  List<String> _allAvailableTags = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.selectedTags);
    _loadTags();
  }

  Future<void> _loadTags() async {
    if (widget.availableTags != null) {
      _allAvailableTags = widget.availableTags!;
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      if (widget.collectionId != null) {
        final collectionTags = await _tagService.getCollectionTags(
          widget.collectionId!,
        );
        _allAvailableTags = collectionTags.map((tag) => tag.name).toList();
      } else {
        final allTags = await _tagService.getAllTags();
        _allAvailableTags = allTags.map((tag) => tag.name).toList();
      }
    } catch (e) {
      // 忽略错误，使用空列表
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        if (_selectedTags.length >= widget.maxSelections) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('最多只能选择 ${widget.maxSelections} 个标签')),
          );
          return;
        }
        _selectedTags.add(tag);
      }
    });
    
    widget.onSelectionChanged?.call(_selectedTags);
  }

  void _createNewTag() {
    showDialog(
      context: context,
      builder: (context) {
        final textController = TextEditingController();
        
        return AlertDialog(
          title: const Text('新建标签'),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '输入标签名',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                final tag = textController.text.trim();
                if (tag.isNotEmpty && !_allAvailableTags.contains(tag)) {
                  setState(() {
                    _allAvailableTags.add(tag);
                  });
                }
                Navigator.of(context).pop();
                if (tag.isNotEmpty) {
                  _toggleTag(tag);
                }
              },
              child: const Text('创建'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 已选标签
        if (_selectedTags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '已选标签',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _selectedTags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      onDeleted: () => _toggleTag(tag),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        
        // 标签选择
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Row(
                  children: [
                    Text(
                      '选择标签',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const Spacer(),
                    if (widget.allowCreateNew)
                      TextButton.icon(
                        onPressed: _createNewTag,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('新建'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // 标签网格
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _allAvailableTags.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              '暂无可用标签',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _allAvailableTags.map((tag) {
                              final isSelected = _selectedTags.contains(tag);
                              return FilterChip(
                                label: Text(tag),
                                selected: isSelected,
                                onSelected: (_) => _toggleTag(tag),
                              );
                            }).toList(),
                          ),
                
                // 选择限制提示
                if (_selectedTags.length >= widget.maxSelections * 0.8)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '已选择 ${_selectedTags.length}/${widget.maxSelections} 个标签',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _selectedTags.length >= widget.maxSelections
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.warning,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 标签云组件（显示热门标签）
class TagCloud extends StatefulWidget {
  final String? collectionId;
  final int tagCount;
  final Function(String)? onTagTap;
  final bool showFrequency;

  const TagCloud({
    Key? key,
    this.collectionId,
    this.tagCount = 20,
    this.onTagTap,
    this.showFrequency = true,
  }) : super(key: key);

  @override
  State<TagCloud> createState() => _TagCloudState();
}

class _TagCloudState extends State<TagCloud> {
  final TagService _tagService = TagService();
  List<CollectionTag> _tags = [];
  bool _isLoading = false;
  TagStatistics? _statistics;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() => _isLoading = true);
    
    try {
      final popularTags = await _tagService.getPopularTags(limit: widget.tagCount);
      final statistics = await _tagService.getTagStatistics();
      
      setState(() {
        _tags = popularTags;
        _statistics = statistics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_tags.isEmpty) {
      return Center(
        child: Text(
          '暂无标签数据',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题和统计
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '热门标签',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (_statistics != null)
                Text(
                  '${_statistics!.uniqueTags} 个标签',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 标签云
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _tags.asMap().entries.map((entry) {
              final index = entry.key;
              final tag = entry.value;
              final frequency = _statistics?.getFrequency(tag.name) ?? 0.0;
              
              // 根据使用频率计算大小
              final fontSize = 14.0 + frequency * 20;
              final opacity = 0.4 + frequency * 0.6;
              final color = tag.color.withOpacity(opacity);
              
              return GestureDetector(
                onTap: () => widget.onTagTap?.call(tag.name),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        tag.name,
                        style: TextStyle(
                          fontSize: fontSize,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.showFrequency && frequency > 0)
                        Text(
                          '${(frequency * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 10,
                            color: color.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        // 标签统计摘要
        if (_statistics != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '标签统计',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem(
                          context,
                          label: '总使用次数',
                          value: _statistics!.totalTags.toString(),
                        ),
                        _buildStatItem(
                          context,
                          label: '唯一标签',
                          value: _statistics!.uniqueTags.toString(),
                        ),
                        _buildStatItem(
                          context,
                          label: '最常用',
                          value: _statistics!.mostUsedTags.isNotEmpty
                              ? _statistics!.mostUsedTags.first.name
                              : '-',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, {required String label, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }
}