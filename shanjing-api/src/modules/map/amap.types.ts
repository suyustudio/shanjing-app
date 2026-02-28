/**
 * 高德地图地理编码相关类型定义
 */

/**
 * 经纬度坐标
 */
export interface LatLng {
  /** 纬度 */
  lat: number;
  /** 经度 */
  lng: number;
}

/**
 * 地址转坐标请求参数
 */
export interface GeocodeRequest {
  /** 结构化地址信息，如：北京市朝阳区阜通东大街6号 */
  address: string;
  /** 指定地址所在城市，如：北京/北京市/BEIJING */
  city?: string;
}

/**
 * 坐标转地址请求参数
 */
export interface RegeocodeRequest {
  /** 经纬度坐标，如：116.481488,39.990464 */
  location: string;
  /** 返回附近POI类型，多个类型用"|"分隔 */
  poitype?: string;
  /** 搜索半径，单位：米，取值范围：0-3000 */
  radius?: number;
  /** 返回结果控制，extensions=base/all，base:基本地址信息，all:基本+附近POI+道路+道路交叉口 */
  extensions?: 'base' | 'all';
  /** 是否优化POI返回顺序，home:住宅相关优先，corp:公司企业相关优先 */
  homeorcorp?: 'home' | 'corp';
}

/**
 * 地理编码响应结果
 */
export interface GeocodeResult {
  /** 返回结果状态值，0表示失败，1表示成功 */
  status: string;
  /** 返回状态说明 */
  info: string;
  /** 返回结果总数 */
  count: string;
  /** 地理编码信息列表 */
  geocodes: GeocodeInfo[];
}

/**
 * 地理编码信息
 */
export interface GeocodeInfo {
  /** 国家 */
  country: string;
  /** 省/直辖市 */
  province: string;
  /** 市 */
  city: string;
  /** 区 */
  district: string;
  /** 乡镇/街道 */
  township: string;
  /** 社区/村 */
  neighborhood?: {
    name: string;
    type: string;
  };
  /** 建筑 */
  building?: {
    name: string;
    type: string;
  };
  /** 门牌信息 */
  street?: string;
  /** 门牌号 */
  number?: string;
  /** 区域编码 */
  adcode: string;
  /** 结构化地址信息 */
  formatted_address: string;
  /** 地址元素列表 */
  addressComponent?: AddressComponent;
  /** 经纬度坐标 */
  location: string;
  /** 匹配级别 */
  level: string;
}

/**
 * 地址元素
 */
export interface AddressComponent {
  /** 国家 */
  country: string;
  /** 省/直辖市 */
  province: string;
  /** 市 */
  city: string;
  /** 区 */
  district: string;
  /** 乡镇/街道 */
  township: string;
  /** 社区/村 */
  neighborhood?: {
    name: string;
    type: string;
  };
  /** 建筑 */
  building?: {
    name: string;
    type: string;
  };
  /** 门牌信息 */
  street?: string;
  /** 门牌号 */
  number?: string;
  /** 区域编码 */
  adcode: string;
}

/**
 * 逆地理编码响应结果
 */
export interface RegeocodeResult {
  /** 返回结果状态值，0表示失败，1表示成功 */
  status: string;
  /** 返回状态说明 */
  info: string;
  /** 逆地理编码信息 */
  regeocode: RegeocodeInfo;
}

/**
 * 逆地理编码信息
 */
export interface RegeocodeInfo {
  /** 结构化地址信息 */
  formatted_address: string;
  /** 地址元素列表 */
  addressComponent: AddressComponent;
  /** POI信息列表（extensions=all时返回） */
  pois?: PoiInfo[];
  /** 道路信息列表（extensions=all时返回） */
  roads?: RoadInfo[];
  /** 道路交叉口列表（extensions=all时返回） */
  roadinters?: RoadIntersection[];
}

/**
 * POI信息
 */
export interface PoiInfo {
  /** POI唯一标识 */
  id: string;
  /** POI名称 */
  name: string;
  /** POI类型 */
  type: string;
  /** 电话 */
  tel?: string;
  /** 方向 */
  direction?: string;
  /** 距离坐标点距离，单位：米 */
  distance?: string;
  /** 位置 */
  location: string;
  /** 地址 */
  address: string;
  /**  poi权重 */
  poiweight?: string;
  /** 业务类型 */
  businessarea?: string;
}

/**
 * 道路信息
 */
export interface RoadInfo {
  /** 道路ID */
  id: string;
  /** 道路名称 */
  name: string;
  /** 方向 */
  direction: string;
  /** 距离坐标点距离，单位：米 */
  distance: string;
  /** 位置 */
  location: string;
}

/**
 * 道路交叉口信息
 */
export interface RoadIntersection {
  /** 方向 */
  direction: string;
  /** 距离坐标点距离，单位：米 */
  distance: string;
  /** 位置 */
  location: string;
  /** 第一条道路ID */
  first_id: string;
  /** 第一条道路名称 */
  first_name: string;
  /** 第二条道路ID */
  second_id: string;
  /** 第二条道路名称 */
  second_name: string;
}

/**
 * 标准化的地理编码结果
 * 用于服务层返回统一格式的数据
 */
export interface StandardGeocodeResult {
  /** 是否成功 */
  success: boolean;
  /** 错误信息 */
  errorMessage?: string;
  /** 地址信息列表 */
  locations: LocationInfo[];
}

/**
 * 标准化的逆地理编码结果
 */
export interface StandardRegeocodeResult {
  /** 是否成功 */
  success: boolean;
  /** 错误信息 */
  errorMessage?: string;
  /** 结构化地址 */
  formattedAddress: string;
  /** 地址组成元素 */
  addressComponent: AddressComponentDetail;
  /** 附近POI列表 */
  pois?: PoiDetail[];
}

/**
 * 位置信息
 */
export interface LocationInfo {
  /** 经纬度坐标 */
  location: LatLng;
  /** 格式化地址 */
  formattedAddress: string;
  /** 国家 */
  country: string;
  /** 省/直辖市 */
  province: string;
  /** 市 */
  city: string;
  /** 区 */
  district: string;
  /** 街道 */
  street?: string;
  /** 门牌号 */
  streetNumber?: string;
  /** 区域编码 */
  adcode: string;
  /** 匹配级别 */
  level: string;
}

/**
 * 详细地址组成元素
 */
export interface AddressComponentDetail {
  /** 国家 */
  country: string;
  /** 省/直辖市 */
  province: string;
  /** 市 */
  city: string;
  /** 区 */
  district: string;
  /** 乡镇/街道 */
  township: string;
  /** 社区/村 */
  neighborhood?: string;
  /** 建筑 */
  building?: string;
  /** 街道 */
  street?: string;
  /** 门牌号 */
  number?: string;
  /** 区域编码 */
  adcode: string;
}

/**
 * POI详细信息
 */
export interface PoiDetail {
  /** POI ID */
  id: string;
  /** POI名称 */
  name: string;
  /** POI类型 */
  type: string;
  /** 电话 */
  tel?: string;
  /** 距离，单位：米 */
  distance?: number;
  /** 地址 */
  address: string;
  /** 经纬度坐标 */
  location: LatLng;
}
