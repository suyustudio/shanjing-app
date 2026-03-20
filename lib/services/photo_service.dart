// ================================================================
// M6: 照片服务
// ================================================================

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/photo_model.dart';

class PhotoService {
  static final PhotoService _instance = PhotoService._internal();
  factory PhotoService() => _instance;
  PhotoService._internal();

  final String _baseUrl = ApiConfig.baseUrl;
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // ==================== 照片 CRUD ====================

  /// 获取照片列表 (瀑布流分页)
  Future<PhotoListResponse> getPhotos({
    String? trailId,
    String? userId,
    String sort = 'newest',
    String? cursor,
    int limit = 20,
  }) async {
    final queryParams = PhotoQueryParams(
      trailId: trailId,
      userId: userId,
      sort: sort,
      cursor: cursor,
      limit: limit,
    );

    final uri = Uri.parse('$_baseUrl/v1/photos')
        .replace(queryParameters: queryParams.toQueryParams());

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true) {
        final data = json['data'] as Map<String, dynamic>;
        return PhotoListResponse.fromJson(data);
      }
      throw Exception(json['error']?['message'] ?? '获取照片列表失败');
    } else {
      throw Exception('获取照片列表失败: ${response.statusCode}');
    }
  }

  /// 获取照片详情
  Future<Photo> getPhotoDetail(String photoId) async {
    final uri = Uri.parse('$_baseUrl/v1/photos/$photoId');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true) {
        return Photo.fromJson(json['data'] as Map<String, dynamic>);
      }
      throw Exception(json['error']?['message'] ?? '获取照片详情失败');
    } else {
      throw Exception('获取照片详情失败: ${response.statusCode}');
    }
  }

  /// 上传单张照片
  Future<Photo> createPhoto(CreatePhotoRequest request) async {
    final uri = Uri.parse('$_baseUrl/v1/photos');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true) {
        return Photo.fromJson(json['data'] as Map<String, dynamic>);
      }
      throw Exception(json['error']?['message'] ?? '上传照片失败');
    } else {
      throw Exception('上传照片失败: ${response.statusCode}');
    }
  }

  /// 批量上传照片
  Future<List<Photo>> createPhotos(List<CreatePhotoRequest> requests) async {
    final uri = Uri.parse('$_baseUrl/v1/photos/batch');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({'photos': requests.map((r) => r.toJson()).toList()}),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true) {
        final photos = (json['data'] as List)
            .map((e) => Photo.fromJson(e as Map<String, dynamic>))
            .toList();
        return photos;
      }
      throw Exception(json['error']?['message'] ?? '批量上传照片失败');
    } else {
      throw Exception('批量上传照片失败: ${response.statusCode}');
    }
  }

  /// 更新照片信息
  Future<Photo> updatePhoto(String photoId, UpdatePhotoRequest request) async {
    final uri = Uri.parse('$_baseUrl/v1/photos/$photoId');
    final response = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true) {
        return Photo.fromJson(json['data'] as Map<String, dynamic>);
      }
      throw Exception(json['error']?['message'] ?? '更新照片失败');
    } else {
      throw Exception('更新照片失败: ${response.statusCode}');
    }
  }

  /// 删除照片
  Future<void> deletePhoto(String photoId) async {
    final uri = Uri.parse('$_baseUrl/v1/photos/$photoId');
    final response = await http.delete(uri, headers: _headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] != true) {
        throw Exception(json['error']?['message'] ?? '删除照片失败');
      }
    } else {
      throw Exception('删除照片失败: ${response.statusCode}');
    }
  }

  /// 点赞/取消点赞照片
  Future<LikePhotoResponse> likePhoto(String photoId) async {
    final uri = Uri.parse('$_baseUrl/v1/photos/$photoId/like');
    final response = await http.post(uri, headers: _headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true) {
        return LikePhotoResponse.fromJson(json['data'] as Map<String, dynamic>);
      }
      throw Exception(json['error']?['message'] ?? '点赞操作失败');
    } else {
      throw Exception('点赞操作失败: ${response.statusCode}');
    }
  }

  /// 获取用户的照片列表
  Future<PhotoListResponse> getUserPhotos(
    String userId, {
    String? cursor,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
    };
    if (cursor != null) queryParams['cursor'] = cursor;

    final uri = Uri.parse('$_baseUrl/v1/users/$userId/photos')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true) {
        final data = json['data'] as Map<String, dynamic>;
        return PhotoListResponse.fromJson(data);
      }
      throw Exception(json['error']?['message'] ?? '获取用户照片失败');
    } else {
      throw Exception('获取用户照片失败: ${response.statusCode}');
    }
  }

  // ==================== OSS 上传 ====================

  /// 获取单张照片上传凭证
  Future<UploadUrlResponse> getUploadUrl({
    required String filename,
    required String contentType,
  }) async {
    final uri = Uri.parse('$_baseUrl/v1/files/upload-url');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'filename': filename,
        'contentType': contentType,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true) {
        return UploadUrlResponse.fromJson(json['data'] as Map<String, dynamic>);
      }
      throw Exception(json['error']?['message'] ?? '获取上传凭证失败');
    } else {
      throw Exception('获取上传凭证失败: ${response.statusCode}');
    }
  }

  /// 批量获取上传凭证
  Future<List<UploadUrlResponse>> getBatchUploadUrls(
    List<{String filename, String contentType}> files,
  ) async {
    final uri = Uri.parse('$_baseUrl/v1/files/upload-urls');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'files': files
            .map((f) => {'filename': f.filename, 'contentType': f.contentType})
            .toList(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true) {
        final list = (json['data'] as List)
            .map((e) => UploadUrlResponse.fromJson(e as Map<String, dynamic>))
            .toList();
        return list;
      }
      throw Exception(json['error']?['message'] ?? '批量获取上传凭证失败');
    } else {
      throw Exception('批量获取上传凭证失败: ${response.statusCode}');
    }
  }

  /// 上传文件到 OSS
  Future<void> uploadToOss({
    required String uploadUrl,
    required File file,
    required String contentType,
    void Function(int sent, int total)? onProgress,
  }) async {
    final request = http.Request('PUT', Uri.parse(uploadUrl));
    request.headers['Content-Type'] = contentType;
    
    final bytes = await file.readAsBytes();
    request.bodyBytes = bytes;

    final streamedResponse = await request.send();
    
    if (streamedResponse.statusCode != 200 &&
        streamedResponse.statusCode != 201) {
      throw Exception('上传文件失败: ${streamedResponse.statusCode}');
    }
  }

  /// 完整的照片上传流程
  Future<Photo> uploadPhoto({
    required File file,
    String? trailId,
    String? description,
    double? latitude,
    double? longitude,
    DateTime? takenAt,
    void Function(double progress)? onProgress,
  }) async {
    // 1. 获取文件信息
    final filename = file.path.split('/').last;
    final extension = filename.split('.').last.toLowerCase();
    final contentType = _getContentType(extension);

    // 2. 获取上传凭证
    if (onProgress != null) onProgress(0.1);
    final uploadUrlResponse = await getUploadUrl(
      filename: filename,
      contentType: contentType,
    );

    // 3. 上传到 OSS
    if (onProgress != null) onProgress(0.3);
    await uploadToOss(
      uploadUrl: uploadUrlResponse.uploadUrl,
      file: file,
      contentType: contentType,
    );

    // 4. 创建照片记录
    if (onProgress != null) onProgress(0.8);
    final request = CreatePhotoRequest(
      url: uploadUrlResponse.accessUrl,
      thumbnailUrl: uploadUrlResponse.thumbnailUrl,
      trailId: trailId,
      description: description,
      latitude: latitude,
      longitude: longitude,
      takenAt: takenAt ?? DateTime.now(),
    );

    final photo = await createPhoto(request);
    if (onProgress != null) onProgress(1.0);

    return photo;
  }

  /// 批量上传照片
  Future<List<Photo>> uploadPhotos({
    required List<File> files,
    String? trailId,
    String? description,
    void Function(int current, int total)? onProgress,
  }) async {
    final photos = <Photo>[];

    // 1. 批量获取上传凭证
    final fileInfos = files.map((file) {
      final filename = file.path.split('/').last;
      final extension = filename.split('.').last.toLowerCase();
      return (
        filename: filename,
        contentType: _getContentType(extension),
      );
    }).toList();

    final uploadUrls = await getBatchUploadUrls(fileInfos);

    // 2. 逐个上传并创建记录
    for (var i = 0; i < files.length; i++) {
      if (onProgress != null) onProgress(i + 1, files.length);

      final file = files[i];
      final uploadUrl = uploadUrls[i];

      // 上传到 OSS
      await uploadToOss(
        uploadUrl: uploadUrl.uploadUrl,
        file: file,
        contentType: fileInfos[i].contentType,
      );

      // 创建照片记录
      final request = CreatePhotoRequest(
        url: uploadUrl.accessUrl,
        thumbnailUrl: uploadUrl.thumbnailUrl,
        trailId: trailId,
        description: description,
      );

      final photo = await createPhoto(request);
      photos.add(photo);
    }

    return photos;
  }

  String _getContentType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }
}
