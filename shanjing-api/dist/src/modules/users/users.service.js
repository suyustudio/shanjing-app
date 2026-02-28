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
exports.UsersService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../database/prisma.service");
const files_service_1 = require("../files/files.service");
let UsersService = class UsersService {
    constructor(prisma, filesService) {
        this.prisma = prisma;
        this.filesService = filesService;
    }
    async getUserById(userId) {
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
        });
        if (!user) {
            throw new common_1.NotFoundException({
                success: false,
                error: {
                    code: 'USER_NOT_FOUND',
                    message: '用户不存在',
                },
            });
        }
        return {
            success: true,
            data: this.sanitizeUser(user),
        };
    }
    async updateUser(userId, dto) {
        const { nickname, settings } = dto;
        const existingUser = await this.prisma.user.findUnique({
            where: { id: userId },
        });
        if (!existingUser) {
            throw new common_1.NotFoundException({
                success: false,
                error: {
                    code: 'USER_NOT_FOUND',
                    message: '用户不存在',
                },
            });
        }
        const user = await this.prisma.user.update({
            where: { id: userId },
            data: {
                ...(nickname !== undefined && { nickname }),
                ...(settings !== undefined && { settings }),
            },
        });
        return {
            success: true,
            data: this.sanitizeUser(user),
        };
    }
    async uploadAvatar(userId, file) {
        const existingUser = await this.prisma.user.findUnique({
            where: { id: userId },
        });
        if (!existingUser) {
            throw new common_1.NotFoundException({
                success: false,
                error: {
                    code: 'USER_NOT_FOUND',
                    message: '用户不存在',
                },
            });
        }
        const avatarUrl = await this.filesService.uploadAvatar(file, userId);
        const user = await this.prisma.user.update({
            where: { id: userId },
            data: { avatarUrl },
        });
        return {
            success: true,
            data: {
                avatarUrl,
                updatedAt: user.updatedAt,
            },
        };
    }
    async updateEmergencyContacts(userId, dto) {
        const { contacts } = dto;
        const existingUser = await this.prisma.user.findUnique({
            where: { id: userId },
        });
        if (!existingUser) {
            throw new common_1.NotFoundException({
                success: false,
                error: {
                    code: 'USER_NOT_FOUND',
                    message: '用户不存在',
                },
            });
        }
        if (contacts.length > 3) {
            throw new common_1.BadRequestException({
                success: false,
                error: {
                    code: 'TOO_MANY_CONTACTS',
                    message: '紧急联系人最多只能添加3个',
                },
            });
        }
        const phoneRegex = /^1[3-9]\d{9}$/;
        for (const contact of contacts) {
            if (!phoneRegex.test(contact.phone)) {
                throw new common_1.BadRequestException({
                    success: false,
                    error: {
                        code: 'INVALID_PHONE_FORMAT',
                        message: `联系人 ${contact.name} 的手机号格式错误`,
                    },
                });
            }
        }
        const user = await this.prisma.user.update({
            where: { id: userId },
            data: {
                emergencyContacts: contacts,
            },
        });
        return {
            success: true,
            data: {
                emergencyContacts: user.emergencyContacts,
                updatedAt: user.updatedAt,
            },
        };
    }
    async bindPhone(userId, dto) {
        const { phone, code } = dto;
        await this.verifySmsCode(phone, code);
        const existingUser = await this.prisma.user.findUnique({
            where: { phone },
        });
        if (existingUser && existingUser.id !== userId) {
            throw new common_1.ConflictException({
                success: false,
                error: {
                    code: 'PHONE_ALREADY_EXISTS',
                    message: '该手机号已被其他账号绑定',
                },
            });
        }
        const user = await this.prisma.user.update({
            where: { id: userId },
            data: { phone },
        });
        return {
            success: true,
            data: {
                phone: user.phone,
                updatedAt: user.updatedAt,
            },
        };
    }
    async verifySmsCode(phone, code) {
        const testCode = '123456';
        if (code !== testCode) {
            throw new common_1.BadRequestException({
                success: false,
                error: {
                    code: 'INVALID_VERIFICATION_CODE',
                    message: '验证码错误或已过期',
                },
            });
        }
    }
    sanitizeUser(user) {
        const { wxOpenid, wxUnionid, ...safeUser } = user;
        return safeUser;
    }
};
exports.UsersService = UsersService;
exports.UsersService = UsersService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        files_service_1.FilesService])
], UsersService);
//# sourceMappingURL=users.service.js.map