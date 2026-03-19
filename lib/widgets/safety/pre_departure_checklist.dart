import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/design_system.dart';

/// 出发前检查清单对话框
/// 用户在开始导航前需要确认的检查项
class PreDepartureChecklistDialog extends StatefulWidget {
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const PreDepartureChecklistDialog({
    Key? key,
    required this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  /// 显示检查清单对话框
  static Future<bool> show({
    required BuildContext context,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PreDepartureChecklistDialog(
        onConfirm: () {
          Navigator.of(context).pop(true);
          onConfirm();
        },
        onCancel: () {
          Navigator.of(context).pop(false);
          onCancel?.call();
        },
      ),
    );
    return result ?? false;
  }

  @override
  State<PreDepartureChecklistDialog> createState() => _PreDepartureChecklistDialogState();
}

class _PreDepartureChecklistDialogState extends State<PreDepartureChecklistDialog> {
  final Map<String, bool> _checklist = {
    'water': false,
    'battery': false,
    'equipment': false,
    'notify': false,
  };

  bool get _allChecked => _checklist.values.every((checked) => checked);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.getBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 拖动条
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
              const SizedBox(height: 20),
              
              // 标题
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: DesignSystem.getPrimary(context).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.checklist,
                      color: DesignSystem.getPrimary(context),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '出发前检查清单',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: DesignSystem.getTextPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '安全第一，确认以下事项后再出发',
                          style: TextStyle(
                            fontSize: 14,
                            color: DesignSystem.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // 检查项列表
              _buildChecklistItem(
                id: 'water',
                icon: Icons.water_drop_outlined,
                title: '水和食物',
                subtitle: '已准备充足的水和能量食品',
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildChecklistItem(
                id: 'battery',
                icon: Icons.battery_full_outlined,
                title: '手机电量',
                subtitle: '手机电量充足（建议80%以上）',
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              _buildChecklistItem(
                id: 'equipment',
                icon: Icons.backpack_outlined,
                title: '必备装备',
                subtitle: '登山鞋、雨具、急救包等已备齐',
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildChecklistItem(
                id: 'notify',
                icon: Icons.notifications_active_outlined,
                title: '告知亲友',
                subtitle: '已将行程告知家人或朋友',
                color: DesignSystem.getPrimary(context),
              ),
              
              const SizedBox(height: 24),
              
              // 安全提示
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DesignSystem.getWarning(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: DesignSystem.getWarning(context),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '勾选所有项目后才能开始导航，这是为了您的安全',
                        style: TextStyle(
                          fontSize: 13,
                          color: DesignSystem.getTextSecondary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 按钮
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: DesignSystem.getTextSecondary(context),
                        side: BorderSide(color: DesignSystem.getDivider(context)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('稍后再说'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _allChecked ? () {
                        HapticFeedback.mediumImpact();
                        widget.onConfirm();
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.getPrimary(context),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: DesignSystem.getPrimary(context).withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        _allChecked ? '开始导航' : '请完成检查 (${_checklist.values.where((v) => v).length}/${_checklist.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistItem({
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isChecked = _checklist[id] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          _checklist[id] = !isChecked;
        });
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isChecked 
              ? color.withOpacity(0.1) 
              : DesignSystem.getBackgroundSecondary(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isChecked 
                ? color.withOpacity(0.5) 
                : DesignSystem.getDivider(context),
            width: isChecked ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isChecked ? color.withOpacity(0.2) : color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isChecked 
                          ? DesignSystem.getTextPrimary(context)
                          : DesignSystem.getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: DesignSystem.getTextSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isChecked ? color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isChecked ? color : DesignSystem.getDivider(context),
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
