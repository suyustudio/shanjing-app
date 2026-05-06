// recording_preparation_screen.dart
// 山径APP - 录制前准备页面

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/design_system.dart';
import '../models/recording_model.dart';

/// 录制前准备页面
class RecordingPreparationScreen extends StatefulWidget {
  const RecordingPreparationScreen({super.key});

  @override
  State<RecordingPreparationScreen> createState() => _RecordingPreparationScreenState();
}

class _RecordingPreparationScreenState extends State<RecordingPreparationScreen> {
  // 表单数据
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _descriptionController = TextEditingController();

  TrailType _selectedTrailType = TrailType.hiking;
  DifficultyLevel _selectedDifficulty = DifficultyLevel.casual;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// 开始录制
  Future<void> _startRecording() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();

    // 准备数据
    final preparationData = RecordingPreparationData(
      trailName: _nameController.text.trim(),
      trailType: _selectedTrailType,
      difficulty: _selectedDifficulty,
      city: _cityController.text.trim(),
      district: _districtController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    // 返回准备数据
    Navigator.of(context).pop(preparationData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.getBackground(context),
      appBar: AppBar(
        backgroundColor: DesignSystem.getBackground(context),
        foregroundColor: DesignSystem.getTextPrimary(context),
        elevation: 0,
        title: Text(
          '录制准备',
          style: DesignSystem.getTitleLarge(context),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close, color: DesignSystem.getTextPrimary(context)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(DesignSystem.spacingMedium),
          children: [
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
                if (value.trim().length < 2) {
                  return '名称至少需要2个字符';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 路线类型
            _buildSectionTitle('路线类型'),
            const SizedBox(height: 8),
            _buildTrailTypeSelector(),
            const SizedBox(height: 24),

            // 难度选择
            _buildSectionTitle('难度预估'),
            const SizedBox(height: 8),
            _buildDifficultySelector(),
            const SizedBox(height: 24),

            // 位置信息
            _buildSectionTitle('位置信息'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 1,
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
                  flex: 1,
                  child: TextFormField(
                    controller: _districtController,
                    decoration: _buildInputDecoration(
                      hintText: '区域/区县',
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

            // 描述（可选）
            _buildSectionTitle('路线描述（可选）'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              maxLength: 200,
              decoration: _buildInputDecoration(
                hintText: '简单描述一下这条路线...',
                prefixIcon: Icons.description,
              ),
            ),
            const SizedBox(height: 32),

            // 开始录制按钮
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _startRecording,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignSystem.getError(context),
                  foregroundColor: DesignSystem.textInverse,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fiber_manual_record),
                    SizedBox(width: 8),
                    Text(
                      '开始录制',
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: DesignSystem.getError(context), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  /// 构建路线类型选择器
  Widget _buildTrailTypeSelector() {
    return Row(
      children: TrailType.values.map((type) {
        final isSelected = _selectedTrailType == type;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => setState(() => _selectedTrailType = type),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? DesignSystem.getPrimary(context).withOpacity(0.1)
                      : DesignSystem.getBackgroundSecondary(context),
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: DesignSystem.getPrimary(context), width: 2)
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      _getTrailTypeIcon(type),
                      color: isSelected
                          ? DesignSystem.getPrimary(context)
                          : DesignSystem.getTextSecondary(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      type.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? DesignSystem.getPrimary(context)
                            : DesignSystem.getTextPrimary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 获取路线类型图标
  IconData _getTrailTypeIcon(TrailType type) {
    switch (type) {
      case TrailType.hiking:
        return Icons.hiking;
      case TrailType.mountaineering:
        return Icons.terrain;
      case TrailType.cycling:
        return Icons.pedal_bike;
    }
  }

  /// 构建难度选择器
  Widget _buildDifficultySelector() {
    return Column(
      children: DifficultyLevel.values.map((difficulty) {
        final isSelected = _selectedDifficulty == difficulty;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => setState(() => _selectedDifficulty = difficulty),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? difficulty.color.withOpacity(0.1)
                    : DesignSystem.getBackgroundSecondary(context),
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: difficulty.color, width: 2)
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: difficulty.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          difficulty.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: DesignSystem.getTextPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          difficulty.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: DesignSystem.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: difficulty.color,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

}