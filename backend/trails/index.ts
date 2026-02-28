// index.ts - Trails模块导出
// 山径APP - 路线数据 API

export { TrailsModule } from './trails.module';
export { TrailsController } from './trails.controller';
export { TrailsService } from './trails.service';
export { FavoritesController, UserFavoritesController } from './favorites.controller';
export { FavoritesService } from './favorites.service';
export { DownloadsController, UserDownloadsController } from './downloads.controller';
export { DownloadsService } from './downloads.service';
export * from './dto/list-trails.dto';
export * from './dto/list-favorites.dto';
export * from './dto/trail-response.dto';
export * from './dto/favorite-response.dto';
export * from './dto/download-response.dto';
export * from './dto/track-response.dto';
