import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/design_system.dart';
import '../../models/emergency_contact.dart';
import '../../providers/emergency_contact_provider.dart';
import '../../providers/lifeline_provider.dart';
import '../../services/emergency_contact_service.dart';
import '../../widgets/app_app_bar.dart';
import '../../widgets/safety/emergency_contact_list.dart';

/// Lifeline设置页面
/// 用于设置预计完成时间和选择紧急联系人
class LifelineSetupScreen extends StatefulWidget {
  final String? routeId;
  final String? routeName;

  const LifelineSetupScreen({
    super.key,
    this.routeId,
    this.routeName,
  });

  @override
  State<LifelineSetupScreen> createState() => _LifelineSetupScreenState();
}

class _LifelineSetupScreenState extends State<LifelineSetupScreen> {
  // 时间选择
  int _selectedDurationMinutes = 120; // 默认2小时
  int _selectedBufferMinutes = 30; // 默认30分钟缓冲
  
  // 自定义时间
  bool _isCustomDuration = false;
  final TextEditingController _customHourController = TextEditingController();
  final TextEditingController _customMinuteController = TextEditingController();

  // 选中的联系人
  List<String> _selectedContactIds = [];

  // 预设时间选项
  final List<Map<String, dynamic>> _durationOptions = [
    {'label': '1小时', 'minutes': 60},
    {'label': '2小时', 'minutes': 120},
    {'label': '3小时', 'minutes': 180},
    {'label': '4小时', 'minutes': 240},
    {'label': '自定义', 'minutes': -1},
  ];

  // 缓冲时间选项
  final List<Map<String, dynamic>> _bufferOptions = [
    {'label': '15分钟', 'minutes': 15},
    {'label': '30分钟', 'minutes': 30},
    {'label': '1小时', 'minutes': 60},
  ];

