"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const auth_service_1 = require("./auth.service");
const jwt_1 = require("@nestjs/jwt");
const config_1 = require("@nestjs/config");
const prisma_service_1 = require("../../database/prisma.service");
const common_1 = require("@nestjs/common");
describe('AuthService', () => {
    let service;
    let prisma;
    let jwtService;
    const mockPrismaService = {
        user: {
            findUnique: jest.fn(),
            create: jest.fn(),
        },
        tokenBlacklist: {
            findUnique: jest.fn(),
            create: jest.fn(),
        },
    };
    const mockJwtService = {
        signAsync: jest.fn(),
        verify: jest.fn(),
        decode: jest.fn(),
    };
    const mockConfigService = {
        get: jest.fn((key) => {
            const config = {
                JWT_ACCESS_SECRET: 'test-access-secret',
                JWT_REFRESH_SECRET: 'test-refresh-secret',
                JWT_ACCESS_EXPIRATION: '2h',
                JWT_REFRESH_EXPIRATION: '7d',
            };
            return config[key];
        }),
    };
    beforeEach(async () => {
        const module = await testing_1.Test.createTestingModule({
            providers: [
                auth_service_1.AuthService,
                {
                    provide: prisma_service_1.PrismaService,
                    useValue: mockPrismaService,
                },
                {
                    provide: jwt_1.JwtService,
                    useValue: mockJwtService,
                },
                {
                    provide: config_1.ConfigService,
                    useValue: mockConfigService,
                },
            ],
        }).compile();
        service = module.get(auth_service_1.AuthService);
        prisma = module.get(prisma_service_1.PrismaService);
        jwtService = module.get(jwt_1.JwtService);
        jest.clearAllMocks();
    });
    it('should be defined', () => {
        expect(service).toBeDefined();
    });
    describe('registerByPhone', () => {
        const dto = {
            phone: '13800138000',
            code: '123456',
            nickname: '测试用户',
        };
        it('should register a new user successfully', async () => {
            mockPrismaService.user.findUnique.mockResolvedValue(null);
            mockPrismaService.user.create.mockResolvedValue({
                id: 'user-1',
                phone: dto.phone,
                nickname: dto.nickname,
                avatarUrl: null,
                createdAt: new Date(),
            });
            mockJwtService.signAsync.mockResolvedValue('mock-token');
            const result = await service.registerByPhone(dto);
            expect(result.success).toBe(true);
            expect(result.data.user.phone).toBe(dto.phone);
            expect(result.data.tokens).toBeDefined();
        });
        it('should throw ConflictException if phone already exists', async () => {
            mockPrismaService.user.findUnique.mockResolvedValue({ id: 'existing-user' });
            await expect(service.registerByPhone(dto)).rejects.toThrow(common_1.ConflictException);
        });
        it('should throw BadRequestException if verification code is invalid', async () => {
            const invalidDto = { ...dto, code: '999999' };
            await expect(service.registerByPhone(invalidDto)).rejects.toThrow(common_1.BadRequestException);
        });
    });
    describe('loginByPhone', () => {
        const dto = {
            phone: '13800138000',
            code: '123456',
        };
        it('should login existing user successfully', async () => {
            mockPrismaService.user.findUnique.mockResolvedValue({
                id: 'user-1',
                phone: dto.phone,
                nickname: '测试用户',
                avatarUrl: null,
                createdAt: new Date(),
            });
            mockJwtService.signAsync.mockResolvedValue('mock-token');
            const result = await service.loginByPhone(dto);
            expect(result.success).toBe(true);
            expect(result.data.user.phone).toBe(dto.phone);
        });
        it('should auto-register if user not exists', async () => {
            mockPrismaService.user.findUnique.mockResolvedValue(null);
            mockPrismaService.user.create.mockResolvedValue({
                id: 'new-user',
                phone: dto.phone,
                nickname: `用户${dto.phone.slice(-4)}`,
                avatarUrl: null,
                createdAt: new Date(),
            });
            mockJwtService.signAsync.mockResolvedValue('mock-token');
            const result = await service.loginByPhone(dto);
            expect(result.success).toBe(true);
            expect(mockPrismaService.user.create).toHaveBeenCalled();
        });
    });
    describe('refreshToken', () => {
        it('should refresh token successfully', async () => {
            const mockPayload = { sub: 'user-1', type: 'refresh', exp: Date.now() / 1000 + 3600 };
            mockJwtService.verify.mockReturnValue(mockPayload);
            mockPrismaService.tokenBlacklist.findUnique.mockResolvedValue(null);
            mockJwtService.signAsync.mockResolvedValue('new-mock-token');
            mockJwtService.decode.mockReturnValue({ exp: Date.now() / 1000 + 7200 });
            const result = await service.refreshToken('valid-refresh-token');
            expect(result.accessToken).toBeDefined();
            expect(result.refreshToken).toBeDefined();
        });
        it('should throw UnauthorizedException if token is blacklisted', async () => {
            const mockPayload = { sub: 'user-1', type: 'refresh' };
            mockJwtService.verify.mockReturnValue(mockPayload);
            mockPrismaService.tokenBlacklist.findUnique.mockResolvedValue({ id: 'blacklisted' });
            await expect(service.refreshToken('blacklisted-token')).rejects.toThrow(common_1.UnauthorizedException);
        });
        it('should throw UnauthorizedException if token is invalid', async () => {
            mockJwtService.verify.mockImplementation(() => {
                throw new Error('Invalid token');
            });
            await expect(service.refreshToken('invalid-token')).rejects.toThrow(common_1.UnauthorizedException);
        });
    });
    describe('logout', () => {
        it('should add token to blacklist', async () => {
            const mockPayload = { sub: 'user-1', type: 'refresh', exp: Date.now() / 1000 + 3600 };
            mockJwtService.decode.mockReturnValue(mockPayload);
            await service.logout({ refreshToken: 'valid-token', allDevices: false });
            expect(mockPrismaService.tokenBlacklist.create).toHaveBeenCalled();
        });
    });
});
//# sourceMappingURL=auth.service.spec.js.map