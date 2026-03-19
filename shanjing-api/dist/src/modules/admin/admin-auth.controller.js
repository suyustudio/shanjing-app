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
exports.AdminAuthController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const admin_auth_service_1 = require("./admin-auth.service");
const admin_jwt_guard_1 = require("./guards/admin-jwt.guard");
const current_admin_decorator_1 = require("./decorators/current-admin.decorator");
const admin_auth_dto_1 = require("./dto/admin-auth.dto");
let AdminAuthController = class AdminAuthController {
    constructor(adminAuthService) {
        this.adminAuthService = adminAuthService;
    }
    async login(dto) {
        return this.adminAuthService.login(dto);
    }
    async refreshToken(refreshToken) {
        return this.adminAuthService.refreshToken(refreshToken);
    }
    async getProfile(adminId) {
        return this.adminAuthService.getAdminInfo(adminId);
    }
    async createAdmin(dto, admin) {
        return this.adminAuthService.createAdmin(dto, admin.role);
    }
    async getAdminList(page = '1', limit = '20') {
        return this.adminAuthService.getAdminList(parseInt(page, 10), parseInt(limit, 10));
    }
    async updateAdmin(dto, admin) {
        return {
            success: true,
            message: '请使用 PUT /admin/admins/:id 接口',
        };
    }
};
exports.AdminAuthController = AdminAuthController;
__decorate([
    (0, common_1.Post)('login'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: '管理员登录' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '登录成功',
        type: admin_auth_dto_1.AdminLoginResponseDto,
    }),
    (0, swagger_1.ApiResponse)({ status: 401, description: '用户名或密码错误' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [admin_auth_dto_1.AdminLoginDto]),
    __metadata("design:returntype", Promise)
], AdminAuthController.prototype, "login", null);
__decorate([
    (0, common_1.Post)('refresh'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: '刷新Token' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '刷新成功' }),
    (0, swagger_1.ApiResponse)({ status: 401, description: 'Token无效或已过期' }),
    __param(0, (0, common_1.Body)('refreshToken')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], AdminAuthController.prototype, "refreshToken", null);
__decorate([
    (0, common_1.Get)('profile'),
    (0, common_1.UseGuards)(admin_jwt_guard_1.AdminJwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: '获取当前管理员信息' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '获取成功',
        type: admin_auth_dto_1.AdminInfoResponseDto,
    }),
    __param(0, (0, current_admin_decorator_1.CurrentAdmin)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], AdminAuthController.prototype, "getProfile", null);
__decorate([
    (0, common_1.Post)('admins'),
    (0, common_1.UseGuards)(admin_jwt_guard_1.AdminJwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: '创建管理员（仅超级管理员）' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '创建成功' }),
    (0, swagger_1.ApiResponse)({ status: 401, description: '权限不足' }),
    (0, swagger_1.ApiResponse)({ status: 409, description: '用户名已存在' }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, current_admin_decorator_1.CurrentAdmin)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [admin_auth_dto_1.CreateAdminDto, Object]),
    __metadata("design:returntype", Promise)
], AdminAuthController.prototype, "createAdmin", null);
__decorate([
    (0, common_1.Get)('admins'),
    (0, common_1.UseGuards)(admin_jwt_guard_1.AdminJwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: '获取管理员列表' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '获取成功',
        type: admin_auth_dto_1.AdminListResponseDto,
    }),
    __param(0, (0, common_1.Query)('page')),
    __param(1, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], AdminAuthController.prototype, "getAdminList", null);
__decorate([
    (0, common_1.Post)('admins/:id'),
    (0, common_1.UseGuards)(admin_jwt_guard_1.AdminJwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: '更新管理员信息' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '更新成功' }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, current_admin_decorator_1.CurrentAdmin)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [admin_auth_dto_1.UpdateAdminDto, Object]),
    __metadata("design:returntype", Promise)
], AdminAuthController.prototype, "updateAdmin", null);
exports.AdminAuthController = AdminAuthController = __decorate([
    (0, swagger_1.ApiTags)('后台管理-认证'),
    (0, common_1.Controller)('admin/auth'),
    __metadata("design:paramtypes", [admin_auth_service_1.AdminAuthService])
], AdminAuthController);
//# sourceMappingURL=admin-auth.controller.js.map