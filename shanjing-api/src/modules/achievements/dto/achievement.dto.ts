// ================================================================
// Achievement DTOs
// 成就系统数据传输对象
// ================================================================

import { IsString, IsNumber, IsBoolean, IsOptional, IsEnum, IsUUID } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { AchievementCategory, AchievementLevelEnum } from '@prisma/client';

// ==================== 成就等级 DTO ====================

export class AchievementLevelDto {
  @ApiProperty({ description: '等级ID' })
  @IsUUID()
  id: string;

  @ApiProperty({ description: '等级', enum: AchievementLevelEnum })
  @IsEnum(AchievementLevelEnum)
  level: AchievementLevelEnum;

  @ApiProperty({ description: '达成条件数值' })
  @IsNumber()
  requirement: number;

  @ApiProperty({ description: '等级名称' })
  @IsString()
  name: string;

  @ApiProperty({ description: '等级描述', required: false })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ description: '奖励说明', required: false })
  @IsOptional()
  @IsString()
  reward?: string;

  @ApiProperty({ description: '等级图标URL', required: false })
  @IsOptional()
  @IsString()
  iconUrl?: string;
}

// ==================== 成就定义 DTO ====================

export class AchievementDto {
  @ApiProperty({ description: '成就ID' })
  @IsUUID()
  id: string;

  @ApiProperty({ description: '成就标识符' })
  @IsString()
  key: string;

  @ApiProperty({ description: '成就名称' })
  @IsString()
  name: string;

  @ApiProperty({ description: '成就描述', required: false })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ description: '成就类别', enum: AchievementCategory })
  @IsEnum(AchievementCategory)
  category: AchievementCategory;

  @ApiProperty({ description: '成就图标URL', required: false })
  @IsOptional()
  @IsString()
  iconUrl?: string;

  @ApiProperty({ description: '是否为隐藏成就' })
  @IsBoolean()
  isHidden: boolean;

  @ApiProperty({ description: '排序权重' })
  @IsNumber()
  sortOrder: number;

  @ApiProperty({ description: '成就等级列表', type: [AchievementLevelDto] })
  levels: AchievementLevelDto[];
}

// ==================== 用户成就 DTO ====================

export class UserAchievementDto {
  @ApiProperty({ description: '成就ID' })
  @IsUUID()
  achievementId: string;

  @ApiProperty({ description: '成就标识符' })
  @IsString()
  key: string;

  @ApiProperty({ description: '成就名称' })
  @IsString()
  name: string;

  @ApiProperty({ description: '成就类别' })
  @IsString()
  category: string;

  @ApiProperty({ description: '当前等级', required: false })
  @IsOptional()
  @IsString()
  currentLevel?: string;

  @ApiProperty({ description: '当前进度值' })
  @IsNumber()
  currentProgress: number;

  @ApiProperty({ description: '下一级需求值' })
  @IsNumber()
  nextRequirement: number;

  @ApiProperty({ description: '进度百分比' })
  @IsNumber()
  percentage: number;

  @ApiProperty({ description: '解锁时间', required: false })
  @IsOptional()
  unlockedAt?: Date;

  @ApiProperty({ description: '是否新解锁' })
  @IsBoolean()
  isNew: boolean;

  @ApiProperty({ description: '是否已解锁' })
  @IsBoolean()
  isUnlocked: boolean;
}

export class UserAchievementSummaryDto {
  @ApiProperty({ description: '成就总数' })
  @IsNumber()
  totalCount: number;

  @ApiProperty({ description: '已解锁数量' })
  @IsNumber()
  unlockedCount: number;

  @ApiProperty({ description: '新解锁数量' })
  @IsNumber()
  newUnlockedCount: number;

  @ApiProperty({ description: '用户成就列表', type: [UserAchievementDto] })
  achievements: UserAchievementDto[];
}

// ==================== 检查成就请求 DTO ====================

export class CheckAchievementsRequestDto {
  @ApiProperty({ description: '触发类型', enum: ['trail_completed', 'share', 'manual'] })
  @IsString()
  triggerType: 'trail_completed' | 'share' | 'manual';

