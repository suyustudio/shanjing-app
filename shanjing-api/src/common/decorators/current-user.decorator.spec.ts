import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { CurrentUser } from './current-user.decorator';

describe('CurrentUser Decorator', () => {
  let decorator: ReturnType<typeof createParamDecorator>;

  beforeEach(() => {
    decorator = CurrentUser;
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
    
    const factory = (CurrentUser as any).KEY;
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
    
    const factory = (CurrentUser as any).KEY;
    const result = factory('userId', mockContext);

    expect(result).toBe('user-1');
  });

  it('should return null when user does not exist', () => {
    const mockContext = createMockContext({ user: null });
    
    const factory = (CurrentUser as any).KEY;
    const result = factory(undefined, mockContext);

    expect(result).toBeNull();
  });

  it('should return null when user is undefined', () => {
    const mockContext = createMockContext({});
    
    const factory = (CurrentUser as any).KEY;
    const result = factory(undefined, mockContext);

    expect(result).toBeNull();
  });

  it('should return undefined when accessing non-existent property', () => {
    const mockUser = {
      userId: 'user-1',
    };

    const mockContext = createMockContext({ user: mockUser });
    
    const factory = (CurrentUser as any).KEY;
    const result = factory('nonExistent', mockContext);

    expect(result).toBeUndefined();
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
