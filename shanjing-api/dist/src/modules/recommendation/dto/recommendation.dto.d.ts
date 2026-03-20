export declare enum RecommendationScene {
    HOME = "home",
    LIST = "list",
    SIMILAR = "similar",
    NEARBY = "nearby"
}
export declare enum UserAction {
    CLICK = "click",
    BOOKMARK = "bookmark",
    COMPLETE = "complete",
    IGNORE = "ignore"
}
export declare class GetRecommendationsDto {
    userId?: string;
    scene: RecommendationScene;
    lat?: number;
    lng?: number;
    limit?: number;
    excludeIds?: string[];
    referenceTrailId?: string;
}
export declare class FeedbackDto {
    action: UserAction;
    trailId: string;
    logId?: string;
    durationSec?: number;
}
export declare class ImpressionDto {
    scene: RecommendationScene;
    trailIds: string[];
    logId?: string;
    timestamp?: string;
}
export declare class MatchFactorsDto {
    difficultyMatch: number;
    distance: number;
    rating: number;
    popularity: number;
    freshness: number;
}
export declare class RecommendedTrailDto {
    id: string;
    name: string;
    coverImage: string;
    distanceKm: number;
    durationMin: number;
    difficulty: string;
    rating: number;
    matchScore: number;
    matchFactors: MatchFactorsDto;
    recommendReason?: string;
    userDistanceM?: number;
}
export declare class RecommendationsResponseDto {
    algorithm: string;
    scene: string;
    logId: string;
    trails: RecommendedTrailDto[];
}
export interface TrailFeatureVector {
    difficulty: number;
    distanceKm: number;
    rating: number;
    popularity: number;
    freshness: number;
    tags: string[];
}
export interface UserPreferenceVector {
    preferredDifficulty: number;
    preferredMinDistance: number;
    preferredMaxDistance: number;
    preferredTags: string[];
    difficultyDistribution: Record<string, number>;
}
export interface ScoredTrail {
    trail: any;
    score: number;
    factors: {
        difficultyMatch: number;
        distance: number;
        rating: number;
        popularity: number;
        freshness: number;
    };
    userDistanceM?: number;
}
