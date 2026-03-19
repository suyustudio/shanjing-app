"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AdminTrailsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const admin_trails_service_1 = require("./admin-trails.service");
const admin_jwt_guard_1 = require("../guards/admin-jwt.guard");
const current_admin_decorator_1 = require("../decorators/current-admin.decorator");
const trail_admin_dto_1 = require("./dto/trail-admin.dto");
let AdminTrailsController = class AdminTrailsController {
    constructor(adminTrailsService) {
        this.adminTrailsService = adminTrailsService;
    }
    async getTrailList(query) {
        return this.adminTrailsService.getTrailList(query);
    }
    async getTrailStats() {
        return this.adminTrailsService.getTrailStats();
    }
    async getTrailById(trailId) {
        return this.adminTrailsService.getTrailById(trailId);
    }
    async createTrail(dto, admin) {
        return this.adminTrailsService.createTrail(dto, admin.id);
    }
    async updateTrail(trailId, dto) {
        return this.adminTrailsService.updateTrail(trailId, dto);
    }
    async deleteTrail(trailId) {
        return this.adminTrailsService.deleteTrail(trailId);
    }
    async batchUpdateStatus(trailIds, isActive) {
        return this.adminTrailsService.batchUpdateStatus(trailIds, isActive);
    }
};
exports.AdminTrailsController = AdminTrailsController;
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: '获取路线列表', description: '支持分页、搜索、筛选' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '获取成功',
        type: trail_admin_dto_1.TrailListResponseDto,
    }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [trail_admin_dto_1.TrailListQueryDto]),
    __metadata("design:returntype", Promise)
], AdminTrailsController.prototype, "getTrailList", null);
__decorate([
    (0, common_1.Get)('stats'),
    (0, swagger_1.ApiOperation)({ summary: '获取路线统计信息' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '获取成功' }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], AdminTrailsController.prototype, "getTrailStats", null);
__decorate([
    (0, common_1.Get)(':id'),
    (0, swagger_1.ApiOperation)({ summary: '获取路线详情' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '路线ID' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '获取成功',
        type: trail_admin_dto_1.TrailResponseDto,
    }),
    (0, swagger_1.ApiResponse)({ status: 404, description: '路线不存在' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], AdminTrailsController.prototype, "getTrailById", null);
__decorate([
    (0, common_1.Post)(),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: '创建路线', description: '需要 trail:create 权限' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '创建成功',
        type: trail_admin_dto_1.TrailResponseDto,
    }),
    (0, swagger_1.ApiResponse)({ status: 400, description: '参数错误' }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, current_admin_decorator_1.CurrentAdmin)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [trail_admin_dto_1.CreateTrailDto, Object]),
    __metadata("design:returntype", Promise)
], AdminTrailsController.prototype, "createTrail", null);
__decorate([
    (0, common_1.Put)(':id'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: '更新路线', description: '需要 trail:update 权限' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '路线ID' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '更新成功',
        type: trail_admin_dto_1.TrailResponseDto,
    }),
    (0, swagger_1.ApiResponse)({ status: 404, description: '路线不存在' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, trail_admin_dto_1.UpdateTrailDto]),
    __metadata("design:returntype", Promise)
], AdminTrailsController.prototype, "updateTrail", null);
__decorate([
    (0, common_1.Delete)(':id'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: '删除路线', description: '需要 trail:delete 权限（软删除）' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '路线ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '删除成功' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: '路线不存在' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], AdminTrailsController.prototype, "deleteTrail", null);
__decorate([
    (0, common_1.Post)('batch/status'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: '批量更新路线状态' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '更新成功' }),
    __param(0, (0, common_1.Body)('trailIds')),
    __param(1, (0, common_1.Body)('isActive')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Array, Boolean]),
    __metadata("design:returntype", Promise)
], AdminTrailsController.prototype, "batchUpdateStatus", null);
exports.AdminTrailsController = AdminTrailsController = __decorate([
    (0, swagger_1.ApiTags)('后台管理-路线管理'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(admin_jwt_guard_1.AdminJwtAuthGuard),
    (0, common_1.Controller)('admin/trails'),
    __metadata("design:paramtypes", [admin_trails_service_1.AdminTrailsService])
], AdminTrailsController);
//# sourceMappingURL=admin-trails.controller.js.map