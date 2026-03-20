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
exports.RecommendationController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const recommendation_service_1 = require("./services/recommendation.service");
const jwt_auth_guard_1 = require("../../../common/guards/jwt-auth.guard");
const recommendation_dto_1 = require("./dto/recommendation.dto");
let RecommendationController = class RecommendationController {
    constructor(recommendationService) {
        this.recommendationService = recommendationService;
    }
    async getRecommendations(dto, req) {
        const userId = req.user?.userId;
        const result = await this.recommendationService.getRecommendations(dto, userId);
        return { success: true, data: result };
    }
    async recordFeedback(dto, req) {
        const userId = req.user?.userId;
        const result = await this.recommendationService.recordFeedback(dto, userId);
        return result;
    }
    async recordImpression(dto, req) {
        const userId = req.user?.userId;
        const result = await this.recommendationService.recordImpression(dto, userId);
        return result;
    }
};
exports.RecommendationController = RecommendationController;
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: '获取个性化推荐路线' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '获取推荐成功',
        type: recommendation_dto_1.RecommendationsResponseDto,
    }),
    __param(0, (0, common_1.Query)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [recommendation_dto_1.GetRecommendationsDto, Object]),
    __metadata("design:returntype", Promise)
], RecommendationController.prototype, "getRecommendations", null);
__decorate([
    (0, common_1.Post)('feedback'),
    (0, swagger_1.ApiOperation)({ summary: '记录用户反馈' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '反馈记录成功',
    }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [recommendation_dto_1.FeedbackDto, Object]),
    __metadata("design:returntype", Promise)
], RecommendationController.prototype, "recordFeedback", null);
__decorate([
    (0, common_1.Post)('impression'),
    (0, swagger_1.ApiOperation)({ summary: '记录推荐曝光事件' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '曝光记录成功',
    }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [recommendation_dto_1.ImpressionDto, Object]),
    __metadata("design:returntype", Promise)
], RecommendationController.prototype, "recordImpression", null);
exports.RecommendationController = RecommendationController = __decorate([
    (0, swagger_1.ApiTags)('推荐'),
    (0, common_1.Controller)('api/recommendations'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    __metadata("design:paramtypes", [recommendation_service_1.RecommendationService])
], RecommendationController);
//# sourceMappingURL=recommendation.controller.js.map