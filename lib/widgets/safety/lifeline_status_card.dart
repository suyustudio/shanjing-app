import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/design_system.dart';
import '../../providers/lifeline_provider.dart';

/// Lifeline状态卡片
/// 显示在首页，展示当前Lifeline状态
class LifelineStatusCard extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onActivate;
  final VoidCallback? onStop;

  const LifelineStatusCard({
    super.key,
    this.onTap,
    this.onActivate,
    this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LifelineProvider>(
      builder: (context, provider, child) {
        final isActive = provider.isActive;
        final isOverdue = provider.isOverdue;
        final session = provider.currentSession;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(DesignSystem.spacingLarge),
            decoration: BoxDecoration(
              color: _getBackgroundColor(context, isActive, isOverdue),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getBorderColor(context, isActive, isOverdue),
                width: 2,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: DesignSystem.primary.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildStatusIcon(isActive, isOverdue),
                    const SizedBox(width: DesignSystem.spacingSmall),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTitle(isActive, isOverdue),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getTextColor(context, isActive, isOverdue),
                            ),
                          ),
                          if (isActive && session != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '预计返回 ${provider.estimatedReturnTimeString}',
                              style: TextStyle(
                                fontSize: 13,
                                color: _getSecondaryTextColor(context, isActive),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isActive)
                      _buildPulsingIndicator()
                    else
                      Icon(
                        Icons.chevron_right,
                        color: DesignSystem.getTextTertiary(context),
                      ),
                  ],
                ),
                if (isActive) ...[
                  const SizedBox(height: DesignSystem.spacingMedium),
                  _buildCountdown(provider),
                  const SizedBox(height: DesignSystem.spacingMedium),
                  _buildActionButtons(context, provider),
                ] else ...[
                  const SizedBox(height: DesignSystem.spacingMedium),
                  _buildInactiveContent(context),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(bool isActive, bool isOverdue) {
    if (isOverdue) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.warning_amber,
          color: Colors.red,
          size: 24,
        ),
      );
    }

    if (isActive) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.shield,
          color: Colors.green,
          size: 24,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.shield_outlined,
        color: Colors.grey.shade600,
        size: 24,
      ),
    );
  }

  String _getTitle(bool isActive, bool isOverdue) {
    if (isOverdue) return '行程已超时';
    if (isActive) return '行程守护中';
    return '未开启行程守护';
  }

  Color _getBackgroundColor(BuildContext context, bool isActive, bool isOverdue) {
    if (isOverdue) return Colors.red.shade50;
    if (isActive) return Colors.green.shade50;
    return DesignSystem.getBackgroundElevated(context);
  }

  Color _getBorderColor(BuildContext context, bool isActive, bool isOverdue) {
    if (isOverdue) return Colors.red.shade200;
    if (isActive) return Colors.green.shade300;
    return DesignSystem.getDivider(context);
  }

  Color _getTextColor(BuildContext context, bool isActive, bool isOverdue) {
    if (isOverdue) return Colors.red.shade700;
    if (isActive) return Colors.green.shade700;
    return DesignSystem.getTextPrimary(context);
  }

  Color _getSecondaryTextColor(BuildContext context, bool isActive) {
    if (isActive) return Colors.green.shade600;
    return DesignSystem.getTextSecondary(context);
  }

  Widget _buildPulsingIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: 1.0),
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(value),
            shape: BoxShape.circle,
          ),
        );
      },
      onEnd: () {
        // 动画循环由父级重建处理
      },
    );
  }

  Widget _buildCountdown(LifelineProvider provider) {
    final remaining = provider.remainingTime;
    final isAboutToTimeout = provider.isAboutToTimeout;

    String timeText;
    if (remaining == null) {
      timeText = '--:--:--';
    } else {
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes.remainder(60);
      final seconds = remaining.inSeconds.remainder(60);
      timeText =
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isAboutToTimeout ? Colors.orange.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            size: 18,
            color: isAboutToTimeout ? Colors.orange : Colors.green.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            '剩余时间: ',
            style: TextStyle(
              fontSize: 14,
              color: isAboutToTimeout ? Colors.orange.shade700 : Colors.green.shade700,
            ),
          ),
          Text(
            timeText,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isAboutToTimeout ? Colors.orange.shade800 : Colors.green.shade800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, LifelineProvider provider) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _showExtendTimeDialog(context, provider);
            },
            icon: const Icon(Icons.more_time, size: 18),
            label: const Text('延长时间'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade100,
              foregroundColor: Colors.orange.shade800,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onStop,
            icon: const Icon(Icons.stop_circle, size: 18),
            label: const Text('结束行程'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red.shade800,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInactiveContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '出发徒步前开启，让关心你的人知道你很安全',
          style: TextStyle(
            fontSize: 14,
            color: DesignSystem.getTextSecondary(context),
          ),
        ),
        const SizedBox(height: DesignSystem.spacingMedium),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onActivate,
            icon: const Icon(Icons.shield, size: 18),
            label: const Text('开启行程守护'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showExtendTimeDialog(BuildContext context, LifelineProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.spacingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '延长预计时间',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DesignSystem.getTextPrimary(context),
                ),
              ),
              const SizedBox(height: DesignSystem.spacingMedium),
              _buildTimeOption(context, provider, 15, '延长 15 分钟'),
              _buildTimeOption(context, provider, 30, '延长 30 分钟'),
              _buildTimeOption(context, provider, 60, '延长 1 小时'),
              _buildTimeOption(context, provider, 120, '延长 2 小时'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeOption(
    BuildContext context,
    LifelineProvider provider,
    int minutes,
    String label,
  ) {
    return ListTile(
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () async {
        Navigator.pop(context);
        final success = await provider.extendTime(minutes);
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已延长 $minutes 分钟'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }
}
