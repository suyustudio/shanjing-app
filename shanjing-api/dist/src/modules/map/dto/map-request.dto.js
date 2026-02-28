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
exports.RegeocodeDto = exports.GeocodeDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
const class_transformer_1 = require("class-transformer");
class GeocodeDto {
}
exports.GeocodeDto = GeocodeDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '结构化地址信息，如：北京市朝阳区阜通东大街6号',
        example: '北京市朝阳区阜通东大街6号',
    }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], GeocodeDto.prototype, "address", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '指定地址所在城市，如：北京/北京市/BEIJING',
        example: '北京',
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], GeocodeDto.prototype, "city", void 0);
class RegeocodeDto {
}
exports.RegeocodeDto = RegeocodeDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '纬度',
        example: 39.990464,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], RegeocodeDto.prototype, "lat", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '经度',
        example: 116.481488,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], RegeocodeDto.prototype, "lng", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '返回结果控制，base:基本地址信息，all:基本+附近POI+道路',
        enum: ['base', 'all'],
        default: 'base',
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(['base', 'all']),
    __metadata("design:type", String)
], RegeocodeDto.prototype, "extensions", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '搜索半径，单位：米，取值范围：0-3000',
        default: 1000,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], RegeocodeDto.prototype, "radius", void 0);
//# sourceMappingURL=map-request.dto.js.map