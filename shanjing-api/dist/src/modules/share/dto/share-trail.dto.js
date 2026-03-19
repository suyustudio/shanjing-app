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
exports.TrailShareResponseDto = exports.TrailShareDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
class TrailShareDto {
}
exports.TrailShareDto = TrailShareDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '路线ID', example: 'trail_123456' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], TrailShareDto.prototype, "trailId", void 0);
class TrailShareResponseDto {
}
exports.TrailShareResponseDto = TrailShareResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '分享链接', example: 'https://shanjing.app/share/trail_123456' }),
    __metadata("design:type", String)
], TrailShareResponseDto.prototype, "shareUrl", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '二维码图片链接', example: 'https://shanjing.app/qrcode/trail_123456.png' }),
    __metadata("design:type", String)
], TrailShareResponseDto.prototype, "qrCodeUrl", void 0);
//# sourceMappingURL=share-trail.dto.js.map