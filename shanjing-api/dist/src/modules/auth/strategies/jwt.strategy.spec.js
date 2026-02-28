"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const jwt_strategy_1 = require("./jwt.strategy");
const config_1 = require("@nestjs/config");
const prisma_service_1 = require("../../../database/prisma.service");
const common_1 = require("@nestjs/common");
describe('JwtStrategy', () => {
    let strategy;
    let prisma;
    const mockConfigService = {
        get: jest.fn().mockReturnValue('test-secret'),
    };
    const mockPrismaService = {
        user: {
            findUnique: jest.fn(),
        },
    };
    beforeEach(async () => {
        const module = await testing_1.Test.createTestingModule({
            providers: [
                jwt_strategy_1.JwtStrategy,
                {
                    provide: config_1.ConfigService,
                    useValue: mockConfigService,
                },
                {
                    provide: prisma_service_1.PrismaService,
                    useValue: mockPrismaService,
                },
            ],
        }).compile();
        strategy = module.get(jwt_strategy_1.JwtStrategy);
        prisma = module.get(prisma_service_1.PrismaService);
        jest.clearAllMocks();
    });
    it('should be defined', () => {
        expect(strategy).toBeDefined();
    });
    describe('validate', () => {
        it('should validate access token and return user info', async () => {
            const payload = {
                sub: 'user-1',
                type: 'access',
            };
            const mockUser = {
                id: 'user-1',
                phone: '13800138000',
                wxOpenid: 'wx_openid_xxx',
            };
            mockPrismaService.user.findUnique.mockResolvedValue(mockUser);
            const result = await strategy.validate(payload);
            expect(result).toEqual({
                userId: 'user-1',
                phone: '13800138000',
                wxOpenid: 'wx_openid_xxx',
            });
            expect(prisma.user.findUnique).toHaveBeenCalledWith({
                where: { id: 'user-1' },
            });
        });
        it('should throw UnauthorizedException for refresh token type', async () => {
            const payload = {
                sub: 'user-1',
                type: 'refresh',
            };
            await expect(strategy.validate(payload)).rejects.toThrow(common_1.UnauthorizedException);
        });
        it('should throw UnauthorizedException when user not found', async () => {
            const payload = {
                sub: 'non-existent-user',
                type: 'access',
            };
            mockPrismaService.user.findUnique.mockResolvedValue(null);
            await expect(strategy.validate(payload)).rejects.toThrow(common_1.UnauthorizedException);
        });
        it('should throw UnauthorizedException with correct error code for refresh token', async () => {
            const payload = {
                sub: 'user-1',
                type: 'refresh',
            };
            try {
                await strategy.validate(payload);
                fail('Should have thrown UnauthorizedException');
            }
            catch (error) {
                expect(error).toBeInstanceOf(common_1.UnauthorizedException);
                expect(error.response).toEqual({
                    success: false,
                    error: {
                        code: 'TOKEN_INVALID',
                        message: 'Token类型错误',
                    },
                });
            }
        });
        it('should throw UnauthorizedException with correct error code for non-existent user', async () => {
            const payload = {
                sub: 'non-existent-user',
                type: 'access',
            };
            mockPrismaService.user.findUnique.mockResolvedValue(null);
            try {
                await strategy.validate(payload);
                fail('Should have thrown UnauthorizedException');
            }
            catch (error) {
                expect(error).toBeInstanceOf(common_1.UnauthorizedException);
                expect(error.response).toEqual({
                    success: false,
                    error: {
                        code: 'USER_NOT_FOUND',
                        message: '用户不存在',
                    },
                });
            }
        });
    });
});
//# sourceMappingURL=jwt.strategy.spec.js.map