// recordings_list_screen.dart
// 山径APP - 轨迹录制列表页面（P0修复版）

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/design_system.dart';
import '../models/recording_model.dart';
import '../services/recording_service.dart';
import '../services/export_service.dart';
import 'recording_screen.dart';
import 'recording_edit_screen.dart';
import 'recording_preparation_screen.dart';

/// 录制列表页面
class RecordingsListScreen extends StatefulWidget {
  const RecordingsListScreen({super.key});

  @override
  State<RecordingsListScreen> createState() => _RecordingsListScreenState();
}

class _RecordingsListScreenState extends State<RecordingsListScreen>
    with SingleTickerProviderStateMixin {
  final RecordingService _recordingService = RecordingService();
  List<RecordingSession> _recordings = [];
  bool _isLoading = true;
  
  late TabController _tabController;
  SubmissionStatus _selectedFilter = SubmissionStatus.draft;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadRecordings();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedFilter = SubmissionStatus.draft;
            break;
          case 1:
            _selectedFilter = SubmissionStatus.reviewing;
            break;
          case 2:
            _selectedFilter = SubmissionStatus.approved;
            break;
          case 3:
            _selectedFilter = SubmissionStatus.rejected;
            break;
        }
      });
    }
  }

  Future<void> _loadRecordings() async {
    setState(() => _isLoading = true);
    
    final recordings = await _recordingService.getAllSessions();
    
    setState(() {
      _recordings = recordings;
      _isLoading = false;
    });
  }

  List<RecordingSession> get _filteredRecordings {
    return _recordings.where((r) => r.submissionStatus == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.getBackground(context),
      appBar: AppBar(
        backgroundColor: DesignSystem.getBackground(context),
        foregroundColor: DesignSystem.getTextPrimary(context),
        elevation: 0,
        title: Text('我的采集', style: DesignSystem.getTitleLarge(context)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: DesignSystem.getPrimary(context)),
            onPressed: _loadRecordings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: DesignSystem.getPrimary(context),
          unselectedLabelColor: DesignSystem.getTextSecondary(context),
          indicatorColor: DesignSystem.getPrimary(context),
          tabs: [
            _buildTab('草稿', SubmissionStatus.draft),
            _buildTab('审核中', SubmissionStatus.reviewing),
            _buildTab('已通过', SubmissionStatus.approved),
            _buildTab('已拒绝', SubmissionStatus.rejected),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: DesignSystem.getPrimary(context)))
          : _filteredRecordings.isEmpty
              ? _buildEmptyState()
              : _buildRecordingsList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startNewRecording(),
        icon: const Icon(Icons.add),
        label: const Text('新建采集'),
        backgroundColor: DesignSystem.getPrimary(context),
      ),
    );
  }

  Widget _buildTab(String label, SubmissionStatus status) {
    final count = _recordings.where((r) => r.submissionStatus == status).length;
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: DesignSystem.getPrimary(context).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: DesignSystem.getPrimary(context),
                ),
              ),
            ),
          ],
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
            Icons.map_outlined,
            size: 80,
            color: DesignSystem.getTextTertiary(context).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _getEmptyStateMessage(),
            style: DesignSystem.getTitleMedium(context)?.copyWith(
              color: DesignSystem.getTextSecondary(context),
            ),
          ),
          if (_selectedFilter == SubmissionStatus.draft) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _startNewRecording(),
              icon: const Icon(Icons.add),
              label: const Text('开始采集'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.getPrimary(context),
                foregroundColor: DesignSystem.textInverse,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getEmptyStateMessage() {
    switch (_selectedFilter) {
      case SubmissionStatus.draft:
        return '还没有草稿';
      case SubmissionStatus.reviewing:
        return '没有审核中的路线';
      case SubmissionStatus.approved:
        return '没有已通过的路线';
      case SubmissionStatus.rejected:
        return '没有已拒绝的路线';
      default:
        return '暂无数据';
    }
  }

  Widget _buildRecordingsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredRecordings.length,
      itemBuilder: (context, index) {
        final recording = _filteredRecordings[index];
        return _buildRecordingCard(recording);
      },
    );
  }

  Widget _buildRecordingCard(RecordingSession recording) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: DesignSystem.getSurface(context),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _viewRecordingDetail(recording),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      recording.trailName ?? '未命名路线',
                      style: DesignSystem.getTitleMedium(context, weight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(recording.submissionStatus),
                ],
              ),
              if (recording.city != null || recording.district != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${recording.city ?? ''} ${recording.district ?? ''}',
                  style: DesignSystem.getBodySmall(context),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(Icons.timer, recording.formattedDuration),
                  const SizedBox(width: 16),
                  _buildInfoChip(Icons.straighten, recording.formattedDistance),
                  const SizedBox(width: 16),
                  _buildInfoChip(Icons.location_on, '${recording.pois.length}标记'),
                ],
              ),
              if (recording.reviewComment != null && 
                  recording.submissionStatus == SubmissionStatus.rejected) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DesignSystem.getError(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, 
                        size: 16, 
                        color: DesignSystem.getError(context)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '拒绝原因: ${recording.reviewComment}',
                          style: TextStyle(
                            fontSize: 13,
                            color: DesignSystem.getError(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Divider(height: 24),
              _buildActionButtons(recording),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(SubmissionStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case SubmissionStatus.draft:
        color = DesignSystem.getTextSecondary(context);
        text = '草稿';
        break;
      case SubmissionStatus.submitted:
      case SubmissionStatus.reviewing:
        color = DesignSystem.getWarning(context);
        text = '审核中';
        break;
      case SubmissionStatus.approved:
        color = DesignSystem.getSuccess(context);
        text = '已通过';
        break;
      case SubmissionStatus.rejected:
        color = DesignSystem.getError(context);
        text = '已拒绝';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: DesignSystem.getTextSecondary(context)),
        const SizedBox(width: 4),
        Text(
          text,
          style: DesignSystem.getBodySmall(context),
        ),
      ],
    );
  }

  Widget _buildActionButtons(RecordingSession recording) {
    switch (recording.submissionStatus) {
      case SubmissionStatus.draft:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editRecording(recording),
                    icon: Icon(Icons.edit, size: 18, color: DesignSystem.getPrimary(context)),
                    label: Text('编辑', style: TextStyle(color: DesignSystem.getPrimary(context))),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: DesignSystem.getBorder(context)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _submitForReview(recording),
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('提交审核'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.getPrimary(context),
                      foregroundColor: DesignSystem.textInverse,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _exportRecording(recording),
              icon: Icon(Icons.download, size: 18, color: DesignSystem.getSuccess(context)),
              label: Text('导出数据', style: TextStyle(color: DesignSystem.getSuccess(context))),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: DesignSystem.getSuccess(context)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        );
      
      case SubmissionStatus.submitted:
      case SubmissionStatus.reviewing:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewRecordingDetail(recording),
                    icon: Icon(Icons.visibility, size: 18, color: DesignSystem.getTextSecondary(context)),
                    label: Text('查看详情', style: TextStyle(color: DesignSystem.getTextSecondary(context))),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: DesignSystem.getBorder(context)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _exportRecording(recording),
              icon: Icon(Icons.download, size: 18, color: DesignSystem.getSuccess(context)),
              label: Text('导出数据', style: TextStyle(color: DesignSystem.getSuccess(context))),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: DesignSystem.getSuccess(context)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        );
      
      case SubmissionStatus.approved:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewRecordingDetail(recording),
                    icon: Icon(Icons.visibility, size: 18, color: DesignSystem.getSuccess(context)),
                    label: Text('查看详情', style: TextStyle(color: DesignSystem.getSuccess(context))),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: DesignSystem.getSuccess(context)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _exportRecording(recording),
              icon: Icon(Icons.download, size: 18, color: DesignSystem.getSuccess(context)),
              label: Text('导出数据', style: TextStyle(color: DesignSystem.getSuccess(context))),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: DesignSystem.getSuccess(context)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        );
      
      case SubmissionStatus.rejected:
        final canResubmit = recording.submissionCount < 3;
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewRecordingDetail(recording),
                    icon: Icon(Icons.visibility, size: 18, color: DesignSystem.getTextSecondary(context)),
                    label: Text('查看详情', style: TextStyle(color: DesignSystem.getTextSecondary(context))),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: DesignSystem.getBorder(context)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                if (canResubmit) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _editRecording(recording),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text('重新编辑(${3 - recording.submissionCount}次)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.getWarning(context),
                        foregroundColor: DesignSystem.textInverse,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _exportRecording(recording),
              icon: Icon(Icons.download, size: 18, color: DesignSystem.getSuccess(context)),
              label: Text('导出数据', style: TextStyle(color: DesignSystem.getSuccess(context))),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: DesignSystem.getSuccess(context)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        );
    }
  }

  Future<void> _startNewRecording() async {
    // 显示准备页面
    final preparationData = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RecordingPreparationScreen(),
      ),
    );

    if (preparationData != null && preparationData is RecordingPreparationData) {
      // 进入录制页面
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const RecordingScreen(),
        ),
      );

      // 刷新列表
      _loadRecordings();
    }
  }

  Future<void> _editRecording(RecordingSession recording) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecordingEditScreen(session: recording),
      ),
    );

    if (result != null && result is RecordingSession) {
      // 更新本地存储
      await _recordingService.updateSession(result);
      _loadRecordings();
    }
  }

  /// 导出录制数据
  Future<void> _exportRecording(RecordingSession recording) async {
    // 显示导出格式选择
    final exportFormat = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignSystem.getSurface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('导出格式', style: DesignSystem.getTitleLarge(context)),
        content: Text(
          '选择导出格式：\n• GPX：通用GPS轨迹格式，可在大多数地图软件中打开\n• JSON：原始数据格式，包含完整录制信息',
          style: DesignSystem.getBodyMedium(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop('gpx'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.getPrimary(context),
              foregroundColor: DesignSystem.textInverse,
            ),
            child: const Text('GPX'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop('json'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.getSurface(context),
              foregroundColor: DesignSystem.getPrimary(context),
            ),
            child: const Text('JSON'),
          ),
        ],
      ),
    );

    if (exportFormat == null) return;

    // 显示导出进度
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)),
            const SizedBox(width: 12),
            Text('正在导出${exportFormat.toUpperCase()}...'),
          ],
        ),
        duration: const Duration(seconds: 30),
      ),
    );

    try {
      String? filePath;
      if (exportFormat == 'gpx') {
        filePath = await ExportService.exportToGpx(recording);
      } else {
        filePath = await ExportService.exportToJson(recording);
      }

      // 清除进度提示
      ScaffoldMessenger.of(context).clearSnackBars();

      if (filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('导出失败'),
            backgroundColor: DesignSystem.getError(context),
          ),
        );
        return;
      }

      // 显示导出成功消息
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: DesignSystem.getSurface(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('导出成功', style: DesignSystem.getTitleLarge(context)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '文件已保存到：',
                style: DesignSystem.getBodyMedium(context),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DesignSystem.getBackground(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  filePath,
                  style: TextStyle(
                    fontSize: 12,
                    color: DesignSystem.getTextPrimary(context),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '文件位置：\n• 主目录：应用私有存储/recordings_export/\n• 备份目录：手机Download/（如权限允许）',
                style: TextStyle(
                  fontSize: 12,
                  color: DesignSystem.getTextSecondary(context),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('导出失败: $e'),
          backgroundColor: DesignSystem.getError(context),
        ),
      );
    }
  }

  Future<void> _submitForReview(RecordingSession recording) async {
    if (recording.submissionCount >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('提交次数已达上限(3次)'),
          backgroundColor: DesignSystem.getError(context),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignSystem.getSurface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('提交审核', style: DesignSystem.getTitleLarge(context)),
        content: Text(
          '提交后路线将进入审核流程，审核通过后会正式发布。\n\n剩余提交次数: ${3 - recording.submissionCount - 1}次',
          style: DesignSystem.getBodyMedium(context),
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

    if (confirmed == true) {
      final updated = recording.copyWith(
        submissionStatus: SubmissionStatus.submitted,
        submissionCount: recording.submissionCount + 1,
        updatedAt: DateTime.now(),
      );
      
      await _recordingService.updateSession(updated);
      await _recordingService.submitForReview(updated);
      
      _loadRecordings();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('已提交审核'),
          backgroundColor: DesignSystem.getSuccess(context),
        ),
      );
    }
  }

  void _viewRecordingDetail(RecordingSession recording) {
    // TODO: 实现详情页面
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: DesignSystem.getSurface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DesignSystem.getDivider(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                recording.trailName ?? '未命名路线',
                style: DesignSystem.getHeadlineSmall(context)?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailItem('状态', _getStatusText(recording.submissionStatus)),
              _buildDetailItem('时长', recording.formattedDuration),
              _buildDetailItem('距离', recording.formattedDistance),
              _buildDetailItem('轨迹点', '${recording.trackPoints.length}个'),
              _buildDetailItem('标记点', '${recording.pois.length}个'),
              _buildDetailItem('海拔爬升', '${recording.elevationGain.toStringAsFixed(1)}米'),
              _buildDetailItem('海拔下降', '${recording.elevationLoss.toStringAsFixed(1)}米'),
              _buildDetailItem('提交次数', '${recording.submissionCount}/3'),
              if (recording.reviewComment != null)
                _buildDetailItem('审核备注', recording.reviewComment!),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.getPrimary(context),
                    foregroundColor: DesignSystem.textInverse,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('关闭'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: DesignSystem.getBodyMedium(context)),
          Text(value, style: DesignSystem.getBodyMedium(context)?.copyWith(
            fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }

  String _getStatusText(SubmissionStatus status) {
    switch (status) {
      case SubmissionStatus.draft:
        return '草稿';
      case SubmissionStatus.submitted:
        return '已提交';
      case SubmissionStatus.reviewing:
        return '审核中';
      case SubmissionStatus.approved:
        return '已通过';
      case SubmissionStatus.rejected:
        return '已拒绝';
    }
  }
}