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
exports.FollowsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const follows_service_1 = require("./follows.service");
const jwt_auth_guard_1 = require("../../common/guards/jwt-auth.guard");
const current_user_decorator_1 = require("../../common/decorators/current-user.decorator");
const follow_dto_1 = require("./dto/follow.dto");
function wrapResponse(data, meta) {
    return {
        success: true,
        data,
        meta,
    };
}
let FollowsController = class FollowsController {
    constructor(followsService) {
        this.followsService = followsService;
    }
    async followUser(currentUserId, targetUserId) {
        const result = await this.followsService.toggleFollow(currentUserId, targetUserId);
        return wrapResponse(result);
    }
    async unfollowUser(currentUserId, targetUserId) {
        const result = await this.followsService.toggleFollow(currentUserId, targetUserId);
        return wrapResponse(result);
    }
    async getFollowers(currentUserId, userId, query) {
        const result = await this.followsService.getFollowers(userId, query, currentUserId);
        return wrapResponse(result.list, {
            total: result.total,
            cursor: result.nextCursor,
            hasMore: result.hasMore,
        });
    }
    async getFollowing(currentUserId, userId, query) {
        const result = await this.followsService.getFollowing(userId, query, currentUserId);
        return wrapResponse(result.list, {
            total: result.total,
            cursor: result.nextCursor,
            hasMore: result.hasMore,
        });
    }
    async getFollowStatus(currentUserId, targetUserId) {
        const [currentUserStatus, targetUserStatus] = await Promise.all([
            this.followsService.checkFollowStatus(currentUserId, targetUserId),
            this.followsService.checkFollowStatus(targetUserId, currentUserId),
        ]);
        return wrapResponse({
            isFollowing: currentUserStatus.isFollowing,
            isMutual: currentUserStatus.isFollowing && targetUserStatus.isFollowing,
        });
    }
    async getFollowStats(currentUserId, userId) {
        const result = await this.followsService.getFollowStats(userId, currentUserId);
        return wrapResponse(result);
    }
    async getFollowSuggestions(currentUserId, limit = 10) {
        const result = await this.followsService.getSuggestions(currentUserId, limit);
        return wrapResponse(result.list, {
            total: result.total,
            cursor: result.nextCursor,
            hasMore: result.hasMore,
        });
    }
};
exports.FollowsController = FollowsController;
__decorate([
    (0, common_1.Post)(':id/follow'),
    (0, swagger_1.ApiOperation)({ summary: '关注用户' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '关注成功' }),
    (0, swagger_1.ApiResponse)({ status: 400, description: '不能关注自己' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: '用户不存在' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)('userId')),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], FollowsController.prototype, "followUser", null);
__decorate([
    (0, common_1.Delete)(':id/follow'),
    (0, swagger_1.ApiOperation)({ summary: '取消关注用户' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '取消关注成功' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: '用户不存在' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)('userId')),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], FollowsController.prototype, "unfollowUser", null);
__decorate([
    (0, common_1.Get)(':id/followers'),
    (0, swagger_1.ApiOperation)({ summary: '获取粉丝列表' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '获取成功' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)('userId')),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, follow_dto_1.QueryFollowsDto]),
    __metadata("design:returntype", Promise)
], FollowsController.prototype, "getFollowers", null);
__decorate([
    (0, common_1.Get)(':id/following'),
    (0, swagger_1.ApiOperation)({ summary: '获取关注列表' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '获取成功' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)('userId')),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, follow_dto_1.QueryFollowsDto]),
    __metadata("design:returntype", Promise)
], FollowsController.prototype, "getFollowing", null);
__decorate([
    (0, common_1.Get)(':id/follow-status'),
    (0, swagger_1.ApiOperation)({ summary: '获取关注状态' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '获取成功' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)('userId')),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], FollowsController.prototype, "getFollowStatus", null);
__decorate([
    (0, common_1.Get)(':id/follow-stats'),
    (0, swagger_1.ApiOperation)({ summary: '获取关注统计' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '获取成功' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)('userId')),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], FollowsController.prototype, "getFollowStats", null);
__decorate([
    (0, common_1.Get)('suggestions'),
    (0, swagger_1.ApiOperation)({ summary: '获取推荐关注用户' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '获取成功' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)('userId')),
    __param(1, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Number]),
    __metadata("design:returntype", Promise)
], FollowsController.prototype, "getFollowSuggestions", null);
exports.FollowsController = FollowsController = __decorate([
    (0, swagger_1.ApiTags)('关注系统'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Controller)('v1/users'),
    __metadata("design:paramtypes", [follows_service_1.FollowsService])
], FollowsController);
//# sourceMappingURL=follows.controller.js.map