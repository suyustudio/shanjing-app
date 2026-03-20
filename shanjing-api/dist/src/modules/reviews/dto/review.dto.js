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
exports.LikeReviewResponseDto = exports.ReviewListResponseDto = exports.ReviewStatsDto = exports.ReviewDetailDto = exports.ReviewDto = exports.ReviewReplyDto = exports.ReviewUserDto = exports.QueryReviewsDto = exports.ReportReviewDto = exports.CreateReplyDto = exports.UpdateReviewDto = exports.CreateReviewDto = exports.ApiResponseDto = exports.PREDEFINED_TAGS = void 0;
const class_validator_1 = require("class-validator");
const class_transformer_1 = require("class-transformer");
const swagger_1 = require("@nestjs/swagger");
exports.PREDEFINED_TAGS = [
    '风景优美', '视野开阔', '拍照圣地', '秋色迷人', '春花烂漫',
    '难度适中', '轻松休闲', '挑战性强', '适合新手', '需要体能',
    '设施完善', '补给方便', '厕所干净', '指示牌清晰',
    '适合亲子', '宠物友好', '人少清静', '团队建设',
    '历史文化', '古迹众多', '森林氧吧', '溪流潺潺'
];
class ApiResponseDto {
}
exports.ApiResponseDto = ApiResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否成功' }),
    __metadata("design:type", Boolean)
], ApiResponseDto.prototype, "success", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '响应数据' }),
    __metadata("design:type", Object)
], ApiResponseDto.prototype, "data", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '错误信息' }),
    __metadata("design:type", String)
], ApiResponseDto.prototype, "message", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '分页信息' }),
    __metadata("design:type", Object)
], ApiResponseDto.prototype, "meta", void 0);
class CreateReviewDto {
}
exports.CreateReviewDto = CreateReviewDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '评分 (1-5星，整数)', minimum: 1, maximum: 5, example: 4 }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(1),
    (0, class_validator_1.Max)(5),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], CreateReviewDto.prototype, "rating", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '评论内容 (0-500字)', example: '这条路线风景很美，难度适中，非常适合周末徒步。' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.Length)(0, 500, { message: '评论内容需要在0-500字之间' }),
    __metadata("design:type", String)
], CreateReviewDto.prototype, "content", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '评论标签', enum: exports.PREDEFINED_TAGS, isArray: true }),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.ArrayMaxSize)(5, { message: '最多选择5个标签' }),
    __metadata("design:type", Array)
], CreateReviewDto.prototype, "tags", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '评论配图URL列表 (最多9张)', example: ['https://cdn.example.com/photo1.jpg'] }),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.ArrayMaxSize)(9, { message: '最多上传9张图片' }),
    __metadata("design:type", Array)
], CreateReviewDto.prototype, "photos", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '难度再评估 (可选)', enum: ['EASY', 'MODERATE', 'HARD'] }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateReviewDto.prototype, "difficulty", void 0);
class UpdateReviewDto {
}
exports.UpdateReviewDto = UpdateReviewDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '评分 (1-5星)', minimum: 1, maximum: 5 }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(1),
    (0, class_validator_1.Max)(5),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], UpdateReviewDto.prototype, "rating", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '评论内容 (0-500字)' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.Length)(0, 500),
    __metadata("design:type", String)
], UpdateReviewDto.prototype, "content", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '评论标签' }),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.ArrayMaxSize)(5),
    __metadata("design:type", Array)
], UpdateReviewDto.prototype, "tags", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '评论配图URL列表 (可修改)', example: ['https://cdn.example.com/photo1.jpg'] }),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.ArrayMaxSize)(9),
    __metadata("design:type", Array)
], UpdateReviewDto.prototype, "photos", void 0);
class CreateReplyDto {
}
exports.CreateReplyDto = CreateReplyDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '回复内容', example: '感谢分享，我也想去试试！' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Length)(1, 500),
    __metadata("design:type", String)
], CreateReplyDto.prototype, "content", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '父回复ID（用于嵌套回复）' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateReplyDto.prototype, "parentId", void 0);
class ReportReviewDto {
}
exports.ReportReviewDto = ReportReviewDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '举报原因', example: '内容不适当' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Length)(1, 100),
    __metadata("design:type", String)
], ReportReviewDto.prototype, "reason", void 0);
class QueryReviewsDto {
    constructor() {
        this.sort = 'newest';
        this.page = 1;
        this.limit = 10;
    }
}
exports.QueryReviewsDto = QueryReviewsDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '排序方式', enum: ['newest', 'highest', 'lowest', 'hot'], default: 'newest' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], QueryReviewsDto.prototype, "sort", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '评分筛选', example: 5 }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], QueryReviewsDto.prototype, "rating", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '页码', default: 1 }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], QueryReviewsDto.prototype, "page", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '每页数量 (最大100)', default: 10 }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.Max)(100),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], QueryReviewsDto.prototype, "limit", void 0);
class ReviewUserDto {
}
exports.ReviewUserDto = ReviewUserDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '用户ID' }),
    __metadata("design:type", String)
], ReviewUserDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '用户昵称', nullable: true }),
    __metadata("design:type", String)
], ReviewUserDto.prototype, "nickname", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '用户头像', nullable: true }),
    __metadata("design:type", String)
], ReviewUserDto.prototype, "avatarUrl", void 0);
class ReviewReplyDto {
}
exports.ReviewReplyDto = ReviewReplyDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '回复ID' }),
    __metadata("design:type", String)
], ReviewReplyDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '回复内容' }),
    __metadata("design:type", String)
], ReviewReplyDto.prototype, "content", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '回复用户信息', type: ReviewUserDto }),
    __metadata("design:type", ReviewUserDto)
], ReviewReplyDto.prototype, "user", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '父回复ID', nullable: true }),
    __metadata("design:type", String)
], ReviewReplyDto.prototype, "parentId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '创建时间' }),
    __metadata("design:type", Date)
], ReviewReplyDto.prototype, "createdAt", void 0);
class ReviewDto {
}
exports.ReviewDto = ReviewDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '评论ID' }),
    __metadata("design:type", String)
], ReviewDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '评分 (1-5星)' }),
    __metadata("design:type", Number)
], ReviewDto.prototype, "rating", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '评论内容', nullable: true }),
    __metadata("design:type", String)
], ReviewDto.prototype, "content", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '评论标签', type: [String] }),
    __metadata("design:type", Array)
], ReviewDto.prototype, "tags", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '评论配图URL列表', type: [String] }),
    __metadata("design:type", Array)
], ReviewDto.prototype, "photos", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '点赞数' }),
    __metadata("design:type", Number)
], ReviewDto.prototype, "likeCount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '回复数' }),
    __metadata("design:type", Number)
], ReviewDto.prototype, "replyCount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否已编辑' }),
    __metadata("design:type", Boolean)
], ReviewDto.prototype, "isEdited", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否"体验过"认证' }),
    __metadata("design:type", Boolean)
], ReviewDto.prototype, "isVerified", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '当前用户是否已点赞', nullable: true }),
    __metadata("design:type", Boolean)
], ReviewDto.prototype, "isLiked", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '评论用户信息', type: ReviewUserDto }),
    __metadata("design:type", ReviewUserDto)
], ReviewDto.prototype, "user", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '创建时间' }),
    __metadata("design:type", Date)
], ReviewDto.prototype, "createdAt", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '更新时间' }),
    __metadata("design:type", Date)
], ReviewDto.prototype, "updatedAt", void 0);
class ReviewDetailDto extends ReviewDto {
}
exports.ReviewDetailDto = ReviewDetailDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '回复列表', type: [ReviewReplyDto] }),
    __metadata("design:type", Array)
], ReviewDetailDto.prototype, "replies", void 0);
class ReviewStatsDto {
}
exports.ReviewStatsDto = ReviewStatsDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路线ID' }),
    __metadata("design:type", String)
], ReviewStatsDto.prototype, "trailId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '加权平均评分' }),
    __metadata("design:type", Number)
], ReviewStatsDto.prototype, "avgRating", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '总评论数' }),
    __metadata("design:type", Number)
], ReviewStatsDto.prototype, "totalCount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '5星数量' }),
    __metadata("design:type", Number)
], ReviewStatsDto.prototype, "rating5Count", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '4星数量' }),
    __metadata("design:type", Number)
], ReviewStatsDto.prototype, "rating4Count", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '3星数量' }),
    __metadata("design:type", Number)
], ReviewStatsDto.prototype, "rating3Count", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '2星数量' }),
    __metadata("design:type", Number)
], ReviewStatsDto.prototype, "rating2Count", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '1星数量' }),
    __metadata("design:type", Number)
], ReviewStatsDto.prototype, "rating1Count", void 0);
class ReviewListResponseDto {
}
exports.ReviewListResponseDto = ReviewListResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '评论列表', type: [ReviewDto] }),
    __metadata("design:type", Array)
], ReviewListResponseDto.prototype, "list", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '总数' }),
    __metadata("design:type", Number)
], ReviewListResponseDto.prototype, "total", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '当前页码' }),
    __metadata("design:type", Number)
], ReviewListResponseDto.prototype, "page", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '每页数量' }),
    __metadata("design:type", Number)
], ReviewListResponseDto.prototype, "limit", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '评分统计', type: ReviewStatsDto }),
    __metadata("design:type", ReviewStatsDto)
], ReviewListResponseDto.prototype, "stats", void 0);
class LikeReviewResponseDto {
}
exports.LikeReviewResponseDto = LikeReviewResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否已点赞' }),
    __metadata("design:type", Boolean)
], LikeReviewResponseDto.prototype, "isLiked", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '当前点赞数' }),
    __metadata("design:type", Number)
], LikeReviewResponseDto.prototype, "likeCount", void 0);
//# sourceMappingURL=review.dto.js.map