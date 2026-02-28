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
var AmapConfigService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.AmapConfigService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
let AmapConfigService = AmapConfigService_1 = class AmapConfigService {
    constructor(configService) {
        this.configService = configService;
        this.logger = new common_1.Logger(AmapConfigService_1.name);
        this.config = this.loadConfig();
        this.validateConfig();
        if (this.config.enableLog) {
            this.logger.log('高德地图配置已加载');
        }
    }
    loadConfig() {
        return {
            apiKey: this.configService.get('AMAP_API_KEY', ''),
            securityConfig: this.configService.get('AMAP_SECURITY_CONFIG', ''),
            baseUrl: this.configService.get('AMAP_BASE_URL', 'https://restapi.amap.com/v3'),
            timeout: this.configService.get('AMAP_TIMEOUT', 10000),
            enableLog: this.configService.get('AMAP_ENABLE_LOG', false),
        };
    }
    validateConfig() {
        if (!this.config.apiKey) {
            this.logger.error('高德地图 API Key 未配置，请在环境变量中设置 AMAP_API_KEY');
            throw new Error('AMAP_API_KEY is required');
        }
        if (this.config.enableLog) {
            this.logger.log(`高德地图 API 基础地址: ${this.config.baseUrl}`);
        }
    }
    getConfig() {
        return { ...this.config };
    }
    getApiKey() {
        return this.config.apiKey;
    }
    getBaseUrl() {
        return this.config.baseUrl;
    }
    getTimeout() {
        return this.config.timeout;
    }
    isLogEnabled() {
        return this.config.enableLog;
    }
};
exports.AmapConfigService = AmapConfigService;
exports.AmapConfigService = AmapConfigService = AmapConfigService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], AmapConfigService);
//# sourceMappingURL=amap-config.service.js.map