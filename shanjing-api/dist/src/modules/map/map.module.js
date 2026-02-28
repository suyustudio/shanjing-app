"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MapModule = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const amap_config_service_1 = require("./amap-config.service");
const amap_geocode_service_1 = require("./amap-geocode.service");
const map_controller_1 = require("./map.controller");
let MapModule = class MapModule {
};
exports.MapModule = MapModule;
exports.MapModule = MapModule = __decorate([
    (0, common_1.Module)({
        imports: [config_1.ConfigModule],
        controllers: [map_controller_1.MapController],
        providers: [amap_config_service_1.AmapConfigService, amap_geocode_service_1.AmapGeocodeService],
        exports: [amap_config_service_1.AmapConfigService, amap_geocode_service_1.AmapGeocodeService],
    })
], MapModule);
//# sourceMappingURL=map.module.js.map