  @override
  void initState() {
    super.initState();
    // 加载联系人
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmergencyContactProvider>().loadContacts();
    });
  }

  @override
  void dispose() {
    _customHourController.dispose();
    _customMinuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(
        title: '开启行程守护',
      ),
      body: Consumer<EmergencyContactProvider>(
        builder: (context, contactProvider, child) {
          // 如果没有选中联系人但有联系人，默认全选
          if (_selectedContactIds.isEmpty && contactProvider.contacts.isNotEmpty) {
            _selectedContactIds = contactProvider.contacts.map((c) => c.id).toList();
          }

          return ListView(
            padding: const EdgeInsets.all(DesignSystem.spacingLarge),
            children: [
              // 标题区域
              _buildHeader(),
              const SizedBox(height: DesignSystem.spacingLarge),
              
              // 联系人选择
              _buildContactSection(contactProvider),
              const SizedBox(height: DesignSystem.spacingLarge),
              
              // 预计用时
              _buildDurationSection(),
              const SizedBox(height: DesignSystem.spacingLarge),
              
              // 缓冲时间
              _buildBufferSection(),
              const SizedBox(height: DesignSystem.spacingLarge),
              
              // 确认按钮
              _buildConfirmButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingLarge),
      decoration: BoxDecoration(
        color: DesignSystem.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.shield,
            size: 48,
            color: DesignSystem.primary,
          ),
          const SizedBox(height: DesignSystem.spacingSmall),
          Text(
            '让关心你的人知道你很安全',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignSystem.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '超时未归时自动通知紧急联系人',
            style: TextStyle(
              fontSize: 14,
              color: DesignSystem.primary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(EmergencyContactProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '选择紧急联系人',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: DesignSystem.getTextPrimary(context),
              ),
            ),
            if (!provider.isAtMaxLimit)
              TextButton.icon(
                onPressed: () => _showAddContactDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('添加'),
              ),
          ],
        ),
        const SizedBox(height: DesignSystem.spacingSmall),
        if (provider.contacts.isEmpty)
          _buildNoContactsHint()
        else
          EmergencyContactList(
            showAddButton: false,
            showEditActions: false,
            selectable: true,
            selectedIds: _selectedContactIds,
            onSelectionChanged: (id, selected) {
              setState(() {
                if (selected) {
                  _selectedContactIds.add(id);
                } else {
                  _selectedContactIds.remove(id);
                }
              });
            },
          ),
      ],
    );
  }

  Widget _buildNoContactsHint() {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade700),
          const SizedBox(height: 8),
          Text(
            '请先添加紧急联系人',
            style: TextStyle(
              fontSize: 15,
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _showAddContactDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('立即添加'),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '预计完成时间',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: DesignSystem.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _durationOptions.map((option) {
            final isSelected = _selectedDurationMinutes == option['minutes'] ||
                (option['minutes'] == -1 && _isCustomDuration);
            return ChoiceChip(
              label: Text(option['label']),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    if (option['minutes'] == -1) {
                      _isCustomDuration = true;
                      _customHourController.text = '2';
                      _customMinuteController.text = '0';
                    } else {
                      _isCustomDuration = false;
                      _selectedDurationMinutes = option['minutes'] as int;
                    }
                  });
                }
              },
              selectedColor: DesignSystem.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : DesignSystem.getTextPrimary(context),
              ),
            );
          }).toList(),
        ),
        if (_isCustomDuration) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customHourController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: '小时',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final hours = int.tryParse(value) ?? 0;
                    final minutes = int.tryParse(_customMinuteController.text) ?? 0;
                    _selectedDurationMinutes = hours * 60 + minutes;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _customMinuteController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: '分钟',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final hours = int.tryParse(_customHourController.text) ?? 0;
                    final minutes = int.tryParse(value) ?? 0;
                    _selectedDurationMinutes = hours * 60 + minutes;
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBufferSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '缓冲时间',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: DesignSystem.getTextPrimary(context),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: '超过预计时间后，系统会等待缓冲时间再发送报警',
              child: Icon(
                Icons.help_outline,
                size: 18,
                color: DesignSystem.getTextTertiary(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '额外预留的安全时间',
          style: TextStyle(
            fontSize: 13,
            color: DesignSystem.getTextSecondary(context),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _bufferOptions.map((option) {
            final isSelected = _selectedBufferMinutes == option['minutes'];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: option == _bufferOptions.last ? 0 : 8,
                ),
                child: ChoiceChip(
                  label: Center(child: Text(option['label'])),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedBufferMinutes = option['minutes'] as int;
                      });
                    }
                  },
                  selectedColor: DesignSystem.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : DesignSystem.getTextPrimary(context),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    final bool canStart = _selectedContactIds.isNotEmpty && _selectedDurationMinutes > 0;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: canStart ? _startLifeline : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '一键开启行程守护',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '开启后，我们会实时追踪您的位置\n超时未归时自动通知紧急联系人',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: DesignSystem.getTextTertiary(context),
          ),
        ),
      ],
    );
  }

  void _showAddContactDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return _AddContactBottomSheet(
            scrollController: scrollController,
            onContactAdded: (contact) {
              setState(() {
                _selectedContactIds.add(contact.id);
              });
            },
          );
        },
      ),
    );
  }

  Future<void> _startLifeline() async {
    final provider = context.read<LifelineProvider>();
    
    final success = await provider.startLifeline(
      contactIds: _selectedContactIds,
      estimatedDurationMinutes: _selectedDurationMinutes,
      bufferTimeMinutes: _selectedBufferMinutes,
      routeId: widget.routeId,
      routeName: widget.routeName,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('行程守护已开启'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

/// 添加联系人底部弹窗
class _AddContactBottomSheet extends StatefulWidget {
  final ScrollController scrollController;
  final Function(EmergencyContact) onContactAdded;

  const _AddContactBottomSheet({
    required this.scrollController,
    required this.onContactAdded,
  });

  @override
  State<_AddContactBottomSheet> createState() => _AddContactBottomSheetState();
}

class _AddContactBottomSheetState extends State<_AddContactBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRelation = '父母';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 拖动条
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingLarge),
          Text(
            '添加紧急联系人',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DesignSystem.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingMedium),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '姓名',
                          hintText: '请输入联系人姓名',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入姓名';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: '手机号',
                          hintText: '请输入11位手机号',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入手机号';
                          }
                          if (!EmergencyContactService.isValidPhone(value)) {
                            return '请输入有效的手机号';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedRelation,
                        decoration: const InputDecoration(
                          labelText: '关系',
                          prefixIcon: Icon(Icons.people_outline),
                        ),
                        items: EmergencyContact.relationTypes.map((relation) {
                          return DropdownMenuItem(
                            value: relation,
                            child: Text(relation),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRelation = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignSystem.spacingMedium),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saveContact,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '保存',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<EmergencyContactProvider>();
    final success = await provider.addContact(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      relation: _selectedRelation,
    );

    if (success && mounted) {
      final newContact = provider.contacts.last;
      widget.onContactAdded(newContact);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('联系人已添加')),
      );
    }
  }
}
