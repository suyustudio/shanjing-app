// ================================================================
// Achievement Error Types
// 成就系统错误类型定义
// ================================================================

export class AchievementError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly statusCode: number = 500,
    public readonly details?: Record<string, any>,
  ) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace?.(this, this.constructor);
  }

  toJSON() {
    return {
      success: false,
      error: {
        code: this.code,
        message: this.message,
        details: this.details,
      },
    };
  }
}

/**
 * 成就已解锁错误
 */
export class AchievementAlreadyUnlockedError extends AchievementError {
  constructor(achievementId: string, userId: string) {
    super(
      `成就已解锁: ${achievementId}`,
      'ACHIEVEMENT_ALREADY_UNLOCKED',
      409,
      { achievementId, userId },
    );
  }
}

/**
 * 成就未找到错误
 */
export class AchievementNotFoundError extends AchievementError {
  constructor(achievementId: string) {
    super(
      `成就不存在: ${achievementId}`,
      'ACHIEVEMENT_NOT_FOUND',
      404,
      { achievementId },
    );
  }
}

/**
 * 无效的触发类型错误
 */
export class InvalidTriggerTypeError extends AchievementError {
  constructor(triggerType: string) {
    super(
      `无效的触发类型: ${triggerType}`,
      'INVALID_TRIGGER_TYPE',
      400,
      { triggerType, allowedTypes: ['trail_completed', 'share', 'manual'] },
    );
  }
}

/**
 * 无效的统计数据错误
 */
export class InvalidStatsError extends AchievementError {
  constructor(field: string, value: any, constraint: string) {
    super(
      `无效的统计数据: ${field}`,
      'INVALID_STATS',
      400,
      { field, value, constraint },
    );
  }
}

/**
 * 并发冲突错误（乐观锁失败）
 */
export class ConcurrentModificationError extends AchievementError {
  constructor(resource: string, userId: string) {
    super(
      `资源被并发修改，请重试: ${resource}`,
      'CONCURRENT_MODIFICATION',
      409,
      { resource, userId },
    );
  }
}

/**
 * 数据库事务错误
 */
export class TransactionError extends AchievementError {
  constructor(operation: string, originalError?: Error) {
    super(
      `数据库事务失败: ${operation}`,
      'TRANSACTION_ERROR',
      500,
      { operation, originalError: originalError?.message },
    );
  }
}

/**
 * 推荐服务错误
 */
export class RecommendationError extends AchievementError {
  constructor(message: string, code: string = 'RECOMMENDATION_ERROR', statusCode: number = 500) {
    super(message, code, statusCode);
  }
}

/**
 * 参数验证错误
 */
export class ValidationError extends AchievementError {
  constructor(field: string, message: string) {
    super(
      `参数验证失败: ${field}`,
      'VALIDATION_ERROR',
      400,
      { field, message },
    );
  }
}
