import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

/**
 * 经纬度坐标 DTO
 */
export class LatLngDto {
  @ApiProperty({ description: '纬度', example: 39.990464 })
  lat: number;

  @ApiProperty({ description: '经度', example: 116.481488 })
  lng: number;
}

/**
 * 地址组成元素 DTO
 */
export class AddressComponentDto {
  @ApiProperty({ description: '国家', example: '中国' })
  country: string;

  @ApiProperty({ description: '省/直辖市', example: '北京市' })
  province: string;

  @ApiProperty({ description: '市', example: '北京市' })
  city: string;

  @ApiProperty({ description: '区', example: '朝阳区' })
  district: string;

  @ApiProperty({ description: '乡镇/街道', example: '望京街道' })
  township: string;

  @ApiPropertyOptional({ description: '社区/村' })
  neighborhood?: string;

  @ApiPropertyOptional({ description: '建筑' })
  building?: string;

  @ApiPropertyOptional({ description: '街道' })
  street?: string;

  @ApiPropertyOptional({ description: '门牌号' })
  number?: string;

  @ApiProperty({ description: '区域编码', example: '110105' })
  adcode: string;
}

/**
 * 位置信息 DTO
 */
export class LocationInfoDto {
  @ApiProperty({ description: '经纬度坐标', type: LatLngDto })
  location: LatLngDto;

  @ApiProperty({ description: '格式化地址', example: '北京市朝阳区望京街道阜通东大街6号' })
  formattedAddress: string;

  @ApiProperty({ description: '国家', example: '中国' })
  country: string;

  @ApiProperty({ description: '省/直辖市', example: '北京市' })
  province: string;

  @ApiProperty({ description: '市', example: '北京市' })
  city: string;

  @ApiProperty({ description: '区', example: '朝阳区' })
  district: string;

  @ApiPropertyOptional({ description: '街道' })
  street?: string;

  @ApiPropertyOptional({ description: '门牌号' })
  streetNumber?: string;

  @ApiProperty({ description: '区域编码', example: '110105' })
  adcode: string;

  @ApiProperty({ description: '匹配级别', example: '门址' })
  level: string;
}

/**
 * POI信息 DTO
 */
export class PoiInfoDto {
  @ApiProperty({ description: 'POI ID', example: 'B000A7BGD1' })
  id: string;

  @ApiProperty({ description: 'POI名称', example: '方恒国际中心' })
  name: string;

  @ApiProperty({ description: 'POI类型', example: '商务住宅;楼宇;商务写字楼' })
  type: string;

  @ApiPropertyOptional({ description: '电话' })
  tel?: string;

  @ApiPropertyOptional({ description: '距离坐标点距离，单位：米' })
  distance?: number;

  @ApiProperty({ description: '地址', example: '阜通东大街6号' })
  address: string;

  @ApiProperty({ description: '经纬度坐标', type: LatLngDto })
  location: LatLngDto;
}

/**
 * 地理编码响应数据 DTO
 */
export class GeocodeDataDto {
  @ApiProperty({ description: '地址信息列表', type: [LocationInfoDto] })
  locations: LocationInfoDto[];
}

/**
 * 逆地理编码响应数据 DTO
 */
export class RegeocodeDataDto {
  @ApiProperty({ description: '结构化地址', example: '北京市朝阳区望京街道阜通东大街6号方恒国际中心' })
  formattedAddress: string;

  @ApiProperty({ description: '地址组成元素', type: AddressComponentDto })
  addressComponent: AddressComponentDto;

  @ApiPropertyOptional({ description: '附近POI列表', type: [PoiInfoDto] })
  pois?: PoiInfoDto[];
}

/**
 * 地理编码响应 DTO
 */
export class GeocodeResponseDto {
  @ApiProperty({ description: '是否成功', example: true })
  success: boolean;

  @ApiPropertyOptional({ description: '错误信息' })
  errorMessage?: string;

  @ApiProperty({ description: '响应数据', type: GeocodeDataDto })
  data: GeocodeDataDto;
}

/**
 * 逆地理编码响应 DTO
 */
export class RegeocodeResponseDto {
  @ApiProperty({ description: '是否成功', example: true })
  success: boolean;

  @ApiPropertyOptional({ description: '错误信息' })
  errorMessage?: string;

  @ApiProperty({ description: '响应数据', type: RegeocodeDataDto })
  data: RegeocodeDataDto;
}
