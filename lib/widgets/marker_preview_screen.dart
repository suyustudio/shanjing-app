import 'package:flutter/material.dart';
import '../constants/design_system.dart';
import 'map_markers.dart';

/// 地图标记图标预览页面
/// 
/// 用于设计审查和开发调试
/// 展示所有标记的不同尺寸和状态
class MarkerPreviewScreen extends StatelessWidget {
  const MarkerPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('地图标记图标预览'),
        backgroundColor: DesignSystem.getPrimary(context),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            _buildSectionTitle(context, '图标设计预览'),
            const SizedBox(height: 16),
            
            // 不同尺寸的预览
            _buildSizeComparison(context),
            const SizedBox(height: 24),
            
            // 状态对比
            _buildStateComparison(context),
            const SizedBox(height: 24),
            
            // 户外场景测试
            _buildOutdoorTest(context),
            const SizedBox(height: 24),
            
            // 设计规范
            _buildDesignSpecs(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: DesignSystem.getHeadlineSmall(context),
    );
  }

  /// 尺寸对比展示
  Widget _buildSizeComparison(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '尺寸规格',
              style: DesignSystem.getTitleMedium(context),
            ),
            const SizedBox(height: 16),
            _buildSizeRow(context, '起点标记', MarkerType.start),
            const Divider(height: 24),
            _buildSizeRow(context, '终点标记', MarkerType.end),
            const Divider(height: 24),
            _buildSizeRow(context, '停车场标记', MarkerType.parking),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeRow(BuildContext context, String label, MarkerType type) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: DesignSystem.getBodyMedium(context)),
        ),
        _buildSizePreview(context, type, CustomMarkers.sizeSmall, '36px\n@1x'),
        const SizedBox(width: 16),
        _buildSizePreview(context, type, CustomMarkers.sizeMedium, '48px\n@2x'),
        const SizedBox(width: 16),
        _buildSizePreview(context, type, CustomMarkers.sizeLarge, '64px\n@3x'),
      ],
    );
  }

  Widget _buildSizePreview(
    BuildContext context,
    MarkerType type,
    double size,
    String label,
  ) {
    return Column(
      children: [
        CustomMarkers.buildMarkerPreview(type: type, size: size),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  /// 状态对比展示
  Widget _buildStateComparison(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '状态展示',
              style: DesignSystem.getTitleMedium(context),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatePreview(context, '正常', MarkerType.start, false),
                _buildStatePreview(context, '选中', MarkerType.start, true),
                _buildStatePreview(context, '正常', MarkerType.end, false),
                _buildStatePreview(context, '选中', MarkerType.end, true),
                _buildStatePreview(context, '正常', MarkerType.parking, false),
                _buildStatePreview(context, '选中', MarkerType.parking, true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatePreview(
    BuildContext context,
    String label,
    MarkerType type,
    bool selected,
  ) {
    return Column(
      children: [
        CustomMarkers.buildMarkerPreview(
          type: type,
          size: CustomMarkers.sizeMedium,
          selected: selected,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: DesignSystem.getBodySmall(context),
        ),
      ],
    );
  }

  /// 户外场景测试
  Widget _buildOutdoorTest(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '户外场景测试',
              style: DesignSystem.getTitleMedium(context),
            ),
            const SizedBox(height: 16),
            
            // 模拟地图背景
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://picsum.photos/seed/map/400/200',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // 模拟阳光直射效果
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // 标记点
                  Positioned(
                    left: 50,
                    top: 80,
                    child: CustomMarkers.buildMarkerPreview(
                      type: MarkerType.start,
                      size: CustomMarkers.sizeMedium,
                    ),
                  ),
                  Positioned(
                    left: 200,
                    top: 60,
                    child: CustomMarkers.buildMarkerPreview(
                      type: MarkerType.end,
                      size: CustomMarkers.sizeMedium,
                    ),
                  ),
                  Positioned(
                    left: 130,
                    top: 120,
                    child: CustomMarkers.buildMarkerPreview(
                      type: MarkerType.parking,
                      size: CustomMarkers.sizeMedium,
                    ),
                  ),
                  // 标签
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '阳光直射模拟',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 设计规范展示
  Widget _buildDesignSpecs(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '设计规范',
              style: DesignSystem.getTitleMedium(context),
            ),
            const SizedBox(height: 16),
            _buildSpecRow('尺寸基准', '48x48px (@2x)'),
            _buildSpecRow('放大倍数', '比系统默认大 1.5-2 倍'),
            _buildSpecRow('描边宽度', '2px'),
            _buildSpecRow('阴影', '0 2px 4px rgba(0,0,0,0.3)'),
            _buildSpecRow('起点颜色', '#4CAF50 (绿色系)'),
            _buildSpecRow('终点颜色', '#FF5722 (橙红色系)'),
            _buildSpecRow('停车场颜色', '#2196F3 (蓝色系)'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '提示：户外使用时，图标会自动提升对比度，'
                      '确保阳光直射下依然清晰可见。',
                      style: DesignSystem.getBodySmall(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
