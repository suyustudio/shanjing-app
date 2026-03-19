"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const admin_trails_controller_1 = require("./admin-trails.controller");
const admin_trails_service_1 = require("./admin-trails.service");
const admin_role_enum_1 = require("../admin-role.enum");
const client_1 = require("@prisma/client");
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
    let controller;
    let service;
    const mockTrail = {
        id: 'trail-123',
        name: '西湖环湖步道',
        description: '环绕西湖的经典徒步路线',
        distanceKm: 10.5,
        durationMin: 180,
        elevationGainM: 150,
        difficulty: client_1.TrailDifficulty.MODERATE,
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
        const module = await testing_1.Test.createTestingModule({
            controllers: [admin_trails_controller_1.AdminTrailsController],
            providers: [
                {
                    provide: admin_trails_service_1.AdminTrailsService,
                    useValue: mockService,
                },
            ],
        }).compile();
        controller = module.get(admin_trails_controller_1.AdminTrailsController);
        service = module.get(admin_trails_service_1.AdminTrailsService);
    });
    describe('正常创建路线', () => {
        it('应成功创建路线并返回成功响应', async () => {
            const dto = {
                name: '西湖环湖步道',
                description: '环绕西湖的经典徒步路线',
                distanceKm: 10.5,
                durationMin: 180,
                elevationGainM: 150,
                difficulty: client_1.TrailDifficulty.MODERATE,
                tags: ['风景优美', '适合新手'],
                coverImages: ['https://example.com/image1.jpg'],
                city: '杭州市',
                district: '西湖区',
                startPointLat: 30.25961,
                startPointLng: 120.13026,
                startPointAddress: '断桥残雪',
                safetyInfo: {},
            };
            const admin = { id: 'admin-123', username: 'admin', role: admin_role_enum_1.AdminRole.ADMIN };
            const expectedResponse = { success: true, data: mockTrail };
            jest.spyOn(service, 'createTrail').mockResolvedValue(expectedResponse);
            const result = await controller.createTrail(dto, admin);
            expect(result).toEqual(expectedResponse);
            expect(service.createTrail).toHaveBeenCalledWith(dto, admin.id);
        });
    });
    describe('参数校验', () => {
        it('应拒绝缺少必填字段的请求', async () => {
            const invalidDto = {
                description: '缺少名称的路线',
            };
            const admin = { id: 'admin-123', username: 'admin', role: admin_role_enum_1.AdminRole.ADMIN };
            jest.spyOn(service, 'createTrail').mockRejectedValue(new Error('Missing required fields'));
            await expect(controller.createTrail(invalidDto, admin)).rejects.toThrow('Missing required fields');
        });
        it('应拒绝无效的坐标值', async () => {
            const dto = {
                name: '测试路线',
                distanceKm: 5.0,
                durationMin: 60,
                elevationGainM: 100,
                difficulty: client_1.TrailDifficulty.EASY,
                city: '杭州市',
                district: '西湖区',
                startPointLat: 100,
                startPointLng: 120.13026,
            };
            const admin = { id: 'admin-123', username: 'admin', role: admin_role_enum_1.AdminRole.ADMIN };
            jest.spyOn(service, 'createTrail').mockRejectedValue(new Error('Invalid latitude'));
            await expect(controller.createTrail(dto, admin)).rejects.toThrow('Invalid latitude');
        });
        it('应拒绝过短的路线名称', async () => {
            const dto = {
                name: 'A',
                distanceKm: 5.0,
                durationMin: 60,
                elevationGainM: 100,
                difficulty: client_1.TrailDifficulty.EASY,
                city: '杭州市',
                district: '西湖区',
                startPointLat: 30.25961,
                startPointLng: 120.13026,
            };
            const admin = { id: 'admin-123', username: 'admin', role: admin_role_enum_1.AdminRole.ADMIN };
            jest.spyOn(service, 'createTrail').mockRejectedValue(new Error('Name too short'));
            await expect(controller.createTrail(dto, admin)).rejects.toThrow('Name too short');
        });
    });
});
//# sourceMappingURL=admin-trails.controller.spec.js.map