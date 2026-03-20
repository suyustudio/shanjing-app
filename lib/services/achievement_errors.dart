// ================================================================
// Achievement Error Types
// 成就系统错误类型定义
// ================================================================

/// 成就服务错误基类
class AchievementServiceError implements Exception {
  final String message;
  final String code;
  final int? statusCode;
  final Map<String, dynamic>? details;

  const AchievementServiceError({
    required this.message,
    required this.code,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => 'AchievementServiceError[$code]: $message';
}

/// 网络错误
class AchievementNetworkError extends AchievementServiceError {
  final String? endpoint;
  final dynamic originalError;

  const AchievementNetworkError({
    required super.message,
    this.endpoint,
    this.originalError,
  }) : super(
    code: 'NETWORK_ERROR',
    statusCode: null,
  );
}

/// 服务器错误
class AchievementServerError extends AchievementServiceError {
  const AchievementServerError({
    required super.message,
    super.statusCode = 500,
    super.details,
  }) : super(code: 'SERVER_ERROR');
}

/// 验证错误
class AchievementValidationError extends AchievementServiceError {
  final String field;
  final dynamic value;
  final String constraint;

  const AchievementValidationError({
    required this.field,
    required this.value,
    required this.constraint,
  }) : super(
    message: '参数验证失败: $field - $constraint',
    code: 'VALIDATION_ERROR',
    statusCode: 400,
    details: {'field': field, 'value': value, 'constraint': constraint},
  );
}

/// 成就不存在错误
class AchievementNotFoundError extends AchievementServiceError {
  final String achievementId;

  const AchievementNotFoundError({
    required this.achievementId,
  }) : super(
    message: '成就不存在: $achievementId',
    code: 'ACHIEVEMENT_NOT_FOUND',
    statusCode: 404,
    details: {'achievementId': achievementId},
  );
}

/// 触发类型无效错误
class InvalidTriggerTypeError extends AchievementServiceError {
  final String triggerType;

  const InvalidTriggerTypeError({
    required this.triggerType,
  }) : super(
    message: '无效的触发类型: $triggerType',
    code: 'INVALID_TRIGGER_TYPE',
    statusCode: 400,
    details: {
      'triggerType': triggerType,
      'allowedTypes': ['trail_completed', 'share', 'manual'],
    },
  );
}

/// 并发修改错误
class ConcurrentModificationError extends AchievementServiceError {
  const ConcurrentModificationError({
    super.message = '资源被并发修改，请稍后重试',
  }) : super(
    code: 'CONCURRENT_MODIFICATION',
    statusCode: 409,
  );
}

/// 缓存错误
class AchievementCacheError extends AchievementServiceError {
  const AchievementCacheError({
    required super.message,
  }) : super(
    code: 'CACHE_ERROR',
    statusCode: null,
  );
}

/// 操作结果封装
class AchievementResult<T> {
  final T? data;
  final AchievementServiceError? error;
  final bool isSuccess;

  const AchievementResult._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  factory AchievementResult.success(T data) =>
    AchievementResult._(data: data, isSuccess: true);

  factory AchievementResult.failure(AchievementServiceError error) =>
    AchievementResult._(error: error, isSuccess: false);

  /// 成功时返回数据，失败时抛出错误
  T getOrThrow() {
    if (isSuccess && data != null) {
      return data;
    }
    throw error ?? const AchievementServiceError(
      message: '未知错误',
      code: 'UNKNOWN_ERROR',
    );
  }

  /// 成功时执行回调
  AchievementResult<T> onSuccess(void Function(T data) callback) {
    if (isSuccess && data != null) {
      callback(data);
    }
    return this;
  }

  /// 失败时执行回调
  AchievementResult<T> onFailure(void Function(AchievementServiceError error) callback) {
    if (!isSuccess && error != null) {
      callback(error);
    }
    return this;
  }

  /// 映射成功值
  AchievementResult<R> map<R>(R Function(T data) transform) {
    if (isSuccess && data != null) {
      return AchievementResult.success(transform(data));
    }
    return AchievementResult<R>.failure(error!);
  }
}
