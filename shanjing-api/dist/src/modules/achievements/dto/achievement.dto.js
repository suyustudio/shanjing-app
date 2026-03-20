"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserStatsDto = exports.CheckAchievementsResponseDto = exports.ProgressUpdateDto = exports.NewlyUnlockedAchievementDto = exports.CheckAchievementsRequestDto = exports.UserAchievementSummaryDto = exports.UserAchievementDto = exports.AchievementDto = exports.AchievementLevelDto = exports.TrailStatsDto = void 0;
const class_validator_1 = require("class-validator");
const class_transformer_1 = require("class-transformer");
const swagger_1 = require("@nestjs/swagger");
const client_1 = require("@prisma/client");
class TrailStatsDto {
}
exports.TrailStatsDto = TrailStatsDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '距离（米）' }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(0),
    (0, class_validator_1.Max)(1000000),
    __metadata("design:type", Number)
], TrailStatsDto.prototype, "distance", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '时长（秒）' }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(0),
    (0, class_validator_1.Max)(86400),
    __metadata("design:type", Number)
], TrailStatsDto.prototype, "duration", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否夜间' }),
    (0, class_validator_1.IsBoolean)(),
    __metadata("design:type", Boolean)
], TrailStatsDto.prototype, "isNight", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否雨天' }),
    (0, class_validator_1.IsBoolean)(),
    __metadata("design:type", Boolean)
], TrailStatsDto.prototype, "isRain", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否独自' }),
    (0, class_validator_1.IsBoolean)(),
    __metadata("design:type", Boolean)
], TrailStatsDto.prototype, "isSolo", void 0);
class AchievementLevelDto {
}
exports.AchievementLevelDto = AchievementLevelDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '等级ID' }),
    (0, class_validator_1.IsUUID)(),
    __metadata("design:type", String)
], AchievementLevelDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '等级', enum: client_1.AchievementLevelEnum }),
    (0, class_validator_1.IsEnum)(client_1.AchievementLevelEnum),
    __metadata("design:type", String)
], AchievementLevelDto.prototype, "level", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '达成条件数值' }),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], AchievementLevelDto.prototype, "requirement", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '等级名称' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], AchievementLevelDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '等级描述', required: false }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], AchievementLevelDto.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '奖励说明', required: false }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], AchievementLevelDto.prototype, "reward", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '等级图标URL', required: false }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], AchievementLevelDto.prototype, "iconUrl", void 0);
class AchievementDto {
}
exports.AchievementDto = AchievementDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '成就ID' }),
    (0, class_validator_1.IsUUID)(),
    __metadata("design:type", String)
], AchievementDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '成就标识符' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], AchievementDto.prototype, "key", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '成就名称' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], AchievementDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '成就描述', required: false }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], AchievementDto.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '成就类别', enum: client_1.AchievementCategory }),
    (0, class_validator_1.IsEnum)(client_1.AchievementCategory),
    __metadata("design:type", String)
], AchievementDto.prototype, "category", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '成就图标URL', required: false }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], AchievementDto.prototype, "iconUrl", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否为隐藏成就' }),
    (0, class_validator_1.IsBoolean)(),
    __metadata("design:type", Boolean)
], AchievementDto.prototype, "isHidden", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '排序权重' }),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], AchievementDto.prototype, "sortOrder", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '成就等级列表', type: [AchievementLevelDto] }),
    __metadata("design:type", Array)
], AchievementDto.prototype, "levels", void 0);
class UserAchievementDto {
}
exports.UserAchievementDto = UserAchievementDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '成就ID' }),
    (0, class_validator_1.IsUUID)(),
    __metadata("design:type", String)
], UserAchievementDto.prototype, "achievementId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '成就标识符' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UserAchievementDto.prototype, "key", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '成就名称' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UserAchievementDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '成就类别' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UserAchievementDto.prototype, "category", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '当前等级', required: false }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UserAchievementDto.prototype, "currentLevel", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '当前进度值' }),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], UserAchievementDto.prototype, "currentProgress", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '下一级需求值' }),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], UserAchievementDto.prototype, "nextRequirement", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '进度百分比' }),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], UserAchievementDto.prototype, "percentage", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '解锁时间', required: false }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Date)
], UserAchievementDto.prototype, "unlockedAt", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否新解锁' }),
    (0, class_validator_1.IsBoolean)(),
    __metadata("design:type", Boolean)
], UserAchievementDto.prototype, "isNew", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否已解锁' }),
    (0, class_validator_1.IsBoolean)(),
    __metadata("design:type", Boolean)
], UserAchievementDto.prototype, "isUnlocked", void 0);
class UserAchievementSummaryDto {
}
exports.UserAchievementSummaryDto = UserAchievementSummaryDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '成就总数' }),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], UserAchievementSummaryDto.prototype, "totalCount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '已解锁数量' }),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], UserAchievementSummaryDto.prototype, "unlockedCount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '新解锁数量' }),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], UserAchievementSummaryDto.prototype, "newUnlockedCount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '用户成就列表', type: [UserAchievementDto] }),
    __metadata("design:type", Array)
], UserAchievementSummaryDto.prototype, "achievements", void 0);
class CheckAchievementsRequestDto {
}
exports.CheckAchievementsRequestDto = CheckAchievementsRequestDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '触发类型', enum: ['trail_completed', 'share', 'manual'] }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsEnum)(['trail_completed', 'share', 'manual'], {
        message: 'triggerType 必须是 trail_completed, share 或 manual',
    }),
    __metadata("design:type", String)
], CheckAchievementsRequestDto.prototype, "triggerType", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路线ID', required: false }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MinLength)(1, { message: 'trailId 不能为空字符串' }),
    (0, class_validator_1.MaxLength)(64, { message: 'trailId 长度不能超过64' }),
    __metadata("design:type", String)
], CheckAchievementsRequestDto.prototype, "trailId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '轨迹统计数据', required: false, type: TrailStatsDto }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.ValidateNested)(),
    (0, class_transformer_1.Type)(() => TrailStatsDto),
    __metadata("design:type", TrailStatsDto)
], CheckAchievementsRequestDto.prototype, "stats", void 0);
class NewlyUnlockedAchievementDto {
}
exports.NewlyUnlockedAchievementDto = NewlyUnlockedAchievementDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '成就ID' }),
    (0, class_validator_1.IsUUID)(),
    __metadata("design:type", String)
], NewlyUnlockedAchievementDto.prototype, "achievementId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '等级' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], NewlyUnlockedAchievementDto.prototype, "level", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '成就名称' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], NewlyUnlockedAchievementDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '解锁消息' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], NewlyUnlockedAchievementDto.prototype, "message", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '徽章URL' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], NewlyUnlockedAchievementDto.prototype, "badgeUrl", void 0);
class ProgressUpdateDto {
}
exports.ProgressUpdateDto = ProgressUpdateDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '成就ID' }),
    (0, class_validator_1.IsUUID)(),
    __metadata("design:type", String)
], ProgressUpdateDto.prototype, "achievementId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '当前进度' }),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], ProgressUpdateDto.prototype, "progress", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '需求值' }),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], ProgressUpdateDto.prototype, "requirement", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '进度百分比' }),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], ProgressUpdateDto.prototype, "percentage", void 0);
class CheckAchievementsResponseDto {
}
exports.CheckAchievementsResponseDto = CheckAchievementsResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '新解锁成就列表', type: [NewlyUnlockedAchievementDto] }),
    __metadata("design:type", Array)
], CheckAchievementsResponseDto.prototype, "newlyUnlocked", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '进度更新列表', type: [ProgressUpdateDto] }),
    __metadata("design:type", Array)
], CheckAchievementsResponseDto.prototype, "progressUpdated", void 0);
class UserStatsDto {
}
exports.UserStatsDto = UserStatsDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '累计距离（米）' }),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], UserStatsDto.prototype, "totalDistanceM", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '累计时长（秒）' }),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], UserStatsDto.prototype, "totalDurationSec", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '累计爬升（米）' }),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], UserStatsDto.prototype, "totalElevationGainM", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '完成的不同路线数' }),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], UserStatsDto.prototype, "uniqueTrailsCount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '当前连续周数' }),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], UserStatsDto.prototype, "currentWeeklyStreak", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '最长连续周数' }),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], UserStatsDto.prototype, "longestWeeklyStreak", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '夜间徒步次数' }),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], UserStatsDto.prototype, "nightTrailCount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '雨天徒步次数' }),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], UserStatsDto.prototype, "rainTrailCount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '分享次数' }),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], UserStatsDto.prototype, "shareCount", void 0);
//# sourceMappingURL=achievement.dto.js.map