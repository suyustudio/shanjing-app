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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserStatsController = exports.AchievementCacheController = exports.AchievementsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const jwt_auth_guard_1 = require("../../common/guards/jwt-auth.guard");
const admin_guard_1 = require("../../common/guards/admin.guard");
const achievements_service_1 = require("./achievements.service");
const achievement_dto_1 = require("./dto/achievement.dto");
let AchievementsController = class AchievementsController {
    constructor(achievementsService) {
        this.achievementsService = achievementsService;
    }
    async getAllAchievements() {
        return this.achievementsService.getAllAchievements();
    }
    async getAchievementById(id) {
        return this.achievementsService.getAchievementById(id);
    }
    async getMyAchievements(req) {
        return this.achievementsService.getUserAchievements(req.user.userId);
    }
    async getUserAchievements(userId) {
        return this.achievementsService.getUserAchievements(userId);
    }
    async checkAchievements(req, dto) {
        return this.achievementsService.checkAchievements(req.user.userId, dto);
    }
    async markAchievementViewed(req, achievementId) {
        await this.achievementsService.markAchievementViewed(req.user.userId, achievementId);
        return { success: true };
    }
    async markAllAchievementsViewed(req) {
        await this.achievementsService.markAllAchievementsViewed(req.user.userId);
        return { success: true };
    }
};
exports.AchievementsController = AchievementsController;
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: '获取所有成就定义', description: '获取系统中所有成就的定义列表，包含等级信息' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '成功获取成就列表',
        type: [achievement_dto_1.AchievementDto],
    }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], AchievementsController.prototype, "getAllAchievements", null);
__decorate([
    (0, common_1.Get)(':id'),
    (0, swagger_1.ApiOperation)({ summary: '获取单个成就定义', description: '根据ID获取成就的详细信息' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '成功获取成就信息',
        type: achievement_dto_1.AchievementDto,
    }),
    (0, swagger_1.ApiResponse)({ status: 404, description: '成就不存在' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], AchievementsController.prototype, "getAchievementById", null);
__decorate([
    (0, common_1.Get)('user/me'),
    (0, swagger_1.ApiOperation)({
        summary: '获取当前用户成就',
        description: '获取当前登录用户的所有成就状态和进度',
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '成功获取用户成就',
        type: achievement_dto_1.UserAchievementSummaryDto,
    }),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], AchievementsController.prototype, "getMyAchievements", null);
__decorate([
    (0, common_1.Get)('user/:userId'),
    (0, swagger_1.ApiOperation)({
        summary: '获取指定用户成就',
        description: '获取指定用户的成就列表（公开信息）',
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '成功获取用户成就',
        type: achievement_dto_1.UserAchievementSummaryDto,
    }),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], AchievementsController.prototype, "getUserAchievements", null);
__decorate([
    (0, common_1.Post)('check'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '检查并解锁成就',
        description: '根据用户行为检查是否满足成就解锁条件，通常在轨迹完成或分享后调用',
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '检查完成，返回新解锁的成就和进度更新',
        type: achievement_dto_1.CheckAchievementsResponseDto,
    }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, achievement_dto_1.CheckAchievementsRequestDto]),
    __metadata("design:returntype", Promise)
], AchievementsController.prototype, "checkAchievements", null);
__decorate([
    (0, common_1.Put)(':id/viewed'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '标记成就已查看',
        description: '标记指定成就的新解锁状态为已查看',
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '标记成功',
    }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], AchievementsController.prototype, "markAchievementViewed", null);
__decorate([
    (0, common_1.Put)('viewed/all'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '标记所有成就已查看',
        description: '将所有新解锁的成就标记为已查看',
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '标记成功',
    }),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], AchievementsController.prototype, "markAllAchievementsViewed", null);
exports.AchievementsController = AchievementsController = __decorate([
    (0, swagger_1.ApiTags)('成就系统'),
    (0, common_1.Controller)('achievements'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    __metadata("design:paramtypes", [achievements_service_1.AchievementsService])
], AchievementsController);
let AchievementCacheController = class AchievementCacheController {
    constructor(achievementsService) {
        this.achievementsService = achievementsService;
    }
    async clearAllCache() {
        await this.achievementsService.clearAllAchievementCache();
        return { success: true, message: '所有成就缓存已清除' };
    }
    async invalidateByTag(tag) {
        const deletedCount = await this.achievementsService.invalidateCacheByTag(tag);
        return { success: true, deletedCount };
    }
};
exports.AchievementCacheController = AchievementCacheController;
__decorate([
    (0, common_1.Delete)('all'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '清除所有成就缓存',
        description: '管理员接口：清除所有成就相关的缓存',
    }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '清除成功' }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], AchievementCacheController.prototype, "clearAllCache", null);
__decorate([
    (0, common_1.Delete)('by-tag'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '按标签清除缓存',
        description: '管理员接口：按指定标签批量清除缓存',
    }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '清除成功' }),
    __param(0, (0, common_1.Query)('tag')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], AchievementCacheController.prototype, "invalidateByTag", null);
exports.AchievementCacheController = AchievementCacheController = __decorate([
    (0, swagger_1.ApiTags)('成就缓存管理'),
    (0, common_1.Controller)('achievements/admin/cache'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, admin_guard_1.AdminGuard),
    (0, swagger_1.ApiBearerAuth)(),
    __metadata("design:paramtypes", [achievements_service_1.AchievementsService])
], AchievementCacheController);
let UserStatsController = class UserStatsController {
    constructor(achievementsService) {
        this.achievementsService = achievementsService;
    }
    async getUserStats(req) {
        return this.achievementsService.getUserStats(req.user.userId);
    }
};
exports.UserStatsController = UserStatsController;
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({
        summary: '获取用户统计',
        description: '获取当前用户的徒步统计数据',
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '成功获取用户统计',
        type: achievement_dto_1.UserStatsDto,
    }),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], UserStatsController.prototype, "getUserStats", null);
exports.UserStatsController = UserStatsController = __decorate([
    (0, swagger_1.ApiTags)('用户统计'),
    (0, common_1.Controller)('users/me/stats'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    __metadata("design:paramtypes", [achievements_service_1.AchievementsService])
], UserStatsController);
//# sourceMappingURL=achievements.controller.js.map