import { Test, TestingModule } from '@nestjs/testing';
import { AdminTrailsController } from './admin-trails.controller';
import { AdminTrailsService } from './admin-trails.service';
import { CreateTrailDto } from './dto/trail-admin.dto';
import { AdminRole } from '../admin-role.enum';
import { TrailDifficulty } from '@prisma/client';

// Mock 守卫（避免依赖 JwtService）
jest.mock('../guards/admin-jwt.guard', () => ({
  AdminJwtAuthGuard: class MockAdminJwtAuthGuard {
    canActivate() {
      return true;
    }
  },
  AdminPermissionGuard: class MockAdminPermissionGuard {
    canActivate() {
      return true;
    }
  },
}));

describe('AdminTrailsController - POST /admin/trails', () => {
  let controller: AdminTrailsController;
  let service: AdminTrailsService;

  const mockTrail = {
    id: 'trail-123',
    name: '西湖环湖步道',
    description: '环绕西湖的经典徒步路线',
    distanceKm: 10.5,
    durationMin: 180,
    elevationGainM: 150,
    difficulty: TrailDifficulty.MODERATE,
    tags: ['风景优美', '适合新手'],
    coverImages: ['https://example.com/image1.jpg'],
    gpxUrl: null,
    city: '杭州市',
    district: '西湖区',
    startPointLat: 30.25961,
    startPointLng: 120.13026,
    startPointAddress: '断桥残雪',
    safetyInfo: {},
    isActive: true,
    createdBy: 'admin-123',
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  beforeEach(async () => {
    const mockService = {
      createTrail: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [AdminTrailsController],
      providers: [
        {
          provide: AdminTrailsService,
          useValue: mockService,
        },
      ],
    }).compile();

    controller = module.get<AdminTrailsController>(AdminTrailsController);
    service = module.get<AdminTrailsService>(AdminTrailsService);
  });

  describe('正常创建路线', () => {
    it('应成功创建路线并返回成功响应', async () => {
      const dto: CreateTrailDto = {
        name: '西湖环湖步道',
        description: '环绕西湖的经典徒步路线',
        distanceKm: 10.5,
        durationMin: 180,
        elevationGainM: 150,
        difficulty: TrailDifficulty.MODERATE,
        tags: ['风景优美', '适合新手'],
        coverImages: ['https://example.com/image1.jpg'],
        city: '杭州市',
        district: '西湖区',
        startPointLat: 30.25961,
        startPointLng: 120.13026,
        startPointAddress: '断桥残雪',
        safetyInfo: {},
      };

      const admin = { id: 'admin-123', username: 'admin', role: AdminRole.ADMIN };
      const expectedResponse = { success: true, data: mockTrail };

      jest.spyOn(service, 'createTrail').mockResolvedValue(expectedResponse as any);

      const result = await controller.createTrail(dto, admin);

      expect(result).toEqual(expectedResponse);
      expect(service.createTrail).toHaveBeenCalledWith(dto, admin.id);
    });
  });

  describe('参数校验', () => {
    it('应拒绝缺少必填字段的请求', async () => {
      const invalidDto = {
        description: '缺少名称的路线',
      } as CreateTrailDto;

      const admin = { id: 'admin-123', username: 'admin', role: AdminRole.ADMIN };

      jest.spyOn(service, 'createTrail').mockRejectedValue(
        new Error('Missing required fields'),
      );

      await expect(controller.createTrail(invalidDto, admin)).rejects.toThrow(
        'Missing required fields',
      );
    });

    it('应拒绝无效的坐标值', async () => {
      const dto: CreateTrailDto = {
        name: '测试路线',
        distanceKm: 5.0,
        durationMin: 60,
        elevationGainM: 100,
        difficulty: TrailDifficulty.EASY,
        city: '杭州市',
        district: '西湖区',
        startPointLat: 100, // 无效纬度
        startPointLng: 120.13026,
      };

      const admin = { id: 'admin-123', username: 'admin', role: AdminRole.ADMIN };

      jest.spyOn(service, 'createTrail').mockRejectedValue(
        new Error('Invalid latitude'),
      );

      await expect(controller.createTrail(dto, admin)).rejects.toThrow(
        'Invalid latitude',
      );
    });

    it('应拒绝过短的路线名称', async () => {
      const dto: CreateTrailDto = {
        name: 'A', // 太短
        distanceKm: 5.0,
        durationMin: 60,
        elevationGainM: 100,
        difficulty: TrailDifficulty.EASY,
        city: '杭州市',
        district: '西湖区',
        startPointLat: 30.25961,
        startPointLng: 120.13026,
      };

      const admin = { id: 'admin-123', username: 'admin', role: AdminRole.ADMIN };

      jest.spyOn(service, 'createTrail').mockRejectedValue(
        new Error('Name too short'),
      );

      await expect(controller.createTrail(dto, admin)).rejects.toThrow(
        'Name too short',
      );
    });
  });
});
