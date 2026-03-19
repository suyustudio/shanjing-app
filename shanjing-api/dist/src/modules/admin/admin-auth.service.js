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
exports.AdminAuthService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const jwt_1 = require("@nestjs/jwt");
const prisma_service_1 = require("../../database/prisma.service");
const admin_role_enum_1 = require("../admin-role.enum");
const crypto = require("crypto");
let AdminAuthService = class AdminAuthService {
    constructor(prisma, jwtService, configService) {
        this.prisma = prisma;
        this.jwtService = jwtService;
        this.configService = configService;
    }
    async login(dto) {
        const { username, password } = dto;
        const admin = await this.prisma.adminUser.findUnique({
            where: { username },
        });
        if (!admin) {
            throw new common_1.UnauthorizedException({
                success: false,
                error: {
                    code: 'INVALID_CREDENTIALS',
                    message: '用户名或密码错误',
                },
            });
        }
        if (!admin.isActive) {
            throw new common_1.UnauthorizedException({
                success: false,
                error: {
                    code: 'ACCOUNT_DISABLED',
                    message: '账号已被禁用',
                },
            });
        }
        const hashedPassword = this.hashPassword(password);
        if (hashedPassword !== admin.passwordHash) {
            throw new common_1.UnauthorizedException({
                success: false,
                error: {
                    code: 'INVALID_CREDENTIALS',
                    message: '用户名或密码错误',
                },
            });
        }
        await this.prisma.adminUser.update({
            where: { id: admin.id },
            data: { lastLoginAt: new Date() },
        });
        const tokens = await this.generateTokens(admin.id, admin.username, admin.role);
        return {
            success: true,
            data: {
                admin: {
                    id: admin.id,
                    username: admin.username,
                    nickname: admin.nickname,
                    role: admin.role,
                },
                tokens,
            },
        };
    }
    async refreshToken(refreshToken) {
        try {
            const payload = this.jwtService.verify(refreshToken, {
                secret: this.configService.get('ADMIN_JWT_REFRESH_SECRET'),
            });
            if (payload.type !== 'admin_refresh') {
                throw new common_1.UnauthorizedException({
                    success: false,
                    error: {
                        code: 'TOKEN_INVALID',
                        message: 'Token类型错误',
                    },
                });
            }
            const admin = await this.prisma.adminUser.findUnique({
                where: { id: payload.sub },
            });
            if (!admin || !admin.isActive) {
                throw new common_1.UnauthorizedException({
                    success: false,
                    error: {
                        code: 'ACCOUNT_INVALID',
                        message: '账号不存在或已被禁用',
                    },
                });
            }
            return this.generateTokens(admin.id, admin.username, admin.role);
        }
        catch (error) {
            throw new common_1.UnauthorizedException({
                success: false,
                error: {
                    code: 'TOKEN_EXPIRED',
                    message: 'Token已过期或无效',
                },
            });
        }
    }
    async getAdminInfo(adminId) {
        const admin = await this.prisma.adminUser.findUnique({
            where: { id: adminId },
        });
        if (!admin) {
            throw new common_1.NotFoundException({
                success: false,
                error: {
                    code: 'ADMIN_NOT_FOUND',
                    message: '管理员不存在',
                },
            });
        }
        return {
            success: true,
            data: {
                id: admin.id,
                username: admin.username,
                nickname: admin.nickname,
                role: admin.role,
                isActive: admin.isActive,
                lastLoginAt: admin.lastLoginAt,
                createdAt: admin.createdAt,
            },
        };
    }
    async createAdmin(dto, currentAdminRole) {
        if (currentAdminRole !== admin_role_enum_1.AdminRole.SUPER_ADMIN) {
            throw new common_1.UnauthorizedException({
                success: false,
                error: {
                    code: 'PERMISSION_DENIED',
                    message: '只有超级管理员可以创建管理员',
                },
            });
        }
        const existingAdmin = await this.prisma.adminUser.findUnique({
            where: { username: dto.username },
        });
        if (existingAdmin) {
            throw new common_1.ConflictException({
                success: false,
                error: {
                    code: 'USERNAME_EXISTS',
                    message: '用户名已存在',
                },
            });
        }
        const admin = await this.prisma.adminUser.create({
            data: {
                username: dto.username,
                passwordHash: this.hashPassword(dto.password),
                nickname: dto.nickname || null,
                role: dto.role,
                isActive: true,
            },
        });
        return {
            success: true,
            data: {
                id: admin.id,
                username: admin.username,
                nickname: admin.nickname,
                role: admin.role,
                isActive: admin.isActive,
                createdAt: admin.createdAt,
            },
        };
    }
    async updateAdmin(adminId, dto, currentAdminId, currentAdminRole) {
        if (currentAdminId !== adminId && currentAdminRole !== admin_role_enum_1.AdminRole.SUPER_ADMIN) {
            throw new common_1.UnauthorizedException({
                success: false,
                error: {
                    code: 'PERMISSION_DENIED',
                    message: '无权修改其他管理员',
                },
            });
        }
        if (currentAdminId === adminId && dto.role) {
            throw new common_1.BadRequestException({
                success: false,
                error: {
                    code: 'CANNOT_MODIFY_SELF_ROLE',
                    message: '不能修改自己的角色',
                },
            });
        }
        const admin = await this.prisma.adminUser.findUnique({
            where: { id: adminId },
        });
        if (!admin) {
            throw new common_1.NotFoundException({
                success: false,
                error: {
                    code: 'ADMIN_NOT_FOUND',
                    message: '管理员不存在',
                },
            });
        }
        const updateData = {};
        if (dto.nickname !== undefined)
            updateData.nickname = dto.nickname;
        if (dto.password)
            updateData.passwordHash = this.hashPassword(dto.password);
        if (dto.role !== undefined)
            updateData.role = dto.role;
        if (dto.isActive !== undefined)
            updateData.isActive = dto.isActive;
        const updatedAdmin = await this.prisma.adminUser.update({
            where: { id: adminId },
            data: updateData,
        });
        return {
            success: true,
            data: {
                id: updatedAdmin.id,
                username: updatedAdmin.username,
                nickname: updatedAdmin.nickname,
                role: updatedAdmin.role,
                isActive: updatedAdmin.isActive,
                lastLoginAt: updatedAdmin.lastLoginAt,
                createdAt: updatedAdmin.createdAt,
            },
        };
    }
    async deleteAdmin(adminId, currentAdminId, currentAdminRole) {
        if (currentAdminId === adminId) {
            throw new common_1.BadRequestException({
                success: false,
                error: {
                    code: 'CANNOT_DELETE_SELF',
                    message: '不能删除自己',
                },
            });
        }
        if (currentAdminRole !== admin_role_enum_1.AdminRole.SUPER_ADMIN) {
            throw new common_1.UnauthorizedException({
                success: false,
                error: {
                    code: 'PERMISSION_DENIED',
                    message: '只有超级管理员可以删除管理员',
                },
            });
        }
        const admin = await this.prisma.adminUser.findUnique({
            where: { id: adminId },
        });
        if (!admin) {
            throw new common_1.NotFoundException({
                success: false,
                error: {
                    code: 'ADMIN_NOT_FOUND',
                    message: '管理员不存在',
                },
            });
        }
        await this.prisma.adminUser.delete({
            where: { id: adminId },
        });
        return {
            success: true,
            data: { message: '管理员删除成功' },
        };
    }
    async getAdminList(page = 1, limit = 20) {
        const skip = (page - 1) * limit;
        const [admins, total] = await Promise.all([
            this.prisma.adminUser.findMany({
                skip,
                take: limit,
                orderBy: { createdAt: 'desc' },
                select: {
                    id: true,
                    username: true,
                    nickname: true,
                    role: true,
                    isActive: true,
                    lastLoginAt: true,
                    createdAt: true,
                },
            }),
            this.prisma.adminUser.count(),
        ]);
        return {
            success: true,
            data: admins,
            meta: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
            },
        };
    }
    checkPermission(adminRole, permission) {
        return (0, admin_role_enum_1.hasPermission)(adminRole, permission);
    }
    async generateTokens(adminId, username, role) {
        const accessSecret = this.configService.get('ADMIN_JWT_SECRET');
        const refreshSecret = this.configService.get('ADMIN_JWT_REFRESH_SECRET');
        const accessExpiration = this.configService.get('ADMIN_JWT_EXPIRATION', '2h');
        const refreshExpiration = this.configService.get('ADMIN_JWT_REFRESH_EXPIRATION', '7d');
        const accessPayload = {
            sub: adminId,
            username,
            role,
            type: 'admin_access',
        };
        const refreshPayload = {
            sub: adminId,
            username,
            role,
            type: 'admin_refresh',
            jti: crypto.randomUUID(),
        };
        const [accessToken, refreshToken] = await Promise.all([
            this.jwtService.signAsync(accessPayload, {
                secret: accessSecret,
                expiresIn: accessExpiration,
            }),
            this.jwtService.signAsync(refreshPayload, {
                secret: refreshSecret,
                expiresIn: refreshExpiration,
            }),
        ]);
        const decoded = this.jwtService.decode(accessToken);
        const expiresIn = decoded.exp - Math.floor(Date.now() / 1000);
        return {
            accessToken,
            refreshToken,
            expiresIn,
        };
    }
    hashPassword(password) {
        return crypto.createHash('sha256').update(password).digest('hex');
    }
    async initializeDefaultAdmin() {
        const defaultUsername = this.configService.get('DEFAULT_ADMIN_USERNAME', 'admin');
        const defaultPassword = this.configService.get('DEFAULT_ADMIN_PASSWORD', 'admin123');
        const existingAdmin = await this.prisma.adminUser.findUnique({
            where: { username: defaultUsername },
        });
        if (!existingAdmin) {
            await this.prisma.adminUser.create({
                data: {
                    username: defaultUsername,
                    passwordHash: this.hashPassword(defaultPassword),
                    nickname: '超级管理员',
                    role: admin_role_enum_1.AdminRole.SUPER_ADMIN,
                    isActive: true,
                },
            });
            console.log(`默认管理员已创建: ${defaultUsername}`);
        }
    }
};
exports.AdminAuthService = AdminAuthService;
exports.AdminAuthService = AdminAuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        jwt_1.JwtService,
        config_1.ConfigService])
], AdminAuthService);
//# sourceMappingURL=admin-auth.service.js.map