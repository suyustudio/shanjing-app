// ================================================================
// M6: 照片系统模型
// ================================================================

/// 照片模型
class Photo {
  final String id;
  final String url;
  final String? thumbnailUrl;
  final int? width;
  final int? height;
  final String? description;
  final int likeCount;
  final bool isLiked;
  final bool isPublic;
  final DateTime createdAt;
  final PhotoUser user;
  final PhotoTrail? trail;
  final PhotoLocation? location;
  final DateTime? takenAt;

  Photo({
    required this.id,
    required this.url,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.description,
    required this.likeCount,
    this.isLiked = false,
    required this.isPublic,
    required this.createdAt,
    required this.user,
    this.trail,
    this.location,
    this.takenAt,
  });

  factory Photo.fromJson(Map<string, dynamic> json) {
    return Photo(
      id: json['id'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      description: json['description'] as String?,
      likeCount: json['likeCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isPublic: json['isPublic'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      user: PhotoUser.fromJson(json['user'] as Map<String, dynamic>),
      trail: json['trail'] != null
          ? PhotoTrail.fromJson(json['trail'] as Map<String, dynamic>)
          : null,
      location: json['latitude'] != null && json['longitude'] != null
          ? PhotoLocation(
              latitude: (json['latitude'] as num).toDouble(),
              longitude: (json['longitude'] as num).toDouble(),
              name: json['locationName'] as String?,
            )
          : null,
      takenAt: json['takenAt'] != null
          ? DateTime.parse(json['takenAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'width': width,
      'height': height,
      'description': description,
      'likeCount': likeCount,
      'isLiked': isLiked,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'user': user.toJson(),
      'trail': trail?.toJson(),
      'latitude': location?.latitude,
      'longitude': location?.longitude,
      'locationName': location?.name,
      'takenAt': takenAt?.toIso8601String(),
    };
  }

  Photo copyWith({
    String? id,
    String? url,
    String? thumbnailUrl,
    int? width,
    int? height,
    String? description,
    int? likeCount,
    bool? isLiked,
    bool? isPublic,
    DateTime? createdAt,
    PhotoUser? user,
    PhotoTrail? trail,
    PhotoLocation? location,
    DateTime? takenAt,
  }) {
    return Photo(
      id: id ?? this.id,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      width: width ?? this.width,
      height: height ?? this.height,
      description: description ?? this.description,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
      trail: trail ?? this.trail,
      location: location ?? this.location,
      takenAt: takenAt ?? this.takenAt,
    );
  }
}

/// 照片作者信息
class PhotoUser {
  final String id;
  final String? nickname;
  final String? avatarUrl;

  PhotoUser({
    required this.id,
    this.nickname,
    this.avatarUrl,
  });

  factory PhotoUser.fromJson(Map<String, dynamic> json) {
    return PhotoUser(
      id: json['id'] as String,
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
    };
  }
}

/// 关联路线信息
class PhotoTrail {
  final String id;
  final String name;

  PhotoTrail({
    required this.id,
    required this.name,
  });

  factory PhotoTrail.fromJson(Map<String, dynamic> json) {
    return PhotoTrail(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

/// 照片位置信息
class PhotoLocation {
  final double latitude;
  final double longitude;
  final String? name;

  PhotoLocation({
    required this.latitude,
    required this.longitude,
    this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
    };
  }
}

/// 照片列表响应
class PhotoListResponse {
  final List<Photo> list;
  final String? nextCursor;
  final bool hasMore;

  PhotoListResponse({
    required this.list,
    this.nextCursor,
    required this.hasMore,
  });

  factory PhotoListResponse.fromJson(Map<String, dynamic> json) {
    return PhotoListResponse(
      list: (json['list'] as List)
          .map((e) => Photo.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}

/// 创建照片请求
class CreatePhotoRequest {
  final String url;
  final String? thumbnailUrl;
  final String? trailId;
  final String? poiId;
  final int? width;
  final int? height;
  final String? description;
  final double? latitude;
  final double? longitude;
  final DateTime? takenAt;

  CreatePhotoRequest({
    required this.url,
    this.thumbnailUrl,
    this.trailId,
    this.poiId,
    this.width,
    this.height,
    this.description,
    this.latitude,
    this.longitude,
    this.takenAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'trailId': trailId,
      'poiId': poiId,
      'width': width,
      'height': height,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'takenAt': takenAt?.toIso8601String(),
    };
  }
}

/// 更新照片请求
class UpdatePhotoRequest {
  final String? description;
  final bool? isPublic;

  UpdatePhotoRequest({
    this.description,
    this.isPublic,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'isPublic': isPublic,
    };
  }
}

/// 点赞响应
class LikePhotoResponse {
  final bool isLiked;
  final int likeCount;

  LikePhotoResponse({
    required this.isLiked,
    required this.likeCount,
  });

  factory LikePhotoResponse.fromJson(Map<String, dynamic> json) {
    return LikePhotoResponse(
      isLiked: json['isLiked'] as bool,
      likeCount: json['likeCount'] as int,
    );
  }
}

/// 上传凭证响应
class UploadUrlResponse {
  final String uploadUrl;
  final String accessUrl;
  final String? thumbnailUrl;
  final String key;
  final int expires;

  UploadUrlResponse({
    required this.uploadUrl,
    required this.accessUrl,
    this.thumbnailUrl,
    required this.key,
    required this.expires,
  });

  factory UploadUrlResponse.fromJson(Map<String, dynamic> json) {
    return UploadUrlResponse(
      uploadUrl: json['uploadUrl'] as String,
      accessUrl: json['accessUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      key: json['key'] as String,
      expires: json['expires'] as int,
    );
  }
}

/// 照片查询参数
class PhotoQueryParams {
  final String? trailId;
  final String? userId;
  final String sort;
  final String? cursor;
  final int limit;

  PhotoQueryParams({
    this.trailId,
    this.userId,
    this.sort = 'newest',
    this.cursor,
    this.limit = 20,
  });

  Map<String, String> toQueryParams() {
    final params = <String, String>{
      'sort': sort,
      'limit': limit.toString(),
    };
    if (trailId != null) params['trailId'] = trailId!;
    if (userId != null) params['userId'] = userId!;
    if (cursor != null) params['cursor'] = cursor!;
    return params;
  }
}
