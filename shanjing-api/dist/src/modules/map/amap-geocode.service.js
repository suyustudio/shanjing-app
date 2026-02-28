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
var AmapGeocodeService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.AmapGeocodeService = void 0;
const common_1 = require("@nestjs/common");
const axios_1 = require("axios");
const amap_config_service_1 = require("./amap-config.service");
let AmapGeocodeService = AmapGeocodeService_1 = class AmapGeocodeService {
    constructor(configService) {
        this.configService = configService;
        this.logger = new common_1.Logger(AmapGeocodeService_1.name);
        this.httpClient = axios_1.default.create({
            timeout: this.configService.getTimeout(),
            headers: {
                'Content-Type': 'application/json',
            },
        });
        this.httpClient.interceptors.request.use((config) => {
            if (this.configService.isLogEnabled()) {
                this.logger.debug(`高德地图请求: ${config.url}`);
            }
            return config;
        });
        this.httpClient.interceptors.response.use((response) => response, (error) => {
            this.logger.error(`高德地图请求失败: ${error.message}`);
            throw error;
        });
    }
    async geocode(request) {
        try {
            const params = {
                key: this.configService.getApiKey(),
                address: request.address,
                city: request.city || '',
                output: 'JSON',
            };
            const response = await this.httpClient.get(`${this.configService.getBaseUrl()}/geocode/geo`, { params });
            const data = response.data;
            if (data.status !== '1') {
                this.logger.warn(`地理编码失败: ${data.info}`);
                return {
                    success: false,
                    errorMessage: data.info || '地理编码失败',
                    locations: [],
                };
            }
            const locations = data.geocodes.map((item) => this.convertToLocationInfo(item));
            if (this.configService.isLogEnabled()) {
                this.logger.debug(`地理编码成功: 找到 ${locations.length} 个结果`);
            }
            return {
                success: true,
                locations,
            };
        }
        catch (error) {
            this.logger.error(`地理编码请求异常: ${error.message}`);
            return {
                success: false,
                errorMessage: `请求异常: ${error.message}`,
                locations: [],
            };
        }
    }
    async regeocode(request) {
        try {
            const params = {
                key: this.configService.getApiKey(),
                location: request.location,
                poitype: request.poitype || '',
                radius: request.radius || 1000,
                extensions: request.extensions || 'base',
                homeorcorp: request.homeorcorp || '',
                output: 'JSON',
            };
            const response = await this.httpClient.get(`${this.configService.getBaseUrl()}/geocode/regeo`, { params });
            const data = response.data;
            if (data.status !== '1') {
                this.logger.warn(`逆地理编码失败: ${data.info}`);
                return {
                    success: false,
                    errorMessage: data.info || '逆地理编码失败',
                    formattedAddress: '',
                    addressComponent: {},
                };
            }
            const result = this.convertToRegeocodeResult(data);
            if (this.configService.isLogEnabled()) {
                this.logger.debug(`逆地理编码成功: ${result.formattedAddress}`);
            }
            return result;
        }
        catch (error) {
            this.logger.error(`逆地理编码请求异常: ${error.message}`);
            return {
                success: false,
                errorMessage: `请求异常: ${error.message}`,
                formattedAddress: '',
                addressComponent: {},
            };
        }
    }
    async batchGeocode(addresses, city) {
        const results = new Map();
        const promises = addresses.map(async (address) => {
            const result = await this.geocode({ address, city });
            results.set(address, result);
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
    convertToLocationInfo(item) {
        const location = this.parseLocation(item.location);
        return {
            location,
            formattedAddress: item.formatted_address || '',
            country: item.country || '中国',
            province: item.province || '',
            city: item.city || '',
            district: item.district || '',
            street: item.street || item.addressComponent?.street || '',
            streetNumber: item.number || item.addressComponent?.number || '',
            adcode: item.adcode || '',
            level: item.level || '',
        };
    }
    convertToRegeocodeResult(data) {
        const regeocode = data.regeocode;
        const component = regeocode.addressComponent;
        const addressComponent = {
            country: component.country || '中国',
            province: component.province || '',
            city: component.city || '',
            district: component.district || '',
            township: component.township || '',
            neighborhood: component.neighborhood?.name || '',
            building: component.building?.name || '',
            street: component.street || '',
            number: component.number || '',
            adcode: component.adcode || '',
        };
        const result = {
            success: true,
            formattedAddress: regeocode.formatted_address,
            addressComponent,
        };
        if (regeocode.pois && regeocode.pois.length > 0) {
            result.pois = regeocode.pois.map((poi) => ({
                id: poi.id,
                name: poi.name,
                type: poi.type,
                tel: poi.tel,
                distance: poi.distance ? parseInt(poi.distance, 10) : undefined,
                address: poi.address,
                location: this.parseLocation(poi.location),
            }));
        }
        return result;
    }
};
exports.AmapGeocodeService = AmapGeocodeService;
exports.AmapGeocodeService = AmapGeocodeService = AmapGeocodeService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [amap_config_service_1.AmapConfigService])
], AmapGeocodeService);
//# sourceMappingURL=amap-geocode.service.js.map