// trails.module.ts - 路线模块
// 山径APP - 路线数据 API

import { Module } from '@nestjs/common';
import { TrailsController } from './trails.controller';
import { TrailsService } from './trails.service';
import { FavoritesController, UserFavoritesController } from './favorites.controller';
import { FavoritesService } from './favorites.service';
import { DownloadsController, UserDownloadsController } from './downloads.controller';
import { DownloadsService } from './downloads.service';

/**
 * 路线模块
 *
 * 提供路线相关的 API 接口：
 * - 路线列表查询
 * - 路线搜索
 * - 路线详情
 * - 路线收藏/取消收藏
 * - 用户收藏列表
 * - 离线包下载记录
 * - 用户下载历史
 */
@Module({
  controllers: [
    TrailsController,
    FavoritesController,
    UserFavoritesController,
    DownloadsController,
    UserDownloadsController,
  ],
  providers: [TrailsService, FavoritesService, DownloadsService],
  exports: [TrailsService, FavoritesService, DownloadsService],
})
export class TrailsModule {}
