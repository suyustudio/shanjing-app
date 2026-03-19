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
exports.RecommendedTrailsResponseDto = exports.NearbyTrailsQueryDto = exports.TrailListResponseDto = exports.TrailListItemDto = exports.TrailPoiDto = exports.TrailDetailResponseDto = exports.TrailListQueryDto = void 0;
const class_validator_1 = require("class-validator");
const swagger_1 = require("@nestjs/swagger");
const client_1 = require("@prisma/client");
class TrailListQueryDto {
    constructor() {
        this.page = 1;
        this.limit = 20;
    }
}
exports.TrailListQueryDto = TrailListQueryDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '搜索关键词（路线名称）' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], TrailListQueryDto.prototype, "keyword", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '城市' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], TrailListQueryDto.prototype, "city", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '区域/区县' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], TrailListQueryDto.prototype, "district", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '难度级别',
        enum: client_1.TrailDifficulty,
        enumName: 'TrailDifficulty'
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(client_1.TrailDifficulty),
    __metadata("design:type", String)
], TrailListQueryDto.prototype, "difficulty", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '标签筛选' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], TrailListQueryDto.prototype, "tag", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '页码', default: 1 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(1),
    __metadata("design:type", Number)
], TrailListQueryDto.prototype, "page", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '每页数量', default: 20 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(1),
    (0, class_validator_1.Max)(100),
    __metadata("design:type", Number)
], TrailListQueryDto.prototype, "limit", void 0);
class TrailDetailResponseDto {
}
exports.TrailDetailResponseDto = TrailDetailResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路线ID' }),
    __metadata("design:type", String)
], TrailDetailResponseDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路线名称' }),
    __metadata("design:type", String)
], TrailDetailResponseDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '路线描述' }),
    __metadata("design:type", String)
], TrailDetailResponseDto.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '距离（公里）' }),
    __metadata("design:type", Number)
], TrailDetailResponseDto.prototype, "distanceKm", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '预计用时（分钟）' }),
    __metadata("design:type", Number)
], TrailDetailResponseDto.prototype, "durationMin", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '海拔爬升（米）' }),
    __metadata("design:type", Number)
], TrailDetailResponseDto.prototype, "elevationGainM", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '难度级别', enum: client_1.TrailDifficulty }),
    __metadata("design:type", String)
], TrailDetailResponseDto.prototype, "difficulty", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '标签列表' }),
    __metadata("design:type", Array)
], TrailDetailResponseDto.prototype, "tags", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '封面图片列表' }),
    __metadata("design:type", Array)
], TrailDetailResponseDto.prototype, "coverImages", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: 'GPX文件URL' }),
    __metadata("design:type", String)
], TrailDetailResponseDto.prototype, "gpxUrl", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '城市' }),
    __metadata("design:type", String)
], TrailDetailResponseDto.prototype, "city", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '区域' }),
    __metadata("design:type", String)
], TrailDetailResponseDto.prototype, "district", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '起点纬度' }),
    __metadata("design:type", Number)
], TrailDetailResponseDto.prototype, "startPointLat", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '起点经度' }),
    __metadata("design:type", Number)
], TrailDetailResponseDto.prototype, "startPointLng", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '起点地址' }),
    __metadata("design:type", String)
], TrailDetailResponseDto.prototype, "startPointAddress", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '安全信息' }),
    __metadata("design:type", Object)
], TrailDetailResponseDto.prototype, "safetyInfo", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '收藏数' }),
    __metadata("design:type", Number)
], TrailDetailResponseDto.prototype, "favoriteCount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否已收藏（当前用户）' }),
    __metadata("design:type", Boolean)
], TrailDetailResponseDto.prototype, "isFavorited", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'POI点列表' }),
    __metadata("design:type", Array)
], TrailDetailResponseDto.prototype, "pois", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '创建时间' }),
    __metadata("design:type", Date)
], TrailDetailResponseDto.prototype, "createdAt", void 0);
class TrailPoiDto {
}
exports.TrailPoiDto = TrailPoiDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'POI ID' }),
    __metadata("design:type", String)
], TrailPoiDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'POI名称' }),
    __metadata("design:type", String)
], TrailPoiDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: 'POI描述' }),
    __metadata("design:type", String)
], TrailPoiDto.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '纬度' }),
    __metadata("design:type", Number)
], TrailPoiDto.prototype, "lat", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '经度' }),
    __metadata("design:type", Number)
], TrailPoiDto.prototype, "lng", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'POI类型' }),
    __metadata("design:type", String)
], TrailPoiDto.prototype, "type", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '排序顺序' }),
    __metadata("design:type", Number)
], TrailPoiDto.prototype, "order", void 0);
class TrailListItemDto {
}
exports.TrailListItemDto = TrailListItemDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路线ID' }),
    __metadata("design:type", String)
], TrailListItemDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路线名称' }),
    __metadata("design:type", String)
], TrailListItemDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '距离（公里）' }),
    __metadata("design:type", Number)
], TrailListItemDto.prototype, "distanceKm", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '预计用时（分钟）' }),
    __metadata("design:type", Number)
], TrailListItemDto.prototype, "durationMin", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '难度级别', enum: client_1.TrailDifficulty }),
    __metadata("design:type", String)
], TrailListItemDto.prototype, "difficulty", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '城市' }),
    __metadata("design:type", String)
], TrailListItemDto.prototype, "city", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '区域' }),
    __metadata("design:type", String)
], TrailListItemDto.prototype, "district", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '封面图片' }),
    __metadata("design:type", Array)
], TrailListItemDto.prototype, "coverImages", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '收藏数' }),
    __metadata("design:type", Number)
], TrailListItemDto.prototype, "favoriteCount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否已收藏（当前用户）' }),
    __metadata("design:type", Boolean)
], TrailListItemDto.prototype, "isFavorited", void 0);
class TrailListResponseDto {
}
exports.TrailListResponseDto = TrailListResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路线列表', type: [TrailListItemDto] }),
    __metadata("design:type", Array)
], TrailListResponseDto.prototype, "data", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '分页信息' }),
    __metadata("design:type", Object)
], TrailListResponseDto.prototype, "meta", void 0);
class NearbyTrailsQueryDto {
    constructor() {
        this.radius = 10;
        this.limit = 20;
    }
}
exports.NearbyTrailsQueryDto = NearbyTrailsQueryDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '纬度' }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(-90),
    (0, class_validator_1.Max)(90),
    __metadata("design:type", Number)
], NearbyTrailsQueryDto.prototype, "lat", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '经度' }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(-180),
    (0, class_validator_1.Max)(180),
    __metadata("design:type", Number)
], NearbyTrailsQueryDto.prototype, "lng", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '搜索半径（公里）', default: 10 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(1),
    (0, class_validator_1.Max)(100),
    __metadata("design:type", Number)
], NearbyTrailsQueryDto.prototype, "radius", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '数量限制', default: 20 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(1),
    (0, class_validator_1.Max)(50),
    __metadata("design:type", Number)
], NearbyTrailsQueryDto.prototype, "limit", void 0);
class RecommendedTrailsResponseDto {
}
exports.RecommendedTrailsResponseDto = RecommendedTrailsResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '推荐路线列表', type: [TrailListItemDto] }),
    __metadata("design:type", Array)
], RecommendedTrailsResponseDto.prototype, "data", void 0);
//# sourceMappingURL=trail.dto.js.map