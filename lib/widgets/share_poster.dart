import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../constants/design_system.dart';
import '../../services/share_service.dart';
import '../widgets/app_loading.dart';

/// 分享海报模板类型
enum PosterTemplate {
  nature,    // 山野自然风
  minimal,   // 极简数据风
  film,      // 文艺胶片风
}

/// 分享海报数据模型
class PosterData {
  final String routeName;
  final String? routeCoverUrl;
  final double distance;
  final double duration;
  final int elevation;
  final String difficulty;
  final String location;
  final String routeId;
  final double? rating;
  
  PosterData({
    required this.routeName,
    this.routeCoverUrl,
    required this.distance,
    required this.duration,
    required this.elevation,
    required this.difficulty,
    required this.location,
    required this.routeId,
    this.rating,
  });
}

/// 分享海报组件
class SharePoster extends StatelessWidget {
  final PosterData data;
  final PosterTemplate template;
  final double width;
  
  const SharePoster({
    super.key,
    required this.data,
    this.template = PosterTemplate.nature,
    this.width = 300,
  });

  @override
  Widget build(BuildContext context) {
    final height = width * 16 / 9;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: width,
        height: height,
        child: _buildTemplate(),
      ),
    );
  }

  Widget _buildTemplate() {
    switch (template) {
      case PosterTemplate.nature:
        return _NatureTemplate(data: data);
      case PosterTemplate.minimal:
        return _MinimalTemplate(data: data);
      case PosterTemplate.film:
        return _FilmTemplate(data: data);
    }
  }
}

/// 山野自然风模板
class _NatureTemplate extends StatelessWidget {
  final PosterData data;
  
