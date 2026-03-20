export declare const TIME_CONSTANTS: {
    readonly ONE_MINUTE: number;
    readonly FIVE_MINUTES: number;
    readonly TEN_MINUTES: number;
    readonly THIRTY_MINUTES: number;
    readonly ONE_HOUR: number;
    readonly ONE_DAY: number;
    readonly THIRTY_DAYS: number;
    readonly NINETY_DAYS: number;
};
export declare const DISTANCE_CONSTANTS: {
    readonly ONE_KM: 1000;
    readonly TEN_KM: number;
    readonly FIFTY_KM: number;
    readonly ONE_HUNDRED_KM: number;
    readonly MAX_REFERENCE_DISTANCE_KM: 100;
    readonly EARTH_RADIUS_METERS: 6371000;
};
export declare const CACHE_TTL: {
    readonly VERY_SHORT: 120;
    readonly SHORT: 180;
    readonly MEDIUM: 300;
    readonly LONG: 600;
    readonly PERSISTENT: 1800;
};
export declare const ACHIEVEMENT_CONSTANTS: {
    readonly ACHIEVEMENT_CACHE_TTL: 300;
    readonly USER_ACHIEVEMENT_CACHE_TTL: 180;
    readonly ACHIEVEMENT_LIST_CACHE_KEY: "achievements:all";
    readonly USER_ACHIEVEMENT_CACHE_PREFIX: "achievements:user";
    readonly VALID_TRIGGER_TYPES: readonly ["trail_completed", "share", "manual"];
};
export declare const RECOMMENDATION_CONSTANTS: {
    readonly CACHE_PREFIX: "recommendation:";
    readonly POPULARITY_CACHE_TTL: 300;
    readonly RECOMMENDATION_CACHE_TTL: 600;
    readonly FRESHNESS_DECAY_DAYS: 90;
    readonly MAX_DIFFICULTY_DIFF: 3;
    readonly COLD_START_MULTIPLIER: 3;
    readonly HOME_TOP_TRAILS_COUNT: 3;
    readonly FRESHNESS_HIGH_THRESHOLD: 0.7;
    readonly DIFFICULTY_MATCH_HIGH_THRESHOLD: 0.8;
    readonly DISTANCE_HIGH_THRESHOLD: 0.7;
    readonly POPULARITY_HIGH_THRESHOLD: 0.8;
    readonly RATING_HIGH_THRESHOLD: 0.85;
    readonly NEARBY_MAX_DISTANCE_METERS: 50000;
    readonly DISTANCE_BONUS_THRESHOLD_KM: 10;
    readonly DISTANCE_PENALTY_THRESHOLD_KM: 100;
    readonly NEW_TRAIL_PROTECTION_DAYS: 30;
    readonly MIN_REVIEW_COUNT: 10;
    readonly DEFAULT_RATING: 3.5;
    readonly POPULARITY_COMPLETION_DENOMINATOR: 100;
    readonly POPULARITY_BOOKMARK_DENOMINATOR: 50;
    readonly POPULARITY_COMPLETION_WEIGHT: 0.6;
    readonly POPULARITY_BOOKMARK_WEIGHT: 0.4;
    readonly NEW_TRAIL_BASE_POPULARITY_SCORE: 0.5;
    readonly COLD_START_DEFAULT_MATCH_SCORE: 0.8;
    readonly DEFAULT_DISTANCE_SCORE: 0.5;
    readonly DEFAULT_FRESHNESS_SCORE: 0.5;
    readonly LOW_REVIEW_COUNT_SCORE: 0.7;
};
export declare const DIFFICULTY_MAP: {
    readonly EASY: 1;
    readonly MODERATE: 2;
    readonly HARD: 3;
    readonly EXPERT: 4;
};
export declare const CACHE_TTL_BY_SCENE: {
    readonly HOME: 300;
    readonly LIST: 600;
    readonly SIMILAR: 1800;
    readonly NEARBY: 120;
};
export declare const ALGORITHM_WEIGHTS: {
    readonly DEFAULT: {
        readonly difficultyMatch: 0.25;
        readonly distance: 0.2;
        readonly rating: 0.2;
        readonly popularity: 0.2;
        readonly freshness: 0.15;
    };
    readonly NEARBY: {
        readonly difficultyMatch: 0.2;
        readonly distance: 0.4;
        readonly rating: 0.15;
        readonly popularity: 0.15;
        readonly freshness: 0.1;
    };
};
export declare const TRANSACTION_CONFIG: {
    readonly MAX_WAIT_MS: 5000;
    readonly TIMEOUT_MS: 10000;
    readonly ISOLATION_LEVEL: "Serializable";
};
export declare const LOG_CONTEXT: {
    readonly ACHIEVEMENTS_SERVICE: "AchievementsService";
    readonly RECOMMENDATION_SERVICE: "RecommendationService";
    readonly RECOMMENDATION_ALGORITHM_SERVICE: "RecommendationAlgorithmService";
    readonly USER_PROFILE_SERVICE: "UserProfileService";
};
export declare const VALIDATION_CONSTRAINTS: {
    readonly MAX_DISTANCE_METERS: 1000000;
    readonly MAX_DURATION_SECONDS: 86400;
    readonly MAX_LIMIT: 50;
    readonly MIN_LIMIT: 1;
    readonly DEFAULT_LIMIT: 10;
};
