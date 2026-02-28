// index.ts - DTO模块导出
// 山径APP - 后台管理 Trails API

export { CreateTrailDto, CoordinateDto, BoundsInputDto, ElevationPointDto } from './create-trail.dto';
export { UpdateTrailDto } from './update-trail.dto';
export {
  AdminTrailListItemDto,
  AdminTrailDetailDto,
  CreateTrailDataDto,
  UpdateTrailDataDto,
  DeleteTrailDataDto,
  AdminCreateTrailResponseDto,
  AdminUpdateTrailResponseDto,
  AdminDeleteTrailResponseDto,
  AdminTrailDetailResponseDto,
} from './admin-trail-response.dto';
