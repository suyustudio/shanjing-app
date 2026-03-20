// ================================================================
// Achievement Share Poster
// 成就分享海报组件 - 完整实现版
// 
// 修复内容:
// - P1-1: 实现生成分享图片功能
// - P1-3: 添加分享事件埋点
// ================================================================

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/achievement_model.dart';
import '../../services/analytics_service.dart';
import '../../utils/image_utils.dart';

/// 成就分享海报数据
class AchievementShareData {
  final String achievementName;
  final String achievementLevel;
  final String achievementIconUrl;
  final String? badgeUrl;
  final AchievementCategory category;
  final AchievementLevel level;
  final String description;
  final DateTime unlockedAt;
  final int totalUnlocked;
  final int totalAchievements;
  final String? userNickname;
  final String? userAvatarUrl;
  
  AchievementShareData({
    required this.achievementName,
    required this.achievementLevel,
    required this.achievementIconUrl,
    this.badgeUrl,
    required this.category,
    required this.level,
    required this.description,
    required this.unlockedAt,
    required this.totalUnlocked,
    required this.totalAchievements,
    this.userNickname,
    this.userAvatarUrl,
  });
}

/// 成就分享海报组件
class AchievementSharePoster extends StatefulWidget {
  final AchievementShareData data;
  final VoidCallback? onShareComplete;
  
  const AchievementSharePoster({
    Key? key,
    required this.data,
    this.onShareComplete,
  }) : super(key: key);

  @override
  State<AchievementSharePoster> createState() => _AchievementSharePosterState();
}

