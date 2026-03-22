// collection_search.dart
// 山径APP - 收藏夹搜索组件（M7 P1）
// 提供收藏夹内路线的搜索功能，支持实时搜索、结果高亮、分页等

import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/collection_enhanced_model.dart';
import '../../models/collection_model.dart';
import '../../services/collection_enhanced_service.dart';
import '../widgets/collections/search_filter_panel.dart';

/// 搜索状态
enum SearchState {
  idle,      // 空闲
  loading,   // 加载中
  empty,     // 无结果
  success,   // 有结果
  error,     // 错误
}

/// 搜索结果项
class SearchResultItem {
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? description;
  final Map<String, dynamic>? metadata;
  final List<String>? highlightFields; // 高亮字段

  SearchResultItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.description,
    this.metadata,
    this.highlightFields,
  });
}

/// 搜索控制器
class CollectionSearchController {
  final TextEditingController textController = TextEditingController();
  final ValueNotifier<SearchState> state = ValueNotifier(SearchState.idle);
  final ValueNotifier<List<SearchResultItem>> results =
      ValueNotifier<List<SearchResultItem>>([]);
  final ValueNotifier<CollectionTrailSearchFilter> filter =
      ValueNotifier<CollectionTrailSearchFilter>(
          CollectionTrailSearchFilter());
  
  String _currentQuery = '';
  Timer? _debounceTimer;
  final CollectionEnhancedService _service = CollectionEnhancedService();
  String? _currentCollectionId;
  int _currentPage = 1;
  bool _hasMore = true;

  /// 初始化搜索
  void init({required String collectionId}) {
    _currentCollectionId = collectionId;
  }

  /// 搜索（带防抖）
  void search(String query, {bool immediate = false}) {
    _currentQuery = query.trim();
    
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }

    if (immediate) {
      _performSearch();
    } else {
      _debounceTimer = Timer(const Duration(milliseconds: 300), _performSearch);
    }
  }

  /// 执行搜索
  Future<void> _performSearch() async {
    if (_currentCollectionId == null) return;

    try {
      state.value = SearchState.loading;
      
      final newFilter = filter.value.copyWith(
        searchQuery: _currentQuery.isNotEmpty ? _currentQuery : null,
        page: 1, // 重置页码
      );
      
      final trails = await _service.searchTrailsInCollection(
        collectionId: _currentCollectionId!,
        filter: newFilter,
      );
      
      // 转换为搜索结果项
      final items = trails.map((trail) {
        return SearchResultItem(
          id: trail.id,
          title: trail.name,
          subtitle: _buildSubtitle(trail),
          description: trail.note,
          metadata: {
            'difficulty': trail.difficulty,
            'distance': trail.distanceKm,
            'duration': trail.durationMin,
          },
          highlightFields: _extractHighlightFields(trail),
        );
      }).toList();
      
      results.value = items;
      _currentPage = 1;
      _hasMore = items.length >= newFilter.limit;
      state.value = items.isEmpty ? SearchState.empty : SearchState.success;
      filter.value = newFilter;
    } catch (e) {
      state.value = SearchState.error;
      results.value = [];
      _hasMore = false;
    }
  }

  /// 加载更多结果
  Future<void> loadMore() async {
    if (_currentCollectionId == null || !_hasMore || state.value == SearchState.loading) {
      return;
    }

    try {
      state.value = SearchState.loading;
      
      final nextFilter = filter.value.copyWith(
        page: _currentPage + 1,
      );
      
      final trails = await _service.searchTrailsInCollection(
        collectionId: _currentCollectionId!,
        filter: nextFilter,
      );
      
      if (trails.isEmpty) {
        _hasMore = false;
        state.value = results.value.isEmpty ? SearchState.empty : SearchState.success;
        return;
      }
      
      // 转换为搜索结果项
      final newItems = trails.map((trail) {
        return SearchResultItem(
          id: trail.id,
          title: trail.name,
          subtitle: _buildSubtitle(trail),
          description: trail.note,
          metadata: {
            'difficulty': trail.difficulty,
            'distance': trail.distanceKm,
            'duration': trail.durationMin,
          },
          highlightFields: _extractHighlightFields(trail),
        );
      }).toList();
      
      results.value = [...results.value, ...newItems];
      _currentPage = nextFilter.page;
      _hasMore = newItems.length >= nextFilter.limit;
      state.value = results.value.isEmpty ? SearchState.empty : SearchState.success;
      filter.value = nextFilter;
    } catch (e) {
      state.value = SearchState.error;
    }
  }

  /// 重置搜索
  void reset() {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }
    
    textController.clear();
    _currentQuery = '';
    results.value = [];
    filter.value = CollectionTrailSearchFilter();
    state.value = SearchState.idle;
    _currentPage = 1;
    _hasMore = true;
  }

  /// 应用筛选器
  Future<void> applyFilter(CollectionTrailSearchFilter newFilter) async {
    filter.value = newFilter.copyWith(
      searchQuery: _currentQuery.isNotEmpty ? _currentQuery : null,
      page: 1, // 重置页码
    );
    await _performSearch();
  }

  /// 构建副标题
  String? _buildSubtitle(CollectionTrail trail) {
    final parts = <String>[];
    
    parts.add('难度: ${trail.difficulty}');
    parts.add('距离: ${trail.distanceKm.toStringAsFixed(1)} km');
    parts.add('时长: ${trail.durationMin} min');
    
    return parts.isNotEmpty ? parts.join(' | ') : null;
  }

  /// 提取高亮字段
  List<String>? _extractHighlightFields(CollectionTrail trail) {
    if (_currentQuery.isEmpty) return null;
    
    final highlights = <String>[];
    final lowerQuery = _currentQuery.toLowerCase();
    
    if (trail.name.toLowerCase().contains(lowerQuery)) {
      highlights.add('title');
    }
    
    if (trail.note?.toLowerCase().contains(lowerQuery) == true) {
      highlights.add('description');
    }
    
    return highlights.isNotEmpty ? highlights : null;
  }

  @override
  void dispose() {
    textController.dispose();
    state.dispose();
    results.dispose();
    filter.dispose();
    _debounceTimer?.cancel();
  }
}

