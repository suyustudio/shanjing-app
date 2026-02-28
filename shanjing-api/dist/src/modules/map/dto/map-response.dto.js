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
exports.RegeocodeResponseDto = exports.GeocodeResponseDto = exports.RegeocodeDataDto = exports.GeocodeDataDto = exports.PoiInfoDto = exports.LocationInfoDto = exports.AddressComponentDto = exports.LatLngDto = void 0;
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
class AddressComponentDto {
}
exports.AddressComponentDto = AddressComponentDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '国家', example: '中国' }),
    __metadata("design:type", String)
], AddressComponentDto.prototype, "country", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '省/直辖市', example: '北京市' }),
    __metadata("design:type", String)
], AddressComponentDto.prototype, "province", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '市', example: '北京市' }),
    __metadata("design:type", String)
], AddressComponentDto.prototype, "city", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '区', example: '朝阳区' }),
    __metadata("design:type", String)
], AddressComponentDto.prototype, "district", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '乡镇/街道', example: '望京街道' }),
    __metadata("design:type", String)
], AddressComponentDto.prototype, "township", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '社区/村' }),
    __metadata("design:type", String)
], AddressComponentDto.prototype, "neighborhood", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '建筑' }),
    __metadata("design:type", String)
], AddressComponentDto.prototype, "building", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '街道' }),
    __metadata("design:type", String)
], AddressComponentDto.prototype, "street", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '门牌号' }),
    __metadata("design:type", String)
], AddressComponentDto.prototype, "number", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '区域编码', example: '110105' }),
    __metadata("design:type", String)
], AddressComponentDto.prototype, "adcode", void 0);
class LocationInfoDto {
}
exports.LocationInfoDto = LocationInfoDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '经纬度坐标', type: LatLngDto }),
    __metadata("design:type", LatLngDto)
], LocationInfoDto.prototype, "location", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '格式化地址', example: '北京市朝阳区望京街道阜通东大街6号' }),
    __metadata("design:type", String)
], LocationInfoDto.prototype, "formattedAddress", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '国家', example: '中国' }),
    __metadata("design:type", String)
], LocationInfoDto.prototype, "country", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '省/直辖市', example: '北京市' }),
    __metadata("design:type", String)
], LocationInfoDto.prototype, "province", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '市', example: '北京市' }),
    __metadata("design:type", String)
], LocationInfoDto.prototype, "city", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '区', example: '朝阳区' }),
    __metadata("design:type", String)
], LocationInfoDto.prototype, "district", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '街道' }),
    __metadata("design:type", String)
], LocationInfoDto.prototype, "street", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '门牌号' }),
    __metadata("design:type", String)
], LocationInfoDto.prototype, "streetNumber", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '区域编码', example: '110105' }),
    __metadata("design:type", String)
], LocationInfoDto.prototype, "adcode", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '匹配级别', example: '门址' }),
    __metadata("design:type", String)
], LocationInfoDto.prototype, "level", void 0);
class PoiInfoDto {
}
exports.PoiInfoDto = PoiInfoDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'POI ID', example: 'B000A7BGD1' }),
    __metadata("design:type", String)
], PoiInfoDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'POI名称', example: '方恒国际中心' }),
    __metadata("design:type", String)
], PoiInfoDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'POI类型', example: '商务住宅;楼宇;商务写字楼' }),
    __metadata("design:type", String)
], PoiInfoDto.prototype, "type", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '电话' }),
    __metadata("design:type", String)
], PoiInfoDto.prototype, "tel", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '距离坐标点距离，单位：米' }),
    __metadata("design:type", Number)
], PoiInfoDto.prototype, "distance", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '地址', example: '阜通东大街6号' }),
    __metadata("design:type", String)
], PoiInfoDto.prototype, "address", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '经纬度坐标', type: LatLngDto }),
    __metadata("design:type", LatLngDto)
], PoiInfoDto.prototype, "location", void 0);
class GeocodeDataDto {
}
exports.GeocodeDataDto = GeocodeDataDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '地址信息列表', type: [LocationInfoDto] }),
    __metadata("design:type", Array)
], GeocodeDataDto.prototype, "locations", void 0);
class RegeocodeDataDto {
}
exports.RegeocodeDataDto = RegeocodeDataDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '结构化地址', example: '北京市朝阳区望京街道阜通东大街6号方恒国际中心' }),
    __metadata("design:type", String)
], RegeocodeDataDto.prototype, "formattedAddress", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '地址组成元素', type: AddressComponentDto }),
    __metadata("design:type", AddressComponentDto)
], RegeocodeDataDto.prototype, "addressComponent", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '附近POI列表', type: [PoiInfoDto] }),
    __metadata("design:type", Array)
], RegeocodeDataDto.prototype, "pois", void 0);
class GeocodeResponseDto {
}
exports.GeocodeResponseDto = GeocodeResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否成功', example: true }),
    __metadata("design:type", Boolean)
], GeocodeResponseDto.prototype, "success", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '错误信息' }),
    __metadata("design:type", String)
], GeocodeResponseDto.prototype, "errorMessage", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '响应数据', type: GeocodeDataDto }),
    __metadata("design:type", GeocodeDataDto)
], GeocodeResponseDto.prototype, "data", void 0);
class RegeocodeResponseDto {
}
exports.RegeocodeResponseDto = RegeocodeResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否成功', example: true }),
    __metadata("design:type", Boolean)
], RegeocodeResponseDto.prototype, "success", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '错误信息' }),
    __metadata("design:type", String)
], RegeocodeResponseDto.prototype, "errorMessage", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '响应数据', type: RegeocodeDataDto }),
    __metadata("design:type", RegeocodeDataDto)
], RegeocodeResponseDto.prototype, "data", void 0);
//# sourceMappingURL=map-response.dto.js.map