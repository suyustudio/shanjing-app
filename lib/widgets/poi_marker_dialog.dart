// poi_marker_dialog.dart
// 山径APP - POI标记弹窗组件

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recording_model.dart';
import '../constants/design_system.dart';

/// POI标记弹窗
/// 
/// 用于在录制过程中标记兴趣点
class PoiMarkerDialog extends StatefulWidget {
  final Function(PoiType type, String? name, String? description, List<String> photos) onConfirm;
  final VoidCallback? onCancel;

  const PoiMarkerDialog({
    super.key,
    required this.onConfirm,
    this.onCancel,
  });

  /// 显示弹窗的静态方法
  static Future<void> show({
    required BuildContext context,
    required Function(PoiType type, String? name, String? description, List<String> photos) onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PoiMarkerDialog(
        onConfirm: onConfirm,
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  State<PoiMarkerDialog> createState() => _PoiMarkerDialogState();
}

class _PoiMarkerDialogState extends State<PoiMarkerDialog> {
  PoiType? _selectedType;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<File> _selectedPhotos = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSubmitting = false;

  // POI类型列表（排除起点和终点，这两个自动添加）
  final List<PoiType> _availableTypes = [
    PoiType.junction,
    PoiType.viewpoint,
    PoiType.restroom,
    PoiType.supply,
    PoiType.danger,
    PoiType.rest,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.getSurface(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomPadding + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '标记位置',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: widget.onCancel,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // POI类型选择
          Text(
            '选择类型',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableTypes.map((type) => _buildTypeChip(type)).toList(),
          ),
          const SizedBox(height: 20),

          // 名称输入
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '名称（可选）',
              hintText: '给这个标记起个名字',
              prefixIcon: const Icon(Icons.label_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 描述输入
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: '备注（可选）',
              hintText: '添加一些描述...',
              prefixIcon: const Icon(Icons.notes),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 照片区域
          Text(
            '拍照记录',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildPhotoSection(),
          const SizedBox(height: 24),

          // 提交按钮
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting || _selectedType == null 
                  ? null 
                  : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '确认标记',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建类型选择芯片
  Widget _buildTypeChip(PoiType type) {
    final isSelected = _selectedType == type;
    final theme = Theme.of(context);

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIconData(type),
            size: 18,
            color: isSelected 
                ? theme.colorScheme.onPrimary 
                : theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(type.displayName),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? type : null;
        });
      },
      selectedColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected 
            ? theme.colorScheme.onPrimary 
            : theme.colorScheme.onSurface,
      ),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected 
              ? theme.colorScheme.primary 
              : Colors.transparent,
        ),
      ),
    );
  }

  /// 构建照片区域
  Widget _buildPhotoSection() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // 添加照片按钮
          _buildAddPhotoButton(),
          const SizedBox(width: 8),
          // 已选照片
          ..._selectedPhotos.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildPhotoThumbnail(entry.value, entry.key),
            );
          }),
        ],
      ),
    );
  }

  /// 构建添加照片按钮
  Widget _buildAddPhotoButton() {
    return InkWell(
      onTap: _takePhoto,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: DesignSystem.getBackgroundSecondary(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: DesignSystem.getBorder(context),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 32,
              color: DesignSystem.getTextSecondary(context),
            ),
            const SizedBox(height: 4),
            Text(
              '拍照',
              style: TextStyle(
                fontSize: 12,
                color: DesignSystem.getTextSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建照片缩略图
  Widget _buildPhotoThumbnail(File photo, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            photo,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () => _removePhoto(index),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 拍照
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _selectedPhotos.add(File(photo.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('拍照失败: $e')),
        );
      }
    }
  }

  /// 移除照片
  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  /// 提交
  Future<void> _submit() async {
    if (_selectedType == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 这里应该上传照片到服务器，现在先用本地路径
      final photoUrls = _selectedPhotos.map((f) => f.path).toList();

      widget.onConfirm(
        _selectedType!,
        _nameController.text.isEmpty ? null : _nameController.text,
        _descriptionController.text.isEmpty ? null : _descriptionController.text,
        photoUrls,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// 获取图标数据
  IconData _getIconData(PoiType type) {
    switch (type) {
      case PoiType.start:
        return Icons.flag;
      case PoiType.end:
        return Icons.sports_score;
      case PoiType.junction:
        return Icons.call_split;
      case PoiType.viewpoint:
        return Icons.photo_camera;
      case PoiType.restroom:
        return Icons.wc;
      case PoiType.supply:
        return Icons.local_drink;
      case PoiType.danger:
        return Icons.warning;
      case PoiType.rest:
        return Icons.chair;
    }
  }
}

/// 快速POI标记按钮
class QuickPoiButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isRecording;

  const QuickPoiButton({
    super.key,
    required this.onPressed,
    required this.isRecording,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: isRecording ? onPressed : null,
      backgroundColor: isRecording 
          ? Theme.of(context).colorScheme.secondary 
          : DesignSystem.getTextTertiary(context).withOpacity(0.3),
      icon: const Icon(Icons.add_location_alt),
      label: const Text('标记'),
    );
  }
}

/// POI标记显示卡片
class PoiMarkerCard extends StatelessWidget {
  final PoiMarker poi;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const PoiMarkerCard({
    super.key,
    required this.poi,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 类型图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getTypeColor(poi.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconData(poi.type),
                  color: _getTypeColor(poi.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poi.name ?? poi.type.displayName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (poi.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        poi.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: DesignSystem.getTextSecondary(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(poi.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: DesignSystem.getTextTertiary(context),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // 照片数量
              if (poi.photoUrls.isNotEmpty)
                Chip(
                  label: Text('${poi.photoUrls.length}张照片'),
                  avatar: const Icon(Icons.photo, size: 16),
                  visualDensity: VisualDensity.compact,
                ),
              // 删除按钮
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline, color: DesignSystem.getError(context)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(PoiType type) {
    switch (type) {
      case PoiType.start:
        return Colors.green;
      case PoiType.end:
        return Colors.red;
      case PoiType.junction:
        return Colors.blue;
      case PoiType.viewpoint:
        return Colors.purple;
      case PoiType.restroom:
        return Colors.cyan;
      case PoiType.supply:
        return Colors.orange;
      case PoiType.danger:
        return Colors.red.shade700;
      case PoiType.rest:
        return Colors.teal;
    }
  }

  IconData _getIconData(PoiType type) {
    switch (type) {
      case PoiType.start:
        return Icons.flag;
      case PoiType.end:
        return Icons.sports_score;
      case PoiType.junction:
        return Icons.call_split;
      case PoiType.viewpoint:
        return Icons.photo_camera;
      case PoiType.restroom:
        return Icons.wc;
      case PoiType.supply:
        return Icons.local_drink;
      case PoiType.danger:
        return Icons.warning;
      case PoiType.rest:
        return Icons.chair;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}
