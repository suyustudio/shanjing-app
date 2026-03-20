import { PrismaService } from '../../database/prisma.service';
import { QueryFollowsDto, FollowListResponseDto, FollowStatsDto, FollowActionResponseDto } from './dto/follow.dto';
export declare class FollowsService {
    private prisma;
    constructor(prisma: PrismaService);
    toggleFollow(followerId: string, followingId: string): Promise<FollowActionResponseDto>;
    getFollowing(userId: string, query: QueryFollowsDto, currentUserId?: string): Promise<FollowListResponseDto>;
    getFollowers(userId: string, query: QueryFollowsDto, currentUserId?: string): Promise<FollowListResponseDto>;
    getFollowStats(userId: string, currentUserId?: string): Promise<FollowStatsDto>;
    checkFollowStatus(followerId: string, followingId: string): Promise<{
        isFollowing: boolean;
    }>;
    getSuggestions(userId: string, limit?: number): Promise<FollowListResponseDto>;
}
