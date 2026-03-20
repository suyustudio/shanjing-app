import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_FILTER, APP_INTERCEPTOR } from '@nestjs/core';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { FilesModule } from './modules/files/files.module';
import { MapModule } from './modules/map/map.module';
import { TrailsModule } from './modules/trails/trails.module';
import { FavoritesModule } from './modules/favorites/favorites.module';
import { RecommendationModule } from './modules/recommendation/recommendation.module';
import { ReviewsModule } from './modules/reviews/reviews.module';
import { PrismaModule } from './database/prisma.module';
import { RedisModule } from './shared/redis/redis.module';
import { AllExceptionsFilter } from './common/filters/all-exceptions.filter';
import { TransformInterceptor } from './common/interceptors/transform.interceptor';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    PrismaModule,
    RedisModule,
    AuthModule,
    UsersModule,
    FilesModule,
    MapModule,
    TrailsModule,
    FavoritesModule,
    RecommendationModule,
    ReviewsModule,
  ],
  providers: [
    {
      provide: APP_FILTER,
      useClass: AllExceptionsFilter,
    },
    {
      provide: APP_INTERCEPTOR,
      useClass: TransformInterceptor,
    },
  ],
})
export class AppModule {}