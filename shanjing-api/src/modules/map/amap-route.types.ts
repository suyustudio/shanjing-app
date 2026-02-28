/**
 * 高德地图路线规划相关类型定义
 */

import { LatLng } from './amap.types';

/**
 * 步行路线规划请求参数
 */
export interface WalkingRouteRequest {
  /** 出发点经纬度，如：116.481028,39.989643 */
  origin: string;
  /** 目的地经纬度，如：116.434446,39.90816 */
  destination: string;
}

/**
 * 驾车路线规划请求参数
 */
export interface DrivingRouteRequest {
  /** 出发点经纬度，如：116.481028,39.989643 */
  origin: string;
  /** 目的地经纬度，如：116.434446,39.90816 */
  destination: string;
  /** 
   * 驾车选择策略
   * 0: 速度优先（默认）
   * 1: 费用优先
   * 2: 距离优先
   * 3: 不走高速
   * 4: 躲避拥堵
   * 5: 多策略（速度优先、费用优先、距离优先）
   * 6: 不走高速且避免收费
   * 7: 不走高速且躲避拥堵
   * 8: 躲避收费和拥堵
   * 9: 不走高速且躲避收费和拥堵
   * 10: 躲避拥堵
   * 11: 多策略（速度优先、费用优先、距离优先、躲避拥堵）
   * 12: 优先高速
   * 13: 高速优先且躲避拥堵
   * 14: 少收费
   * 15: 躲避拥堵且少收费
   * 16: 躲避拥堵且不收费
   * 17: 躲避拥堵且高速优先
   * 18: 少收费且高速优先
   * 19: 躲避拥堵且少收费且高速优先
   * 20: 避免拥堵
   */
  strategy?: number;
  /** 途经点，经纬度之间用";"分隔，如：116.481028,39.989643;116.434446,39.90816 */
  waypoints?: string;
  /** 避让区域，如：116.481488,39.990464;116.481489,39.990465;116.481490,39.990466|... */
  avoidpolygons?: string;
  /** 避让道路名称，如：京开高速 */
  avoidroad?: string;
}

/**
 * 骑行路线规划请求参数
 */
export interface BicyclingRouteRequest {
  /** 出发点经纬度，如：116.481028,39.989643 */
  origin: string;
  /** 目的地经纬度，如：116.434446,39.90816 */
  destination: string;
}

/**
 * 步行路线规划响应结果
 */
export interface WalkingRouteResult {
  /** 返回结果状态值，0表示失败，1表示成功 */
  status: string;
  /** 返回状态说明 */
  info: string;
  /** 路线信息 */
  route: {
    /** 起点坐标 */
    origin: string;
    /** 终点坐标 */
    destination: string;
    /** 路线方案列表 */
    paths: WalkingPathInfo[];
  };
}

/**
 * 驾车路线规划响应结果
 */
export interface DrivingRouteResult {
  /** 返回结果状态值，0表示失败，1表示成功 */
  status: string;
  /** 返回状态说明 */
  info: string;
  /** 路线信息 */
  route: {
    /** 起点坐标 */
    origin: string;
    /** 终点坐标 */
    destination: string;
    /** 路线方案列表 */
    paths: DrivingPathInfo[];
  };
}

/**
 * 骑行路线规划响应结果
 */
export interface BicyclingRouteResult {
  /** 返回结果状态值，0表示失败，1表示成功 */
  status: string;
  /** 返回状态说明 */
  info: string;
  /** 路线信息 */
  route: {
    /** 起点坐标 */
    origin: string;
    /** 终点坐标 */
    destination: string;
    /** 路线方案列表 */
    paths: BicyclingPathInfo[];
  };
}

/**
 * 步行路线方案信息
 */
export interface WalkingPathInfo {
  /** 起点坐标 */
  origin: string;
  /** 终点坐标 */
  destination: string;
  /** 距离，单位：米 */
  distance: string;
  /** 预计耗时，单位：秒 */
  duration: string;
  /** 导航路段列表 */
  steps: WalkingStepInfo[];
}

/**
 * 驾车路线方案信息
 */
