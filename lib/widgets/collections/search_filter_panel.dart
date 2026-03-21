// search_filter_panel.dart
// 山径APP - 搜索筛选面板组件（M7 P1）
// 提供收藏夹和路线的搜索筛选功能

import 'package:flutter/material.dart';
import '../../models/collection_enhanced_model.dart';

/// 搜索筛选面板类型
enum FilterPanelType {
  collections,  // 收藏夹筛选
  trails,       // 路线筛选（在收藏夹内）
}

/// 搜索筛选面板
class SearchFilterPanel extends StatefulWidget {
  final FilterPanelType type;
  final CollectionSearchFilter? collectionFilter;
  final CollectionTrailSearchFilter? trailFilter;
  final Function(CollectionSearchFilter)? onCollectionFilterChanged;
  final Function(CollectionTrailSearchFilter)? onTrailFilterChanged;
  final VoidCallback? onClose;
  final bool expanded;

  const SearchFilterPanel({
    Key? key,
    required this.type,
    this.collectionFilter,
    this.trailFilter,
    this.onCollectionFilterChanged,
    this.onTrailFilterChanged,
    this.onClose,
    this.expanded = false,
  }) : super(key: key);

  @override
  State<SearchFilterPanel> createState() => _SearchFilterPanelState();
}

class _SearchFilterPanelState extends State<SearchFilterPanel> {
  late CollectionSearchFilter _collectionFilter;
  late CollectionTrailSearchFilter _trailFilter;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _availableTags = [];
  final List<String> _availableDifficulties = ['简单', '中等', '困难'];

  @override
  void initState() {
    super.initState();
    _collectionFilter = widget.collectionFilter ?? CollectionSearchFilter();
    _trailFilter = widget.trailFilter ?? CollectionTrailSearchFilter();
    _searchController.text = widget.type == FilterPanelType.collections
        ? _collectionFilter.searchQuery ?? ''
        : _trailFilter.searchQuery ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    if (widget.type == FilterPanelType.collections) {
      widget.onCollectionFilterChanged?.call(_collectionFilter);
    } else {
      widget.onTrailFilterChanged?.call(_trailFilter);
    }
  }

