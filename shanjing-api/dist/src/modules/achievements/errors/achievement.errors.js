"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ValidationError = exports.RecommendationError = exports.TransactionError = exports.ConcurrentModificationError = exports.InvalidStatsError = exports.InvalidTriggerTypeError = exports.AchievementNotFoundError = exports.AchievementAlreadyUnlockedError = exports.AchievementError = void 0;
class AchievementError extends Error {
    constructor(message, code, statusCode = 500, details) {
        super(message);
        this.code = code;
        this.statusCode = statusCode;
        this.details = details;
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
exports.AchievementError = AchievementError;
class AchievementAlreadyUnlockedError extends AchievementError {
    constructor(achievementId, userId) {
        super(`成就已解锁: ${achievementId}`, 'ACHIEVEMENT_ALREADY_UNLOCKED', 409, { achievementId, userId });
    }
}
exports.AchievementAlreadyUnlockedError = AchievementAlreadyUnlockedError;
class AchievementNotFoundError extends AchievementError {
    constructor(achievementId) {
        super(`成就不存在: ${achievementId}`, 'ACHIEVEMENT_NOT_FOUND', 404, { achievementId });
    }
}
exports.AchievementNotFoundError = AchievementNotFoundError;
class InvalidTriggerTypeError extends AchievementError {
    constructor(triggerType) {
        super(`无效的触发类型: ${triggerType}`, 'INVALID_TRIGGER_TYPE', 400, { triggerType, allowedTypes: ['trail_completed', 'share', 'manual'] });
    }
}
exports.InvalidTriggerTypeError = InvalidTriggerTypeError;
class InvalidStatsError extends AchievementError {
    constructor(field, value, constraint) {
        super(`无效的统计数据: ${field}`, 'INVALID_STATS', 400, { field, value, constraint });
    }
}
exports.InvalidStatsError = InvalidStatsError;
class ConcurrentModificationError extends AchievementError {
    constructor(resource, userId) {
        super(`资源被并发修改，请重试: ${resource}`, 'CONCURRENT_MODIFICATION', 409, { resource, userId });
    }
}
exports.ConcurrentModificationError = ConcurrentModificationError;
class TransactionError extends AchievementError {
    constructor(operation, originalError) {
        super(`数据库事务失败: ${operation}`, 'TRANSACTION_ERROR', 500, { operation, originalError: originalError?.message });
    }
}
exports.TransactionError = TransactionError;
class RecommendationError extends AchievementError {
    constructor(message, code = 'RECOMMENDATION_ERROR', statusCode = 500) {
        super(message, code, statusCode);
    }
}
exports.RecommendationError = RecommendationError;
class ValidationError extends AchievementError {
    constructor(field, message) {
        super(`参数验证失败: ${field}`, 'VALIDATION_ERROR', 400, { field, message });
    }
}
exports.ValidationError = ValidationError;
//# sourceMappingURL=achievement.errors.js.map