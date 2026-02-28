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
exports.AuthController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const auth_service_1 = require("./auth.service");
const dto_1 = require("./dto");
let AuthController = class AuthController {
    constructor(authService) {
        this.authService = authService;
    }
    async registerByPhone(dto) {
        return this.authService.registerByPhone(dto);
    }
    async registerByWechat(dto) {
        return this.authService.registerByWechat(dto);
    }
    async loginByPhone(dto) {
        return this.authService.loginByPhone(dto);
    }
    async loginByWechat(dto) {
        return this.authService.loginByWechat(dto);
    }
    async refreshToken(dto) {
        return this.authService.refreshToken(dto.refreshToken);
    }
    async logout(dto) {
        await this.authService.logout(dto);
        return {
            success: true,
            data: { message: '退出登录成功' },
        };
    }
};
exports.AuthController = AuthController;
__decorate([
    (0, common_1.Post)('register/phone'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: '手机号注册' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '注册成功' }),
    (0, swagger_1.ApiResponse)({ status: 400, description: '验证码错误或已过期' }),
    (0, swagger_1.ApiResponse)({ status: 409, description: '手机号已存在' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PhoneRegisterDto]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "registerByPhone", null);
__decorate([
    (0, common_1.Post)('register/wechat'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: '微信OAuth注册' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '注册成功' }),
    (0, swagger_1.ApiResponse)({ status: 400, description: '微信授权失败' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.WechatRegisterDto]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "registerByWechat", null);
__decorate([
    (0, common_1.Post)('login/phone'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: '手机号+验证码登录' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '登录成功' }),
    (0, swagger_1.ApiResponse)({ status: 400, description: '验证码错误' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PhoneLoginDto]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "loginByPhone", null);
__decorate([
    (0, common_1.Post)('login/wechat'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: '微信一键登录' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '登录成功' }),
    (0, swagger_1.ApiResponse)({ status: 400, description: '微信授权失败' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.WechatLoginDto]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "loginByWechat", null);
__decorate([
    (0, common_1.Post)('refresh'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: '刷新Token' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '刷新成功' }),
    (0, swagger_1.ApiResponse)({ status: 401, description: 'Token无效或已过期' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.RefreshTokenDto]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "refreshToken", null);
__decorate([
    (0, common_1.Post)('logout'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: '退出登录' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '退出成功' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.LogoutDto]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "logout", null);
exports.AuthController = AuthController = __decorate([
    (0, swagger_1.ApiTags)('认证'),
    (0, common_1.Controller)('auth'),
    __metadata("design:paramtypes", [auth_service_1.AuthService])
], AuthController);
//# sourceMappingURL=auth.controller.js.map