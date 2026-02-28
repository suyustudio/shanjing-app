import { Controller, Post, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AmapGeocodeService } from './amap-geocode.service';
import { AmapRouteService } from './amap-route.service';
import { 
  GeocodeDto, 
  RegeocodeDto, 
  GeocodeResponseDto, 
  RegeocodeResponseDto,
  WalkingRouteDto,
  DrivingRouteDto,
  BicyclingRouteDto,
  RoutePlanningDto,
  RouteResponseDto,
  RouteType,
} from './dto';

/**
 * 地图服务控制器
 * 
 * 提供地理编码、逆地理编码和路线规划的 REST API 接口
 */
@ApiTags('地图服务')
@Controller('map')
export class MapController {
  constructor(
    private readonly amapGeocodeService: AmapGeocodeService,
    private readonly amapRouteService: AmapRouteService,
  ) {}

  /**
   * 地理编码：地址转坐标
   */
  @Post('geocode')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: '地理编码',
    description: '将结构化地址转换为经纬度坐标'
  })
  @ApiResponse({
    status: 200,
    description: '地理编码成功',
    type: GeocodeResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: '请求参数错误',
  })
  async geocode(@Body() dto: GeocodeDto): Promise<GeocodeResponseDto> {
    const result = await this.amapGeocodeService.geocode({
      address: dto.address,
      city: dto.city,
    });

    return {
      success: result.success,
      errorMessage: result.errorMessage,
      data: {
        locations: result.locations,
      },
    };
  }

  /**
   * 逆地理编码：坐标转地址
   */
  @Post('regeocode')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: '逆地理编码',
    description: '将经纬度坐标转换为结构化地址'
  })
  @ApiResponse({
    status: 200,
    description: '逆地理编码成功',
    type: RegeocodeResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: '请求参数错误',
  })
  async regeocode(@Body() dto: RegeocodeDto): Promise<RegeocodeResponseDto> {
    const location = this.amapGeocodeService.formatLocation(dto.lat, dto.lng);
    
    const result = await this.amapGeocodeService.regeocode({
      location,
      extensions: dto.extensions,
      radius: dto.radius,
    });

    return {
      success: result.success,
      errorMessage: result.errorMessage,
      data: {
        formattedAddress: result.formattedAddress,
        addressComponent: result.addressComponent,
        pois: result.pois,
      },
    };
  }

  /**
   * 步行路线规划
   */
  @Post('route/walking')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: '步行路线规划',
    description: '规划两点之间的步行路线'
  })
  @ApiResponse({
    status: 200,
    description: '路线规划成功',
    type: RouteResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: '请求参数错误',
  })
  async walkingRoute(@Body() dto: WalkingRouteDto): Promise<RouteResponseDto> {
    const origin = this.amapRouteService.formatLocation(dto.originLat, dto.originLng);
    const destination = this.amapRouteService.formatLocation(dto.destLat, dto.destLng);
    
    const result = await this.amapRouteService.walkingRoute({
      origin,
      destination,
    });

    return {
      success: result.success,
      errorMessage: result.errorMessage,
      data: {
        origin: result.origin || origin,
        destination: result.destination || destination,
        paths: result.paths,
      },
    };
  }

  /**
   * 驾车路线规划
   */
  @Post('route/driving')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: '驾车路线规划',
    description: '规划两点之间的驾车路线'
  })
  @ApiResponse({
    status: 200,
    description: '路线规划成功',
    type: RouteResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: '请求参数错误',
  })
  async drivingRoute(@Body() dto: DrivingRouteDto): Promise<RouteResponseDto> {
    const origin = this.amapRouteService.formatLocation(dto.originLat, dto.originLng);
    const destination = this.amapRouteService.formatLocation(dto.destLat, dto.destLng);
    
    const result = await this.amapRouteService.drivingRoute({
      origin,
      destination,
      strategy: dto.strategy,
    });

    return {
      success: result.success,
      errorMessage: result.errorMessage,
      data: {
        origin: result.origin || origin,
        destination: result.destination || destination,
        paths: result.paths,
      },
    };
  }

  /**
   * 骑行路线规划
   */
  @Post('route/bicycling')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: '骑行路线规划',
    description: '规划两点之间的骑行路线'
  })
  @ApiResponse({
    status: 200,
    description: '路线规划成功',
    type: RouteResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: '请求参数错误',
  })
  async bicyclingRoute(@Body() dto: BicyclingRouteDto): Promise<RouteResponseDto> {
    const origin = this.amapRouteService.formatLocation(dto.originLat, dto.originLng);
    const destination = this.amapRouteService.formatLocation(dto.destLat, dto.destLng);
    
    const result = await this.amapRouteService.bicyclingRoute({
      origin,
      destination,
    });

    return {
      success: result.success,
      errorMessage: result.errorMessage,
      data: {
        origin: result.origin || origin,
        destination: result.destination || destination,
        paths: result.paths,
      },
    };
  }

  /**
   * 通用路线规划
   * 根据类型自动选择步行、驾车或骑行路线规划
   */
  @Post('route')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: '路线规划',
    description: '根据类型规划路线（步行、驾车、骑行）'
  })
  @ApiResponse({
    status: 200,
    description: '路线规划成功',
    type: RouteResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: '请求参数错误',
  })
  async routePlanning(@Body() dto: RoutePlanningDto): Promise<RouteResponseDto> {
    const origin = this.amapRouteService.formatLocation(dto.originLat, dto.originLng);
    const destination = this.amapRouteService.formatLocation(dto.destLat, dto.destLng);
    
    let result;
    
    switch (dto.type) {
      case RouteType.WALKING:
        result = await this.amapRouteService.walkingRoute({ origin, destination });
        break;
      case RouteType.DRIVING:
        result = await this.amapRouteService.drivingRoute({ 
          origin, 
          destination,
          strategy: dto.strategy,
        });
        break;
      case RouteType.BICYCLING:
        result = await this.amapRouteService.bicyclingRoute({ origin, destination });
        break;
      default:
        return {
          success: false,
          errorMessage: '不支持的路线类型',
          data: {
            origin,
            destination,
            paths: [],
          },
        };
    }

    return {
      success: result.success,
      errorMessage: result.errorMessage,
      data: {
        origin: result.origin || origin,
        destination: result.destination || destination,
        paths: result.paths,
      },
    };
  }
}
