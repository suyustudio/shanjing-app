import { Test, TestingModule } from '@nestjs/testing';
import { JwtStrategy } from './jwt.strategy';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../../database/prisma.service';
import { UnauthorizedException } from '@nestjs/common';

describe('JwtStrategy', () => {
  let strategy: JwtStrategy;
  let prisma: PrismaService;

  const mockConfigService = {
    get: jest.fn().mockReturnValue('test-secret'),
  };

  const mockPrismaService = {
    user: {
      findUnique: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        JwtStrategy,
        {
          provide: ConfigService,
          useValue: mockConfigService,
        },
        {
          provide: PrismaService,
          useValue: mockPrismaService,
        },
      ],
    }).compile();

    strategy = module.get<JwtStrategy>(JwtStrategy);
    prisma = module.get<PrismaService>(PrismaService);

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

      await expect(strategy.validate(payload)).rejects.toThrow(UnauthorizedException);
    });

    it('should throw UnauthorizedException when user not found', async () => {
      const payload = {
        sub: 'non-existent-user',
        type: 'access',
      };

      mockPrismaService.user.findUnique.mockResolvedValue(null);

      await expect(strategy.validate(payload)).rejects.toThrow(UnauthorizedException);
    });

    it('should throw UnauthorizedException with correct error code for refresh token', async () => {
      const payload = {
        sub: 'user-1',
        type: 'refresh',
      };

      try {
        await strategy.validate(payload);
        fail('Should have thrown UnauthorizedException');
      } catch (error) {
        expect(error).toBeInstanceOf(UnauthorizedException);
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
      } catch (error) {
        expect(error).toBeInstanceOf(UnauthorizedException);
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
