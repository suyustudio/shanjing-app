import { Test, TestingModule } from '@nestjs/testing';
import { TrailsAdminController } from './trails-admin.controller';
import { TrailsAdminService } from './trails-admin.service';

describe('TrailsAdminController', () => {
  let controller: TrailsAdminController;
  let service: TrailsAdminService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [TrailsAdminController],
      providers: [
        {
          provide: TrailsAdminService,
          useValue: {
            create: jest.fn(),
            update: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<TrailsAdminController>(TrailsAdminController);
    service = module.get<TrailsAdminService>(TrailsAdminService);
  });

  describe('create', () => {
    it('should create a trail successfully and return 201 with trail ID', async () => {
      const createDto = {
        name: '测试路线',
        description: '测试描述',
      };

      const mockTrail = {
        id: 'trail_123',
        name: '测试路线',
        description: '测试描述',
      };

      jest.spyOn(service, 'create').mockResolvedValue(mockTrail);

      const result = await controller.create(createDto);

      expect(service.create).toHaveBeenCalledWith(createDto);
      expect(result).toEqual({ success: true, data: mockTrail });
    });
  });

  describe('update', () => {
    it('should update trail successfully and return updated name', async () => {
      const trailId = 'trail_123';
      const updateDto = { name: '更新后的路线名称' };
      const mockUpdatedTrail = { id: trailId, name: '更新后的路线名称' };

      jest.spyOn(service, 'update').mockResolvedValue(mockUpdatedTrail);

      const result = await controller.update(trailId, updateDto);

      expect(service.update).toHaveBeenCalledWith(trailId, updateDto);
      expect(result.data.name).toBe('更新后的路线名称');
    });
  });
});
