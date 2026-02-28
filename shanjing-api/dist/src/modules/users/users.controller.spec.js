"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const users_controller_1 = require("./users.controller");
const users_service_1 = require("./users.service");
describe('UsersController', () => {
    let controller;
    let service;
    const mockUsersService = {
        getUserById: jest.fn(),
        updateUser: jest.fn(),
        uploadAvatar: jest.fn(),
        updateEmergencyContacts: jest.fn(),
        bindPhone: jest.fn(),
    };
    beforeEach(async () => {
        const module = await testing_1.Test.createTestingModule({
            controllers: [users_controller_1.UsersController],
            providers: [
                {
                    provide: users_service_1.UsersService,
                    useValue: mockUsersService,
                },
            ],
        }).compile();
        controller = module.get(users_controller_1.UsersController);
        service = module.get(users_service_1.UsersService);
        jest.clearAllMocks();
    });
    it('should be defined', () => {
        expect(controller).toBeDefined();
    });
    describe('getCurrentUser', () => {
        it('should return current user info', async () => {
            const userId = 'user-1';
            const expectedResult = { success: true, data: { id: userId, nickname: '测试用户' } };
            mockUsersService.getUserById.mockResolvedValue(expectedResult);
            const result = await controller.getCurrentUser(userId);
            expect(result).toEqual(expectedResult);
            expect(mockUsersService.getUserById).toHaveBeenCalledWith(userId);
        });
    });
    describe('updateUser', () => {
        it('should update user info', async () => {
            const userId = 'user-1';
            const dto = { nickname: '新昵称' };
            const expectedResult = { success: true, data: { id: userId, nickname: '新昵称' } };
            mockUsersService.updateUser.mockResolvedValue(expectedResult);
            const result = await controller.updateUser(userId, dto);
            expect(result).toEqual(expectedResult);
            expect(mockUsersService.updateUser).toHaveBeenCalledWith(userId, dto);
        });
    });
    describe('uploadAvatar', () => {
        it('should upload avatar', async () => {
            const userId = 'user-1';
            const mockFile = { originalname: 'avatar.jpg' };
            const expectedResult = { success: true, data: { avatarUrl: 'http://example.com/avatar.jpg', updatedAt: new Date() } };
            mockUsersService.uploadAvatar.mockResolvedValue(expectedResult);
            const result = await controller.uploadAvatar(userId, mockFile);
            expect(result).toEqual(expectedResult);
            expect(mockUsersService.uploadAvatar).toHaveBeenCalledWith(userId, mockFile);
        });
    });
    describe('updateEmergencyContacts', () => {
        it('should update emergency contacts', async () => {
            const userId = 'user-1';
            const dto = { contacts: [{ name: '张三', phone: '13900139000', relation: '配偶' }] };
            const expectedResult = { success: true, data: { emergencyContacts: dto.contacts, updatedAt: new Date() } };
            mockUsersService.updateEmergencyContacts.mockResolvedValue(expectedResult);
            const result = await controller.updateEmergencyContacts(userId, dto);
            expect(result).toEqual(expectedResult);
            expect(mockUsersService.updateEmergencyContacts).toHaveBeenCalledWith(userId, dto);
        });
    });
    describe('bindPhone', () => {
        it('should bind phone', async () => {
            const userId = 'user-1';
            const dto = { phone: '13800138000', code: '123456' };
            const expectedResult = { success: true, data: { phone: dto.phone, updatedAt: new Date() } };
            mockUsersService.bindPhone.mockResolvedValue(expectedResult);
            const result = await controller.bindPhone(userId, dto);
            expect(result).toEqual(expectedResult);
            expect(mockUsersService.bindPhone).toHaveBeenCalledWith(userId, dto);
        });
    });
});
//# sourceMappingURL=users.controller.spec.js.map