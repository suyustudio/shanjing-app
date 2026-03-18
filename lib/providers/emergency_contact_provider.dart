import 'package:flutter/foundation.dart';
import '../models/emergency_contact.dart';
import '../services/emergency_contact_service.dart';

/// 紧急联系人状态管理
class EmergencyContactProvider extends ChangeNotifier {
  final EmergencyContactService _service = EmergencyContactService();
  
  List<EmergencyContact> _contacts = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<EmergencyContact> get contacts => List.unmodifiable(_contacts);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasContacts => _contacts.isNotEmpty;
  int get contactCount => _contacts.length;
  bool get isAtMaxLimit => _contacts.length >= 5;

  /// 初始化加载联系人
  Future<void> loadContacts() async {
    _setLoading(true);
    _clearError();
    
    try {
      _contacts = await _service.getAllContacts();
    } catch (e) {
      _setError('加载联系人失败: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// 添加联系人
  Future<bool> addContact({
    required String name,
    required String phone,
    required String relation,
    bool isPrimary = false,
  }) async {
    if (isAtMaxLimit) {
      _setError('最多只能添加5位紧急联系人');
      notifyListeners();
      return false;
    }

    if (!EmergencyContactService.isValidPhone(phone)) {
      _setError('请输入有效的手机号码');
      notifyListeners();
      return false;
    }

    if (name.trim().isEmpty) {
      _setError('请输入联系人姓名');
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final contact = EmergencyContact(
        id: EmergencyContactService.generateId(),
        name: name.trim(),
        phone: phone.replaceAll(RegExp(r'\s+|-'), ''),
        relation: relation,
        isPrimary: isPrimary || _contacts.isEmpty,
      );

      final success = await _service.addContact(contact);
      if (success) {
        _contacts = await _service.getAllContacts();
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('添加联系人失败');
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _setError('添加联系人失败: $e');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// 更新联系人
  Future<bool> updateContact(EmergencyContact contact) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _service.updateContact(contact);
      if (success) {
        _contacts = await _service.getAllContacts();
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('更新联系人失败');
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _setError('更新联系人失败: $e');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// 删除联系人
  Future<bool> deleteContact(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _service.deleteContact(id);
      if (success) {
        _contacts = await _service.getAllContacts();
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('删除联系人失败');
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _setError('删除联系人失败: $e');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// 设置主要联系人
  Future<bool> setPrimaryContact(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _service.setPrimaryContact(id);
      if (success) {
        _contacts = await _service.getAllContacts();
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('设置主要联系人失败');
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _setError('设置主要联系人失败: $e');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// 根据ID获取联系人
  EmergencyContact? getContactById(String id) {
    try {
      return _contacts.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取主要联系人
  EmergencyContact? getPrimaryContact() {
    try {
      return _contacts.firstWhere((c) => c.isPrimary);
    } catch (e) {
      return _contacts.isNotEmpty ? _contacts.first : null;
    }
  }

  /// 获取联系人列表（按ID列表）
  List<EmergencyContact> getContactsByIds(List<String> ids) {
    return _contacts.where((c) => ids.contains(c.id)).toList();
  }

  /// 清空错误信息
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Private helpers
  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(String message) {
    _error = message;
  }

  void _clearError() {
    _error = null;
  }
}
