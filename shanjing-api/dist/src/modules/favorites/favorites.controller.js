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
exports.FavoritesController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const favorites_service_1 = require("./favorites.service");
const current_user_decorator_1 = require("../../common/decorators/current-user.decorator");
const jwt_auth_guard_1 = require("../../common/guards/jwt-auth.guard");
const favorite_dto_1 = require("./dto/favorite.dto");
let FavoritesController = class FavoritesController {
    constructor(favoritesService) {
        this.favoritesService = favoritesService;
    }
    async getUserFavorites(userId, query) {
        return this.favoritesService.getUserFavorites(userId, query);
    }
    async addFavorite(userId, dto) {
        return this.favoritesService.addFavorite(userId, dto.trailId);
    }
    async removeFavorite(userId, trailId) {
        return this.favoritesService.removeFavorite(userId, trailId);
    }
    async toggleFavorite(userId, dto) {
        return this.favoritesService.toggleFavorite(userId, dto.trailId);
    }
    async checkFavoriteStatus(userId, trailId) {
        return this.favoritesService.checkFavoriteStatus(userId, trailId);
    }
};
exports.FavoritesController = FavoritesController;
__decorate([
    (0, common_1.Get)(),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '获取收藏列表',
        description: '获取当前用户的收藏路线列表'
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '获取成功',
        type: favorite_dto_1.FavoriteListResponseDto,
    }),
    (0, swagger_1.ApiResponse)({ status: 401, description: '未授权' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)('userId')),
    __param(1, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, favorite_dto_1.FavoriteListQueryDto]),
    __metadata("design:returntype", Promise)
], FavoritesController.prototype, "getUserFavorites", null);
__decorate([
    (0, common_1.Post)(),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '添加收藏',
        description: '收藏指定路线'
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '收藏成功',
        type: favorite_dto_1.FavoriteActionResponseDto,
    }),
    (0, swagger_1.ApiResponse)({ status: 400, description: '参数错误' }),
    (0, swagger_1.ApiResponse)({ status: 401, description: '未授权' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: '路线不存在' }),
    (0, swagger_1.ApiResponse)({ status: 409, description: '已收藏过该路线' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)('userId')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, favorite_dto_1.AddFavoriteDto]),
    __metadata("design:returntype", Promise)
], FavoritesController.prototype, "addFavorite", null);
__decorate([
    (0, common_1.Delete)(':trailId'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '取消收藏',
        description: '取消收藏指定路线'
    }),
    (0, swagger_1.ApiParam)({ name: 'trailId', description: '路线ID' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '取消收藏成功',
        type: favorite_dto_1.FavoriteActionResponseDto,
    }),
    (0, swagger_1.ApiResponse)({ status: 401, description: '未授权' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: '未找到收藏记录' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)('userId')),
    __param(1, (0, common_1.Param)('trailId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], FavoritesController.prototype, "removeFavorite", null);
__decorate([
    (0, common_1.Post)('toggle'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '切换收藏状态',
        description: '如果已收藏则取消，未收藏则添加'
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '操作成功',
        type: favorite_dto_1.FavoriteActionResponseDto,
    }),
    (0, swagger_1.ApiResponse)({ status: 400, description: '参数错误' }),
    (0, swagger_1.ApiResponse)({ status: 401, description: '未授权' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: '路线不存在' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)('userId')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, favorite_dto_1.AddFavoriteDto]),
    __metadata("design:returntype", Promise)
], FavoritesController.prototype, "toggleFavorite", null);
__decorate([
    (0, common_1.Get)('status/:trailId'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '检查收藏状态',
        description: '检查当前用户是否已收藏指定路线'
    }),
    (0, swagger_1.ApiParam)({ name: 'trailId', description: '路线ID' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '获取成功',
        type: favorite_dto_1.FavoriteStatusResponseDto,
    }),
    (0, swagger_1.ApiResponse)({ status: 401, description: '未授权' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)('userId')),
    __param(1, (0, common_1.Param)('trailId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], FavoritesController.prototype, "checkFavoriteStatus", null);
exports.FavoritesController = FavoritesController = __decorate([
    (0, swagger_1.ApiTags)('收藏'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Controller)('favorites'),
    __metadata("design:paramtypes", [favorites_service_1.FavoritesService])
], FavoritesController);
//# sourceMappingURL=favorites.controller.js.map