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
exports.RouteResponseDto = exports.RouteDataDto = exports.RoutePathDto = exports.RouteStepDto = exports.LatLngDto = void 0;
const swagger_1 = require("@nestjs/swagger");
class LatLngDto {
}
exports.LatLngDto = LatLngDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '纬度', example: 39.990464 }),
    __metadata("design:type", Number)
], LatLngDto.prototype, "lat", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '经度', example: 116.481488 }),
    __metadata("design:type", Number)
], LatLngDto.prototype, "lng", void 0);
class RouteStepDto {
}
exports.RouteStepDto = RouteStepDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路段说明', example: '沿阜通东大街向北步行100米' }),
    __metadata("design:type", String)
], RouteStepDto.prototype, "instruction", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '道路名称', example: '阜通东大街' }),
    __metadata("design:type", String)
], RouteStepDto.prototype, "road", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '距离，单位：米', example: 100 }),
    __metadata("design:type", Number)
], RouteStepDto.prototype, "distance", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '预计耗时，单位：秒', example: 60 }),
    __metadata("design:type", Number)
], RouteStepDto.prototype, "duration", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '坐标点数组', type: [LatLngDto] }),
    __metadata("design:type", Array)
], RouteStepDto.prototype, "polyline", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '收费，单位：元（驾车）', example: 0 }),
    __metadata("design:type", Number)
], RouteStepDto.prototype, "tolls", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: 'toll道路名称（驾车）' }),
    __metadata("design:type", String)
], RouteStepDto.prototype, "tollRoad", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '主要动作', example: '直行' }),
    __metadata("design:type", String)
], RouteStepDto.prototype, "action", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '辅助动作', example: '' }),
    __metadata("design:type", String)
], RouteStepDto.prototype, "assistantAction", void 0);
class RoutePathDto {
}
exports.RoutePathDto = RoutePathDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '距离，单位：米', example: 5000 }),
    __metadata("design:type", Number)
], RoutePathDto.prototype, "distance", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '预计耗时，单位：秒', example: 3600 }),
    __metadata("design:type", Number)
], RoutePathDto.prototype, "duration", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '收费，单位：元（驾车）', example: 0 }),
    __metadata("design:type", Number)
], RoutePathDto.prototype, "tolls", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '收费路段距离，单位：米（驾车）', example: 0 }),
    __metadata("design:type", Number)
], RoutePathDto.prototype, "tollDistance", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '是否限行（驾车）', example: false }),
    __metadata("design:type", Boolean)
], RoutePathDto.prototype, "restriction", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '红绿灯个数（驾车）', example: 5 }),
    __metadata("design:type", Number)
], RoutePathDto.prototype, "trafficLights", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '导航路段列表', type: [RouteStepDto] }),
    __metadata("design:type", Array)
], RoutePathDto.prototype, "steps", void 0);
class RouteDataDto {
}
exports.RouteDataDto = RouteDataDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '起点坐标', example: '116.481028,39.989643' }),
    __metadata("design:type", String)
], RouteDataDto.prototype, "origin", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '终点坐标', example: '116.434446,39.90816' }),
    __metadata("design:type", String)
], RouteDataDto.prototype, "destination", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路线方案列表', type: [RoutePathDto] }),
    __metadata("design:type", Array)
], RouteDataDto.prototype, "paths", void 0);
class RouteResponseDto {
}
exports.RouteResponseDto = RouteResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否成功', example: true }),
    __metadata("design:type", Boolean)
], RouteResponseDto.prototype, "success", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '错误信息' }),
    __metadata("design:type", String)
], RouteResponseDto.prototype, "errorMessage", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '响应数据', type: RouteDataDto }),
    __metadata("design:type", RouteDataDto)
], RouteResponseDto.prototype, "data", void 0);
//# sourceMappingURL=route-response.dto.js.map