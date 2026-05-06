// recordings_list_screen.dart
// 山径APP - 轨迹录制列表页面（P0修复版）

import 'package:flutter/material.dart';
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

class _RecordingsListScreenState extends State<RecordingsListScreen> {
  final RecordingService _recordingService = RecordingService();
  List<RecordingSession> _recordings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecordings();
  }

  Future<void> _loadRecordings() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final recordings = await _recordingService.getAllSessions();

    if (!mounted) return;
    setState(() {
      _recordings = recordings;
      _isLoading = false;
    });
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
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: DesignSystem.getPrimary(context)))
          : _recordings.isEmpty
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
            '还没有录制过路线',
            style: DesignSystem.getTitleMedium(context)?.copyWith(
              color: DesignSystem.getTextSecondary(context),
            ),
          ),
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
      ),
    );
  }

  Widget _buildRecordingsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recordings.length,
      itemBuilder: (context, index) {
        final recording = _recordings[index];
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
              const Divider(height: 24),
              _buildActionButtons(recording),
            ],
          ),
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
              child: OutlinedButton.icon(
                onPressed: () => _exportRecording(recording),
                icon: Icon(Icons.download, size: 18, color: DesignSystem.getSuccess(context)),
                label: Text('导出数据', style: TextStyle(color: DesignSystem.getSuccess(context))),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: DesignSystem.getSuccess(context)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _startNewRecording() async {
    if (!mounted) return;

    // 显示准备页面
    final preparationData = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RecordingPreparationScreen(),
      ),
    );

    if (preparationData != null && preparationData is RecordingPreparationData) {
      // 进入录制页面 - 传递准备数据
      final session = await Navigator.of(context).push<RecordingSession>(
        MaterialPageRoute(
          builder: (context) => RecordingScreen(
            preparationData: preparationData,
          ),
        ),
      );

      // 录制结束后跳转到编辑页面
      if (session != null && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RecordingEditScreen(session: session),
          ),
        );
      }

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
          '选择导出格式：\n• GPX：通用GPS轨迹格式，可在大多数地图软件中打开\n• JSON：原始数据格式\n• 轨迹JSON：山径APP轨迹数据格式，可直接用于APP',
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
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop('trail'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.getInfo(context),
              foregroundColor: DesignSystem.textInverse,
            ),
            child: const Text('轨迹'),
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
      } else if (exportFormat == 'trail') {
        filePath = await ExportService.exportToTrailJson(recording);
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
                  filePath!,
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

  void _viewRecordingDetail(RecordingSession recording) {
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
              _buildDetailItem('时长', recording.formattedDuration),
              _buildDetailItem('距离', recording.formattedDistance),
              _buildDetailItem('轨迹点', '${recording.trackPoints.length}个'),
              _buildDetailItem('标记点', '${recording.pois.length}个'),
              _buildDetailItem('海拔爬升', '${recording.elevationGain.toStringAsFixed(1)}米'),
              _buildDetailItem('海拔下降', '${recording.elevationLoss.toStringAsFixed(1)}米'),
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

}