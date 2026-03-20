// recording_preparation_screen.dart
// 山径APP - 录制前准备页面

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/design_system.dart';
import '../models/recording_model.dart';
import '../services/permission_service.dart';

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
  
  // 检测状态
  bool _isGpsReady = false;
  bool _isBatteryReady = false;
  bool _isStorageReady = false;
  bool _isChecking = true;
  
  // 电池和存储信息
  int _batteryLevel = 0;
  int _availableStorageGB = 0;

  @override
  void initState() {
    super.initState();
    _checkPrerequisites();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// 检查前提条件（GPS、电量、存储）
  Future<void> _checkPrerequisites() async {
    setState(() => _isChecking = true);

    // 检查GPS
    final gpsStatus = await PermissionService.checkLocationStatus();
    
    // 检查电池（模拟）
    final batteryLevel = await _getBatteryLevel();
    final isBatteryEnough = batteryLevel >= 20;
    
    // 检查存储（模拟）
    final availableStorage = await _getAvailableStorage();
    final isStorageEnough = availableStorage >= 1; // 至少1GB

    if (mounted) {
      setState(() {
        _isGpsReady = gpsStatus.isEnabled;
        _batteryLevel = batteryLevel;
        _isBatteryReady = isBatteryEnough;
        _availableStorageGB = availableStorage;
        _isStorageReady = isStorageEnough;
        _isChecking = false;
      });
    }
  }

  /// 获取电池电量（模拟）
  Future<int> _getBatteryLevel() async {
    // 实际实现应该使用 battery_plus 包
    // 这里返回模拟值
    return 65;
  }

  /// 获取可用存储空间（模拟）
  Future<int> _getAvailableStorage() async {
    // 实际实现应该使用 path_provider 和文件系统
    // 这里返回模拟值
    return 8;
  }

  /// 开始录制
  Future<void> _startRecording() async {
    if (!_formKey.currentState!.validate()) return;

    // 检查权限
    final permissionsGranted = await PermissionService.requestRecordingPermissions(context);
    if (!permissionsGranted) return;

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
    final allReady = _isGpsReady && _isBatteryReady && _isStorageReady;

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
            const SizedBox(height: 24),

            // 设备检测
            _buildSectionTitle('设备检测'),
            const SizedBox(height: 8),
            _buildPrerequisiteChecks(),
            const SizedBox(height: 32),

            // 开始录制按钮
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: allReady ? _startRecording : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignSystem.getError(context),
                  foregroundColor: DesignSystem.textInverse,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.fiber_manual_record),
                    const SizedBox(width: 8),
                    Text(
                      allReady ? '开始录制' : '请解决上述问题',
                      style: const TextStyle(
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

  /// 构建前提条件检查项
  Widget _buildPrerequisiteChecks() {
    if (_isChecking) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: DesignSystem.getBackgroundSecondary(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: DesignSystem.getPrimary(context)),
              const SizedBox(height: 16),
              Text(
                '正在检测设备...',
                style: TextStyle(color: DesignSystem.getTextSecondary(context)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildCheckItem(
          icon: Icons.gps_fixed,
          title: 'GPS定位',
          subtitle: _isGpsReady ? '信号良好' : '请开启定位服务',
          isReady: _isGpsReady,
          onTap: _isGpsReady ? null : () => PermissionService.openLocationSettings(),
        ),
        const SizedBox(height: 8),
        _buildCheckItem(
          icon: Icons.battery_full,
          title: '电池电量',
          subtitle: '$_batteryLevel% ${_isBatteryReady ? '' : '(建议20%以上)'}',
          isReady: _isBatteryReady,
        ),
        const SizedBox(height: 8),
        _buildCheckItem(
          icon: Icons.storage,
          title: '存储空间',
          subtitle: '可用 $_availableStorageGB GB ${_isStorageReady ? '' : '(建议1GB以上)'}',
          isReady: _isStorageReady,
        ),
      ],
    );
  }

  /// 构建检查项
  Widget _buildCheckItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isReady,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isReady
              ? DesignSystem.getSuccess(context).withOpacity(0.1)
              : DesignSystem.getError(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isReady ? DesignSystem.getSuccess(context) : DesignSystem.getError(context),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isReady
                    ? DesignSystem.getSuccess(context).withOpacity(0.2)
                    : DesignSystem.getError(context).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isReady ? DesignSystem.getSuccess(context) : DesignSystem.getError(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: DesignSystem.getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isReady
                          ? DesignSystem.getSuccess(context)
                          : DesignSystem.getError(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isReady ? Icons.check_circle : Icons.error,
              color: isReady ? DesignSystem.getSuccess(context) : DesignSystem.getError(context),
            ),
          ],
        ),
      ),
    );
  }
}