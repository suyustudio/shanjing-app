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
exports.LikePhotoResponseDto = exports.PhotoListResponseDto = exports.PhotoDto = exports.PhotoUserDto = exports.QueryPhotosDto = exports.UpdatePhotoDto = exports.CreatePhotosDto = exports.CreatePhotoDto = void 0;
const class_validator_1 = require("class-validator");
const class_transformer_1 = require("class-transformer");
const swagger_1 = require("@nestjs/swagger");
class CreatePhotoDto {
}
exports.CreatePhotoDto = CreatePhotoDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '照片URL', example: 'https://cdn.example.com/photo1.jpg' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreatePhotoDto.prototype, "url", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '缩略图URL', example: 'https://cdn.example.com/photo1_thumb.jpg' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreatePhotoDto.prototype, "thumbnailUrl", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '路线ID' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreatePhotoDto.prototype, "trailId", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: 'POI ID' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreatePhotoDto.prototype, "poiId", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '照片宽度' }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], CreatePhotoDto.prototype, "width", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '照片高度' }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], CreatePhotoDto.prototype, "height", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '照片描述 (0-100字)', example: '山顶的风景' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.Length)(0, 100),
    __metadata("design:type", String)
], CreatePhotoDto.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '纬度' }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], CreatePhotoDto.prototype, "latitude", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '经度' }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], CreatePhotoDto.prototype, "longitude", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '拍摄时间' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreatePhotoDto.prototype, "takenAt", void 0);
class CreatePhotosDto {
}
exports.CreatePhotosDto = CreatePhotosDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '照片列表', type: [CreatePhotoDto] }),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.ArrayMaxSize)(9, { message: '一次最多上传9张照片' }),
    __metadata("design:type", Array)
], CreatePhotosDto.prototype, "photos", void 0);
class UpdatePhotoDto {
}
exports.UpdatePhotoDto = UpdatePhotoDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '照片描述' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.Length)(0, 100),
    __metadata("design:type", String)
], UpdatePhotoDto.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '是否公开', default: true }),
    (0, class_validator_1.IsBoolean)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Boolean)
], UpdatePhotoDto.prototype, "isPublic", void 0);
class QueryPhotosDto {
    constructor() {
        this.sort = 'newest';
        this.limit = 20;
    }
}
exports.QueryPhotosDto = QueryPhotosDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '路线ID' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], QueryPhotosDto.prototype, "trailId", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '用户ID' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], QueryPhotosDto.prototype, "userId", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '排序方式', enum: ['newest', 'popular'], default: 'newest' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], QueryPhotosDto.prototype, "sort", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '游标 (用于分页)' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], QueryPhotosDto.prototype, "cursor", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '每页数量', default: 20 }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.Max)(100),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], QueryPhotosDto.prototype, "limit", void 0);
class PhotoUserDto {
}
exports.PhotoUserDto = PhotoUserDto;
class PhotoDto {
}
exports.PhotoDto = PhotoDto;
class PhotoListResponseDto {
}
exports.PhotoListResponseDto = PhotoListResponseDto;
class LikePhotoResponseDto {
}
exports.LikePhotoResponseDto = LikePhotoResponseDto;
//# sourceMappingURL=photo.dto.js.map