class _AchievementSharePosterState extends State<AchievementSharePoster> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isGenerating = false;
  String? _generatedImagePath;
  
  // 模板选择
  int _selectedTemplate = 0;
  final List<String> _templateNames = ['经典', '极简', '胶片'];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 海报预览
        RepaintBoundary(
          key: _globalKey,
          child: _buildPosterPreview(),
        ),
        
        const SizedBox(height: 16),
        
        // 模板选择
        _buildTemplateSelector(),
        
        const SizedBox(height: 16),
        
        // 分享按钮
        _buildShareButtons(),
      ],
    );
  }

  Widget _buildPosterPreview() {
    switch (_selectedTemplate) {
      case 0:
        return _ClassicTemplate(data: widget.data);
      case 1:
        return _MinimalTemplate(data: widget.data);
      case 2:
        return _FilmTemplate(data: widget.data);
      default:
        return _ClassicTemplate(data: widget.data);
    }
  }

  Widget _buildTemplateSelector() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _templateNames.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedTemplate;
          return ChoiceChip(
            label: Text(_templateNames[index]),
            selected: isSelected,
            onSelected: (_) {
              setState(() => _selectedTemplate = index);
              // 埋点：切换模板
              AnalyticsService.instance.logEvent(
                'achievement_share_template_switch',
                parameters: {
                  'template': _templateNames[index],
                  'achievement_id': widget.data.achievementName,
                },
              );
            },
            selectedColor: Theme.of(context).primaryColor,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
            ),
          );
        },
      ),
    );
  }

  Widget _buildShareButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareButton(
                icon: Icons.chat_bubble,
                label: '微信好友',
                color: const Color(0xFF07C160),
                onTap: () => _shareTo('wechat_session'),
              ),
              _buildShareButton(
                icon: Icons.photo_library,
                label: '朋友圈',
                color: const Color(0xFF07C160),
                onTap: () => _shareTo('wechat_timeline'),
              ),
              _buildShareButton(
                icon: Icons.download,
                label: '保存图片',
                color: Theme.of(context).primaryColor,
                onTap: _saveImage,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 复制链接
          TextButton.icon(
            onPressed: _copyShareLink,
            icon: const Icon(Icons.link, size: 18),
            label: const Text('复制分享链接'),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
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
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  /// 生成分享图片
  Future<String?> _generateShareImage() async {
    if (_isGenerating) return null;
    
    setState(() => _isGenerating = true);
    
    try {
      // 等待渲染完成
      await Future.delayed(const Duration(milliseconds: 100));
      
      final RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('Failed to generate image');
      }
      
      final Uint8List pngBytes = byteData.buffer.asUint8List();
      
      // 保存到临时目录
      final tempDir = await getTemporaryDirectory();
      final fileName = 'achievement_share_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${tempDir.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);
      
      setState(() {
        _generatedImagePath = filePath;
        _isGenerating = false;
      });
      
      return filePath;
    } catch (e) {
      setState(() => _isGenerating = false);
      debugPrint('生成分享图片失败: $e');
      return null;
    }
  }

  /// 分享到指定渠道
  Future<void> _shareTo(String channel) async {
    // 埋点：点击分享
    AnalyticsService.instance.logEvent(
      'achievement_share_click',
      parameters: {
        'achievement_id': widget.data.achievementName,
        'channel': channel,
        'template': _templateNames[_selectedTemplate],
      },
    );
    
    final imagePath = await _generateShareImage();
    if (imagePath == null) {
      _showError('生成图片失败，请重试');
      return;
    }
    
    try {
      final XFile file = XFile(imagePath);
      
      // 根据渠道分享
      if (channel == 'wechat_session' || channel == 'wechat_timeline') {
        // 实际项目中调用微信 SDK
        // 这里使用系统分享作为 fallback
        await Share.shareXFiles(
          [file],
          text: '🎉 我在山径App解锁了「${widget.data.achievementName}」成就！一起来探索吧！',
          subject: '山径成就分享',
        );
      } else {
        await Share.shareXFiles(
          [file],
          text: '🎉 我在山径App解锁了「${widget.data.achievementName}」成就！一起来探索吧！',
        );
      }
      
      // 埋点：分享成功
      AnalyticsService.instance.logEvent(
        'achievement_share_success',
        parameters: {
          'achievement_id': widget.data.achievementName,
          'channel': channel,
          'template': _templateNames[_selectedTemplate],
        },
      );
      
      widget.onShareComplete?.call();
    } catch (e) {
      debugPrint('分享失败: $e');
      _showError('分享失败，请重试');
    }
  }

  /// 保存图片到相册
  Future<void> _saveImage() async {
    // 埋点：点击保存
    AnalyticsService.instance.logEvent(
      'achievement_card_save',
      parameters: {
        'achievement_id': widget.data.achievementName,
        'template': _templateNames[_selectedTemplate],
      },
    );
    
    final imagePath = await _generateShareImage();
    if (imagePath == null) {
      _showError('生成图片失败，请重试');
      return;
    }
    
    try {
      // 保存到相册
      final success = await ImageUtils.saveToGallery(imagePath);
      
      if (success) {
        // 埋点：保存成功
        AnalyticsService.instance.logEvent(
          'achievement_card_save_success',
          parameters: {
            'achievement_id': widget.data.achievementName,
          },
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已保存到相册')),
          );
        }
      } else {
        _showError('保存失败，请检查权限');
      }
    } catch (e) {
      debugPrint('保存图片失败: $e');
      _showError('保存失败，请重试');
    }
  }

  /// 复制分享链接
  Future<void> _copyShareLink() async {
    final link = 'https://shanjing.app/achievement/${widget.data.achievementName}';
    await Clipboard.setData(ClipboardData(text: link));
    
    // 埋点
    AnalyticsService.instance.logEvent(
      'achievement_share_link_copy',
      parameters: {
        'achievement_id': widget.data.achievementName,
      },
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('链接已复制')),
      );
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}

// ================================================================
// 海报模板 - 经典风格
// ================================================================
class _ClassicTemplate extends StatelessWidget {
  final AchievementShareData data;
  
  const _ClassicTemplate({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 480,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _getLevelColor(data.level),
            const Color(0xFF1A1A2E),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // 顶部标题
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.terrain, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '山径',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 徽章大图
          Expanded(
            flex: 3,
            child: Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getLevelColor(data.level).withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: _getLevelIcon(data.level, size: 80),
                ),
              ),
            ),
          ),
          
          // 成就信息
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🎉 恭喜解锁',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.achievementName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    data.achievementLevel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  data.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // 底部统计
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('已解锁', '${data.totalUnlocked}'),
                _buildStat('总成就', '${data.totalAchievements}'),
                _buildStat('完成度', '${(data.totalUnlocked / data.totalAchievements * 100).toInt()}%'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getLevelColor(AchievementLevel level) {
    switch (level) {
      case AchievementLevel.bronze:
        return const Color(0xFFCD7F32);
      case AchievementLevel.silver:
        return const Color(0xFFC0C0C0);
      case AchievementLevel.gold:
        return const Color(0xFFFFD700);
      case AchievementLevel.diamond:
        return const Color(0xFF00CED1);
    }
  }

  Widget _getLevelIcon(AchievementLevel level, {double size = 60}) {
    IconData iconData;
    Color color;
    
    switch (level) {
      case AchievementLevel.bronze:
        iconData = Icons.emoji_events;
        color = const Color(0xFFCD7F32);
      case AchievementLevel.silver:
        iconData = Icons.emoji_events;
        color = const Color(0xFFC0C0C0);
      case AchievementLevel.gold:
        iconData = Icons.emoji_events;
        color = const Color(0xFFFFD700);
      case AchievementLevel.diamond:
        iconData = Icons.diamond;
        color = const Color(0xFF00CED1);
    }
    
    return Icon(iconData, size: size, color: color);
  }
}

