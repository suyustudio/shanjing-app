import { FollowsService } from './follows.service';
import { QueryFollowsDto, FollowStatsDto, FollowActionResponseDto } from './dto/follow.dto';
export declare class FollowsController {
    private readonly followsService;
    constructor(followsService: FollowsService);
    followUser(currentUserId: string, targetUserId: string): Promise<{
        success: boolean;
        data: FollowActionResponseDto;
        meta: any;
    }>;
    unfollowUser(currentUserId: string, targetUserId: string): Promise<{
        success: boolean;
        data: FollowActionResponseDto;
        meta: any;
    }>;
    getFollowers(currentUserId: string, userId: string, query: QueryFollowsDto): Promise<{
        success: boolean;
        data: import("./dto/follow.dto").FollowUserDto[];
        meta: any;
    }>;
    getFollowing(currentUserId: string, userId: string, query: QueryFollowsDto): Promise<{
        success: boolean;
        data: import("./dto/follow.dto").FollowUserDto[];
        meta: any;
    }>;
    getFollowStatus(currentUserId: string, targetUserId: string): Promise<{
        success: boolean;
        data: {
            isFollowing: boolean;
            isMutual: boolean;
        };
        meta: any;
    }>;
    getFollowStats(currentUserId: string, userId: string): Promise<{
        success: boolean;
        data: FollowStatsDto;
        meta: any;
    }>;
    getFollowSuggestions(currentUserId: string, limit?: number): Promise<{
        success: boolean;
        data: import("./dto/follow.dto").FollowUserDto[];
        meta: any;
    }>;
}
