import { Module } from '@nestjs/common';
import { FilesController } from './files.controller';
import { FilesService } from './files.service';
import { OssService } from './oss.service';

@Module({
  controllers: [FilesController],
  providers: [FilesService, OssService],
  exports: [FilesService, OssService],
})
export class FilesModule {}
