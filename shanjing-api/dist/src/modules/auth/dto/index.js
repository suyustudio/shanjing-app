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
exports.LogoutDto = exports.RefreshTokenDto = exports.WechatLoginDto = exports.PhoneLoginDto = exports.WechatRegisterDto = exports.PhoneRegisterDto = void 0;
const class_validator_1 = require("class-validator");
const swagger_1 = require("@nestjs/swagger");
class PhoneRegisterDto {
}
exports.PhoneRegisterDto = PhoneRegisterDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '手机号', example: '13800138000' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Matches)(/^1[3-9]\d{9}$/, { message: '手机号格式错误' }),
    __metadata("design:type", String)
], PhoneRegisterDto.prototype, "phone", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '短信验证码', example: '123456' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Length)(6, 6, { message: '验证码必须是6位数字' }),
    __metadata("design:type", String)
], PhoneRegisterDto.prototype, "code", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '用户昵称', example: '山径用户' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Length)(2, 20, { message: '昵称长度必须在2-20个字符之间' }),
    __metadata("design:type", String)
], PhoneRegisterDto.prototype, "nickname", void 0);
class WechatRegisterDto {
}
exports.WechatRegisterDto = WechatRegisterDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '微信授权code', example: 'wechat_auth_code' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], WechatRegisterDto.prototype, "code", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '用户昵称', example: '微信用户' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Length)(2, 20, { message: '昵称长度必须在2-20个字符之间' }),
    __metadata("design:type", String)
], WechatRegisterDto.prototype, "nickname", void 0);
class PhoneLoginDto {
}
exports.PhoneLoginDto = PhoneLoginDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '手机号', example: '13800138000' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Matches)(/^1[3-9]\d{9}$/, { message: '手机号格式错误' }),
    __metadata("design:type", String)
], PhoneLoginDto.prototype, "phone", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '短信验证码', example: '123456' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Length)(6, 6, { message: '验证码必须是6位数字' }),
    __metadata("design:type", String)
], PhoneLoginDto.prototype, "code", void 0);
class WechatLoginDto {
}
exports.WechatLoginDto = WechatLoginDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '微信授权code', example: 'wechat_auth_code' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], WechatLoginDto.prototype, "code", void 0);
class RefreshTokenDto {
}
exports.RefreshTokenDto = RefreshTokenDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '刷新令牌', example: 'eyJhbGciOiJIUzI1NiIs...' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], RefreshTokenDto.prototype, "refreshToken", void 0);
class LogoutDto {
}
exports.LogoutDto = LogoutDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '刷新令牌', example: 'eyJhbGciOiJIUzI1NiIs...' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], LogoutDto.prototype, "refreshToken", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '是否登出所有设备', default: false }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Boolean)
], LogoutDto.prototype, "allDevices", void 0);
//# sourceMappingURL=index.js.map