"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RolePermissions = exports.AdminPermission = exports.AdminRole = void 0;
exports.hasPermission = hasPermission;
exports.hasAnyPermission = hasAnyPermission;
exports.hasAllPermissions = hasAllPermissions;
var AdminRole;
(function (AdminRole) {
    AdminRole["SUPER_ADMIN"] = "super_admin";
    AdminRole["ADMIN"] = "admin";
    AdminRole["OPERATOR"] = "operator";
    AdminRole["AUDITOR"] = "auditor";
})(AdminRole || (exports.AdminRole = AdminRole = {}));
var AdminPermission;
(function (AdminPermission) {
    AdminPermission["USER_VIEW"] = "user:view";
    AdminPermission["USER_MANAGE"] = "user:manage";
    AdminPermission["TRAIL_VIEW"] = "trail:view";
    AdminPermission["TRAIL_CREATE"] = "trail:create";
    AdminPermission["TRAIL_UPDATE"] = "trail:update";
    AdminPermission["TRAIL_DELETE"] = "trail:delete";
    AdminPermission["POI_VIEW"] = "poi:view";
    AdminPermission["POI_MANAGE"] = "poi:manage";
    AdminPermission["SYSTEM_VIEW"] = "system:view";
    AdminPermission["SYSTEM_MANAGE"] = "system:manage";
    AdminPermission["STATS_VIEW"] = "stats:view";
})(AdminPermission || (exports.AdminPermission = AdminPermission = {}));
exports.RolePermissions = {
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
function hasPermission(role, permission) {
    return exports.RolePermissions[role]?.includes(permission) ?? false;
}
function hasAnyPermission(role, permissions) {
    return permissions.some((permission) => hasPermission(role, permission));
}
function hasAllPermissions(role, permissions) {
    return permissions.every((permission) => hasPermission(role, permission));
}
//# sourceMappingURL=admin-role.enum.js.map