/**
 * 高德地图 SDK 初始化配置
 * B6-1: 高德地图 API Key 配置 + 初始化地图服务客户端
 */

// 高德地图 API Key（从环境变量读取）
const AMAP_KEY = process.env.AMAP_KEY || '';

// 高德地图 API 基础地址
const GAODE_API_BASE = 'https://restapi.amap.com/v3';

/**
 * 高德地图服务客户端配置
 */
export const gaodeConfig = {
  apiKey: AMAP_KEY,
  baseUrl: GAODE_API_BASE,
};

/**
 * 检查 API Key 是否已配置
 */
export function isGaodeConfigured(): boolean {
  return !!gaodeConfig.apiKey;
}

/**
 * 获取高德地图 API 请求 URL
 * @param path API 路径（如 /geocode/geo）
 * @param params 查询参数
 */
export function getGaodeApiUrl(path: string, params: Record<string, string> = {}): string {
  const queryParams = new URLSearchParams({
    key: gaodeConfig.apiKey,
    ...params,
  });
  return `${gaodeConfig.baseUrl}${path}?${queryParams.toString()}`;
}
