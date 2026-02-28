"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const current_user_decorator_1 = require("./current-user.decorator");
describe('CurrentUser Decorator', () => {
    let decorator;
    beforeEach(() => {
        decorator = current_user_decorator_1.CurrentUser;
    });
    it('should be defined', () => {
        expect(decorator).toBeDefined();
    });
    it('should return full user object when no data key provided', () => {
        const mockUser = {
            userId: 'user-1',
            phone: '13800138000',
            wxOpenid: 'wx_openid_xxx',
        };
        const mockContext = createMockContext({ user: mockUser });
        const factory = current_user_decorator_1.CurrentUser.KEY;
        const result = factory(undefined, mockContext);
        expect(result).toEqual(mockUser);
    });
    it('should return specific user property when data key provided', () => {
        const mockUser = {
            userId: 'user-1',
            phone: '13800138000',
            wxOpenid: 'wx_openid_xxx',
        };
        const mockContext = createMockContext({ user: mockUser });
        const factory = current_user_decorator_1.CurrentUser.KEY;
        const result = factory('userId', mockContext);
        expect(result).toBe('user-1');
    });
    it('should return null when user does not exist', () => {
        const mockContext = createMockContext({ user: null });
        const factory = current_user_decorator_1.CurrentUser.KEY;
        const result = factory(undefined, mockContext);
        expect(result).toBeNull();
    });
    it('should return null when user is undefined', () => {
        const mockContext = createMockContext({});
        const factory = current_user_decorator_1.CurrentUser.KEY;
        const result = factory(undefined, mockContext);
        expect(result).toBeNull();
    });
    it('should return undefined when accessing non-existent property', () => {
        const mockUser = {
            userId: 'user-1',
        };
        const mockContext = createMockContext({ user: mockUser });
        const factory = current_user_decorator_1.CurrentUser.KEY;
        const result = factory('nonExistent', mockContext);
        expect(result).toBeUndefined();
    });
});
function createMockContext(requestProps) {
    return {
        switchToHttp: () => ({
            getRequest: () => requestProps,
        }),
    };
}
//# sourceMappingURL=current-user.decorator.spec.js.map