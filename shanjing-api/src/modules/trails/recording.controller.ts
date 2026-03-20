/**
 * 轨迹录制控制器
 * 
 * 处理轨迹录制数据上传和管理
 */

import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  Query,
  HttpCode,
  HttpStatus,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam, ApiQuery } from '@nestjs/swagger';
import { RecordingService } from './recording.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import {
  UploadRecordingDto,
  RecordingListQueryDto,
  RecordingDetailResponseDto,
  RecordingListResponseDto,
  UploadResponseDto,
  ApproveRecordingDto,
} from './dto/recording.dto';

@ApiTags('轨迹录制')
@Controller('trails/recording')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class RecordingController {
  constructor(private readonly recordingService: RecordingService) {}

  @Post('upload')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '上传轨迹录制数据',
    description: '上传GPS轨迹、POI标记等录制数据，提交后进入审核状态',
  })
  @ApiResponse({
    status: 200,
    description: '上传成功',
    type: UploadResponseDto,
  })
  @ApiResponse({ status: 400, description: '数据格式错误' })
  @ApiResponse({ status: 401, description: '未授权' })
  async uploadRecording(
    @Body() dto: UploadRecordingDto,
    @CurrentUser('userId') userId: string,
  ) {
    return this.recordingService.uploadRecording(dto, userId);
  }

  @Get('my-recordings')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '获取我的录制记录',
    description: '获取当前用户的所有轨迹录制记录',
  })
  @ApiResponse({
    status: 200,
    description: '获取成功',
    type: RecordingListResponseDto,
  })
  @ApiQuery({ name: 'status', required: false, description: '筛选状态: pending/approved/rejected' })
  @ApiQuery({ name: 'page', required: false, description: '页码', type: Number })
  @ApiQuery({ name: 'limit', required: false, description: '每页数量', type: Number })
  async getMyRecordings(
    @Query() query: RecordingListQueryDto,
    @CurrentUser('userId') userId: string,
  ) {
    return this.recordingService.getUserRecordings(userId, query);
  }

  @Get('my-recordings/:id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '获取录制详情',
    description: '获取指定录制记录的详细信息',
  })
  @ApiParam({ name: 'id', description: '录制记录ID' })
  @ApiResponse({
    status: 200,
    description: '获取成功',
    type: RecordingDetailResponseDto,
  })
  @ApiResponse({ status: 404, description: '记录不存在' })
  async getRecordingDetail(
    @Param('id') recordingId: string,
    @CurrentUser('userId') userId: string,
  ) {
    return this.recordingService.getRecordingDetail(recordingId, userId);
  }

  // ========== 管理员接口 ==========

  @Get('admin/pending')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '【管理员】获取待审核列表',
    description: '获取所有待审核的轨迹录制记录',
  })
  @ApiResponse({
    status: 200,
    description: '获取成功',
    type: RecordingListResponseDto,
  })
  @ApiQuery({ name: 'page', required: false, description: '页码', type: Number })
  @ApiQuery({ name: 'limit', required: false, description: '每页数量', type: Number })
  async getPendingRecordings(@Query() query: RecordingListQueryDto) {
    return this.recordingService.getPendingRecordings(query);
  }

  @Post('admin/:id/approve')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '【管理员】审核通过',
    description: '审核通过轨迹录制，创建正式路线',
  })
  @ApiParam({ name: 'id', description: '录制记录ID' })
  @ApiResponse({
    status: 200,
    description: '审核通过',
    type: UploadResponseDto,
  })
  async approveRecording(
    @Param('id') recordingId: string,
    @Body() dto: ApproveRecordingDto,
  ) {
    return this.recordingService.approveRecording(recordingId, dto);
  }

  @Post('admin/:id/reject')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '【管理员】审核拒绝',
    description: '拒绝轨迹录制，可选择填写拒绝原因',
  })
  @ApiParam({ name: 'id', description: '录制记录ID' })
  @ApiResponse({
    status: 200,
    description: '已拒绝',
  })
  async rejectRecording(
    @Param('id') recordingId: string,
    @Body('reason') reason?: string,
  ) {
    return this.recordingService.rejectRecording(recordingId, reason);
  }
}
