// recordings_list_screen.dart
// 山径APP - 轨迹录制列表页面

import 'package:flutter/material.dart';
import '../models/recording_model.dart';
import '../services/recording_service.dart';
import 'recording_screen.dart';

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
    setState(() => _isLoading = true);
    
    final recordings = await _recordingService.getPendingSessions();
    
    setState(() {
      _recordings = recordings;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的轨迹'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecordings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recordings.isEmpty
              ? _buildEmptyState()
              : _buildRecordingsList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startNewRecording(),
        icon: const Icon(Icons.fiber_manual_record),
        label: const Text('开始录制'),
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
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '还没有录制轨迹',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方的按钮开始录制你的第一条路线',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _startNewRecording(),
            icon: const Icon(Icons.fiber_manual_record),
            label: const Text('开始录制'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewRecordingDetail(recording),
        borderRadius: BorderRadius.circular(12),
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(recording.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(Icons.timer, recording.formattedDuration),
                  const SizedBox(width: 12),
                  _buildInfoChip(Icons.straighten, recording.formattedDistance),
                  const SizedBox(width: 12),
                  _buildInfoChip(Icons.location_on, '${recording.pois.length}个标记'),
                ],
              ),
              if (!recording.isUploaded) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _uploadRecording(recording),
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('上传'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => _deleteRecording(recording),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(RecordingStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case RecordingStatus.recording:
        color = Colors.red;
        text = '录制中';
        break;
      case RecordingStatus.paused:
        color = Colors.orange;
        text = '已暂停';
        break;
      case RecordingStatus.finished:
        color = Colors.green;
        text = '已完成';
        break;
      default:
        color = Colors.grey;
        text = '未知';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  void _startNewRecording() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RecordingScreen(),
      ),
    );
  }

  void _viewRecordingDetail(RecordingSession recording) {
    // TODO: 实现录制详情页面
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(recording.trailName ?? '路线详情'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('时长: ${recording.formattedDuration}'),
            Text('距离: ${recording.formattedDistance}'),
            Text('轨迹点: ${recording.trackPoints.length}个'),
            Text('POI标记: ${recording.pois.length}个'),
            Text('海拔爬升: ${recording.elevationGain.toStringAsFixed(1)}米'),
            Text('海拔下降: ${recording.elevationLoss.toStringAsFixed(1)}米'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadRecording(RecordingSession recording) async {
    // TODO: 实现上传对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('上传轨迹'),
        content: const Text('上传功能需要在录制页面完成。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRecording(RecordingSession recording) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除录制'),
        content: const Text('确定要删除这条录制记录吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _recordingService.deleteSession(recording.id);
      if (success) {
        await _loadRecordings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已删除')),
          );
        }
      }
    }
  }
}
