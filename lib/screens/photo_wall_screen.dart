// ================================================================
// M6: 照片墙屏幕
// ================================================================

import 'package:flutter/material.dart';
import '../constants/design_system.dart';
import '../models/photo_model.dart';
import '../services/photo_service.dart';
import '../widgets/photo_masonry_grid.dart';
import '../widgets/photo_viewer.dart';
import 'photo_upload_screen.dart';

class PhotoWallScreen extends StatefulWidget {
  final String? trailId;
  final String? trailName;

  const PhotoWallScreen({
    Key? key,
    this.trailId,
    this.trailName,
  }) : super(key: key);

  @override
  State<PhotoWallScreen> createState() => _PhotoWallScreenState();
}

class _PhotoWallScreenState extends State<PhotoWallScreen> {
  final PhotoService _photoService = PhotoService();
  final ScrollController _scrollController = ScrollController();

  List<Photo> _photos = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _cursor;
  String _currentSort = 'newest';

  final List<Map<String, String>> _sortOptions = [
    {'value': 'newest', 'label': '最新'},
    {'value': 'popular', 'label': '最热'},
  ];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPhotos({bool refresh = false}) async {
    if (_isLoading) return;
    if (!refresh && !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _photoService.getPhotos(
        trailId: widget.trailId,
        sort: _currentSort,
        cursor: refresh ? null : _cursor,
        limit: 20,
      );

      setState(() {
        if (refresh) {
          _photos = response.list;
        } else {
          _photos.addAll(response.list);
        }
        _cursor = response.nextCursor;
        _hasMore = response.hasMore;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadPhotos(refresh: true);
  }

  void _onPhotoTap(Photo photo, int index) {
    showPhotoViewer(
      context: context,
      photos: _photos,
      initialIndex: index,
      onLikeTap: _toggleLike,
    );
  }

  Future<void> _toggleLike(Photo photo) async {
    try {
      final response = await _photoService.likePhoto(photo.id);
      
      setState(() {
        final index = _photos.indexWhere((p) => p.id == photo.id);
        if (index != -1) {
          _photos[index] = _photos[index].copyWith(
            isLiked: response.isLiked,
            likeCount: response.likeCount,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  void _onSortChanged(String? value) {
    if (value != null && value != _currentSort) {
      setState(() {
        _currentSort = value;
        _photos = [];
        _cursor = null;
        _hasMore = true;
      });
      _loadPhotos(refresh: true);
    }
  }

  Future<void> _navigateToUpload() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PhotoUploadScreen(
          trailId: widget.trailId,
          trailName: widget.trailName,
        ),
      ),
    );

    if (result != null) {
      // 上传成功后刷新
      _onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DesignSystem.gray900),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.trailName != null ? '${widget.trailName}的照片' : '照片墙',
          style: const TextStyle(
            color: DesignSystem.gray900,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: DesignSystem.primaryColor),
            onPressed: _navigateToUpload,
          ),
        ],
      ),
      body: Column(
        children: [
          // 排序栏
          _buildSortBar(),

          // 照片网格
          Expanded(
            child: _photos.isEmpty && !_isLoading
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: DesignSystem.primaryColor,
                    child: PhotoMasonryGrid(
                      photos: _photos,
                      scrollController: _scrollController,
                      onPhotoTap: (photo) {
                        final index = _photos.indexWhere((p) => p.id == photo.id);
                        _onPhotoTap(photo, index);
                      },
                      onLikeTap: _toggleLike,
                      isLoading: _isLoading,
                      hasMore: _hasMore,
                      onLoadMore: () => _loadPhotos(),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToUpload,
        backgroundColor: DesignSystem.primaryColor,
        icon: const Icon(Icons.camera_alt),
        label: const Text('上传照片'),
      ),
    );
  }

  Widget _buildSortBar() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: DesignSystem.gray100),
        ),
      ),
      child: Row(
        children: [
          const Text(
            '排序:',
            style: TextStyle(
              fontSize: 14,
              color: DesignSystem.gray500,
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _currentSort,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, size: 20),
            items: _sortOptions.map((option) {
              return DropdownMenuItem<String>(
                value: option['value'],
                child: Text(
                  option['label']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: _currentSort == option['value']
                        ? DesignSystem.primaryColor
                        : DesignSystem.gray600,
                    fontWeight: _currentSort == option['value']
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
            onChanged: _onSortChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: DesignSystem.gray300,
          ),
          const SizedBox(height: 16),
          Text(
            '还没有照片',
            style: TextStyle(
              fontSize: 16,
              color: DesignSystem.gray500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '成为第一个上传照片的人吧！',
            style: TextStyle(
              fontSize: 14,
              color: DesignSystem.gray400,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToUpload,
            icon: const Icon(Icons.camera_alt),
            label: const Text('上传照片'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
