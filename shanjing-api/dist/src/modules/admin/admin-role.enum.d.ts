export declare enum AdminRole {
    SUPER_ADMIN = "super_admin",
    ADMIN = "admin",
    OPERATOR = "operator",
    AUDITOR = "auditor"
}
export declare enum AdminPermission {
    USER_VIEW = "user:view",
    USER_MANAGE = "user:manage",
    TRAIL_VIEW = "trail:view",
    TRAIL_CREATE = "trail:create",
    TRAIL_UPDATE = "trail:update",
    TRAIL_DELETE = "trail:delete",
    POI_VIEW = "poi:view",
    POI_MANAGE = "poi:manage",
    SYSTEM_VIEW = "system:view",
    SYSTEM_MANAGE = "system:manage",
    STATS_VIEW = "stats:view"
}
export declare const RolePermissions: Record<AdminRole, AdminPermission[]>;
export declare function hasPermission(role: AdminRole, permission: AdminPermission): boolean;
export declare function hasAnyPermission(role: AdminRole, permissions: AdminPermission[]): boolean;
export declare function hasAllPermissions(role: AdminRole, permissions: AdminPermission[]): boolean;
