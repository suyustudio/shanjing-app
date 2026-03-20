// collections.module.ts
// 山径APP - 收藏夹模块

import { Module } from '@nestjs/common';
import { CollectionsController } from './collections.controller';
import { CollectionsService } from './collections.service';

/**
 * 收藏夹模块
 * 
 * 提供用户收藏夹管理功能：
 * - 创建/编辑/删除收藏夹
 * - 添加/移除路线
 * - 收藏夹列表和详情
 */
@Module({
  controllers: [CollectionsController],
  providers: [CollectionsService],
  exports: [CollectionsService],
})
export class CollectionsModule {}
