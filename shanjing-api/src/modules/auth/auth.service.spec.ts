import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../database/prisma.service';
import { ConflictException, BadRequestException, UnauthorizedException } from '@nestjs/common';

describe('AuthService', () => {
  let service: AuthService;
  let prisma: PrismaService;
  let jwtService: JwtService;

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
    get: jest.fn((key: string) => {
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
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: PrismaService,
          useValue: mockPrismaService,
        },
        {
          provide: JwtService,
          useValue: mockJwtService,
        },
        {
          provide: ConfigService,
          useValue: mockConfigService,
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    prisma = module.get<PrismaService>(PrismaService);
    jwtService = module.get<JwtService>(JwtService);

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

      await expect(service.registerByPhone(dto)).rejects.toThrow(ConflictException);
    });

    it('should throw BadRequestException if verification code is invalid', async () => {
      const invalidDto = { ...dto, code: '999999' };

      await expect(service.registerByPhone(invalidDto)).rejects.toThrow(BadRequestException);
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

      await expect(service.refreshToken('blacklisted-token')).rejects.toThrow(UnauthorizedException);
    });

    it('should throw UnauthorizedException if token is invalid', async () => {
      mockJwtService.verify.mockImplementation(() => {
        throw new Error('Invalid token');
      });

      await expect(service.refreshToken('invalid-token')).rejects.toThrow(UnauthorizedException);
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
