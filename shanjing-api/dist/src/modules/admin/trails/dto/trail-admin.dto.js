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
exports.TrailListResponseDto = exports.TrailResponseDto = exports.TrailListQueryDto = exports.UpdateTrailDto = exports.CreateTrailDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
const class_transformer_1 = require("class-transformer");
const client_1 = require("@prisma/client");
class CreateTrailDto {
}
exports.CreateTrailDto = CreateTrailDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '路线名称',
        example: '西湖环湖步道',
    }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MinLength)(2),
    (0, class_validator_1.MaxLength)(100),
    __metadata("design:type", String)
], CreateTrailDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '路线描述',
        example: '环绕西湖的经典徒步路线，风景优美...',
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateTrailDto.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '距离（公里）',
        example: 10.5,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(0.1),
    (0, class_validator_1.Max)(1000),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], CreateTrailDto.prototype, "distanceKm", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '预计耗时（分钟）',
        example: 180,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(1),
    (0, class_validator_1.Max)(1440),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], CreateTrailDto.prototype, "durationMin", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '爬升高度（米）',
        example: 150,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(0),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], CreateTrailDto.prototype, "elevationGainM", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '难度等级',
        enum: client_1.TrailDifficulty,
        example: client_1.TrailDifficulty.MODERATE,
    }),
    (0, class_validator_1.IsEnum)(client_1.TrailDifficulty),
    __metadata("design:type", String)
], CreateTrailDto.prototype, "difficulty", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '标签列表',
        example: ['风景优美', '适合新手', '亲子友好'],
        type: [String],
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.IsString)({ each: true }),
    __metadata("design:type", Array)
], CreateTrailDto.prototype, "tags", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '封面图片URL列表',
        example: ['https://example.com/image1.jpg'],
        type: [String],
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.IsString)({ each: true }),
    __metadata("design:type", Array)
], CreateTrailDto.prototype, "coverImages", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: 'GPX文件URL',
        example: 'https://example.com/trail.gpx',
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateTrailDto.prototype, "gpxUrl", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '城市',
        example: '杭州市',
    }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateTrailDto.prototype, "city", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '区县',
        example: '西湖区',
    }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateTrailDto.prototype, "district", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '起点纬度',
        example: 30.25961,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], CreateTrailDto.prototype, "startPointLat", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '起点经度',
        example: 120.13026,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], CreateTrailDto.prototype, "startPointLng", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '起点地址',
        example: '杭州市西湖区断桥残雪',
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateTrailDto.prototype, "startPointAddress", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '安全信息',
        example: {
            femaleFriendly: true,
            signalCoverage: '全程覆盖',
            evacuationPoints: 3,
        },
    }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Object)
], CreateTrailDto.prototype, "safetyInfo", void 0);
class UpdateTrailDto {
}
exports.UpdateTrailDto = UpdateTrailDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '路线名称',
        example: '西湖环湖步道（更新）',
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MinLength)(2),
    (0, class_validator_1.MaxLength)(100),
    __metadata("design:type", String)
], UpdateTrailDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '路线描述',
        example: '环绕西湖的经典徒步路线...',
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateTrailDto.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '距离（公里）',
        example: 10.5,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(0.1),
    (0, class_validator_1.Max)(1000),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], UpdateTrailDto.prototype, "distanceKm", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '预计耗时（分钟）',
        example: 180,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(1),
    (0, class_validator_1.Max)(1440),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], UpdateTrailDto.prototype, "durationMin", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '爬升高度（米）',
        example: 150,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(0),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], UpdateTrailDto.prototype, "elevationGainM", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '难度等级',
        enum: client_1.TrailDifficulty,
        example: client_1.TrailDifficulty.MODERATE,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(client_1.TrailDifficulty),
    __metadata("design:type", String)
], UpdateTrailDto.prototype, "difficulty", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '标签列表',
        example: ['风景优美', '适合新手'],
        type: [String],
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.IsString)({ each: true }),
    __metadata("design:type", Array)
], UpdateTrailDto.prototype, "tags", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '封面图片URL列表',
        example: ['https://example.com/image1.jpg'],
        type: [String],
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.IsString)({ each: true }),
    __metadata("design:type", Array)
], UpdateTrailDto.prototype, "coverImages", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: 'GPX文件URL',
        example: 'https://example.com/trail.gpx',
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateTrailDto.prototype, "gpxUrl", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '城市',
        example: '杭州市',
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateTrailDto.prototype, "city", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '区县',
        example: '西湖区',
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateTrailDto.prototype, "district", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '起点纬度',
        example: 30.25961,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], UpdateTrailDto.prototype, "startPointLat", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '起点经度',
        example: 120.13026,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], UpdateTrailDto.prototype, "startPointLng", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '起点地址',
        example: '杭州市西湖区断桥残雪',
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateTrailDto.prototype, "startPointAddress", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '安全信息',
        example: {
            femaleFriendly: true,
            signalCoverage: '全程覆盖',
            evacuationPoints: 3,
        },
    }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Object)
], UpdateTrailDto.prototype, "safetyInfo", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '状态：true-上架，false-下架',
        example: true,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsBoolean)(),
    __metadata("design:type", Boolean)
], UpdateTrailDto.prototype, "isActive", void 0);
class TrailListQueryDto {
}
exports.TrailListQueryDto = TrailListQueryDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '搜索关键词（路线名称）',
        example: '西湖',
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], TrailListQueryDto.prototype, "keyword", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '城市',
        example: '杭州市',
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], TrailListQueryDto.prototype, "city", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '难度等级',
        enum: client_1.TrailDifficulty,
        example: client_1.TrailDifficulty.EASY,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(client_1.TrailDifficulty),
    __metadata("design:type", String)
], TrailListQueryDto.prototype, "difficulty", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '状态：true-上架，false-下架',
        example: true,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsBoolean)(),
    (0, class_transformer_1.Type)(() => Boolean),
    __metadata("design:type", Boolean)
], TrailListQueryDto.prototype, "isActive", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '页码',
        example: 1,
        default: 1,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], TrailListQueryDto.prototype, "page", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '每页数量',
        example: 20,
        default: 20,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], TrailListQueryDto.prototype, "limit", void 0);
class TrailResponseDto {
}
exports.TrailResponseDto = TrailResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否成功', example: true }),
    __metadata("design:type", Boolean)
], TrailResponseDto.prototype, "success", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '错误信息' }),
    __metadata("design:type", String)
], TrailResponseDto.prototype, "errorMessage", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路线数据' }),
    __metadata("design:type", Object)
], TrailResponseDto.prototype, "data", void 0);
class TrailListResponseDto {
}
exports.TrailListResponseDto = TrailListResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否成功', example: true }),
    __metadata("design:type", Boolean)
], TrailListResponseDto.prototype, "success", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路线列表', type: 'array' }),
    __metadata("design:type", Array)
], TrailListResponseDto.prototype, "data", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '分页信息' }),
    __metadata("design:type", Object)
], TrailListResponseDto.prototype, "meta", void 0);
//# sourceMappingURL=trail-admin.dto.js.map