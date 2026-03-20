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
exports.RecordingController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const recording_service_1 = require("./recording.service");
const jwt_auth_guard_1 = require("../../common/guards/jwt-auth.guard");
const current_user_decorator_1 = require("../../common/decorators/current-user.decorator");
const recording_dto_1 = require("./dto/recording.dto");
let RecordingController = class RecordingController {
    constructor(recordingService) {
        this.recordingService = recordingService;
    }
    async uploadRecording(dto, userId) {
        return this.recordingService.uploadRecording(dto, userId);
    }
    async getMyRecordings(query, userId) {
        return this.recordingService.getUserRecordings(userId, query);
    }
    async getRecordingDetail(recordingId, userId) {
        return this.recordingService.getRecordingDetail(recordingId, userId);
    }
    async getPendingRecordings(query) {
        return this.recordingService.getPendingRecordings(query);
    }
    async approveRecording(recordingId, dto) {
        return this.recordingService.approveRecording(recordingId, dto);
    }
    async rejectRecording(recordingId, reason) {
        return this.recordingService.rejectRecording(recordingId, reason);
    }
};
exports.RecordingController = RecordingController;
__decorate([
    (0, common_1.Post)('upload'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '上传轨迹录制数据',
        description: '上传GPS轨迹、POI标记等录制数据，提交后进入审核状态',
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '上传成功',
        type: recording_dto_1.UploadResponseDto,
    }),
    (0, swagger_1.ApiResponse)({ status: 400, description: '数据格式错误' }),
    (0, swagger_1.ApiResponse)({ status: 401, description: '未授权' }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, current_user_decorator_1.CurrentUser)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [recording_dto_1.UploadRecordingDto, String]),
    __metadata("design:returntype", Promise)
], RecordingController.prototype, "uploadRecording", null);
__decorate([
    (0, common_1.Get)('my-recordings'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '获取我的录制记录',
        description: '获取当前用户的所有轨迹录制记录',
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '获取成功',
        type: recording_dto_1.RecordingListResponseDto,
    }),
    (0, swagger_1.ApiQuery)({ name: 'status', required: false, description: '筛选状态: pending/approved/rejected' }),
    (0, swagger_1.ApiQuery)({ name: 'page', required: false, description: '页码', type: Number }),
    (0, swagger_1.ApiQuery)({ name: 'limit', required: false, description: '每页数量', type: Number }),
    __param(0, (0, common_1.Query)()),
    __param(1, (0, current_user_decorator_1.CurrentUser)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [recording_dto_1.RecordingListQueryDto, String]),
    __metadata("design:returntype", Promise)
], RecordingController.prototype, "getMyRecordings", null);
__decorate([
    (0, common_1.Get)('my-recordings/:id'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '获取录制详情',
        description: '获取指定录制记录的详细信息',
    }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '录制记录ID' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '获取成功',
        type: recording_dto_1.RecordingDetailResponseDto,
    }),
    (0, swagger_1.ApiResponse)({ status: 404, description: '记录不存在' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, current_user_decorator_1.CurrentUser)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], RecordingController.prototype, "getRecordingDetail", null);
__decorate([
    (0, common_1.Get)('admin/pending'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '【管理员】获取待审核列表',
        description: '获取所有待审核的轨迹录制记录',
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '获取成功',
        type: recording_dto_1.RecordingListResponseDto,
    }),
    (0, swagger_1.ApiQuery)({ name: 'page', required: false, description: '页码', type: Number }),
    (0, swagger_1.ApiQuery)({ name: 'limit', required: false, description: '每页数量', type: Number }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [recording_dto_1.RecordingListQueryDto]),
    __metadata("design:returntype", Promise)
], RecordingController.prototype, "getPendingRecordings", null);
__decorate([
    (0, common_1.Post)('admin/:id/approve'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '【管理员】审核通过',
        description: '审核通过轨迹录制，创建正式路线',
    }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '录制记录ID' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '审核通过',
        type: recording_dto_1.UploadResponseDto,
    }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, recording_dto_1.ApproveRecordingDto]),
    __metadata("design:returntype", Promise)
], RecordingController.prototype, "approveRecording", null);
__decorate([
    (0, common_1.Post)('admin/:id/reject'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '【管理员】审核拒绝',
        description: '拒绝轨迹录制，可选择填写拒绝原因',
    }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '录制记录ID' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '已拒绝',
    }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)('reason')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], RecordingController.prototype, "rejectRecording", null);
exports.RecordingController = RecordingController = __decorate([
    (0, swagger_1.ApiTags)('轨迹录制'),
    (0, common_1.Controller)('trails/recording'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    __metadata("design:paramtypes", [recording_service_1.RecordingService])
], RecordingController);
//# sourceMappingURL=recording.controller.js.map