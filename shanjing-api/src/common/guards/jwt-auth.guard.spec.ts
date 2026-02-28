import { Test, TestingModule } from '@nestjs/testing';
import { JwtAuthGuard } from './jwt-auth.guard';
import { ExecutionContext, UnauthorizedException } from '@nestjs/common';

describe('JwtAuthGuard', () => {
  let guard: JwtAuthGuard;

  beforeEach(() => {
    guard = new JwtAuthGuard();
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
      
      expect(() => guard.canActivate(mockContext)).toThrow(UnauthorizedException);
    });

    it('should throw UnauthorizedException when user is undefined', () => {
      const mockContext = createMockContext({});
      
      expect(() => guard.canActivate(mockContext)).toThrow(UnauthorizedException);
    });
  });
});

// Helper function to create mock execution context
function createMockContext(requestProps: any): ExecutionContext {
  return {
    switchToHttp: () => ({
      getRequest: () => requestProps,
    }),
  } as ExecutionContext;
}
