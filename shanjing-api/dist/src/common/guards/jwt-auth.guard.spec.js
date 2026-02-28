"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const jwt_auth_guard_1 = require("./jwt-auth.guard");
const common_1 = require("@nestjs/common");
describe('JwtAuthGuard', () => {
    let guard;
    beforeEach(() => {
        guard = new jwt_auth_guard_1.JwtAuthGuard();
    });
    it('should be defined', () => {
        expect(guard).toBeDefined();
    });
    describe('canActivate', () => {
        it('should return true when user exists in request', () => {
            const mockContext = createMockContext({ user: { userId: 'user-1' } });
            const result = guard.canActivate(mockContext);
            expect(result).toBe(true);
        });
        it('should throw UnauthorizedException when user does not exist', () => {
            const mockContext = createMockContext({ user: null });
            expect(() => guard.canActivate(mockContext)).toThrow(common_1.UnauthorizedException);
        });
        it('should throw UnauthorizedException when user is undefined', () => {
            const mockContext = createMockContext({});
            expect(() => guard.canActivate(mockContext)).toThrow(common_1.UnauthorizedException);
        });
    });
});
function createMockContext(requestProps) {
    return {
        switchToHttp: () => ({
            getRequest: () => requestProps,
        }),
    };
}
//# sourceMappingURL=jwt-auth.guard.spec.js.map