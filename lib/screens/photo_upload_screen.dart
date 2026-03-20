// ================================================================
// M6: 照片上传界面
// ================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/design_system.dart';
import '../models/photo_model.dart';
import '../services/photo_service.dart';

class PhotoUploadScreen extends StatefulWidget {
  final String? trailId;
  final String? trailName;

  const PhotoUploadScreen({
    Key? key,
    this.trailId,
    this.trailName,
  }) : super(key: key);

  @override
  State<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final PhotoService _photoService = PhotoService();
  final TextEditingController _descriptionController = TextEditingController();

  final List<XFile> _selectedPhotos = [];
  int _currentPhotoIndex = 0;
  bool _isUploading = false;
  double _uploadProgress = 0;
  int _currentUploadIndex = 0;

  double? _rating;
  final List<String> _selectedTags = [];

  final List<String> _availableTags = [
    '风景',
    '路况',
    '打卡点',
    '动植物',
    '其他',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final photos = await _picker.pickMultiImage(
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );

    if (photos != null && photos.isNotEmpty) {
      setState(() {
        _selectedPhotos.addAll(photos);
      });
    }
  }

  Future<void> _takePhoto() async {
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );

    if (photo != null) {
      setState(() {
        _selectedPhotos.add(photo);
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
      if (_currentPhotoIndex >= _selectedPhotos.length && _currentPhotoIndex > 0) {
        _currentPhotoIndex--;
      }
    });
  }

  void _setMainPhoto(int index) {
    if (index == 0) return;
    setState(() {
      final photo = _selectedPhotos.removeAt(index);
      _selectedPhotos.insert(0, photo);
      _currentPhotoIndex = 0;
    });
  }

  Future<void> _uploadPhotos() async {
    if (_selectedPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择照片')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
      _currentUploadIndex = 0;
    });

    try {
      final files = _selectedPhotos.map((p) => File(p.path)).toList();
      
      final photos = await _photoService.uploadPhotos(
        files: files,
        trailId: widget.trailId,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        onProgress: (current, total) {
          setState(() {
            _currentUploadIndex = current;
            _uploadProgress = current / total;
          });
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('成功上传 ${photos.length} 张照片')),
        );
        Navigator.of(context).pop(photos);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('上传失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
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
          icon: const Icon(Icons.close, color: DesignSystem.gray900),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '上传照片',
          style: TextStyle(
            color: DesignSystem.gray900,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_selectedPhotos.isNotEmpty && !_isUploading)
            TextButton(
              onPressed: _uploadPhotos,
              child: const Text(
                '发布',
                style: TextStyle(
                  color: DesignSystem.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isUploading ? _buildUploadingView() : _buildContentView(),
    );
  }

  Widget _buildUploadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: _uploadProgress,
              strokeWidth: 4,
              backgroundColor: DesignSystem.gray200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                DesignSystem.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '正在上传 $_currentUploadIndex / ${_selectedPhotos.length}',
            style: const TextStyle(
              fontSize: 16,
              color: DesignSystem.gray600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_uploadProgress * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: DesignSystem.gray900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 照片选择区域
          if (_selectedPhotos.isEmpty)
            _buildEmptyPhotoSelector()
          else
            _buildPhotoPreview(),

          const SizedBox(height: 24),

          // 关联路线
          if (widget.trailName != null)
            _buildTrailInfo(),

          const SizedBox(height: 24),

          // 评分
          _buildRatingSection(),

          const SizedBox(height: 24),

          // 标签
          _buildTagsSection(),

          const SizedBox(height: 24),

          // 描述输入
          _buildDescriptionInput(),

          const SizedBox(height: 24),

          // 位置信息
          _buildLocationSection(),
        ],
      ),
    );
  }

  Widget _buildEmptyPhotoSelector() {
    return GestureDetector(
      onTap: _pickPhotos,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: DesignSystem.gray50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: DesignSystem.gray300,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: DesignSystem.gray400,
            ),
            const SizedBox(height: 12),
            Text(
              '点击添加照片',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: DesignSystem.gray700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '或从相册选择',
              style: TextStyle(
                fontSize: 14,
                color: DesignSystem.gray400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 当前照片大图
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: DesignSystem.gray100,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(_selectedPhotos[_currentPhotoIndex].path),
                  fit: BoxFit.cover,
                ),
                // 主图标签
                if (_currentPhotoIndex == 0)
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: DesignSystem.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '主图',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                // 删除按钮
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _removePhoto(_currentPhotoIndex),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 缩略图列表
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedPhotos.length + 1,
            itemBuilder: (context, index) {
              if (index == _selectedPhotos.length) {
                // 添加按钮
                return GestureDetector(
                  onTap: _pickPhotos,
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: DesignSystem.gray50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: DesignSystem.gray300,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: DesignSystem.gray400,
                    ),
                  ),
                );
              }

              return GestureDetector(
                onTap: () => setState(() => _currentPhotoIndex = index),
                onLongPress: () => _setMainPhoto(index),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: _currentPhotoIndex == index
                        ? Border.all(
                            color: DesignSystem.primaryColor,
                            width: 2,
                          )
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_selectedPhotos[index].path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // 提示文字
        Text(
          '长按缩略图可设为主图，主图将用于列表封面展示',
          style: TextStyle(
            fontSize: 12,
            color: DesignSystem.gray400,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignSystem.gray50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.map_outlined,
            color: DesignSystem.gray400,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '关联路线',
                  style: TextStyle(
                    fontSize: 12,
                    color: DesignSystem.gray500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.trailName!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: DesignSystem.gray700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '为照片评分',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: DesignSystem.gray700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(5, (index) {
            final rating = index + 1;
            return GestureDetector(
              onTap: () => setState(() => _rating = rating.toDouble()),
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  rating <= (_rating ?? 0)
                      ? Icons.star
                      : Icons.star_border,
                  size: 32,
                  color: rating <= (_rating ?? 0)
                      ? DesignSystem.ratingColor
                      : DesignSystem.gray200,
                ),
              ),
            );
          }),
        ),
        if (_rating != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _getRatingText(_rating!),
              style: TextStyle(
                fontSize: 13,
                color: DesignSystem.primaryColor,
              ),
            ),
          ),
      ],
    );
  }

  String _getRatingText(double rating) {
    switch (rating.toInt()) {
      case 1:
        return '一般';
      case 2:
        return '还行';
      case 3:
        return '不错';
      case 4:
        return '很好';
      case 5:
        return '完美';
      default:
        return '';
    }
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '添加标签',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: DesignSystem.gray700,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? DesignSystem.primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? DesignSystem.primaryColor
                        : DesignSystem.gray300,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected
                        ? DesignSystem.primaryColor
                        : DesignSystem.gray600,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '添加描述',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: DesignSystem.gray700,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: '分享这张照片的故事...',
            hintStyle: TextStyle(color: DesignSystem.gray400),
            filled: true,
            fillColor: DesignSystem.gray50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignSystem.gray50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            color: DesignSystem.gray400,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '添加位置',
                  style: TextStyle(
                    fontSize: 12,
                    color: DesignSystem.gray500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '自动获取位置信息',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: DesignSystem.gray700,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: true,
            onChanged: (value) {},
            activeColor: DesignSystem.primaryColor,
          ),
        ],
      ),
    );
  }
}