  @ApiProperty({ description: '路线ID', required: false })
  @IsOptional()
  @IsString()
  trailId?: string;

  @ApiProperty({ description: '轨迹统计数据', required: false })
  @IsOptional()
  stats?: {
    distance: number;      // 距离（米）
    duration: number;      // 时长（秒）
    isNight: boolean;      // 是否夜间
    isRain: boolean;       // 是否雨天
    isSolo: boolean;       // 是否独自
  };
}

// ==================== 新解锁成就 DTO ====================

export class NewlyUnlockedAchievementDto {
  @ApiProperty({ description: '成就ID' })
  @IsUUID()
  achievementId: string;

  @ApiProperty({ description: '等级' })
  @IsString()
  level: string;

  @ApiProperty({ description: '成就名称' })
  @IsString()
  name: string;

  @ApiProperty({ description: '解锁消息' })
  @IsString()
  message: string;

  @ApiProperty({ description: '徽章URL' })
  @IsString()
  badgeUrl: string;
}

// ==================== 进度更新 DTO ====================

export class ProgressUpdateDto {
  @ApiProperty({ description: '成就ID' })
  @IsUUID()
  achievementId: string;

  @ApiProperty({ description: '当前进度' })
  @IsNumber()
  progress: number;

  @ApiProperty({ description: '需求值' })
  @IsNumber()
  requirement: number;

  @ApiProperty({ description: '进度百分比' })
  @IsNumber()
  percentage: number;
}

// ==================== 检查成就响应 DTO ====================

export class CheckAchievementsResponseDto {
  @ApiProperty({ description: '新解锁成就列表', type: [NewlyUnlockedAchievementDto] })
  newlyUnlocked: NewlyUnlockedAchievementDto[];

  @ApiProperty({ description: '进度更新列表', type: [ProgressUpdateDto] })
  progressUpdated: ProgressUpdateDto[];
}

// ==================== 用户统计 DTO ====================

export class UserStatsDto {
  @ApiProperty({ description: '累计距离（米）' })
  @IsNumber()
  totalDistanceM: number;

  @ApiProperty({ description: '累计时长（秒）' })
  @IsNumber()
  totalDurationSec: number;

  @ApiProperty({ description: '累计爬升（米）' })
  @IsNumber()
  totalElevationGainM: number;

  @ApiProperty({ description: '完成的不同路线数' })
  @IsNumber()
  uniqueTrailsCount: number;

  @ApiProperty({ description: '当前连续周数' })
  @IsNumber()
  currentWeeklyStreak: number;

  @ApiProperty({ description: '最长连续周数' })
  @IsNumber()
  longestWeeklyStreak: number;

  @ApiProperty({ description: '夜间徒步次数' })
  @IsNumber()
  nightTrailCount: number;

  @ApiProperty({ description: '雨天徒步次数' })
  @IsNumber()
  rainTrailCount: number;

  @ApiProperty({ description: '分享次数' })
  @IsNumber()
  shareCount: number;
}

// ==================== 更新用户统计 DTO ====================

export class UpdateUserStatsDto {
  @ApiProperty({ description: '距离（米）' })
  @IsNumber()
  @IsOptional()
  distance?: number;

  @ApiProperty({ description: '时长（秒）' })
  @IsNumber()
  @IsOptional()
  duration?: number;

  @ApiProperty({ description: '爬升（米）' })
  @IsNumber()
  @IsOptional()
  elevationGain?: number;

  @ApiProperty({ description: '路线ID' })
  @IsString()
  @IsOptional()
  trailId?: string;

  @ApiProperty({ description: '是否夜间' })
  @IsBoolean()
  @IsOptional()
  isNight?: boolean;

  @ApiProperty({ description: '是否雨天' })
  @IsBoolean()
  @IsOptional()
  isRain?: boolean;

  @ApiProperty({ description: '是否独自' })
  @IsBoolean()
  @IsOptional()
  isSolo?: boolean;
}