  void _resetFilters() {
    setState(() {
      if (widget.type == FilterPanelType.collections) {
        _collectionFilter = CollectionSearchFilter();
        _searchController.text = '';
      } else {
        _trailFilter = CollectionTrailSearchFilter();
        _searchController.text = '';
      }
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          _buildHeader(theme),
          
          // 内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: widget.type == FilterPanelType.collections
                  ? _buildCollectionFilters()
                  : _buildTrailFilters(),
            ),
          ),
          
          // 操作按钮
          _buildActionButtons(),
        ],
      ),
    );
  }
  
  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Icon(
            widget.type == FilterPanelType.collections
                ? Icons.filter_list_outlined
                : Icons.search_outlined,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            widget.type == FilterPanelType.collections
                ? '筛选收藏夹'
                : '搜索路线',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close),
            iconSize: 20,
          ),
        ],
      ),
    );
  }
  
  Widget _buildCollectionFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 搜索框
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: '搜索收藏夹名称或描述...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _collectionFilter = _collectionFilter.copyWith(searchQuery: value);
            });
          },
        ),
        
        const SizedBox(height: 16),
        
        // 标签筛选
        Text(
          '标签',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildTagFilter(),
        
        const SizedBox(height: 16),
        
        // 隐私筛选
        Text(
          '隐私设置',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<bool?>(
          segments: const [
            ButtonSegment<bool?>(
              value: null,
              label: Text('全部'),
              icon: Icon(Icons.all_inclusive),
            ),
            ButtonSegment<bool?>(
              value: true,
              label: Text('公开'),
              icon: Icon(Icons.public),
            ),
            ButtonSegment<bool?>(
              value: false,
              label: Text('私密'),
              icon: Icon(Icons.lock),
            ),
          ],
          selected: {_collectionFilter.isPublic},
          onSelectionChanged: (Set<bool?> selected) {
            setState(() {
              _collectionFilter = _collectionFilter.copyWith(
                isPublic: selected.first,
              );
            });
          },
          multiSelectionEnabled: false,
        ),
        
        const SizedBox(height: 16),
        
        // 排序方式
        Text(
          '排序方式',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _collectionFilter.sortBy ?? 'updated',
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(
              value: 'updated',
              child: Text('最近更新'),
            ),
            DropdownMenuItem(
              value: 'created',
              child: Text('创建时间'),
            ),
            DropdownMenuItem(
              value: 'name',
              child: Text('名称'),
            ),
            DropdownMenuItem(
              value: 'trailCount',
              child: Text('路线数量'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _collectionFilter = _collectionFilter.copyWith(sortBy: value);
            });
          },
        ),
        
        const SizedBox(height: 16),
        
        // 排序方向
        CheckboxListTile(
          title: const Text('升序排列'),
          value: _collectionFilter.sortAscending,
          onChanged: (value) {
            setState(() {
              _collectionFilter = _collectionFilter.copyWith(
                sortAscending: value ?? false,
              );
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }
  
  Widget _buildTrailFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 搜索框
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: '搜索路线名称...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _trailFilter = _trailFilter.copyWith(searchQuery: value);
            });
          },
        ),
        
        const SizedBox(height: 16),
        
        // 难度筛选
        Text(
          '难度',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _availableDifficulties.map((difficulty) {
            final isSelected = _trailFilter.difficulties?.contains(difficulty) == true;
            return FilterChip(
              label: Text(difficulty),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final difficulties = List<String>.from(
                    _trailFilter.difficulties ?? [],
                  );
                  if (selected) {
                    difficulties.add(difficulty);
                  } else {
                    difficulties.remove(difficulty);
                  }
                  _trailFilter = _trailFilter.copyWith(
                    difficulties: difficulties,
                  );
                });
              },
            );
          }).toList(),
        ),
        
        const SizedBox(height: 16),
        
        // 距离范围
        Text(
          '距离 (公里)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: RangeValues(
            _trailFilter.minDistance ?? 0,
            _trailFilter.maxDistance ?? 20,
          ),
          min: 0,
          max: 50,
          divisions: 10,
          labels: RangeLabels(
            '${(_trailFilter.minDistance ?? 0).toStringAsFixed(1)} km',
            '${(_trailFilter.maxDistance ?? 20).toStringAsFixed(1)} km',
          ),
          onChanged: (values) {
            setState(() {
              _trailFilter = _trailFilter.copyWith(
                minDistance: values.start,
                maxDistance: values.end,
              );
            });
          },
        ),
        
        const SizedBox(height: 16),
        
        // 时长范围
        Text(
          '时长 (分钟)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: RangeValues(
            _trailFilter.minDuration?.toDouble() ?? 0,
            _trailFilter.maxDuration?.toDouble() ?? 300,
          ),
          min: 0,
          max: 600,
          divisions: 12,
          labels: RangeLabels(
            '${(_trailFilter.minDuration ?? 0)} min',
            '${(_trailFilter.maxDuration ?? 300)} min',
          ),
          onChanged: (values) {
            setState(() {
              _trailFilter = _trailFilter.copyWith(
                minDuration: values.start.toInt(),
                maxDuration: values.end.toInt(),
              );
            });
          },
        ),
        
        const SizedBox(height: 16),
        
        // 排序方式
        Text(
          '排序方式',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _trailFilter.sortBy,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(
              value: 'added',
              child: Text('添加时间'),
            ),
            DropdownMenuItem(
              value: 'name',
              child: Text('名称'),
            ),
            DropdownMenuItem(
              value: 'distance',
              child: Text('距离'),
            ),
            DropdownMenuItem(
              value: 'duration',
              child: Text('时长'),
            ),
            DropdownMenuItem(
              value: 'difficulty',
              child: Text('难度'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _trailFilter = _trailFilter.copyWith(sortBy: value);
            });
          },
        ),
      ],
    );
  }
  
  Widget _buildTagFilter() {
    if (_availableTags.isEmpty) {
      return const Text(
        '暂无标签',
        style: TextStyle(color: Colors.grey),
      );
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableTags.map((tag) {
        final isSelected = _collectionFilter.tags?.contains(tag) == true;
        return FilterChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              final tags = List<String>.from(_collectionFilter.tags ?? []);
              if (selected) {
                tags.add(tag);
              } else {
                tags.remove(tag);
              }
              _collectionFilter = _collectionFilter.copyWith(tags: tags);
            });
          },
        );
      }).toList(),
    );
  }
  
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _resetFilters,
              child: const Text('重置'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('应用'),
            ),
          ),
        ],
      ),
    );
  }
}

/// 搜索筛选按钮（触发面板显示）
class SearchFilterButton extends StatelessWidget {
  final FilterPanelType type;
  final CollectionSearchFilter? collectionFilter;
  final CollectionTrailSearchFilter? trailFilter;
  final VoidCallback onPressed;

  const SearchFilterButton({
    Key? key,
    required this.type,
    this.collectionFilter,
    this.trailFilter,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveFilters = _hasActiveFilters();
    
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: hasActiveFilters
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
        side: BorderSide(
          color: hasActiveFilters
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.3),
          width: hasActiveFilters ? 1.5 : 1,
        ),
        backgroundColor: hasActiveFilters
            ? theme.colorScheme.primary.withOpacity(0.05)
            : Colors.transparent,
      ),
      icon: Icon(
        hasActiveFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
        size: 18,
      ),
      label: Text(
        type == FilterPanelType.collections ? '筛选' : '搜索',
        style: TextStyle(
          fontWeight: hasActiveFilters ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }
  
  bool _hasActiveFilters() {
    if (type == FilterPanelType.collections) {
      final filter = collectionFilter;
      return filter != null && (
        (filter.searchQuery?.isNotEmpty == true) ||
        (filter.tags?.isNotEmpty == true) ||
        filter.isPublic != null ||
        filter.sortBy != null
      );
    } else {
      final filter = trailFilter;
      return filter != null && (
        (filter.searchQuery?.isNotEmpty == true) ||
        (filter.difficulties?.isNotEmpty == true) ||
        filter.minDistance != null ||
        filter.maxDistance != null ||
        filter.minDuration != null ||
        filter.maxDuration != null ||
        filter.sortBy != 'added'
      );
    }
  }
}
