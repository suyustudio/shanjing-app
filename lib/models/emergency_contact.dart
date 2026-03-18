/// 紧急联系人数据模型
class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relation;
  final bool isPrimary;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
    this.isPrimary = false,
  });

  /// 从JSON反序列化
  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      relation: json['relation'] as String,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  /// 序列化为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'relation': relation,
      'isPrimary': isPrimary,
    };
  }

  /// 创建副本并修改字段
  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phone,
    String? relation,
    bool? isPrimary,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relation: relation ?? this.relation,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  @override
  String toString() {
    return 'EmergencyContact(id: $id, name: $name, phone: $phone, relation: $relation, isPrimary: $isPrimary)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmergencyContact && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// 预设关系类型
  static const List<String> relationTypes = [
    '父母',
    '配偶',
    '子女',
    '兄弟姐妹',
    '朋友',
    '同事',
    '其他',
  ];
}
