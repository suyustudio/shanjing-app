export declare class AchievementError extends Error {
    readonly code: string;
    readonly statusCode: number;
    readonly details?: Record<string, any>;
    constructor(message: string, code: string, statusCode?: number, details?: Record<string, any>);
    toJSON(): {
        success: boolean;
        error: {
            code: string;
            message: string;
            details: Record<string, any>;
        };
    };
}
export declare class AchievementAlreadyUnlockedError extends AchievementError {
    constructor(achievementId: string, userId: string);
}
export declare class AchievementNotFoundError extends AchievementError {
    constructor(achievementId: string);
}
export declare class InvalidTriggerTypeError extends AchievementError {
    constructor(triggerType: string);
}
export declare class InvalidStatsError extends AchievementError {
    constructor(field: string, value: any, constraint: string);
}
export declare class ConcurrentModificationError extends AchievementError {
    constructor(resource: string, userId: string);
}
export declare class TransactionError extends AchievementError {
    constructor(operation: string, originalError?: Error);
}
export declare class RecommendationError extends AchievementError {
    constructor(message: string, code?: string, statusCode?: number);
}
export declare class ValidationError extends AchievementError {
    constructor(field: string, message: string);
}