export interface DrivingPathInfo {
  /** 起点坐标 */
  origin: string;
  /** 终点坐标 */
  destination: string;
  /** 距离，单位：米 */
  distance: string;
  /** 预计耗时，单位：秒 */
  duration: string;
  /** 策略 */
  strategy: string;
  /** 收费，单位：元 */
  tolls: string;
  /** 收费路段距离，单位：米 */
  toll_distance: string;
  /** 限行结果，0: 无限行，1: 有限行 */
  restriction: string;
  /** 红绿灯个数 */
  traffic_lights: string;
  /** 导航路段列表 */
  steps: DrivingStepInfo[];
}

/**
 * 骑行路线方案信息
 */
export interface BicyclingPathInfo {
  /** 起点坐标 */
  origin: string;
  /** 终点坐标 */
  destination: string;
  /** 距离，单位：米 */
  distance: string;
  /** 预计耗时，单位：秒 */
  duration: string;
  /** 导航路段列表 */
  steps: BicyclingStepInfo[];
}

/**
 * 步行导航路段信息
 */
export interface WalkingStepInfo {
  /** 路段说明 */
  instruction: string;
  /** 方向 */
  orientation: string;
  /** 道路名称 */
  road: string;
  /** 距离，单位：米 */
  distance: string;
  /** 预计耗时，单位：秒 */
  duration: string;
  /** 坐标点串，格式：lng,lat;lng,lat;... */
  polyline: string;
  /** 主要动作 */
  action: string;
  /** 辅助动作 */
  assistant_action: string;
  /** 步行类型 */
  walk_type: string;
}

/**
 * 驾车导航路段信息
 */
export interface DrivingStepInfo {
  /** 路段说明 */
  instruction: string;
  /** 方向 */
  orientation: string;
  /** 道路名称 */
  road: string;
  /** 距离，单位：米 */
  distance: string;
  /** 预计耗时，单位：秒 */
  duration: string;
  /** 坐标点串，格式：lng,lat;lng,lat;... */
  polyline: string;
  /** 主要动作 */
  action: string;
  /** 辅助动作 */
  assistant_action: string;
  /**  toll道路名称 */
  toll_road: string;
  /** 收费，单位：元 */
  tolls: string;
  /** 收费距离，单位：米 */
  toll_distance: string;
}

/**
 * 骑行导航路段信息
 */
export interface BicyclingStepInfo {
  /** 路段说明 */
  instruction: string;
  /** 方向 */
  orientation: string;
  /** 道路名称 */
  road: string;
  /** 距离，单位：米 */
  distance: string;
  /** 预计耗时，单位：秒 */
  duration: string;
  /** 坐标点串，格式：lng,lat;lng,lat;... */
  polyline: string;
  /** 主要动作 */
  action: string;
  /** 辅助动作 */
  assistant_action: string;
}

/**
 * 标准化的路线规划结果
 */
export interface StandardRouteResult {
  /** 是否成功 */
  success: boolean;
  /** 错误信息 */
  errorMessage?: string;
  /** 起点坐标 */
  origin?: string;
  /** 终点坐标 */
  destination?: string;
  /** 路线方案列表 */
  paths: RoutePath[];
}

/**
 * 路线方案
 */
export interface RoutePath {
  /** 距离，单位：米 */
  distance: number;
  /** 预计耗时，单位：秒 */
  duration: number;
  /** 收费，单位：元（驾车） */
  tolls?: number;
  /** 收费路段距离，单位：米（驾车） */
  tollDistance?: number;
  /** 是否限行（驾车） */
  restriction?: boolean;
  /** 红绿灯个数（驾车） */
  trafficLights?: number;
  /** 导航路段列表 */
  steps: RouteStep[];
}

/**
 * 导航路段
 */
export interface RouteStep {
  /** 路段说明 */
  instruction: string;
  /** 道路名称 */
  road: string;
  /** 距离，单位：米 */
  distance: number;
  /** 预计耗时，单位：秒 */
  duration: number;
  /** 坐标点数组 */
  polyline: LatLng[];
  /** 收费，单位：元（驾车） */
  tolls?: number;
  /** toll道路名称（驾车） */
  tollRoad?: string;
  /** 主要动作 */
  action: string;
  /** 辅助动作 */
  assistantAction: string;
}
