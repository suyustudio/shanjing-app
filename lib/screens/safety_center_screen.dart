import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/design_system.dart';
import '../providers/emergency_contact_provider.dart';
import '../providers/lifeline_provider.dart';
import '../widgets/app_app_bar.dart';
import '../widgets/safety/emergency_contact_list.dart';
import '../widgets/safety/lifeline_status_card.dart';
import 'lifeline_setup_screen.dart';
import 'sos_screen.dart';

/// 安全中心页面（重构版）
/// 新结构：
/// - 顶部: Lifeline 状态卡片（激活/未激活）
/// - 中部: 紧急联系人管理入口
/// - 底部: SOS 按钮（收起状态，减少焦虑）
class SafetyCenterScreen extends StatefulWidget {
  const SafetyCenterScreen({super.key});

  @override
  State<SafetyCenterScreen> createState() => _SafetyCenterScreenState();
}

class _SafetyCenterScreenState extends State<SafetyCenterScreen> {
  bool _isSOSExpanded = false;

  @override
  void initState() {
    super.initState();
    // 初始化Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LifelineProvider>().initialize();
      context.read<EmergencyContactProvider>().loadContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(
        title: '安全中心',
      ),
      body: ListView(
        padding: const EdgeInsets.all(DesignSystem.spacingLarge),
        children: [
          // 顶部: Lifeline状态卡片
          _buildLifelineSection(),
          const SizedBox(height: DesignSystem.spacingLarge),
          
          // 中部: 紧急联系人管理
          _buildContactSection(),
          const SizedBox(height: DesignSystem.spacingLarge),
          
          // SOS区域（折叠/展开）
          _buildSOSSection(),
          const SizedBox(height: DesignSystem.spacingLarge),
          
          // 安全提示
          _buildSafetyTips(),
        ],
      ),
    );
  }

  // ========== Lifeline状态卡片 ==========
  Widget _buildLifelineSection() {
    return LifelineStatusCard(
      onTap: () {
        final provider = context.read<LifelineProvider>();
        if (!provider.isActive) {
          _navigateToLifelineSetup();
        }
      },
      onActivate: _navigateToLifelineSetup,
      onStop: () => _showStopConfirmDialog(),
    );
  }

  // ========== 紧急联系人区域 ==========
  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingLarge),
      decoration: BoxDecoration(
        color: DesignSystem.getBackgroundElevated(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignSystem.getDivider(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people,
                    color: DesignSystem.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '紧急联系人',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: DesignSystem.getTextPrimary(context),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _showContactManager,
                child: const Text('管理'),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacingMedium),
          EmergencyContactList(
            showAddButton: true,
            showEditActions: false,
            onAddTap: _showAddContactDialog,
          ),
        ],
      ),
    );
  }

  // ========== SOS区域 ==========
  Widget _buildSOSSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _isSOSExpanded 
            ? Colors.red.shade50 
            : DesignSystem.getBackgroundElevated(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isSOSExpanded 
              ? Colors.red.shade200 
              : DesignSystem.getDivider(context),
        ),
      ),
      child: Column(
        children: [
          // 头部（始终显示）
          InkWell(
            onTap: () {
              setState(() {
                _isSOSExpanded = !_isSOSExpanded;
              });
            },
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: Radius.circular(_isSOSExpanded ? 0 : 16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(DesignSystem.spacingLarge),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isSOSExpanded 
                          ? Colors.red.withOpacity(0.1)
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.emergency,
                      color: _isSOSExpanded 
                          ? Colors.red 
                          : Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '紧急求助',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _isSOSExpanded 
                                ? Colors.red.shade700 
                                : DesignSystem.getTextPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '仅在真正紧急情况下使用',
                          style: TextStyle(
                            fontSize: 13,
                            color: DesignSystem.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isSOSExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.expand_more,
                      color: DesignSystem.getTextTertiary(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 展开内容
          if (_isSOSExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(DesignSystem.spacingLarge),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '请仅在人身安全受到威胁、严重受伤或迷路无法返回时使用此功能',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange.shade800,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _navigateToSOS,
                      icon: const Icon(Icons.emergency, size: 24),
                      label: const Text(
                        '进入紧急求助',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '如遇生命危险，请直接拨打 110/120',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ========== 安全提示 ==========
  Widget _buildSafetyTips() {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 18,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                '安全提示',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('出发前告知亲友您的行程计划'),
          _buildTipItem('保持手机电量，建议携带充电宝'),
          _buildTipItem('恶劣天气避免单独徒步'),
          _buildTipItem('遇到紧急情况保持冷静，优先确保自身安全'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== 导航方法 ==========
  void _navigateToLifelineSetup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LifelineSetupScreen(),
      ),
    );
  }

  void _navigateToSOS() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SOSScreen(),
      ),
    );
  }

  void _showContactManager() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _ContactManagerSheet(
            scrollController: scrollController,
          );
        },
      ),
    );
  }

  void _showAddContactDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddContactBottomSheet(),
    );
  }

  void _showStopConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('结束行程守护'),
        content: const Text('确定要结束当前的行程守护吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<LifelineProvider>();
              final success = await provider.stopLifeline();
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('行程守护已结束'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('结束'),
          ),
        ],
      ),
    );
  }
}

// ========== 联系人管理弹窗 ==========
class _ContactManagerSheet extends StatelessWidget {
  final ScrollController scrollController;

  const _ContactManagerSheet({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingLarge),
      child: Column(
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
          // 标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '管理紧急联系人',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: DesignSystem.getTextPrimary(context),
                ),
              ),
              Consumer<EmergencyContactProvider>(
                builder: (context, provider, child) {
                  if (provider.isAtMaxLimit) return const SizedBox.shrink();
                  return IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => const _AddContactBottomSheet(),
                      );
                    },
                    icon: const Icon(Icons.add),
                    color: DesignSystem.primary,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacingMedium),
          // 联系人列表
          Expanded(
            child: ListView(
              controller: scrollController,
              children: const [
                EmergencyContactList(
                  showAddButton: false,
                  showEditActions: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ========== 添加联系人弹窗 ==========
class _AddContactBottomSheet extends StatefulWidget {
  const _AddContactBottomSheet();

  @override
  State<_AddContactBottomSheet> createState() => _AddContactBottomSheetState();
}

class _AddContactBottomSheetState extends State<_AddContactBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRelation = '父母';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: DesignSystem.spacingLarge,
        right: DesignSystem.spacingLarge,
        top: DesignSystem.spacingLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          // 标题
          Text(
            '添加紧急联系人',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DesignSystem.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingLarge),
          // 表单
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
                    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value.replaceAll(RegExp(r'\s+|-'), ''))) {
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
                  items: ['父母', '配偶', '子女', '兄弟姐妹', '朋友', '同事', '其他']
                      .map((relation) => DropdownMenuItem(
                            value: relation,
                            child: Text(relation),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRelation = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // 保存按钮
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveContact,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      '保存',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingLarge),
        ],
      ),
    );
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<EmergencyContactProvider>();
    final success = await provider.addContact(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      relation: _selectedRelation,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('联系人已添加')),
      );
    }
  }
}
