import {
  Controller,
  Get,
  Post,
  Put,
  Param,
  Body,
  Query,
  UseGuards,
  Req,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AchievementsService } from './achievements.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CheckAchievementsDto } from './dto/check-achievements.dto';
import { AchievementResponseDto } from './dto/achievement-response.dto';
import { UserAchievementResponseDto } from './dto/user-achievement-response.dto';
import { CheckResultResponseDto } from './dto/check-result-response.dto';

@ApiTags('成就系统')
@Controller('api/v1/achievements')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class AchievementsController {
  constructor(private readonly achievementsService: AchievementsService) {}

  @Get()
  @ApiOperation({ summary: '获取所有成就定义' })
  @ApiResponse({
    status: 200,
    description: '成功获取成就定义列表',
    type: [AchievementResponseDto],
  })
  async getAllAchievements(): Promise<AchievementResponseDto[]> {
    return this.achievementsService.getAllAchievements();
  }

  @Get('user')
  @ApiOperation({ summary: '获取用户成就' })
  @ApiResponse({
    status: 200,
    description: '成功获取用户成就',
    type: UserAchievementResponseDto,
  })
  async getUserAchievements(
    @Req() req: any,
    @Query('includeHidden') includeHidden?: string,
  ): Promise<UserAchievementResponseDto> {
    const userId = req.user.id;
    return this.achievementsService.getUserAchievements(
      userId,
      includeHidden === 'true',
    );
  }

  @Post('check')
  @ApiOperation({ summary: '检查并解锁成就' })
  @ApiResponse({
    status: 200,
    description: '成就检查完成',
    type: CheckResultResponseDto,
  })
  async checkAchievements(
    @Req() req: any,
    @Body() dto: CheckAchievementsDto,
  ): Promise<CheckResultResponseDto> {
    const userId = req.user.id;
    return this.achievementsService.checkAndUnlockAchievements(userId, dto);
  }

  @Put(':id/viewed')
  @ApiOperation({ summary: '标记成就已查看' })
  @ApiResponse({
    status: 200,
    description: '成就已标记为已查看',
  })
  async markAchievementViewed(
    @Req() req: any,
    @Param('id') achievementId: string,
  ): Promise<{ achievementId: string; isNew: boolean }> {
    const userId = req.user.id;
    return this.achievementsService.markAchievementViewed(userId, achievementId);
  }
}
