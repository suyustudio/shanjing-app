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
exports.RecommendationsResponseDto = exports.RecommendedTrailDto = exports.MatchFactorsDto = exports.ImpressionDto = exports.FeedbackDto = exports.GetRecommendationsDto = exports.UserAction = exports.RecommendationScene = void 0;
const class_validator_1 = require("class-validator");
const class_transformer_1 = require("class-transformer");
const swagger_1 = require("@nestjs/swagger");
var RecommendationScene;
(function (RecommendationScene) {
    RecommendationScene["HOME"] = "home";
    RecommendationScene["LIST"] = "list";
    RecommendationScene["SIMILAR"] = "similar";
    RecommendationScene["NEARBY"] = "nearby";
})(RecommendationScene || (exports.RecommendationScene = RecommendationScene = {}));
var UserAction;
(function (UserAction) {
    UserAction["CLICK"] = "click";
    UserAction["BOOKMARK"] = "bookmark";
    UserAction["COMPLETE"] = "complete";
    UserAction["IGNORE"] = "ignore";
})(UserAction || (exports.UserAction = UserAction = {}));
class GetRecommendationsDto {
    constructor() {
        this.limit = 10;
    }
}
exports.GetRecommendationsDto = GetRecommendationsDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '用户ID（从JWT获取，也可传参用于测试）' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], GetRecommendationsDto.prototype, "userId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ enum: RecommendationScene, description: '推荐场景' }),
    (0, class_validator_1.IsEnum)(RecommendationScene),
    __metadata("design:type", String)
], GetRecommendationsDto.prototype, "scene", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '用户纬度' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], GetRecommendationsDto.prototype, "lat", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '用户经度' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], GetRecommendationsDto.prototype, "lng", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '返回数量', default: 10 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(1),
    (0, class_validator_1.Max)(50),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], GetRecommendationsDto.prototype, "limit", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '排除的路线ID列表' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.IsString)({ each: true }),
    __metadata("design:type", Array)
], GetRecommendationsDto.prototype, "excludeIds", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '参考路线ID（用于相似推荐）' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], GetRecommendationsDto.prototype, "referenceTrailId", void 0);
class FeedbackDto {
}
exports.FeedbackDto = FeedbackDto;
__decorate([
    (0, swagger_1.ApiProperty)({ enum: UserAction, description: '用户行为' }),
    (0, class_validator_1.IsEnum)(UserAction),
    __metadata("design:type", String)
], FeedbackDto.prototype, "action", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '推荐的路线ID' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], FeedbackDto.prototype, "trailId", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '推荐日志ID' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], FeedbackDto.prototype, "logId", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '交互时长（秒）' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(0),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], FeedbackDto.prototype, "durationSec", void 0);
class ImpressionDto {
}
exports.ImpressionDto = ImpressionDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '推荐场景' }),
    (0, class_validator_1.IsEnum)(RecommendationScene),
    __metadata("design:type", String)
], ImpressionDto.prototype, "scene", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '曝光的路线ID列表' }),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.IsString)({ each: true }),
    __metadata("design:type", Array)
], ImpressionDto.prototype, "trailIds", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '推荐日志ID' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], ImpressionDto.prototype, "logId", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '曝光时间戳' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], ImpressionDto.prototype, "timestamp", void 0);
class MatchFactorsDto {
}
exports.MatchFactorsDto = MatchFactorsDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '难度匹配分数 (0-100)' }),
    __metadata("design:type", Number)
], MatchFactorsDto.prototype, "difficultyMatch", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '距离分数 (0-100)' }),
    __metadata("design:type", Number)
], MatchFactorsDto.prototype, "distance", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '评分分数 (0-100)' }),
    __metadata("design:type", Number)
], MatchFactorsDto.prototype, "rating", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '热度分数 (0-100)' }),
    __metadata("design:type", Number)
], MatchFactorsDto.prototype, "popularity", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '新鲜度分数 (0-100)' }),
    __metadata("design:type", Number)
], MatchFactorsDto.prototype, "freshness", void 0);
class RecommendedTrailDto {
}
exports.RecommendedTrailDto = RecommendedTrailDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路线ID' }),
    __metadata("design:type", String)
], RecommendedTrailDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路线名称' }),
    __metadata("design:type", String)
], RecommendedTrailDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '封面图片' }),
    __metadata("design:type", String)
], RecommendedTrailDto.prototype, "coverImage", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '距离（公里）' }),
    __metadata("design:type", Number)
], RecommendedTrailDto.prototype, "distanceKm", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '时长（分钟）' }),
    __metadata("design:type", Number)
], RecommendedTrailDto.prototype, "durationMin", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '难度' }),
    __metadata("design:type", String)
], RecommendedTrailDto.prototype, "difficulty", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '评分' }),
    __metadata("design:type", Number)
], RecommendedTrailDto.prototype, "rating", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '匹配分数 (0-100)' }),
    __metadata("design:type", Number)
], RecommendedTrailDto.prototype, "matchScore", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '匹配因子详情' }),
    __metadata("design:type", MatchFactorsDto)
], RecommendedTrailDto.prototype, "matchFactors", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '推荐理由' }),
    __metadata("design:type", String)
], RecommendedTrailDto.prototype, "recommendReason", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '与用户距离（米）' }),
    __metadata("design:type", Number)
], RecommendedTrailDto.prototype, "userDistanceM", void 0);
class RecommendationsResponseDto {
}
exports.RecommendationsResponseDto = RecommendationsResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '算法版本' }),
    __metadata("design:type", String)
], RecommendationsResponseDto.prototype, "algorithm", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '推荐场景' }),
    __metadata("design:type", String)
], RecommendationsResponseDto.prototype, "scene", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '推荐日志ID（用于反馈追踪）' }),
    __metadata("design:type", String)
], RecommendationsResponseDto.prototype, "logId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '推荐路线列表' }),
    __metadata("design:type", Array)
], RecommendationsResponseDto.prototype, "trails", void 0);
//# sourceMappingURL=recommendation.dto.js.map