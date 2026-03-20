// collection_form_dialog.dart
// 山径APP - 收藏夹创建/编辑弹窗

import 'package:flutter/material.dart';

/// 收藏夹表单弹窗
class CollectionFormDialog extends StatefulWidget {
  final String? initialName;
  final String? initialDescription;
  final bool? initialIsPublic;
  final bool isEditing;
  final Future<bool> Function(String name, String? description, bool isPublic) onSubmit;

  const CollectionFormDialog({
    Key? key,
    this.initialName,
    this.initialDescription,
    this.initialIsPublic,
    this.isEditing = false,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<CollectionFormDialog> createState() => _CollectionFormDialogState();
}

class _CollectionFormDialogState extends State<CollectionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isPublic = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _descriptionController.text = widget.initialDescription ?? '';
    _isPublic = widget.initialIsPublic ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final success = await widget.onSubmit(
      _nameController.text.trim(),
      _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      _isPublic,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? '编辑收藏夹' : '新建收藏夹'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 名称输入
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '名称',
                  hintText: '给收藏夹起个名字',
                  counterText: '',
                ),
                maxLength: 20,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入名称';
                  }
                  if (value.trim().length > 20) {
                    return '名称不能超过20字';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 描述输入
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述（可选）',
                  hintText: '添加一些描述...',
                  counterText: '',
                ),
                maxLength: 200,
                maxLines: 3,
              ),
              
              const SizedBox(height: 16),
              
              // 隐私设置
              if (!widget.isEditing || widget.initialIsPublic != null) ...[
                SwitchListTile(
                  title: const Text('公开收藏夹'),
                  subtitle: Text(
                    _isPublic ? '所有人都可以看到' : '仅自己可见',
                    style: const TextStyle(fontSize: 12),
                  ),
                  value: _isPublic,
                  onChanged: (value) {
                    setState(() {
                      _isPublic = value;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.isEditing ? '保存' : '创建'),
        ),
      ],
    );
  }
}
