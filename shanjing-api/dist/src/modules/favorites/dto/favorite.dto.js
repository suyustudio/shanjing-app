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
exports.FavoriteActionResponseDto = exports.FavoriteStatusResponseDto = exports.FavoriteListResponseDto = exports.FavoriteListItemDto = exports.RemoveFavoriteDto = exports.AddFavoriteDto = exports.FavoriteListQueryDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
class FavoriteListQueryDto {
    constructor() {
        this.page = 1;
        this.limit = 20;
    }
}
exports.FavoriteListQueryDto = FavoriteListQueryDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '页码', default: 1 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(1),
    __metadata("design:type", Number)
], FavoriteListQueryDto.prototype, "page", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '每页数量', default: 20 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(1),
    (0, class_validator_1.Max)(100),
    __metadata("design:type", Number)
], FavoriteListQueryDto.prototype, "limit", void 0);
class AddFavoriteDto {
}
exports.AddFavoriteDto = AddFavoriteDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路线ID' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], AddFavoriteDto.prototype, "trailId", void 0);
class RemoveFavoriteDto {
}
exports.RemoveFavoriteDto = RemoveFavoriteDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路线ID' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], RemoveFavoriteDto.prototype, "trailId", void 0);
class FavoriteListItemDto {
}
exports.FavoriteListItemDto = FavoriteListItemDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '收藏ID' }),
    __metadata("design:type", String)
], FavoriteListItemDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路线ID' }),
    __metadata("design:type", String)
], FavoriteListItemDto.prototype, "trailId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路线名称' }),
    __metadata("design:type", String)
], FavoriteListItemDto.prototype, "trailName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '封面图片' }),
    __metadata("design:type", String)
], FavoriteListItemDto.prototype, "coverImage", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '距离（公里）' }),
    __metadata("design:type", Number)
], FavoriteListItemDto.prototype, "distanceKm", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '预计用时（分钟）' }),
    __metadata("design:type", Number)
], FavoriteListItemDto.prototype, "durationMin", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '难度级别' }),
    __metadata("design:type", String)
], FavoriteListItemDto.prototype, "difficulty", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '城市' }),
    __metadata("design:type", String)
], FavoriteListItemDto.prototype, "city", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '收藏时间' }),
    __metadata("design:type", Date)
], FavoriteListItemDto.prototype, "createdAt", void 0);
class FavoriteListResponseDto {
}
exports.FavoriteListResponseDto = FavoriteListResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '收藏列表', type: [FavoriteListItemDto] }),
    __metadata("design:type", Array)
], FavoriteListResponseDto.prototype, "data", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '分页信息' }),
    __metadata("design:type", Object)
], FavoriteListResponseDto.prototype, "meta", void 0);
class FavoriteStatusResponseDto {
}
exports.FavoriteStatusResponseDto = FavoriteStatusResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否已收藏' }),
    __metadata("design:type", Boolean)
], FavoriteStatusResponseDto.prototype, "isFavorited", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '收藏总数' }),
    __metadata("design:type", Number)
], FavoriteStatusResponseDto.prototype, "favoriteCount", void 0);
class FavoriteActionResponseDto {
}
exports.FavoriteActionResponseDto = FavoriteActionResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '操作成功' }),
    __metadata("design:type", Boolean)
], FavoriteActionResponseDto.prototype, "success", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否已收藏' }),
    __metadata("design:type", Boolean)
], FavoriteActionResponseDto.prototype, "isFavorited", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '收藏总数' }),
    __metadata("design:type", Number)
], FavoriteActionResponseDto.prototype, "favoriteCount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '提示消息' }),
    __metadata("design:type", String)
], FavoriteActionResponseDto.prototype, "message", void 0);
//# sourceMappingURL=favorite.dto.js.map