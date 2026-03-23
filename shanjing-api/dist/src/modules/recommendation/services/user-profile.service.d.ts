import { PrismaService } from '../../../database/prisma.service';
import { UserPreferenceVector } from '../dto/recommendation.dto';
export declare class UserProfileService {
    private prisma;
    constructor(prisma: PrismaService);
    getOrCreateProfile(userId: string): Promise<{
        userId: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        preferredDifficulty: string | null;
        preferredMinDistanceKm: number | null;
        preferredMaxDistanceKm: number | null;
        preferredTags: string[];
        totalCompletedTrails: number;
        totalDistanceKm: number;
        totalDurationMin: number;
        avgRatingGiven: number | null;
        difficultyVector: import("@prisma/client/runtime/library").JsonValue | null;
        tagVector: import("@prisma/client/runtime/library").JsonValue | null;
        isColdStart: boolean;
    }>;
    getUserPreferenceVector(userId: string): Promise<UserPreferenceVector>;
    updateProfile(userId: string): Promise<void>;
    recordInteraction(userId: string, trailId: string, interactionType: string, metadata?: {
        rating?: number;
        durationSec?: number;
        source?: string;
    }): Promise<void>;
    getColdStartRecommendations(limit?: number): Promise<any[]>;
    private difficultyToNumber;
}
