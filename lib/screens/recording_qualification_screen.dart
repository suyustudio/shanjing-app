// recording_qualification_screen.dart
// 山径APP - 采集资格申请页面

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/design_system.dart';
import '../models/recording_model.dart';

/// 采集资格申请页面
class RecordingQualificationScreen extends StatefulWidget {
  const RecordingQualificationScreen({super.key});

  @override
  State<RecordingQualificationScreen> createState() => _RecordingQualificationScreenState();
}

class _RecordingQualificationScreenState extends State<RecordingQualificationScreen> {
  // 当前资格状态（模拟）
  CollectorQualificationStatus _status = CollectorQualificationStatus.notApplied;
  
  // 申请表单
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _experienceController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  /// 提交申请
  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // 模拟提交
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _status = CollectorQualificationStatus.pending;
        _isSubmitting = false;
      });

      HapticFeedback.mediumImpact();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('申请已提交，请等待审核'),
          backgroundColor: DesignSystem.getSuccess(context),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.getBackground(context),
      appBar: AppBar(
        backgroundColor: DesignSystem.getBackground(context),
        foregroundColor: DesignSystem.getTextPrimary(context),
        elevation: 0,
        title: Text('采集资格', style: DesignSystem.getTitleLarge(context)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_status) {
      case CollectorQualificationStatus.notApplied:
        return _buildApplicationForm();
      case CollectorQualificationStatus.pending:
        return _buildPendingView();
      case CollectorQualificationStatus.approved:
        return _buildApprovedView();
      case CollectorQualificationStatus.rejected:
        return _buildRejectedView();
    }
  }

  /// 申请表单
  Widget _buildApplicationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignSystem.spacingMedium),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 说明卡片
            _buildInfoCard(
              icon: Icons.info_outline,
              title: '成为路线采集者',
              content: '提交申请并通过审核后，你将获得使用GPS录制路线的权限。采集的路线经审核后会发布到发现页，供其他用户参考。',
              color: DesignSystem.getInfo(context),
            ),
            const SizedBox(height: 24),

            // 申请原因
            _buildSectionTitle('申请原因'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              decoration: _buildInputDecoration(
                hintText: '请说明你为什么想要成为路线采集者...',
              ),
              validator: (value) {
                if (value == null || value.trim().length < 10) {
                  return '请至少输入10个字符';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 户外经验
            _buildSectionTitle('户外经验'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _experienceController,
              maxLines: 3,
              decoration: _buildInputDecoration(
                hintText: '请简述你的户外运动经验，如徒步、登山等...',
              ),
              validator: (value) {
                if (value == null || value.trim().length < 10) {
                  return '请至少输入10个字符';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 要求说明
            _buildRequirementsList(),
            const SizedBox(height: 32),

            // 提交按钮
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignSystem.getPrimary(context),
                  foregroundColor: DesignSystem.textInverse,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(DesignSystem.textInverse),
                        ),
                      )
                    : const Text(
                        '提交申请',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// 等待审核视图
  Widget _buildPendingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: DesignSystem.getWarning(context).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hourglass_empty,
                size: 60,
                color: DesignSystem.getWarning(context),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '审核中',
              style: DesignSystem.getHeadlineMedium(context)?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '你的申请正在审核中，\n我们会在3个工作日内完成审核。',
              style: DesignSystem.getBodyLarge(context)?.copyWith(
                color: DesignSystem.getTextSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildInfoCard(
              icon: Icons.access_time,
              title: '预计审核时间',
              content: '1-3个工作日',
              color: DesignSystem.getInfo(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 已通过视图
  Widget _buildApprovedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: DesignSystem.getSuccess(context).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified_user,
                size: 60,
                color: DesignSystem.getSuccess(context),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '审核通过',
              style: DesignSystem.getHeadlineMedium(context)?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '恭喜！你已经获得路线采集资格，\n现在可以开始录制路线了。',
              style: DesignSystem.getBodyLarge(context)?.copyWith(
                color: DesignSystem.getTextSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignSystem.getPrimary(context),
                  foregroundColor: DesignSystem.textInverse,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam),
                    SizedBox(width: 8),
                    Text(
                      '去录制路线',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 已拒绝视图
  Widget _buildRejectedView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignSystem.spacingMedium),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: DesignSystem.getError(context).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.block,
              size: 60,
              color: DesignSystem.getError(context),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '申请未通过',
            style: DesignSystem.getHeadlineMedium(context)?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '很抱歉，你的申请未通过审核。',
            style: DesignSystem.getBodyLarge(context)?.copyWith(
              color: DesignSystem.getTextSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // 拒绝原因
          _buildInfoCard(
            icon: Icons.info_outline,
            title: '拒绝原因',
            content: '申请材料不够详细，请补充更多户外运动经验后再试。',
            color: DesignSystem.getError(context),
          ),
          const SizedBox(height: 32),

          // 重新申请按钮
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _status = CollectorQualificationStatus.notApplied;
                  _reasonController.clear();
                  _experienceController.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.getPrimary(context),
                foregroundColor: DesignSystem.textInverse,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '重新申请',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
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
  InputDecoration _buildInputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: DesignSystem.getTextTertiary(context)),
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
      contentPadding: const EdgeInsets.all(16),
    );
  }

  /// 构建信息卡片
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
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
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: DesignSystem.getTextPrimary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建要求列表
  Widget _buildRequirementsList() {
    final requirements = [
      '拥有一定的户外运动经验',
      '熟悉GPS设备和地图使用',
      '能够清晰描述路线特点',
      '愿意分享优质路线给社区',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('采集者要求'),
        const SizedBox(height: 12),
        ...requirements.map((req) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 20,
                color: DesignSystem.getSuccess(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  req,
                  style: DesignSystem.getBodyMedium(context),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}