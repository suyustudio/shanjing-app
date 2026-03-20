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
exports.ReviewsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const reviews_service_1 = require("./reviews.service");
const review_dto_1 = require("./dto/review.dto");
const jwt_auth_guard_1 = require("../../common/guards/jwt-auth.guard");
function wrapResponse(data, meta) {
    return {
        success: true,
        data,
        meta,
    };
}
let ReviewsController = class ReviewsController {
    constructor(reviewsService) {
        this.reviewsService = reviewsService;
    }
    async createReview(req, trailId, dto) {
        const review = await this.reviewsService.createReview(req.user.userId, trailId, dto);
        return wrapResponse(review);
    }
    async getReviews(req, trailId, query) {
        const currentUserId = req.user?.userId;
        const result = await this.reviewsService.getReviews(trailId, query, currentUserId);
        return wrapResponse(result, {
            total: result.total,
            page: result.page,
            limit: result.limit,
        });
    }
    async getReviewDetail(req, id) {
        const currentUserId = req.user?.userId;
        const review = await this.reviewsService.getReviewDetail(id, currentUserId);
        return wrapResponse(review);
    }
    async updateReview(req, id, dto) {
        const review = await this.reviewsService.updateReview(req.user.userId, id, dto);
        return wrapResponse(review);
    }
    async deleteReview(req, id) {
        await this.reviewsService.deleteReview(req.user.userId, id);
        return wrapResponse({ message: '删除成功' });
    }
    async likeReview(req, id) {
        const result = await this.reviewsService.likeReview(req.user.userId, id);
        return wrapResponse(result);
    }
    async checkLikeStatus(req, id) {
        const isLiked = await this.reviewsService.checkUserLikedReview(req.user.userId, id);
        return wrapResponse({ isLiked });
    }
    async createReply(req, id, dto) {
        const reply = await this.reviewsService.createReply(req.user.userId, id, dto);
        return wrapResponse(reply);
    }
    async getReplies(id) {
        const replies = await this.reviewsService.getReplies(id);
        return wrapResponse(replies);
    }
    async reportReview(req, id, dto) {
        await this.reviewsService.reportReview(req.user.userId, id, dto.reason);
        return wrapResponse({ message: '举报成功' });
    }
};
exports.ReviewsController = ReviewsController;
__decorate([
    (0, common_1.Post)('trails/:trailId/reviews'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: '发表评论' }),
    (0, swagger_1.ApiParam)({ name: 'trailId', description: '路线ID' }),
    (0, swagger_1.ApiResponse)({ status: 201, description: '评论成功', type: review_dto_1.ReviewDto }),
    (0, swagger_1.ApiResponse)({ status: 400, description: '参数错误或已评论过' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: '路线不存在' }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('trailId')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, review_dto_1.CreateReviewDto]),
    __metadata("design:returntype", Promise)
], ReviewsController.prototype, "createReview", null);
__decorate([
    (0, common_1.Get)('trails/:trailId/reviews'),
    (0, swagger_1.ApiOperation)({ summary: '获取路线评论列表' }),
    (0, swagger_1.ApiParam)({ name: 'trailId', description: '路线ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '获取成功', type: review_dto_1.ReviewListResponseDto }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('trailId')),
    __param(2, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, review_dto_1.QueryReviewsDto]),
    __metadata("design:returntype", Promise)
], ReviewsController.prototype, "getReviews", null);
__decorate([
    (0, common_1.Get)('reviews/:id'),
    (0, swagger_1.ApiOperation)({ summary: '获取评论详情' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '评论ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '获取成功', type: review_dto_1.ReviewDetailDto }),
    (0, swagger_1.ApiResponse)({ status: 404, description: '评论不存在' }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], ReviewsController.prototype, "getReviewDetail", null);
__decorate([
    (0, common_1.Put)('reviews/:id'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: '编辑评论' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '评论ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '更新成功', type: review_dto_1.ReviewDto }),
    (0, swagger_1.ApiResponse)({ status: 403, description: '无权修改或超过24小时' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: '评论不存在' }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, review_dto_1.UpdateReviewDto]),
    __metadata("design:returntype", Promise)
], ReviewsController.prototype, "updateReview", null);
__decorate([
    (0, common_1.Delete)('reviews/:id'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: '删除评论' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '评论ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '删除成功' }),
    (0, swagger_1.ApiResponse)({ status: 403, description: '无权删除' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: '评论不存在' }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], ReviewsController.prototype, "deleteReview", null);
__decorate([
    (0, common_1.Post)('reviews/:id/like'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: '点赞/取消点赞评论' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '评论ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '操作成功', type: review_dto_1.LikeReviewResponseDto }),
    (0, swagger_1.ApiResponse)({ status: 404, description: '评论不存在' }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], ReviewsController.prototype, "likeReview", null);
__decorate([
    (0, common_1.Get)('reviews/:id/like'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: '检查是否已点赞评论' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '评论ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '查询成功' }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], ReviewsController.prototype, "checkLikeStatus", null);
__decorate([
    (0, common_1.Post)('reviews/:id/replies'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: '回复评论' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '评论ID' }),
    (0, swagger_1.ApiResponse)({ status: 201, description: '回复成功' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: '评论不存在' }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, review_dto_1.CreateReplyDto]),
    __metadata("design:returntype", Promise)
], ReviewsController.prototype, "createReply", null);
__decorate([
    (0, common_1.Get)('reviews/:id/replies'),
    (0, swagger_1.ApiOperation)({ summary: '获取评论回复列表' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '评论ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '获取成功' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], ReviewsController.prototype, "getReplies", null);
__decorate([
    (0, common_1.Post)('reviews/:id/report'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: '举报评论' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '评论ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '举报成功' }),
    (0, swagger_1.ApiResponse)({ status: 400, description: '不能举报自己的评论' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: '评论不存在' }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, review_dto_1.ReportReviewDto]),
    __metadata("design:returntype", Promise)
], ReviewsController.prototype, "reportReview", null);
exports.ReviewsController = ReviewsController = __decorate([
    (0, swagger_1.ApiTags)('评论系统'),
    (0, common_1.Controller)('v1'),
    __metadata("design:paramtypes", [reviews_service_1.ReviewsService])
], ReviewsController);
//# sourceMappingURL=reviews.controller.js.map