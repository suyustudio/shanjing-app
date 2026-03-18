import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/design_system.dart';
import '../../models/emergency_contact.dart';
import '../../providers/emergency_contact_provider.dart';
import '../../services/emergency_contact_service.dart';

/// 紧急联系人列表组件
class EmergencyContactList extends StatelessWidget {
  final bool showAddButton;
  final bool showEditActions;
  final Function(EmergencyContact)? onContactTap;
  final Function(EmergencyContact)? onContactEdit;
  final VoidCallback? onAddTap;
  final List<String> selectedIds;
  final bool selectable;
  final Function(String, bool)? onSelectionChanged;

  const EmergencyContactList({
    super.key,
    this.showAddButton = true,
    this.showEditActions = true,
    this.onContactTap,
    this.onContactEdit,
    this.onAddTap,
    this.selectedIds = const [],
    this.selectable = false,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<EmergencyContactProvider>(
      builder: (context, provider, child) {
        final contacts = provider.contacts;

        if (provider.isLoading && contacts.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (contacts.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!showAddButton) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: DesignSystem.spacingSmall),
                child: Text(
                  '紧急联系人 (${contacts.length}/5)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: DesignSystem.getTextSecondary(context),
                  ),
                ),
              ),
            ],
            ...contacts.map((contact) => _buildContactItem(context, contact)),
            if (showAddButton && !provider.isAtMaxLimit) ...[
              const SizedBox(height: DesignSystem.spacingSmall),
              _buildAddButton(context),
            ],
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingLarge),
      decoration: BoxDecoration(
        color: DesignSystem.getCardBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesignSystem.getDivider(context)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: DesignSystem.spacingSmall),
          Text(
            '暂无紧急联系人',
            style: TextStyle(
              fontSize: 16,
              color: DesignSystem.getTextSecondary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '添加联系人，在紧急情况下可以快速通知他们',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: DesignSystem.getTextTertiary(context),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingMedium),
          if (showAddButton)
            ElevatedButton.icon(
              onPressed: onAddTap,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('添加联系人'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.primary,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, EmergencyContact contact) {
    final isSelected = selectedIds.contains(contact.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected 
            ? DesignSystem.primary.withOpacity(0.1)
            : DesignSystem.getCardBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? DesignSystem.primary
              : DesignSystem.getDivider(context),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: selectable
            ? () => onSelectionChanged?.call(contact.id, !isSelected)
            : () => onContactTap?.call(contact),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 头像
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: contact.isPrimary
                      ? DesignSystem.primary.withOpacity(0.1)
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    contact.name.isNotEmpty ? contact.name[0] : '?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: contact.isPrimary
                          ? DesignSystem.primary
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          contact.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: DesignSystem.getTextPrimary(context),
                          ),
                        ),
                        if (contact.isPrimary) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: DesignSystem.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '主要',
                              style: TextStyle(
                                fontSize: 10,
                                color: DesignSystem.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${contact.relation} • ${EmergencyContactService.formatPhoneForDisplay(contact.phone)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: DesignSystem.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              // 操作按钮
              if (selectable)
                Checkbox(
                  value: isSelected,
                  onChanged: (value) => onSelectionChanged?.call(contact.id, value ?? false),
                  activeColor: DesignSystem.primary,
                )
              else if (showEditActions)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => onContactEdit?.call(contact),
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: DesignSystem.getTextTertiary(context),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      onPressed: () => _showDeleteConfirm(context, contact),
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red.shade400,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: DesignSystem.getTextTertiary(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return InkWell(
      onTap: onAddTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DesignSystem.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: DesignSystem.primary.withOpacity(0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 20,
              color: DesignSystem.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '添加紧急联系人',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: DesignSystem.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除联系人'),
        content: Text('确定要删除 ${contact.name} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<EmergencyContactProvider>();
              final success = await provider.deleteContact(contact.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('联系人已删除')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
