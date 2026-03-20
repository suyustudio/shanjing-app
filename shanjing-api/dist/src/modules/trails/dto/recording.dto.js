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
exports.RecordingDetailResponseDto = exports.RecordingListResponseDto = exports.RecordingListItemDto = exports.UploadResponseDto = exports.ApproveRecordingDto = exports.RecordingListQueryDto = exports.UploadRecordingDto = void 0;
const class_validator_1 = require("class-validator");
const swagger_1 = require("@nestjs/swagger");
const client_1 = require("@prisma/client");
class UploadRecordingDto {
}
exports.UploadRecordingDto = UploadRecordingDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '录制会话ID' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UploadRecordingDto.prototype, "sessionId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路线名称' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UploadRecordingDto.prototype, "trailName", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '路线描述' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UploadRecordingDto.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '城市' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UploadRecordingDto.prototype, "city", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '区域/区县' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UploadRecordingDto.prototype, "district", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '难度级别',
        enum: client_1.TrailDifficulty,
        default: client_1.TrailDifficulty.EASY
    }),
    (0, class_validator_1.IsEnum)(client_1.TrailDifficulty),
    __metadata("design:type", String)
], UploadRecordingDto.prototype, "difficulty", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '标签列表' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.IsString)({ each: true }),
    __metadata("design:type", Array)
], UploadRecordingDto.prototype, "tags", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '轨迹数据（包含轨迹点和POI）' }),
    (0, class_validator_1.IsObject)(),
    __metadata("design:type", Object)
], UploadRecordingDto.prototype, "trackData", void 0);
class RecordingListQueryDto {
    constructor() {
        this.page = 1;
        this.limit = 20;
    }
}
exports.RecordingListQueryDto = RecordingListQueryDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '状态筛选: pending/approved/rejected' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], RecordingListQueryDto.prototype, "status", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '页码', default: 1 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(1),
    __metadata("design:type", Number)
], RecordingListQueryDto.prototype, "page", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '每页数量', default: 20 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(1),
    (0, class_validator_1.Max)(100),
    __metadata("design:type", Number)
], RecordingListQueryDto.prototype, "limit", void 0);
class ApproveRecordingDto {
}
exports.ApproveRecordingDto = ApproveRecordingDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '路线名称（可修改）' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], ApproveRecordingDto.prototype, "trailName", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '路线描述（可修改）' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], ApproveRecordingDto.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '难度级别（可修改）', enum: client_1.TrailDifficulty }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(client_1.TrailDifficulty),
    __metadata("design:type", String)
], ApproveRecordingDto.prototype, "difficulty", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '标签列表（可修改）' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.IsString)({ each: true }),
    __metadata("design:type", Array)
], ApproveRecordingDto.prototype, "tags", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '起点地址' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], ApproveRecordingDto.prototype, "startPointAddress", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '封面图片列表' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.IsString)({ each: true }),
    __metadata("design:type", Array)
], ApproveRecordingDto.prototype, "coverImages", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '审核备注' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], ApproveRecordingDto.prototype, "comment", void 0);
class UploadResponseDto {
}
exports.UploadResponseDto = UploadResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否成功' }),
    __metadata("design:type", Boolean)
], UploadResponseDto.prototype, "success", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '响应数据' }),
    __metadata("design:type", Object)
], UploadResponseDto.prototype, "data", void 0);
class RecordingListItemDto {
}
exports.RecordingListItemDto = RecordingListItemDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '录制记录ID' }),
    __metadata("design:type", String)
], RecordingListItemDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路线名称' }),
    __metadata("design:type", String)
], RecordingListItemDto.prototype, "trailName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '状态: pending/approved/rejected' }),
    __metadata("design:type", String)
], RecordingListItemDto.prototype, "status", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '城市' }),
    __metadata("design:type", String)
], RecordingListItemDto.prototype, "city", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '区域' }),
    __metadata("design:type", String)
], RecordingListItemDto.prototype, "district", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '难度级别', enum: client_1.TrailDifficulty }),
    __metadata("design:type", String)
], RecordingListItemDto.prototype, "difficulty", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '距离（公里）' }),
    __metadata("design:type", String)
], RecordingListItemDto.prototype, "distanceKm", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '时长（分钟）' }),
    __metadata("design:type", Number)
], RecordingListItemDto.prototype, "durationMin", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '轨迹点数量' }),
    __metadata("design:type", Number)
], RecordingListItemDto.prototype, "pointCount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'POI数量' }),
    __metadata("design:type", Number)
], RecordingListItemDto.prototype, "poiCount", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '生成的路线ID' }),
    __metadata("design:type", String)
], RecordingListItemDto.prototype, "trailId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '创建时间' }),
    __metadata("design:type", Date)
], RecordingListItemDto.prototype, "createdAt", void 0);
class RecordingListResponseDto {
}
exports.RecordingListResponseDto = RecordingListResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '录制记录列表', type: [RecordingListItemDto] }),
    __metadata("design:type", Array)
], RecordingListResponseDto.prototype, "data", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '分页信息' }),
    __metadata("design:type", Object)
], RecordingListResponseDto.prototype, "meta", void 0);
class RecordingDetailResponseDto {
}
exports.RecordingDetailResponseDto = RecordingDetailResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '录制记录ID' }),
    __metadata("design:type", String)
], RecordingDetailResponseDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路线名称' }),
    __metadata("design:type", String)
], RecordingDetailResponseDto.prototype, "trailName", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '路线描述' }),
    __metadata("design:type", String)
], RecordingDetailResponseDto.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '状态' }),
    __metadata("design:type", String)
], RecordingDetailResponseDto.prototype, "status", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '城市' }),
    __metadata("design:type", String)
], RecordingDetailResponseDto.prototype, "city", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '区域' }),
    __metadata("design:type", String)
], RecordingDetailResponseDto.prototype, "district", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '难度级别', enum: client_1.TrailDifficulty }),
    __metadata("design:type", String)
], RecordingDetailResponseDto.prototype, "difficulty", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '标签列表' }),
    __metadata("design:type", Array)
], RecordingDetailResponseDto.prototype, "tags", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '距离（米）' }),
    __metadata("design:type", Number)
], RecordingDetailResponseDto.prototype, "distanceMeters", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '时长（秒）' }),
    __metadata("design:type", Number)
], RecordingDetailResponseDto.prototype, "durationSeconds", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '海拔爬升' }),
    __metadata("design:type", Number)
], RecordingDetailResponseDto.prototype, "elevationGain", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '海拔下降' }),
    __metadata("design:type", Number)
], RecordingDetailResponseDto.prototype, "elevationLoss", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '轨迹点数量' }),
    __metadata("design:type", Number)
], RecordingDetailResponseDto.prototype, "pointCount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'POI数量' }),
    __metadata("design:type", Number)
], RecordingDetailResponseDto.prototype, "poiCount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '轨迹数据' }),
    __metadata("design:type", Object)
], RecordingDetailResponseDto.prototype, "trackData", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '生成的路线ID' }),
    __metadata("design:type", String)
], RecordingDetailResponseDto.prototype, "trailId", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '审核备注' }),
    __metadata("design:type", String)
], RecordingDetailResponseDto.prototype, "reviewComment", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '创建时间' }),
    __metadata("design:type", Date)
], RecordingDetailResponseDto.prototype, "createdAt", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '更新时间' }),
    __metadata("design:type", Date)
], RecordingDetailResponseDto.prototype, "updatedAt", void 0);
//# sourceMappingURL=recording.dto.js.map