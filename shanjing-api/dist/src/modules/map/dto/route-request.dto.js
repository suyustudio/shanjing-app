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
exports.RoutePlanningDto = exports.RouteType = exports.BicyclingRouteDto = exports.DrivingRouteDto = exports.WalkingRouteDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
const class_transformer_1 = require("class-transformer");
class WalkingRouteDto {
}
exports.WalkingRouteDto = WalkingRouteDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '出发点纬度',
        example: 39.989643,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], WalkingRouteDto.prototype, "originLat", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '出发点经度',
        example: 116.481028,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], WalkingRouteDto.prototype, "originLng", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '目的地纬度',
        example: 39.90816,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], WalkingRouteDto.prototype, "destLat", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '目的地经度',
        example: 116.434446,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], WalkingRouteDto.prototype, "destLng", void 0);
class DrivingRouteDto {
}
exports.DrivingRouteDto = DrivingRouteDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '出发点纬度',
        example: 39.989643,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], DrivingRouteDto.prototype, "originLat", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '出发点经度',
        example: 116.481028,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], DrivingRouteDto.prototype, "originLng", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '目的地纬度',
        example: 39.90816,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], DrivingRouteDto.prototype, "destLat", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '目的地经度',
        example: 116.434446,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], DrivingRouteDto.prototype, "destLng", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '驾车策略，默认10（躲避拥堵）',
        example: 10,
        default: 10,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], DrivingRouteDto.prototype, "strategy", void 0);
class BicyclingRouteDto {
}
exports.BicyclingRouteDto = BicyclingRouteDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '出发点纬度',
        example: 39.989643,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], BicyclingRouteDto.prototype, "originLat", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '出发点经度',
        example: 116.481028,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], BicyclingRouteDto.prototype, "originLng", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '目的地纬度',
        example: 39.90816,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], BicyclingRouteDto.prototype, "destLat", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '目的地经度',
        example: 116.434446,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], BicyclingRouteDto.prototype, "destLng", void 0);
var RouteType;
(function (RouteType) {
    RouteType["WALKING"] = "walking";
    RouteType["DRIVING"] = "driving";
    RouteType["BICYCLING"] = "bicycling";
})(RouteType || (exports.RouteType = RouteType = {}));
class RoutePlanningDto {
}
exports.RoutePlanningDto = RoutePlanningDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '出发点纬度',
        example: 39.989643,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], RoutePlanningDto.prototype, "originLat", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '出发点经度',
        example: 116.481028,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], RoutePlanningDto.prototype, "originLng", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '目的地纬度',
        example: 39.90816,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], RoutePlanningDto.prototype, "destLat", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '目的地经度',
        example: 116.434446,
    }),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], RoutePlanningDto.prototype, "destLng", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '路线类型：walking(步行)、driving(驾车)、bicycling(骑行)',
        enum: RouteType,
        example: RouteType.WALKING,
    }),
    (0, class_validator_1.IsEnum)(RouteType),
    __metadata("design:type", String)
], RoutePlanningDto.prototype, "type", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '驾车策略（仅驾车路线有效），默认10（躲避拥堵）',
        example: 10,
        default: 10,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_transformer_1.Type)(() => Number),
    __metadata("design:type", Number)
], RoutePlanningDto.prototype, "strategy", void 0);
//# sourceMappingURL=route-request.dto.js.map