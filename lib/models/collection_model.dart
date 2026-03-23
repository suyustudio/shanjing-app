// collection_model.dart
// 山径APP - 收藏夹数据模型

import 'dart:convert';

/// 收藏夹模型
class Collection {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final int trailCount;
  final bool isPublic;
  final bool isDefault;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  Collection({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    required this.trailCount,
    required this.isPublic,
    required this.isDefault,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      coverUrl: json['coverUrl'],
      trailCount: json['trailCount'] ?? 0,
      isPublic: json['isPublic'] ?? true,
      isDefault: json['isDefault'] ?? false,
      sortOrder: json['sortOrder'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverUrl': coverUrl,
      'trailCount': trailCount,
      'isPublic': isPublic,
      'isDefault': isDefault,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Collection copyWith({
    String? id,
    String? name,
    String? description,
    String? coverUrl,
    int? trailCount,
    bool? isPublic,
    bool? isDefault,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      trailCount: trailCount ?? this.trailCount,
      isPublic: isPublic ?? this.isPublic,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 收藏夹中的路线模型
class CollectionTrail {
  final String id;
  final String trailId;
  final String name;
  final String? coverImage;
  final double distanceKm;
  final int durationMin;
  final String difficulty;
  final double? rating;
  final int? reviewCount;
  final String? note;
  final DateTime addedAt;
  final int sortOrder;
  final List<String> tags; // 路线标签

  CollectionTrail({
    required this.id,
    required this.trailId,
    required this.name,
    this.coverImage,
    required this.distanceKm,
    required this.durationMin,
    required this.difficulty,
    this.rating,
    this.reviewCount,
    this.note,
    required this.addedAt,
    required this.sortOrder,
    this.tags = const [],
  });

  factory CollectionTrail.fromJson(Map<String, dynamic> json) {
    return CollectionTrail(
      id: json['id'] ?? '',
      trailId: json['trailId'] ?? '',
      name: json['name'] ?? '',
      coverImage: json['coverImage'],
      distanceKm: (json['distanceKm'] ?? 0).toDouble(),
      durationMin: json['durationMin'] ?? 0,
      difficulty: json['difficulty'] ?? 'EASY',
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount'],
      note: json['note'],
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'])
          : DateTime.now(),
      sortOrder: json['sortOrder'] ?? 0,
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trailId': trailId,
      'name': name,
      'coverImage': coverImage,
      'distanceKm': distanceKm,
      'durationMin': durationMin,
      'difficulty': difficulty,
      'rating': rating,
      'reviewCount': reviewCount,
      'note': note,
      'addedAt': addedAt.toIso8601String(),
      'sortOrder': sortOrder,
      'tags': tags,
    };
  }

  CollectionTrail copyWith({
    String? id,
    String? trailId,
    String? name,
    String? coverImage,
    double? distanceKm,
    int? durationMin,
    String? difficulty,
    double? rating,
    int? reviewCount,
    String? note,
    DateTime? addedAt,
    int? sortOrder,
    List<String>? tags,
  }) {
    return CollectionTrail(
      id: id ?? this.id,
      trailId: trailId ?? this.trailId,
      name: name ?? this.name,
      coverImage: coverImage ?? this.coverImage,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMin: durationMin ?? this.durationMin,
      difficulty: difficulty ?? this.difficulty,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      note: note ?? this.note,
      addedAt: addedAt ?? this.addedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      tags: tags ?? this.tags,
    );
  }
}

/// 收藏夹用户信息
class CollectionUser {
  final String id;
  final String nickname;
  final String? avatar;

  CollectionUser({
    required this.id,
    required this.nickname,
    this.avatar,
  });

  factory CollectionUser.fromJson(Map<String, dynamic> json) {
    return CollectionUser(
      id: json['id'] ?? '',
      nickname: json['nickname'] ?? '',
      avatar: json['avatar'],
    );
  }
}

/// 收藏夹详情
class CollectionDetail {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final CollectionUser user;
  final int trailCount;
  final bool isPublic;
  final bool isOwner;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CollectionTrail> trails;

  CollectionDetail({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    required this.user,
    required this.trailCount,
    required this.isPublic,
    required this.isOwner,
    required this.createdAt,
    required this.updatedAt,
    required this.trails,
  });

  factory CollectionDetail.fromJson(Map<String, dynamic> json) {
    return CollectionDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      coverUrl: json['coverUrl'],
      user: CollectionUser.fromJson(json['user'] ?? {}),
      trailCount: json['trailCount'] ?? 0,
      isPublic: json['isPublic'] ?? true,
      isOwner: json['isOwner'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      trails: (json['trails'] as List? ?? [])
          .map((t) => CollectionTrail.fromJson(t))
          .toList(),
    );
  }
}

/// 快速收藏结果
class QuickCollectResult {
  final bool success;
  final String trailId;
  final String collectionId;
  final bool isCollected;
  final int trailCount;

  QuickCollectResult({
    required this.success,
    required this.trailId,
    required this.collectionId,
    required this.isCollected,
    required this.trailCount,
  });

  factory QuickCollectResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return QuickCollectResult(
      success: json['success'] ?? false,
      trailId: data['trailId'] ?? '',
      collectionId: data['collectionId'] ?? '',
      isCollected: data['action'] == 'added',
      trailCount: data['trailCount'] ?? 0,
    );
  }
}
