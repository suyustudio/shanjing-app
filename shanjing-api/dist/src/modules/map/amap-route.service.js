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
var AmapRouteService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.AmapRouteService = void 0;
const common_1 = require("@nestjs/common");
const axios_1 = require("axios");
const amap_config_service_1 = require("./amap-config.service");
let AmapRouteService = AmapRouteService_1 = class AmapRouteService {
    constructor(configService) {
        this.configService = configService;
        this.logger = new common_1.Logger(AmapRouteService_1.name);
        this.httpClient = axios_1.default.create({
            timeout: this.configService.getTimeout(),
            headers: {
                'Content-Type': 'application/json',
            },
        });
        this.httpClient.interceptors.request.use((config) => {
            if (this.configService.isLogEnabled()) {
                this.logger.debug(`高德地图路线规划请求: ${config.url}`);
            }
            return config;
        });
        this.httpClient.interceptors.response.use((response) => response, (error) => {
            this.logger.error(`高德地图路线规划请求失败: ${error.message}`);
            throw error;
        });
    }
    async walkingRoute(request) {
        try {
            const params = {
                key: this.configService.getApiKey(),
                origin: request.origin,
                destination: request.destination,
                output: 'JSON',
            };
            const response = await this.httpClient.get(`${this.configService.getBaseUrl()}/direction/walking`, { params });
            const data = response.data;
            if (data.status !== '1') {
                this.logger.warn(`步行路线规划失败: ${data.info}`);
                return {
                    success: false,
                    errorMessage: data.info || '步行路线规划失败',
                    paths: [],
                };
            }
            const paths = data.route.paths.map((path) => this.convertWalkingPath(path));
            if (this.configService.isLogEnabled()) {
                this.logger.debug(`步行路线规划成功: 找到 ${paths.length} 条路线`);
            }
            return {
                success: true,
                origin: data.route.origin,
                destination: data.route.destination,
                paths,
            };
        }
        catch (error) {
            this.logger.error(`步行路线规划请求异常: ${error.message}`);
            return {
                success: false,
                errorMessage: `请求异常: ${error.message}`,
                paths: [],
            };
        }
    }
    async drivingRoute(request) {
        try {
            const params = {
                key: this.configService.getApiKey(),
                origin: request.origin,
                destination: request.destination,
                strategy: request.strategy || 10,
                waypoints: request.waypoints || '',
                avoidpolygons: request.avoidpolygons || '',
                avoidroad: request.avoidroad || '',
                output: 'JSON',
            };
            const response = await this.httpClient.get(`${this.configService.getBaseUrl()}/direction/driving`, { params });
            const data = response.data;
            if (data.status !== '1') {
                this.logger.warn(`驾车路线规划失败: ${data.info}`);
                return {
                    success: false,
                    errorMessage: data.info || '驾车路线规划失败',
                    paths: [],
                };
            }
            const paths = data.route.paths.map((path) => this.convertDrivingPath(path));
            if (this.configService.isLogEnabled()) {
                this.logger.debug(`驾车路线规划成功: 找到 ${paths.length} 条路线`);
            }
            return {
                success: true,
                origin: data.route.origin,
                destination: data.route.destination,
                paths,
            };
        }
        catch (error) {
            this.logger.error(`驾车路线规划请求异常: ${error.message}`);
            return {
                success: false,
                errorMessage: `请求异常: ${error.message}`,
                paths: [],
            };
        }
    }
    async bicyclingRoute(request) {
        try {
            const params = {
                key: this.configService.getApiKey(),
                origin: request.origin,
                destination: request.destination,
                output: 'JSON',
            };
            const response = await this.httpClient.get(`${this.configService.getBaseUrl()}/direction/bicycling`, { params });
            const data = response.data;
            if (data.status !== '1') {
                this.logger.warn(`骑行路线规划失败: ${data.info}`);
                return {
                    success: false,
                    errorMessage: data.info || '骑行路线规划失败',
                    paths: [],
                };
            }
            const paths = data.route.paths.map((path) => this.convertBicyclingPath(path));
            if (this.configService.isLogEnabled()) {
                this.logger.debug(`骑行路线规划成功: 找到 ${paths.length} 条路线`);
            }
            return {
                success: true,
                origin: data.route.origin,
                destination: data.route.destination,
                paths,
            };
        }
        catch (error) {
            this.logger.error(`骑行路线规划请求异常: ${error.message}`);
            return {
                success: false,
                errorMessage: `请求异常: ${error.message}`,
                paths: [],
            };
        }
    }
    async batchWalkingRoute(requests) {
        const results = new Map();
        const promises = requests.map(async (request, index) => {
            const result = await this.walkingRoute(request);
            results.set(`route_${index}`, result);
        });
        await Promise.all(promises);
        return results;
    }
    formatLocation(lat, lng) {
        return `${lng},${lat}`;
    }
    parseLocation(location) {
        const [lng, lat] = location.split(',').map(Number);
        return { lat, lng };
    }
    convertWalkingPath(path) {
        return {
            distance: parseInt(path.distance, 10),
            duration: parseInt(path.duration, 10),
            steps: path.steps.map((step) => ({
                instruction: step.instruction,
                road: step.road,
                distance: parseInt(step.distance, 10),
                duration: parseInt(step.duration, 10),
                polyline: this.parsePolyline(step.polyline),
                action: step.action,
                assistantAction: step.assistant_action,
            })),
        };
    }
    convertDrivingPath(path) {
        return {
            distance: parseInt(path.distance, 10),
            duration: parseInt(path.duration, 10),
            tolls: parseFloat(path.tolls || '0'),
            tollDistance: parseInt(path.toll_distance || '0', 10),
            restriction: parseInt(path.restriction || '0', 10) === 1,
            trafficLights: parseInt(path.traffic_lights || '0', 10),
            steps: path.steps.map((step) => ({
                instruction: step.instruction,
                road: step.road,
                distance: parseInt(step.distance, 10),
                duration: parseInt(step.duration, 10),
                polyline: this.parsePolyline(step.polyline),
                tolls: parseFloat(step.tolls || '0'),
                tollRoad: step.toll_road,
                action: step.action,
                assistantAction: step.assistant_action,
            })),
        };
    }
    convertBicyclingPath(path) {
        return {
            distance: parseInt(path.distance, 10),
            duration: parseInt(path.duration, 10),
            steps: path.steps.map((step) => ({
                instruction: step.instruction,
                road: step.road,
                distance: parseInt(step.distance, 10),
                duration: parseInt(step.duration, 10),
                polyline: this.parsePolyline(step.polyline),
                action: step.action,
                assistantAction: step.assistant_action,
            })),
        };
    }
    parsePolyline(polyline) {
        if (!polyline)
            return [];
        return polyline.split(';').map((point) => {
            const [lng, lat] = point.split(',').map(Number);
            return { lat, lng };
        });
    }
};
exports.AmapRouteService = AmapRouteService;
exports.AmapRouteService = AmapRouteService = AmapRouteService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [amap_config_service_1.AmapConfigService])
], AmapRouteService);
//# sourceMappingURL=amap-route.service.js.map