/**
 * 管理员角色枚举
 */
export enum AdminRole {
  /** 超级管理员 */
  SUPER_ADMIN = 'super_admin',
  /** 管理员 */
  ADMIN = 'admin',
  /** 运营人员 */
  OPERATOR = 'operator',
  /** 审核员 */
  AUDITOR = 'auditor',
}

/**
 * 管理员权限枚举
 */
export enum AdminPermission {
  // 用户管理权限
  USER_VIEW = 'user:view',
  USER_MANAGE = 'user:manage',
  
  // 路线管理权限
  TRAIL_VIEW = 'trail:view',
  TRAIL_CREATE = 'trail:create',
  TRAIL_UPDATE = 'trail:update',
  TRAIL_DELETE = 'trail:delete',
  
  // POI管理权限
  POI_VIEW = 'poi:view',
  POI_MANAGE = 'poi:manage',
  
  // 系统管理权限
  SYSTEM_VIEW = 'system:view',
  SYSTEM_MANAGE = 'system:manage',
  
  // 数据统计权限
  STATS_VIEW = 'stats:view',
}

/**
 * 角色权限映射
 */
export const RolePermissions: Record<AdminRole, AdminPermission[]> = {
  [AdminRole.SUPER_ADMIN]: Object.values(AdminPermission),
  [AdminRole.ADMIN]: [
    AdminPermission.USER_VIEW,
    AdminPermission.USER_MANAGE,
    AdminPermission.TRAIL_VIEW,
    AdminPermission.TRAIL_CREATE,
    AdminPermission.TRAIL_UPDATE,
    AdminPermission.TRAIL_DELETE,
    AdminPermission.POI_VIEW,
    AdminPermission.POI_MANAGE,
    AdminPermission.STATS_VIEW,
  ],
  [AdminRole.OPERATOR]: [
    AdminPermission.TRAIL_VIEW,
    AdminPermission.TRAIL_CREATE,
    AdminPermission.TRAIL_UPDATE,
    AdminPermission.POI_VIEW,
    AdminPermission.POI_MANAGE,
    AdminPermission.STATS_VIEW,
  ],
  [AdminRole.AUDITOR]: [
    AdminPermission.TRAIL_VIEW,
    AdminPermission.POI_VIEW,
  ],
};

/**
 * 检查角色是否有指定权限
 */
export function hasPermission(role: AdminRole, permission: AdminPermission): boolean {
  return RolePermissions[role]?.includes(permission) ?? false;
}

/**
 * 检查角色是否有任意指定权限
 */
export function hasAnyPermission(role: AdminRole, permissions: AdminPermission[]): boolean {
  return permissions.some((permission) => hasPermission(role, permission));
}

/**
 * 检查角色是否有所有指定权限
 */
export function hasAllPermissions(role: AdminRole, permissions: AdminPermission[]): boolean {
  return permissions.every((permission) => hasPermission(role, permission));
}
