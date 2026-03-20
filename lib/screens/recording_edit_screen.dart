// recording_edit_screen.dart
// 山径APP - 录制后编辑页面

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/design_system.dart';
import '../models/recording_model.dart';
import '../widgets/poi_marker_dialog.dart';

/// 录制后编辑页面
class RecordingEditScreen extends StatefulWidget {
  final RecordingSession session;

  const RecordingEditScreen({
    super.key,
    required this.session,
  });

  @override
  State<RecordingEditScreen> createState() => _RecordingEditScreenState();
}

class _RecordingEditScreenState extends State<RecordingEditScreen> {
  // 表单数据
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _cityController;
  late TextEditingController _districtController;
  
  // 标签
  final List<String> _tags = [];
  final _tagController = TextEditingController();
  
  // 编辑状态
  late RecordingSession _editedSession;
  int _selectedCoverPoiIndex = -1; // -1表示使用默认封面
  
  // 播放状态
  bool _isPlaying = false;
  int _currentPlayIndex = 0;

  @override
  void initState() {
    super.initState();
    _editedSession = widget.session;
    _nameController = TextEditingController(text: widget.session.trailName);
    _descriptionController = TextEditingController(text: widget.session.description);
    _cityController = TextEditingController(text: widget.session.city);
    _districtController = TextEditingController(text: widget.session.district);
    _tags.addAll(widget.session.tags);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  /// 添加标签
  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag) && _tags.length < 10) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  /// 删除标签
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  /// 删除POI
  void _removePoi(int index) {
    setState(() {
      final updatedPois = List<PoiMarker>.from(_editedSession.pois);
      updatedPois.removeAt(index);
      _editedSession = _editedSession.copyWith(pois: updatedPois);
      
      // 调整封面选择
      if (_selectedCoverPoiIndex == index) {
        _selectedCoverPoiIndex = -1;
      } else if (_selectedCoverPoiIndex > index) {
        _selectedCoverPoiIndex--;
      }
    });
  }

  /// 编辑POI
  void _editPoi(int index) {
    final poi = _editedSession.pois[index];
    // TODO: 实现POI编辑对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑标记点'),
        content: Text('即将支持编辑POI: ${poi.name ?? poi.type.displayName}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  /// 保存草稿
  Future<void> _saveDraft() async {
    HapticFeedback.lightImpact();
    
    final updatedSession = _editedSession.copyWith(
      trailName: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      city: _cityController.text.trim(),
      district: _districtController.text.trim(),
      tags: _tags,
      submissionStatus: SubmissionStatus.draft,
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop(updatedSession);
  }

  /// 提交审核
  Future<void> _submitForReview() async {
    if (!_formKey.currentState!.validate()) return;

    // 检查提交次数
    if (_editedSession.submissionCount >= 3) {
      _showErrorDialog('提交次数已达上限', '此录制已提交3次，无法再次提交。');
      return;
    }

    HapticFeedback.mediumImpact();

    // 确认提交对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignSystem.getSurface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('提交审核', style: DesignSystem.getTitleLarge(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '提交后路线将进入审核流程，审核通过后会正式发布。',
              style: DesignSystem.getBodyMedium(context),
            ),
            const SizedBox(height: 12),
            Text(
              '剩余提交次数: ${3 - _editedSession.submissionCount - 1}次',
              style: DesignSystem.getBodySmall(context)?.copyWith(
                color: DesignSystem.getTextSecondary(context),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.getPrimary(context),
              foregroundColor: DesignSystem.textInverse,
            ),
            child: const Text('提交'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final updatedSession = _editedSession.copyWith(
      trailName: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      city: _cityController.text.trim(),
      district: _districtController.text.trim(),
      tags: _tags,
      submissionStatus: SubmissionStatus.submitted,
      submissionCount: _editedSession.submissionCount + 1,
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop(updatedSession);
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignSystem.getSurface(context),
        title: Text(title, style: DesignSystem.getTitleLarge(context)),
        content: Text(message, style: DesignSystem.getBodyMedium(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.getBackground(context),
      appBar: AppBar(
        backgroundColor: DesignSystem.getBackground(context),
        foregroundColor: DesignSystem.getTextPrimary(context),
        elevation: 0,
        title: Text('编辑路线', style: DesignSystem.getTitleLarge(context)),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close, color: DesignSystem.getTextPrimary(context)),
        ),
        actions: [
          TextButton(
            onPressed: _saveDraft,
            child: Text(
              '保存草稿',
              style: TextStyle(color: DesignSystem.getPrimary(context)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(DesignSystem.spacingMedium),
          children: [
            // 轨迹预览
            _buildTrackPreview(),
            const SizedBox(height: 24),

            // 路线名称
            _buildSectionTitle('路线名称'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: _buildInputDecoration(
                hintText: '给你的路线起个名字',
                prefixIcon: Icons.route,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入路线名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 位置信息
            _buildSectionTitle('位置信息'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: _buildInputDecoration(
                      hintText: '城市',
                      prefixIcon: Icons.location_city,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入城市';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _districtController,
                    decoration: _buildInputDecoration(
                      hintText: '区域',
                      prefixIcon: Icons.map,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入区域';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 路线描述
            _buildSectionTitle('路线描述'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              maxLength: 500,
              decoration: _buildInputDecoration(
                hintText: '描述一下这条路线的特点、风景、注意事项...',
                prefixIcon: Icons.description,
              ),
            ),
            const SizedBox(height: 24),

            // 标签
            _buildSectionTitle('标签'),
            const SizedBox(height: 8),
            _buildTagInput(),
            const SizedBox(height: 24),

            // 封面图选择
            _buildSectionTitle('封面图'),
            const SizedBox(height: 8),
            _buildCoverImageSelector(),
            const SizedBox(height: 24),

            // POI列表
            _buildSectionTitle('标记点 (${_editedSession.pois.length})'),
            const SizedBox(height: 8),
            _buildPoiList(),
            const SizedBox(height: 32),

            // 统计信息
            _buildStatsSection(),
            const SizedBox(height: 32),

            // 提交按钮
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _submitForReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignSystem.getPrimary(context),
                  foregroundColor: DesignSystem.textInverse,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send),
                    SizedBox(width: 8),
                    Text(
                      '提交审核',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// 构建轨迹预览
  Widget _buildTrackPreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: DesignSystem.getBackgroundSecondary(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // 轨迹地图占位
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  size: 48,
                  color: DesignSystem.getTextTertiary(context),
                ),
                const SizedBox(height: 8),
                Text(
                  '轨迹预览地图',
                  style: TextStyle(color: DesignSystem.getTextTertiary(context)),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_editedSession.trackPoints.length}个轨迹点',
                  style: DesignSystem.getBodySmall(context),
                ),
              ],
            ),
          ),
          // 播放按钮
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.small(
              onPressed: () {
                setState(() {
                  _isPlaying = !_isPlaying;
                });
              },
              backgroundColor: DesignSystem.getPrimary(context),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: DesignSystem.textInverse,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建章节标题
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: DesignSystem.getTitleMedium(context, weight: FontWeight.w600),
    );
  }

  /// 构建输入框装饰
  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: DesignSystem.getTextTertiary(context)),
      prefixIcon: Icon(prefixIcon, color: DesignSystem.getTextSecondary(context)),
      filled: true,
      fillColor: DesignSystem.getBackgroundSecondary(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: DesignSystem.getPrimary(context), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  /// 构建标签输入
  Widget _buildTagInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: '添加标签（最多10个）',
                  hintStyle: TextStyle(color: DesignSystem.getTextTertiary(context)),
                  filled: true,
                  fillColor: DesignSystem.getBackgroundSecondary(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _tags.length < 10 ? _addTag : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.getPrimary(context),
                foregroundColor: DesignSystem.textInverse,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              child: const Text('添加'),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) => Chip(
              label: Text(tag),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => _removeTag(tag),
              backgroundColor: DesignSystem.getPrimary(context).withOpacity(0.1),
              side: BorderSide(color: DesignSystem.getPrimary(context).withOpacity(0.3)),
            )).toList(),
          ),
        ],
      ],
    );
  }

  /// 构建封面图选择器
  Widget _buildCoverImageSelector() {
    final poisWithPhotos = _editedSession.pois
        .asMap()
        .entries
        .where((e) => e.value.photoUrls.isNotEmpty)
        .toList();

    if (poisWithPhotos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: DesignSystem.getBackgroundSecondary(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            '没有可用的照片作为封面',
            style: DesignSystem.getBodyMedium(context)?.copyWith(
              color: DesignSystem.getTextSecondary(context),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // 默认选项
          _buildCoverOption(
            index: -1,
            imageUrl: null,
            label: '默认封面',
          ),
          ...poisWithPhotos.map((entry) => _buildCoverOption(
            index: entry.key,
            imageUrl: entry.value.photoUrls.first,
            label: entry.value.name ?? entry.value.type.displayName,
          )),
        ],
      ),
    );
  }

  /// 构建封面选项
  Widget _buildCoverOption({
    required int index,
    required String? imageUrl,
    required String label,
  }) {
    final isSelected = _selectedCoverPoiIndex == index;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedCoverPoiIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            color: DesignSystem.getBackgroundSecondary(context),
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: DesignSystem.getPrimary(context), width: 3)
                : null,
          ),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: imageUrl != null
                      ? Image.file(
                          File(imageUrl),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? DesignSystem.getPrimary(context)
                        : DesignSystem.getTextPrimary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: DesignSystem.getBackgroundTertiary(context),
      child: Center(
        child: Icon(
          Icons.image,
          color: DesignSystem.getTextTertiary(context),
        ),
      ),
    );
  }

  /// 构建POI列表
  Widget _buildPoiList() {
    if (_editedSession.pois.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: DesignSystem.getBackgroundSecondary(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            '没有标记点',
            style: DesignSystem.getBodyMedium(context)?.copyWith(
              color: DesignSystem.getTextSecondary(context),
            ),
          ),
        ),
      );
    }

    return Column(
      children: _editedSession.pois.asMap().entries.map((entry) {
        final index = entry.key;
        final poi = entry.value;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: DesignSystem.getBackgroundSecondary(context),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getPoiColor(poi.type).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getPoiIcon(poi.type),
                color: _getPoiColor(poi.type),
                size: 20,
              ),
            ),
            title: Text(
              poi.name ?? poi.type.displayName,
              style: DesignSystem.getBodyLarge(context)?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: poi.description != null
                ? Text(
                    poi.description!,
                    style: DesignSystem.getBodySmall(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (poi.photoUrls.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text('${poi.photoUrls.length}'),
                      avatar: const Icon(Icons.photo, size: 14),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                IconButton(
                  icon: Icon(Icons.edit, color: DesignSystem.getPrimary(context), size: 20),
                  onPressed: () => _editPoi(index),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: DesignSystem.getError(context), size: 20),
                  onPressed: () => _removePoi(index),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 构建统计信息
  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignSystem.getBackgroundSecondary(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '录制统计',
            style: DesignSystem.getTitleSmall(context, weight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('时长', _editedSession.formattedDuration, Icons.timer),
              _buildStatItem('距离', _editedSession.formattedDistance, Icons.straighten),
              _buildStatItem('爬升', '${_editedSession.elevationGain.toStringAsFixed(0)}m', Icons.trending_up),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('轨迹点', '${_editedSession.trackPoints.length}', Icons.gps_fixed),
              _buildStatItem('标记点', '${_editedSession.pois.length}', Icons.location_on),
              _buildStatItem('照片', '${_editedSession.photoCount}', Icons.photo),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: DesignSystem.getTextSecondary(context)),
        const SizedBox(height: 4),
        Text(
          value,
          style: DesignSystem.getTitleMedium(context, weight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: DesignSystem.getBodySmall(context),
        ),
      ],
    );
  }

  Color _getPoiColor(PoiType type) {
    switch (type) {
      case PoiType.start:
        return DesignSystem.success;
      case PoiType.end:
        return DesignSystem.error;
      case PoiType.danger:
        return DesignSystem.errorDark;
      case PoiType.viewpoint:
        return DesignSystem.info;
      case PoiType.restroom:
        return DesignSystem.infoDark;
      default:
        return DesignSystem.primary;
    }
  }

  IconData _getPoiIcon(PoiType type) {
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