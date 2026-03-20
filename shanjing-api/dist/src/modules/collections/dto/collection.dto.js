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
exports.CollectionListResponseDto = exports.CollectionDetailDto = exports.CollectionDto = exports.CollectionTrailDto = exports.CollectionUserDto = exports.QueryCollectionsDto = exports.BatchAddTrailsDto = exports.AddTrailToCollectionDto = exports.UpdateCollectionDto = exports.CreateCollectionDto = void 0;
const class_validator_1 = require("class-validator");
const swagger_1 = require("@nestjs/swagger");
class CreateCollectionDto {
    constructor() {
        this.isPublic = true;
    }
}
exports.CreateCollectionDto = CreateCollectionDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '收藏夹名称 (1-50字)', example: '周末徒步路线' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Length)(1, 50),
    __metadata("design:type", String)
], CreateCollectionDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '收藏夹描述 (0-200字)', example: '适合周末短途徒步的路线合集' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.MaxLength)(200),
    __metadata("design:type", String)
], CreateCollectionDto.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '封面图片URL' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateCollectionDto.prototype, "coverUrl", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '是否公开', default: true }),
    (0, class_validator_1.IsBoolean)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Boolean)
], CreateCollectionDto.prototype, "isPublic", void 0);
class UpdateCollectionDto {
}
exports.UpdateCollectionDto = UpdateCollectionDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '收藏夹名称 (1-50字)' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.Length)(1, 50),
    __metadata("design:type", String)
], UpdateCollectionDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '收藏夹描述 (0-200字)' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.MaxLength)(200),
    __metadata("design:type", String)
], UpdateCollectionDto.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '封面图片URL' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateCollectionDto.prototype, "coverUrl", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '是否公开' }),
    (0, class_validator_1.IsBoolean)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Boolean)
], UpdateCollectionDto.prototype, "isPublic", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '排序权重', example: 0 }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], UpdateCollectionDto.prototype, "sortOrder", void 0);
class AddTrailToCollectionDto {
}
exports.AddTrailToCollectionDto = AddTrailToCollectionDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路线ID' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], AddTrailToCollectionDto.prototype, "trailId", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '备注 (0-100字)', example: '秋天去会很美' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.MaxLength)(100),
    __metadata("design:type", String)
], AddTrailToCollectionDto.prototype, "note", void 0);
class BatchAddTrailsDto {
}
exports.BatchAddTrailsDto = BatchAddTrailsDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路线ID列表', type: [String], example: ['trail1', 'trail2'] }),
    (0, class_validator_1.IsArray)(),
    __metadata("design:type", Array)
], BatchAddTrailsDto.prototype, "trailIds", void 0);
class QueryCollectionsDto {
    constructor() {
        this.page = 1;
        this.limit = 20;
    }
}
exports.QueryCollectionsDto = QueryCollectionsDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '用户ID (不填则查询当前用户)' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], QueryCollectionsDto.prototype, "userId", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '页码', default: 1 }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], QueryCollectionsDto.prototype, "page", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '每页数量', default: 20 }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], QueryCollectionsDto.prototype, "limit", void 0);
class CollectionUserDto {
}
exports.CollectionUserDto = CollectionUserDto;
class CollectionTrailDto {
}
exports.CollectionTrailDto = CollectionTrailDto;
class CollectionDto {
}
exports.CollectionDto = CollectionDto;
class CollectionDetailDto extends CollectionDto {
}
exports.CollectionDetailDto = CollectionDetailDto;
class CollectionListResponseDto {
}
exports.CollectionListResponseDto = CollectionListResponseDto;
//# sourceMappingURL=collection.dto.js.map