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
exports.TrailsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const trails_service_1 = require("./trails.service");
const current_user_decorator_1 = require("../../common/decorators/current-user.decorator");
const trail_dto_1 = require("./dto/trail.dto");
let TrailsController = class TrailsController {
    constructor(trailsService) {
        this.trailsService = trailsService;
    }
    async getTrailList(query, userId) {
        return this.trailsService.getTrailList(query, userId);
    }
    async getRecommendedTrails(limit = 10, userId) {
        return this.trailsService.getRecommendedTrails(limit, userId);
    }
    async getNearbyTrails(query, userId) {
        return this.trailsService.getNearbyTrails(query, userId);
    }
    async getTrailById(trailId, userId) {
        return this.trailsService.getTrailById(trailId, userId);
    }
};
exports.TrailsController = TrailsController;
__decorate([
    (0, common_1.Get)(),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '获取路线列表',
        description: '支持搜索、筛选、分页获取路线列表'
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '获取成功',
        type: trail_dto_1.TrailListResponseDto,
    }),
    (0, swagger_1.ApiQuery)({ name: 'keyword', required: false, description: '搜索关键词' }),
    (0, swagger_1.ApiQuery)({ name: 'city', required: false, description: '城市' }),
    (0, swagger_1.ApiQuery)({ name: 'district', required: false, description: '区域' }),
    (0, swagger_1.ApiQuery)({ name: 'difficulty', required: false, description: '难度级别 (EASY/MODERATE/HARD)' }),
    (0, swagger_1.ApiQuery)({ name: 'tag', required: false, description: '标签筛选' }),
    (0, swagger_1.ApiQuery)({ name: 'page', required: false, description: '页码', type: Number }),
    (0, swagger_1.ApiQuery)({ name: 'limit', required: false, description: '每页数量', type: Number }),
    __param(0, (0, common_1.Query)()),
    __param(1, (0, current_user_decorator_1.CurrentUser)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [trail_dto_1.TrailListQueryDto, String]),
    __metadata("design:returntype", Promise)
], TrailsController.prototype, "getTrailList", null);
__decorate([
    (0, common_1.Get)('recommended'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '获取推荐路线',
        description: '基于收藏数和热度获取推荐路线'
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '获取成功',
        type: trail_dto_1.RecommendedTrailsResponseDto,
    }),
    (0, swagger_1.ApiQuery)({ name: 'limit', required: false, description: '数量限制', type: Number }),
    __param(0, (0, common_1.Query)('limit')),
    __param(1, (0, current_user_decorator_1.CurrentUser)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, String]),
    __metadata("design:returntype", Promise)
], TrailsController.prototype, "getRecommendedTrails", null);
__decorate([
    (0, common_1.Get)('nearby'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '获取附近路线',
        description: '基于当前坐标获取附近路线'
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '获取成功',
    }),
    (0, swagger_1.ApiQuery)({ name: 'lat', required: true, description: '纬度', type: Number }),
    (0, swagger_1.ApiQuery)({ name: 'lng', required: true, description: '经度', type: Number }),
    (0, swagger_1.ApiQuery)({ name: 'radius', required: false, description: '搜索半径（公里）', type: Number }),
    (0, swagger_1.ApiQuery)({ name: 'limit', required: false, description: '数量限制', type: Number }),
    __param(0, (0, common_1.Query)()),
    __param(1, (0, current_user_decorator_1.CurrentUser)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [trail_dto_1.NearbyTrailsQueryDto, String]),
    __metadata("design:returntype", Promise)
], TrailsController.prototype, "getNearbyTrails", null);
__decorate([
    (0, common_1.Get)(':id'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '获取路线详情',
        description: '获取指定路线的详细信息'
    }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '路线ID' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '获取成功',
        type: trail_dto_1.TrailDetailResponseDto,
    }),
    (0, swagger_1.ApiResponse)({ status: 404, description: '路线不存在' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, current_user_decorator_1.CurrentUser)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], TrailsController.prototype, "getTrailById", null);
exports.TrailsController = TrailsController = __decorate([
    (0, swagger_1.ApiTags)('路线'),
    (0, common_1.Controller)('trails'),
    __metadata("design:paramtypes", [trails_service_1.TrailsService])
], TrailsController);
//# sourceMappingURL=trails.controller.js.map