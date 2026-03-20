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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MapController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const amap_geocode_service_1 = require("./amap-geocode.service");
const amap_route_service_1 = require("./amap-route.service");
const dto_1 = require("./dto");
let MapController = class MapController {
    constructor(amapGeocodeService, amapRouteService) {
        this.amapGeocodeService = amapGeocodeService;
        this.amapRouteService = amapRouteService;
    }
    async geocode(dto) {
        const result = await this.amapGeocodeService.geocode({
            address: dto.address,
            city: dto.city,
        });
        return {
            success: result.success,
            errorMessage: result.errorMessage,
            data: {
                locations: result.locations,
            },
        };
    }
    async regeocode(dto) {
        const location = this.amapGeocodeService.formatLocation(dto.lat, dto.lng);
        const result = await this.amapGeocodeService.regeocode({
            location,
            extensions: dto.extensions,
            radius: dto.radius,
        });
        return {
            success: result.success,
            errorMessage: result.errorMessage,
            data: {
                formattedAddress: result.formattedAddress,
                addressComponent: result.addressComponent,
                pois: result.pois,
            },
        };
    }
    async walkingRoute(dto) {
        const origin = this.amapRouteService.formatLocation(dto.originLat, dto.originLng);
        const destination = this.amapRouteService.formatLocation(dto.destLat, dto.destLng);
        const result = await this.amapRouteService.walkingRoute({
            origin,
            destination,
        });
        return {
            success: result.success,
            errorMessage: result.errorMessage,
            data: {
                origin: result.origin || origin,
                destination: result.destination || destination,
                paths: result.paths,
            },
        };
    }
    async drivingRoute(dto) {
        const origin = this.amapRouteService.formatLocation(dto.originLat, dto.originLng);
        const destination = this.amapRouteService.formatLocation(dto.destLat, dto.destLng);
        const result = await this.amapRouteService.drivingRoute({
            origin,
            destination,
            strategy: dto.strategy,
        });
        return {
            success: result.success,
            errorMessage: result.errorMessage,
            data: {
                origin: result.origin || origin,
                destination: result.destination || destination,
                paths: result.paths,
            },
        };
    }
    async bicyclingRoute(dto) {
        const origin = this.amapRouteService.formatLocation(dto.originLat, dto.originLng);
        const destination = this.amapRouteService.formatLocation(dto.destLat, dto.destLng);
        const result = await this.amapRouteService.bicyclingRoute({
            origin,
            destination,
        });
        return {
            success: result.success,
            errorMessage: result.errorMessage,
            data: {
                origin: result.origin || origin,
                destination: result.destination || destination,
                paths: result.paths,
            },
        };
    }
    async routePlanning(dto) {
        const origin = this.amapRouteService.formatLocation(dto.originLat, dto.originLng);
        const destination = this.amapRouteService.formatLocation(dto.destLat, dto.destLng);
        let result;
        switch (dto.type) {
            case dto_1.RouteType.WALKING:
                result = await this.amapRouteService.walkingRoute({ origin, destination });
                break;
            case dto_1.RouteType.DRIVING:
                result = await this.amapRouteService.drivingRoute({
                    origin,
                    destination,
                    strategy: dto.strategy,
                });
                break;
            case dto_1.RouteType.BICYCLING:
                result = await this.amapRouteService.bicyclingRoute({ origin, destination });
                break;
            default:
                return {
                    success: false,
                    errorMessage: '不支持的路线类型',
                    data: {
                        origin,
                        destination,
                        paths: [],
                    },
                };
        }
        return {
            success: result.success,
            errorMessage: result.errorMessage,
            data: {
                origin: result.origin || origin,
                destination: result.destination || destination,
                paths: result.paths,
            },
        };
    }
};
exports.MapController = MapController;
__decorate([
    (0, common_1.Post)('geocode'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '地理编码',
        description: '将结构化地址转换为经纬度坐标'
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '地理编码成功',
        type: dto_1.GeocodeResponseDto,
    }),
    (0, swagger_1.ApiResponse)({
        status: 400,
        description: '请求参数错误',
    }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.GeocodeDto]),
    __metadata("design:returntype", Promise)
], MapController.prototype, "geocode", null);
__decorate([
    (0, common_1.Post)('regeocode'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '逆地理编码',
        description: '将经纬度坐标转换为结构化地址'
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '逆地理编码成功',
        type: dto_1.RegeocodeResponseDto,
    }),
    (0, swagger_1.ApiResponse)({
        status: 400,
        description: '请求参数错误',
    }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.RegeocodeDto]),
    __metadata("design:returntype", Promise)
], MapController.prototype, "regeocode", null);
__decorate([
    (0, common_1.Post)('route/walking'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '步行路线规划',
        description: '规划两点之间的步行路线'
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '路线规划成功',
        type: dto_1.RouteResponseDto,
    }),
    (0, swagger_1.ApiResponse)({
        status: 400,
        description: '请求参数错误',
    }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.WalkingRouteDto]),
    __metadata("design:returntype", Promise)
], MapController.prototype, "walkingRoute", null);
__decorate([
    (0, common_1.Post)('route/driving'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '驾车路线规划',
        description: '规划两点之间的驾车路线'
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '路线规划成功',
        type: dto_1.RouteResponseDto,
    }),
    (0, swagger_1.ApiResponse)({
        status: 400,
        description: '请求参数错误',
    }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.DrivingRouteDto]),
    __metadata("design:returntype", Promise)
], MapController.prototype, "drivingRoute", null);
__decorate([
    (0, common_1.Post)('route/bicycling'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '骑行路线规划',
        description: '规划两点之间的骑行路线'
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '路线规划成功',
        type: dto_1.RouteResponseDto,
    }),
    (0, swagger_1.ApiResponse)({
        status: 400,
        description: '请求参数错误',
    }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.BicyclingRouteDto]),
    __metadata("design:returntype", Promise)
], MapController.prototype, "bicyclingRoute", null);
__decorate([
    (0, common_1.Post)('route'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '路线规划',
        description: '根据类型规划路线（步行、驾车、骑行）'
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '路线规划成功',
        type: dto_1.RouteResponseDto,
    }),
    (0, swagger_1.ApiResponse)({
        status: 400,
        description: '请求参数错误',
    }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.RoutePlanningDto]),
    __metadata("design:returntype", Promise)
], MapController.prototype, "routePlanning", null);
exports.MapController = MapController = __decorate([
    (0, swagger_1.ApiTags)('地图服务'),
    (0, common_1.Controller)('map'),
    __metadata("design:paramtypes", [amap_geocode_service_1.AmapGeocodeService,
        amap_route_service_1.AmapRouteService])
], MapController);
//# sourceMappingURL=map.controller.js.map