/// 搜索输入框组件
class SearchInput extends StatefulWidget {
  final CollectionSearchController controller;
  final String hintText;
  final bool showCancelButton;
  final bool autofocus;

  const SearchInput({
    Key? key,
    required this.controller,
    this.hintText = '搜索路线...',
    this.showCancelButton = true,
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.controller.textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.textController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.textController.text;
    widget.controller.search(text);
  }

  void _onClear() {
    widget.controller.textController.clear();
    widget.controller.reset();
  }

  void _onCancel() {
    widget.controller.reset();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(Icons.search, size: 20, color: Colors.grey),
                  ),
                  Expanded(
                    child: Focus(
                      onFocusChange: (focused) {
                        setState(() {
                          _isFocused = focused;
                        });
                      },
                      child: TextField(
                        controller: widget.controller.textController,
                        autofocus: widget.autofocus,
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          suffixIcon: widget.controller.textController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: _onClear,
                                  padding: EdgeInsets.zero,
                                )
                              : null,
                        ),
                        onChanged: (_) {
                          // 通过监听器处理
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (widget.showCancelButton && (_isFocused || widget.controller.textController.text.isNotEmpty))
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: TextButton(
                onPressed: _onCancel,
                child: const Text('取消'),
              ),
            ),
        ],
      ),
    );
  }
}

/// 搜索结果列表组件
class SearchResultsList extends StatelessWidget {
  final CollectionSearchController controller;
  final Function(SearchResultItem)? onItemTap;
  final WidgetBuilder? emptyBuilder;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? errorBuilder;

