// ================================================================
// M6: 关注系统 DTO
// ================================================================

import { IsString, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

// ==================== 查询参数 ====================
export class QueryFollowsDto {
  @ApiPropertyOptional({ description: '游标 (用于分页)' })
  @IsString()
  @IsOptional()
  cursor?: string;

  @ApiPropertyOptional({ description: '每页数量', default: 20 })
  @IsOptional()
  limit?: number = 20;
}

// ==================== 响应 DTO ====================
export class FollowUserDto {
  id: string;
  nickname: string | null;
  avatarUrl: string | null;
  bio?: string | null;
  followersCount: number;
  isFollowing?: boolean;
  mutualFollows?: number; // 共同关注数
}

export class FollowListResponseDto {
  list: FollowUserDto[];
  nextCursor: string | null;
  hasMore: boolean;
  total: number;
}

export class FollowStatsDto {
  followersCount: number;
  followingCount: number;
  isFollowing: boolean;
}

export class FollowActionResponseDto {
  isFollowing: boolean;
  followersCount: number;
  followingCount: number;
}
