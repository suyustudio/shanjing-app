import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emergency_contact.dart';

/// 紧急联系人服务
/// 管理紧急联系人的CRUD操作和本地持久化
class EmergencyContactService {
  static const String _storageKey = 'emergency_contacts';
  static const int _maxContacts = 5;

  static final EmergencyContactService _instance = EmergencyContactService._internal();
  factory EmergencyContactService() => _instance;
  EmergencyContactService._internal();

  SharedPreferences? _prefs;

  /// 初始化服务
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 获取所有紧急联系人
  Future<List<EmergencyContact>> getAllContacts() async {
    await initialize();
    final jsonString = _prefs?.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => EmergencyContact.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 根据ID获取联系人
  Future<EmergencyContact?> getContactById(String id) async {
    final contacts = await getAllContacts();
    try {
      return contacts.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取主要联系人
  Future<EmergencyContact?> getPrimaryContact() async {
    final contacts = await getAllContacts();
    try {
      return contacts.firstWhere((c) => c.isPrimary);
    } catch (e) {
      return contacts.isNotEmpty ? contacts.first : null;
    }
  }

  /// 添加紧急联系人
  /// 返回: 成功返回true，达到上限返回false
  Future<bool> addContact(EmergencyContact contact) async {
    final contacts = await getAllContacts();
    
    if (contacts.length >= _maxContacts) {
      return false;
    }

    // 检查是否已存在相同ID
    if (contacts.any((c) => c.id == contact.id)) {
      // 更新现有联系人
      return updateContact(contact);
    }

    // 如果是第一个联系人或设置为主要的，处理isPrimary
    List<EmergencyContact> updatedContacts = List.from(contacts);
    if (contact.isPrimary || contacts.isEmpty) {
      // 清除其他主要联系人状态
      updatedContacts = updatedContacts.map((c) => 
        c.copyWith(isPrimary: false)
      ).toList();
    }

    updatedContacts.add(contact);
    await _saveContacts(updatedContacts);
    return true;
  }

  /// 更新紧急联系人
  Future<bool> updateContact(EmergencyContact contact) async {
    final contacts = await getAllContacts();
    final index = contacts.indexWhere((c) => c.id == contact.id);
    
    if (index == -1) {
      return false;
    }

    List<EmergencyContact> updatedContacts = List.from(contacts);
    
    // 如果设置为主要联系人，清除其他的
    if (contact.isPrimary) {
      updatedContacts = updatedContacts.map((c) => 
        c.id == contact.id ? c : c.copyWith(isPrimary: false)
      ).toList();
    }

    updatedContacts[index] = contact;
    await _saveContacts(updatedContacts);
    return true;
  }

  /// 删除紧急联系人
  Future<bool> deleteContact(String id) async {
    final contacts = await getAllContacts();
    final index = contacts.indexWhere((c) => c.id == id);
    
    if (index == -1) {
      return false;
    }

    final deletedContact = contacts[index];
    final updatedContacts = contacts.where((c) => c.id != id).toList();

    // 如果删除的是主要联系人且还有其他联系人，设置第一个为主要联系人
    if (deletedContact.isPrimary && updatedContacts.isNotEmpty) {
      updatedContacts[0] = updatedContacts[0].copyWith(isPrimary: true);
    }

    await _saveContacts(updatedContacts);
    return true;
  }

  /// 设置主要联系人
  Future<bool> setPrimaryContact(String id) async {
    final contacts = await getAllContacts();
    if (!contacts.any((c) => c.id == id)) {
      return false;
    }

    final updatedContacts = contacts.map((c) => 
      c.copyWith(isPrimary: c.id == id)
    ).toList();

    await _saveContacts(updatedContacts);
    return true;
  }

  /// 获取联系人数量
  Future<int> getContactCount() async {
    final contacts = await getAllContacts();
    return contacts.length;
  }

  /// 检查是否已达到上限
  Future<bool> isAtMaxLimit() async {
    final count = await getContactCount();
    return count >= _maxContacts;
  }

  /// 检查是否有联系人
  Future<bool> hasContacts() async {
    final count = await getContactCount();
    return count > 0;
  }

  /// 清空所有联系人
  Future<void> clearAllContacts() async {
    await _prefs?.remove(_storageKey);
  }

  /// 保存联系人到本地存储
  Future<void> _saveContacts(List<EmergencyContact> contacts) async {
    await initialize();
    final jsonList = contacts.map((c) => c.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs?.setString(_storageKey, jsonString);
  }

  /// 生成唯一ID
  static String generateId() {
    return 'contact_${DateTime.now().millisecondsSinceEpoch}_${(1000 + DateTime.now().microsecond % 9000)}';
  }

  /// 验证手机号格式
  static bool isValidPhone(String phone) {
    // 中国大陆手机号正则
    final RegExp phoneRegExp = RegExp(r'^1[3-9]\d{9}$');
    return phoneRegExp.hasMatch(phone.replaceAll(RegExp(r'\s+|-'), ''));
  }

  /// 格式化手机号显示
  static String formatPhoneForDisplay(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\s+|-'), '');
    if (cleaned.length == 11) {
      return '${cleaned.substring(0, 3)}****${cleaned.substring(7)}';
    }
    return phone;
  }
}