  const SearchResultsList({
    Key? key,
    required this.controller,
    this.onItemTap,
    this.emptyBuilder,
    this.loadingBuilder,
    this.errorBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SearchState>(
      valueListenable: controller.state,
      builder: (context, state, _) {
        switch (state) {
          case SearchState.idle:
            return _buildIdleState(context);
          case SearchState.loading:
            return _buildLoadingState(context);
          case SearchState.empty:
            return _buildEmptyState(context);
          case SearchState.success:
            return _buildResultsList(context);
          case SearchState.error:
            return _buildErrorState(context);
        }
      },
    );
  }

  Widget _buildIdleState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '搜索收藏夹内的路线',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '输入关键词或使用筛选器',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    if (loadingBuilder != null) {
      return loadingBuilder!(context);
    }
    
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    if (emptyBuilder != null) {
      return emptyBuilder!(context);
    }
    
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '没有找到相关路线',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '尝试不同的关键词或筛选条件',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    if (errorBuilder != null) {
      return errorBuilder!(context);
    }
    
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            '搜索失败',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => controller.search(controller.textController.text),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context) {
    return ValueListenableBuilder<List<SearchResultItem>>(
      valueListenable: controller.results,
      builder: (context, results, _) {
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: results.length + (controller._hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < results.length) {
                    return _buildResultItem(context, results[index]);
                  } else {
                    // 加载更多指示器
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.loadMore();
                    });
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultItem(BuildContext context, SearchResultItem item) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => onItemTap?.call(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题（支持高亮）
              _buildHighlightedText(
                context,
                text: item.title,
                isHighlighted: item.highlightFields?.contains('title') == true,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              if (item.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  item.subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
              
              if (item.description != null) ...[
                const SizedBox(height: 8),
                _buildHighlightedText(
                  context,
                  text: item.description!,
                  isHighlighted: item.highlightFields?.contains('description') == true,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
    BuildContext context, {
    required String text,
    required bool isHighlighted,
    TextStyle? style,
    int maxLines = 1,
    TextOverflow overflow = TextOverflow.clip,
  }) {
    if (!isHighlighted || controller.textController.text.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }
    
    final query = controller.textController.text.toLowerCase();
    final lowerText = text.toLowerCase();
    final queryIndex = lowerText.indexOf(query);
    
    if (queryIndex == -1) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }
    
    final before = text.substring(0, queryIndex);
    final match = text.substring(queryIndex, queryIndex + query.length);
    final after = text.substring(queryIndex + query.length);
    
    return RichText(
      maxLines: maxLines,
      overflow: overflow,
      text: TextSpan(
        style: style ?? Theme.of(context).textTheme.bodyMedium,
        children: [
          TextSpan(text: before),
          TextSpan(
            text: match,
            style: style?.copyWith(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              fontWeight: FontWeight.bold,
            ) ?? TextStyle(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}

/// 完整搜索组件
class CollectionSearchWidget extends StatefulWidget {
  final String collectionId;
  final Function(SearchResultItem)? onResultTap;
  final bool showFilterButton;

  const CollectionSearchWidget({
    Key? key,
    required this.collectionId,
    this.onResultTap,
    this.showFilterButton = true,
  }) : super(key: key);

  @override
  State<CollectionSearchWidget> createState() => _CollectionSearchWidgetState();
}

class _CollectionSearchWidgetState extends State<CollectionSearchWidget> {
  late final CollectionSearchController _controller;
  bool _showFilterPanel = false;

  @override
  void initState() {
    super.initState();
    _controller = CollectionSearchController();
    _controller.init(collectionId: widget.collectionId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFilterPanel() {
    setState(() {
      _showFilterPanel = !_showFilterPanel;
    });
  }

  void _applyFilter(CollectionTrailSearchFilter filter) async {
    await _controller.applyFilter(filter);
    setState(() {
      _showFilterPanel = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 搜索输入框
        SearchInput(
          controller: _controller,
          hintText: '搜索收藏夹内的路线...',
          showCancelButton: true,
          autofocus: false,
        ),
        
        // 筛选按钮
        if (widget.showFilterButton)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SearchFilterButton(
                  type: FilterPanelType.trails,
                  trailFilter: _controller.filter.value,
                  onPressed: _toggleFilterPanel,
                ),
              ],
            ),
          ),
        
        // 结果区域
        Expanded(
          child: SearchResultsList(
            controller: _controller,
            onItemTap: widget.onResultTap,
          ),
        ),
        
        // 筛选面板
        if (_showFilterPanel)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: SearchFilterPanel(
              type: FilterPanelType.trails,
              trailFilter: _controller.filter.value,
              onTrailFilterChanged: _applyFilter,
              onClose: () => setState(() => _showFilterPanel = false),
              expanded: true,
            ),
          ),
      ],
    );
  }
}