// ================================================================
// 海报模板 - 极简风格
// ================================================================
class _MinimalTemplate extends StatelessWidget {
  final AchievementShareData data;
  
  const _MinimalTemplate({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 480,
      color: Colors.white,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 品牌
          Row(
            children: [
              Icon(Icons.terrain, color: Colors.green.shade700, size: 24),
              const SizedBox(width: 8),
              Text(
                '山径',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          
          // 等级徽章
          Center(
            child: _getLevelIcon(data.level, size: 100),
          ),
          const SizedBox(height: 32),
          
          // 成就名称
          Text(
            data.achievementName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.achievementLevel,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          
          const Spacer(),
          
          // 分割线
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 16),
          
          // 统计
          Row(
            children: [
              Expanded(
                child: _buildStat('已解锁', '${data.totalUnlocked}'),
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade200),
              Expanded(
                child: _buildStat('完成度', '${(data.totalUnlocked / data.totalAchievements * 100).toInt()}%'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 二维码区域
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.qr_code, size: 40, color: Colors.black54),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '扫描二维码下载山径App\n一起探索更多精彩路线',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _getLevelIcon(AchievementLevel level, {double size = 60}) {
    IconData iconData;
    Color color;
    
    switch (level) {
      case AchievementLevel.bronze:
        iconData = Icons.emoji_events;
        color = const Color(0xFFCD7F32);
      case AchievementLevel.silver:
        iconData = Icons.emoji_events;
        color = const Color(0xFFC0C0C0);
      case AchievementLevel.gold:
        iconData = Icons.emoji_events;
        color = const Color(0xFFFFD700);
      case AchievementLevel.diamond:
        iconData = Icons.diamond;
        color = const Color(0xFF00CED1);
    }
    
    return Icon(iconData, size: size, color: color);
  }
}

// ================================================================
// 海报模板 - 胶片风格
// ================================================================
class _FilmTemplate extends StatelessWidget {
  final AchievementShareData data;
  
  const _FilmTemplate({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 480,
      color: const Color(0xFF2C2C2C),
      padding: const EdgeInsets.all(16),
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
                // 胶片孔
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
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
                // 内容区
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _getLevelIcon(data.level, size: 80),
                        const SizedBox(height: 16),
                        Text(
                          data.achievementName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 胶片孔
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
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
          
          // 文字
          Text(
            '"${data.achievementLevel}"',
            style: const TextStyle(
              color: Color(0xFFE8E8E8),
              fontSize: 20,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '徒步，是与自己对话的过程',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          
          const Spacer(),
          
          // 底部信息
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
              const Text(
                '山径记录',
                style: TextStyle(
                  color: Color(0xFF07C160),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getLevelIcon(AchievementLevel level, {double size = 60}) {
    IconData iconData;
    Color color;
    
    switch (level) {
      case AchievementLevel.bronze:
        iconData = Icons.emoji_events;
        color = const Color(0xFFCD7F32);
      case AchievementLevel.silver:
        iconData = Icons.emoji_events;
        color = const Color(0xFFC0C0C0);
      case AchievementLevel.gold:
        iconData = Icons.emoji_events;
        color = const Color(0xFFFFD700);
      case AchievementLevel.diamond:
        iconData = Icons.diamond;
        color = const Color(0xFF00CED1);
    }
    
    return Icon(iconData, size: size, color: color);
  }
}

// ================================================================
// 显示分享弹窗
// ================================================================
void showAchievementShareSheet(
  BuildContext context, {
  required AchievementShareData data,
  VoidCallback? onShareComplete,
}) {
  // 埋点：打开分享弹窗
  AnalyticsService.instance.logEvent(
    'achievement_share_sheet_open',
    parameters: {
      'achievement_id': data.achievementName,
      'level': data.level.toString(),
    },
  );
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖动条
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // 标题
          const Text(
            '分享成就',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          
          // 海报组件
          AchievementSharePoster(
            data: data,
            onShareComplete: onShareComplete,
          ),
          
          const SizedBox(height: 24),
          
          // 关闭按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('取消'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