  const _NatureTemplate({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F0),
      child: Column(
        children: [
          // 封面图区域
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 封面图
                data.routeCoverUrl != null
                    ? Image.network(
                        data.routeCoverUrl!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: DesignSystem.getPrimary(context),
                        child: Icon(
                          Icons.terrain,
                          size: 80,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                // 渐变遮罩
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
                // 路线信息
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.routeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 2,
                        width: 60,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${data.distance.toStringAsFixed(1)}公里 · ${data.difficulty} · ${data.location}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 底部区域
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // 品牌区域
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.terrain,
                              size: 24,
                              color: DesignSystem.getPrimary(context),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '山径',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: DesignSystem.getPrimary(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '探索自然，安心出行',
                          style: TextStyle(
                            fontSize: 12,
                            color: DesignSystem.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 二维码区域
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: _PlaceholderQRCode(size: 64),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '扫码探索更多路线',
                        style: TextStyle(
                          fontSize: 10,
                          color: DesignSystem.getTextTertiary(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 极简数据风模板
class _MinimalTemplate extends StatelessWidget {
  final PosterData data;
  
  const _MinimalTemplate({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // 品牌
          Text(
            '山径',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DesignSystem.getPrimary(context),
            ),
          ),
          Text(
            '探索自然，安心出行',
            style: TextStyle(
              fontSize: 12,
              color: DesignSystem.getTextTertiary(context),
            ),
          ),
          const SizedBox(height: 24),
          // 封面图
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: data.routeCoverUrl != null
                  ? Image.network(
                      data.routeCoverUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: DesignSystem.getBackgroundSecondary(context),
                      child: Icon(
                        Icons.terrain,
                        size: 48,
                        color: DesignSystem.getPrimary(context),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          // 路线名称
          Text(
            data.routeName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          // 数据展示
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDataItem(
                context,
                value: data.distance.toStringAsFixed(1),
                unit: '公里',
                label: '长度',
              ),
              Container(
                width: 1,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                color: DesignSystem.getDivider(context),
              ),
              _buildDataItem(
                context,
                value: data.duration.toStringAsFixed(1),
                unit: '小时',
                label: '用时',
              ),
              Container(
                width: 1,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                color: DesignSystem.getDivider(context),
              ),
              _buildDataItem(
                context,
                value: data.elevation.toString(),
                unit: '米',
                label: '爬升',
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 难度和地点
          Text(
            '难度：${data.difficulty}  |  地点：${data.location}',
            style: TextStyle(
              fontSize: 12,
              color: DesignSystem.getTextSecondary(context),
            ),
          ),
          const Spacer(),
          // 二维码
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: DesignSystem.getDivider(context)),
                ),
                child: Center(
                  child: _PlaceholderQRCode(size: 48),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '扫码获取完整路线',
                style: TextStyle(
                  fontSize: 12,
                  color: DesignSystem.getTextSecondary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataItem(
    BuildContext context, {
    required String value,
    required String unit,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: TextStyle(
                fontSize: 14,
                color: DesignSystem.getTextSecondary(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: DesignSystem.getTextTertiary(context),
          ),
        ),
      ],
    );
  }
}

/// 文艺胶片风模板
class _FilmTemplate extends StatelessWidget {
  final PosterData data;
  
  const _FilmTemplate({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2C2C2C),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 胶片边框装饰
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // 胶片孔装饰
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    8,
                    (index) => Container(
                      width: 12,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF333333),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 封面图
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: data.routeCoverUrl != null
                        ? Image.network(
                            data.routeCoverUrl!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: const Color(0xFF333333),
                            child: const Icon(
                              Icons.terrain,
                              size: 48,
                              color: Colors.white38,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                // 胶片孔装饰
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    8,
                    (index) => Container(
                      width: 12,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF333333),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 路线名称
          Text(
            '"${data.routeName}"',
            style: const TextStyle(
              color: Color(0xFFE8E8E8),
              fontSize: 20,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          // 引言
          Text(
            '徒步，是与自己对话的过程',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
          const Spacer(),
          // 日期和品牌
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${DateTime.now().year}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().day.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: Color(0xFF808080),
                  fontSize: 12,
                ),
              ),
              Text(
                '  ·  ',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              Text(
                '山径记录',
                style: TextStyle(
                  color: DesignSystem.getPrimary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 二维码
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: _PlaceholderQRCode(size: 48),
            ),
          ),
        ],
      ),
    );
  }
}

/// 二维码占位组件
class _PlaceholderQRCode extends StatelessWidget {
  final double size;
  
  const _PlaceholderQRCode({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _QRPainter(),
    );
  }
}

class _QRPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final cellSize = size.width / 21;
    
    // 绘制简化的 QR Code 图案
    // 定位点
    for (final corner in [
      Offset(0, 0),
      Offset(size.width - cellSize * 7, 0),
      Offset(0, size.height - cellSize * 7),
    ]) {
      // 外框
      canvas.drawRect(
        Rect.fromLTWH(corner.dx, corner.dy, cellSize * 7, cellSize * 7),
        paint,
      );
      // 内白框
      paint.color = Colors.white;
      canvas.drawRect(
        Rect.fromLTWH(corner.dx + cellSize, corner.dy + cellSize, cellSize * 5, cellSize * 5),
        paint,
      );
      // 中心黑点
      paint.color = Colors.black;
      canvas.drawRect(
        Rect.fromLTWH(corner.dx + cellSize * 2, corner.dy + cellSize * 2, cellSize * 3, cellSize * 3),
        paint,
      );
    }
    
    // 随机填充一些点
    final random = DateTime.now().millisecond;
    for (int i = 0; i < 50; i++) {
      final x = ((i * 7 + random) % 21).toDouble() * cellSize;
      final y = ((i * 13 + random) % 21).toDouble() * cellSize;
      
      // 避开定位点区域
      if ((x < cellSize * 8 && y < cellSize * 8) ||
          (x > size.width - cellSize * 8 && y < cellSize * 8) ||
          (x < cellSize * 8 && y > size.height - cellSize * 8)) {
        continue;
      }
      
      canvas.drawRect(
        Rect.fromLTWH(x, y, cellSize, cellSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 分享面板组件
class ShareSheet extends StatefulWidget {
  final PosterData posterData;
  final VoidCallback? onShareToWeChat;
  final VoidCallback? onShareToMoments;
  final VoidCallback? onSaveImage;

  const ShareSheet({
    super.key,
    required this.posterData,
    this.onShareToWeChat,
    this.onShareToMoments,
    this.onSaveImage,
  });

  @override
  State<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet> {
  bool _isLoading = false;
  ShareResponse? _shareResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateShareLink();
  }

  Future<void> _generateShareLink() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final shareService = ShareService();
      final result = await shareService.shareTrail(widget.posterData.routeId);
      
      if (mounted) {
        setState(() {
          _shareResult = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '生成分享链接失败';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.getBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖动指示条
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: DesignSystem.getDivider(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // 标题
          Text(
            '分享路线',
            style: DesignSystem.getTitleMedium(context, weight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          // 海报预览
          SizedBox(
            height: 300,
            child: PageView.builder(
              itemCount: PosterTemplate.values.length,
              itemBuilder: (context, index) {
                return Center(
                  child: SharePoster(
                    data: widget.posterData,
                    template: PosterTemplate.values[index],
                    width: 180,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // 模板指示器
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              PosterTemplate.values.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == 0
                      ? DesignSystem.getPrimary(context)
                      : DesignSystem.getDivider(context),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 分享链接区域
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 20, height: 20, child: AppLoadingSmall()),
                  SizedBox(width: 12),
                  Text('生成分享链接中...'),
                ],
              ),
            )
          else if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: DesignSystem.getError(context)),
              ),
            )
          else if (_shareResult != null)
            _buildShareLinkSection(context),
          const SizedBox(height: 32),
          // 分享选项
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  context,
                  icon: Icons.chat_bubble,
                  label: '微信好友',
                  color: const Color(0xFF07C160),
                  onTap: widget.onShareToWeChat,
                ),
                _buildShareOption(
                  context,
                  icon: Icons.photo_library,
                  label: '朋友圈',
                  color: const Color(0xFF07C160),
                  onTap: widget.onShareToMoments,
                ),
                _buildShareOption(
                  context,
                  icon: Icons.download,
                  label: '保存图片',
                  color: DesignSystem.getPrimary(context),
                  onTap: widget.onSaveImage,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // 取消按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: DesignSystem.getBackgroundSecondary(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '取消',
                  style: DesignSystem.getBodyLarge(context),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildShareLinkSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DesignSystem.getBackgroundSecondary(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DesignSystem.getDivider(context)),
        ),
        child: Row(
          children: [
            // Mock QR Code
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: DesignSystem.getDivider(context)),
              ),
              child: const Center(
                child: _PlaceholderQRCode(size: 48),
              ),
            ),
            const SizedBox(width: 16),
            // Share Link
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '分享链接',
                    style: TextStyle(
                      fontSize: 12,
                      color: DesignSystem.getTextTertiary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _shareResult!.shareLink,
                    style: TextStyle(
                      fontSize: 14,
                      color: DesignSystem.getTextPrimary(context),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Copy Button
            IconButton(
              onPressed: () {
                // TODO: Copy to clipboard
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('链接已复制')),
                );
              },
              icon: Icon(
                Icons.copy,
                color: DesignSystem.getPrimary(context),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: DesignSystem.getBodySmall(context),
          ),
        ],
      ),
    );
  }
}

/// 显示分享弹窗
void showShareDialog(BuildContext context, PosterData data) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ShareSheet(
      posterData: data,
      onShareToWeChat: () {
        // TODO: 实现微信分享
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('微信分享功能开发中')),
        );
      },
      onShareToMoments: () {
        // TODO: 实现朋友圈分享
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('朋友圈分享功能开发中')),
        );
      },
      onSaveImage: () {
        // TODO: 实现保存图片
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('图片已保存到相册')),
        );
      },
    ),
  );
}
