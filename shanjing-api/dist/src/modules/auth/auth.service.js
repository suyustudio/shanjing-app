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
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const jwt_1 = require("@nestjs/jwt");
const prisma_service_1 = require("../../database/prisma.service");
const crypto = require("crypto");
let AuthService = class AuthService {
    constructor(prisma, jwtService, configService) {
        this.prisma = prisma;
        this.jwtService = jwtService;
        this.configService = configService;
    }
    async registerByPhone(dto) {
        const { phone, code, nickname } = dto;
        await this.verifySmsCode(phone, code);
        const existingUser = await this.prisma.user.findUnique({
            where: { phone },
        });
        if (existingUser) {
            throw new common_1.ConflictException({
                success: false,
                error: {
                    code: 'PHONE_ALREADY_EXISTS',
                    message: '该手机号已被注册',
                },
            });
        }
        const user = await this.prisma.user.create({
            data: {
                phone,
                nickname: nickname || `用户${phone.slice(-4)}`,
                settings: {},
            },
        });
        const tokens = await this.generateTokens(user.id);
        return {
            success: true,
            data: {
                user: this.sanitizeUser(user),
                tokens,
            },
        };
    }
    async registerByWechat(dto) {
        const { code, nickname } = dto;
        const wechatUser = await this.getWechatUserInfo(code);
        const existingUser = await this.prisma.user.findUnique({
            where: { wxOpenid: wechatUser.openid },
        });
        if (existingUser) {
            throw new common_1.ConflictException({
                success: false,
                error: {
                    code: 'WECHAT_ALREADY_EXISTS',
                    message: '该微信账号已被注册',
                },
            });
        }
        const user = await this.prisma.user.create({
            data: {
                wxOpenid: wechatUser.openid,
                wxUnionid: wechatUser.unionid,
                nickname: nickname || wechatUser.nickname || '微信用户',
                avatarUrl: wechatUser.avatarUrl,
                settings: {},
            },
        });
        const tokens = await this.generateTokens(user.id);
        return {
            success: true,
            data: {
                user: this.sanitizeUser(user),
                tokens,
            },
        };
    }
    async loginByPhone(dto) {
        const { phone, code } = dto;
        await this.verifySmsCode(phone, code);
        let user = await this.prisma.user.findUnique({
            where: { phone },
        });
        if (!user) {
            user = await this.prisma.user.create({
                data: {
                    phone,
                    nickname: `用户${phone.slice(-4)}`,
                    settings: {},
                },
            });
        }
        const tokens = await this.generateTokens(user.id);
        return {
            success: true,
            data: {
                user: this.sanitizeUser(user),
                tokens,
            },
        };
    }
    async loginByWechat(dto) {
        const { code } = dto;
        const wechatUser = await this.getWechatUserInfo(code);
        let user = await this.prisma.user.findUnique({
            where: { wxOpenid: wechatUser.openid },
        });
        if (!user) {
            user = await this.prisma.user.create({
                data: {
                    wxOpenid: wechatUser.openid,
                    wxUnionid: wechatUser.unionid,
                    nickname: wechatUser.nickname || '微信用户',
                    avatarUrl: wechatUser.avatarUrl,
                    settings: {},
                },
            });
        }
        const tokens = await this.generateTokens(user.id);
        return {
            success: true,
            data: {
                user: this.sanitizeUser(user),
                tokens,
            },
        };
    }
    async refreshToken(refreshToken) {
        try {
            const payload = this.jwtService.verify(refreshToken, {
                secret: this.configService.get('JWT_REFRESH_SECRET'),
            });
            if (payload.type !== 'refresh') {
                throw new common_1.UnauthorizedException({
                    success: false,
                    error: {
                        code: 'TOKEN_INVALID',
                        message: 'Token类型错误',
                    },
                });
            }
            const blacklisted = await this.prisma.tokenBlacklist.findUnique({
                where: { token: refreshToken },
            });
            if (blacklisted) {
                throw new common_1.UnauthorizedException({
                    success: false,
                    error: {
                        code: 'TOKEN_BLACKLISTED',
                        message: 'Token已被注销',
                    },
                });
            }
            return this.generateTokens(payload.sub);
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
    async logout(dto) {
        const { refreshToken, allDevices = false } = dto;
        if (refreshToken) {
            const payload = this.jwtService.decode(refreshToken);
            if (payload && payload.exp) {
                await this.prisma.tokenBlacklist.create({
                    data: {
                        token: refreshToken,
                        expiresAt: new Date(payload.exp * 1000),
                    },
                });
            }
        }
    }
    async generateTokens(userId) {
        const accessSecret = this.configService.get('JWT_ACCESS_SECRET');
        const refreshSecret = this.configService.get('JWT_REFRESH_SECRET');
        const accessExpiration = this.configService.get('JWT_ACCESS_EXPIRATION', '2h');
        const refreshExpiration = this.configService.get('JWT_REFRESH_EXPIRATION', '7d');
        const accessPayload = {
            sub: userId,
            type: 'access',
        };
        const refreshPayload = {
            sub: userId,
            type: 'refresh',
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
    async getWechatUserInfo(code) {
        const mockOpenid = `o${crypto.randomBytes(16).toString('hex')}`;
        return {
            openid: mockOpenid,
            unionid: `u${crypto.randomBytes(16).toString('hex')}`,
            nickname: '微信用户',
            avatarUrl: `https://thirdwx.qlogo.cn/mmopen/vi_32/placeholder/${mockOpenid}/132`,
        };
    }
    sanitizeUser(user) {
        const { wxOpenid, wxUnionid, ...safeUser } = user;
        return safeUser;
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        jwt_1.JwtService,
        config_1.ConfigService])
], AuthService);
//# sourceMappingURL=auth.service.js.map