"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const auth_controller_1 = require("./auth.controller");
const auth_service_1 = require("./auth.service");
describe('AuthController', () => {
    let controller;
    let service;
    const mockAuthService = {
        registerByPhone: jest.fn(),
        registerByWechat: jest.fn(),
        loginByPhone: jest.fn(),
        loginByWechat: jest.fn(),
        refreshToken: jest.fn(),
        logout: jest.fn(),
    };
    beforeEach(async () => {
        const module = await testing_1.Test.createTestingModule({
            controllers: [auth_controller_1.AuthController],
            providers: [
                {
                    provide: auth_service_1.AuthService,
                    useValue: mockAuthService,
                },
            ],
        }).compile();
        controller = module.get(auth_controller_1.AuthController);
        service = module.get(auth_service_1.AuthService);
        jest.clearAllMocks();
    });
    it('should be defined', () => {
        expect(controller).toBeDefined();
    });
    describe('registerByPhone', () => {
        it('should call authService.registerByPhone', async () => {
            const dto = { phone: '13800138000', code: '123456', nickname: '测试用户' };
            const expectedResult = { success: true, data: { user: {}, tokens: {} } };
            mockAuthService.registerByPhone.mockResolvedValue(expectedResult);
            const result = await controller.registerByPhone(dto);
            expect(result).toEqual(expectedResult);
            expect(mockAuthService.registerByPhone).toHaveBeenCalledWith(dto);
        });
    });
    describe('registerByWechat', () => {
        it('should call authService.registerByWechat', async () => {
            const dto = { code: 'wechat-code', nickname: '微信用户' };
            const expectedResult = { success: true, data: { user: {}, tokens: {} } };
            mockAuthService.registerByWechat.mockResolvedValue(expectedResult);
            const result = await controller.registerByWechat(dto);
            expect(result).toEqual(expectedResult);
            expect(mockAuthService.registerByWechat).toHaveBeenCalledWith(dto);
        });
    });
    describe('loginByPhone', () => {
        it('should call authService.loginByPhone', async () => {
            const dto = { phone: '13800138000', code: '123456' };
            const expectedResult = { success: true, data: { user: {}, tokens: {} } };
            mockAuthService.loginByPhone.mockResolvedValue(expectedResult);
            const result = await controller.loginByPhone(dto);
            expect(result).toEqual(expectedResult);
            expect(mockAuthService.loginByPhone).toHaveBeenCalledWith(dto);
        });
    });
    describe('loginByWechat', () => {
        it('should call authService.loginByWechat', async () => {
            const dto = { code: 'wechat-code' };
            const expectedResult = { success: true, data: { user: {}, tokens: {} } };
            mockAuthService.loginByWechat.mockResolvedValue(expectedResult);
            const result = await controller.loginByWechat(dto);
            expect(result).toEqual(expectedResult);
            expect(mockAuthService.loginByWechat).toHaveBeenCalledWith(dto);
        });
    });
    describe('refreshToken', () => {
        it('should call authService.refreshToken', async () => {
            const dto = { refreshToken: 'valid-token' };
            const expectedResult = { accessToken: 'new-token', refreshToken: 'new-refresh', expiresIn: 7200 };
            mockAuthService.refreshToken.mockResolvedValue(expectedResult);
            const result = await controller.refreshToken(dto);
            expect(result).toEqual(expectedResult);
            expect(mockAuthService.refreshToken).toHaveBeenCalledWith(dto.refreshToken);
        });
    });
    describe('logout', () => {
        it('should call authService.logout', async () => {
            const dto = { refreshToken: 'valid-token', allDevices: false };
            mockAuthService.logout.mockResolvedValue(undefined);
            const result = await controller.logout(dto);
            expect(result.success).toBe(true);
            expect(result.data.message).toBe('退出登录成功');
            expect(mockAuthService.logout).toHaveBeenCalledWith(dto);
        });
    });
});
//# sourceMappingURL=auth.controller.spec.js.map