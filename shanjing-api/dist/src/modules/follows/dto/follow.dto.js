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
exports.FollowActionResponseDto = exports.FollowStatsDto = exports.FollowListResponseDto = exports.FollowUserDto = exports.QueryFollowsDto = void 0;
const class_validator_1 = require("class-validator");
const swagger_1 = require("@nestjs/swagger");
class QueryFollowsDto {
    constructor() {
        this.limit = 20;
    }
}
exports.QueryFollowsDto = QueryFollowsDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '游标 (用于分页)' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], QueryFollowsDto.prototype, "cursor", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '每页数量', default: 20 }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], QueryFollowsDto.prototype, "limit", void 0);
class FollowUserDto {
}
exports.FollowUserDto = FollowUserDto;
class FollowListResponseDto {
}
exports.FollowListResponseDto = FollowListResponseDto;
class FollowStatsDto {
}
exports.FollowStatsDto = FollowStatsDto;
class FollowActionResponseDto {
}
exports.FollowActionResponseDto = FollowActionResponseDto;
//# sourceMappingURL=follow.dto.js.map