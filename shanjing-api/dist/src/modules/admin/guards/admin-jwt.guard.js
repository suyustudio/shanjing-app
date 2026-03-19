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
exports.SuperAdminGuard = exports.AdminPermissionGuard = exports.AdminJwtAuthGuard = void 0;
const common_1 = require("@nestjs/common");
const jwt_1 = require("@nestjs/jwt");
const config_1 = require("@nestjs/config");
const admin_role_enum_1 = require("../admin-role.enum");
let AdminJwtAuthGuard = class AdminJwtAuthGuard {
    constructor(jwtService, configService) {
        this.jwtService = jwtService;
        this.configService = configService;
    }
    async canActivate(context) {
        const request = context.switchToHttp().getRequest();
        const token = this.extractTokenFromHeader(request);
        if (!token) {
            throw new common_1.UnauthorizedException({
                success: false,
                error: {
                    code: 'ADMIN_TOKEN_MISSING',
                    message: '管理员认证令牌缺失',
                },
            });
        }
        try {
            const payload = await this.jwtService.verifyAsync(token, {
                secret: this.configService.get('ADMIN_JWT_SECRET'),
            });
            if (payload.type !== 'admin_access') {
                throw new common_1.UnauthorizedException({
                    success: false,
                    error: {
                        code: 'ADMIN_TOKEN_INVALID',
                        message: '无效的管理员令牌',
                    },
                });
            }
            request.admin = {
                id: payload.sub,
                username: payload.username,
                role: payload.role,
            };
            return true;
        }
        catch (error) {
            throw new common_1.UnauthorizedException({
                success: false,
                error: {
                    code: 'ADMIN_TOKEN_EXPIRED',
                    message: '管理员令牌已过期或无效',
                },
            });
        }
    }
    extractTokenFromHeader(request) {
        const [type, token] = request.headers.authorization?.split(' ') ?? [];
        return type === 'Bearer' ? token : undefined;
    }
};
exports.AdminJwtAuthGuard = AdminJwtAuthGuard;
exports.AdminJwtAuthGuard = AdminJwtAuthGuard = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [jwt_1.JwtService,
        config_1.ConfigService])
], AdminJwtAuthGuard);
let AdminPermissionGuard = class AdminPermissionGuard {
    constructor(requiredPermission) {
        this.requiredPermission = requiredPermission;
    }
    canActivate(context) {
        const request = context.switchToHttp().getRequest();
        const admin = request.admin;
        if (!admin) {
            throw new common_1.UnauthorizedException({
                success: false,
                error: {
                    code: 'ADMIN_NOT_AUTHENTICATED',
                    message: '管理员未认证',
                },
            });
        }
        if (!(0, admin_role_enum_1.hasPermission)(admin.role, this.requiredPermission)) {
            throw new common_1.ForbiddenException({
                success: false,
                error: {
                    code: 'ADMIN_PERMISSION_DENIED',
                    message: '管理员权限不足',
                },
            });
        }
        return true;
    }
};
exports.AdminPermissionGuard = AdminPermissionGuard;
exports.AdminPermissionGuard = AdminPermissionGuard = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [String])
], AdminPermissionGuard);
let SuperAdminGuard = class SuperAdminGuard {
    canActivate(context) {
        const request = context.switchToHttp().getRequest();
        const admin = request.admin;
        if (!admin) {
            throw new common_1.UnauthorizedException({
                success: false,
                error: {
                    code: 'ADMIN_NOT_AUTHENTICATED',
                    message: '管理员未认证',
                },
            });
        }
        if (admin.role !== admin_role_enum_1.AdminRole.SUPER_ADMIN) {
            throw new common_1.ForbiddenException({
                success: false,
                error: {
                    code: 'SUPER_ADMIN_REQUIRED',
                    message: '需要超级管理员权限',
                },
            });
        }
        return true;
    }
};
exports.SuperAdminGuard = SuperAdminGuard;
exports.SuperAdminGuard = SuperAdminGuard = __decorate([
    (0, common_1.Injectable)()
], SuperAdminGuard);
//# sourceMappingURL=admin-jwt.guard.js.map