// OfflineMapPlugin.swift
// 山径APP - iOS 离线地图插件
// 功能：桥接高德地图iOS离线SDK和Flutter

import Flutter
import UIKit
import MAMapKit

/// 离线地图状态枚举
enum OfflineMapStatus: Int {
    case unknown = -1
    case downloading = 0
    case waiting = 1
    case pause = 2
    case stop = 3
    case success = 4
    case error = 5
    case expire = 6
}

/// 离线地图插件
public class OfflineMapPlugin: NSObject, FlutterPlugin {
    
    // MARK: - 常量
    
    static let METHOD_CHANNEL = "com.shanjing/offline_map"
    static let EVENT_CHANNEL = "com.shanjing/offline_map_events"
    
    // MARK: - 属性
    
    private var methodChannel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?
    private var eventSink: FlutterEventSink?
    
    /// 离线地图管理器
    private lazy var offlineMapManager: MAOfflineMap = {
        return MAOfflineMap.shared()
    }()
    
    /// 下载进度缓存
    private var downloadProgressMap: [String: Int] = [:]
    private var downloadStatusMap: [String: Int] = [:]
    
    // MARK: - FlutterPlugin
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = OfflineMapPlugin()
        
        // 初始化MethodChannel
        instance.methodChannel = FlutterMethodChannel(
            name: METHOD_CHANNEL,
            binaryMessenger: registrar.messenger()
        )
        
        // 初始化EventChannel
        instance.eventChannel = FlutterEventChannel(
            name: EVENT_CHANNEL,
            binaryMessenger: registrar.messenger()
        )
        
        // 设置处理器
        instance.methodChannel?.setMethodCallHandler(instance.handleMethodCall)
        instance.eventChannel?.setStreamHandler(instance)
        
        // 设置离线地图代理
        instance.offlineMapManager.delegate = instance
    }
    
    // MARK: - Method Call Handler
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            result(initialize())
            
        case "getOfflineCityList":
            result(getOfflineCityList())
            
        case "getHotCityList":
            result(getHotCityList())
            
        case "getDownloadedOfflineMapList":
            result(getDownloadedOfflineMapList())
            
        case "downloadOfflineMap":
            if let args = call.arguments as? [String: Any],
               let cityCode = args["cityCode"] as? String {
                let cityName = args["cityName"] as? String ?? ""
                result(downloadOfflineMap(cityCode: cityCode, cityName: cityName))
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing cityCode", details: nil))
            }
            
        case "pauseDownload":
            if let args = call.arguments as? [String: Any],
               let cityCode = args["cityCode"] as? String {
                result(pauseDownload(cityCode: cityCode))
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing cityCode", details: nil))
            }
            
        case "resumeDownload":
            if let args = call.arguments as? [String: Any],
               let cityCode = args["cityCode"] as? String {
                result(resumeDownload(cityCode: cityCode))
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing cityCode", details: nil))
            }
            
        case "deleteOfflineMap":
            if let args = call.arguments as? [String: Any],
               let cityCode = args["cityCode"] as? String {
                result(deleteOfflineMap(cityCode: cityCode))
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing cityCode", details: nil))
            }
            
        case "isCityDownloaded":
            if let args = call.arguments as? [String: Any],
               let cityCode = args["cityCode"] as? String {
                result(isCityDownloaded(cityCode: cityCode))
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing cityCode", details: nil))
            }
            
        case "getDownloadProgress":
            if let args = call.arguments as? [String: Any],
               let cityCode = args["cityCode"] as? String {
                result(getDownloadProgress(cityCode: cityCode))
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing cityCode", details: nil))
            }
            
        case "clearAllOfflineMaps":
            result(clearAllOfflineMaps())
            
        case "updateOfflineMap":
            if let args = call.arguments as? [String: Any],
               let cityCode = args["cityCode"] as? String {
                result(updateOfflineMap(cityCode: cityCode))
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing cityCode", details: nil))
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - 离线地图功能
    
    /// 初始化离线地图
    private func initialize() -> Bool {
        // iOS高德SDK自动初始化
        return true
    }
    
    /// 获取离线地图城市列表
    private func getOfflineCityList() -> [[String: Any?]] {
        let provinces = offlineMapManager.offlineMap provincesWithCities() ?? []
        var allCities: [MAOfflineItemCity] = []
        
        // 收集所有城市
        for province in provinces {
            if let cities = province.cities as? [MAOfflineItemCity] {
                allCities.append(contentsOf: cities)
            }
            // 省本身也可以下载（包含全省地图）
            if let provinceCity = province as? MAOfflineItemCity {
                allCities.append(provinceCity)
            }
        }
        
        // 添加全国地图
        if let nationWide = offlineMapMapManager.nationWide as? MAOfflineItemCity {
            allCities.append(nationWide)
        }
        
        return allCities.map { convertCityToMap(city: $0) }
    }
    
    /// 获取热门城市列表
    private func getHotCityList() -> [[String: Any?]] {
        let hotCities = offlineMapManager.hotCities ?? []
        return (hotCities as? [MAOfflineItemCity] ?? []).map { convertCityToMap(city: $0) }
    }
    
    /// 获取已下载的离线地图列表
    private func getDownloadedOfflineMapList() -> [[String: Any?]] {
        let downloadedCities = offlineMapManager.downloadingItems ?? []
        return (downloadedCities as? [MAOfflineItemCity] ?? []).map { convertCityToMap(city: $0) }
    }
    
    /// 开始下载离线地图
    private func downloadOfflineMap(cityCode: String, cityName: String) -> Bool {
        guard let city = findCity(byCode: cityCode) ?? findCity(byName: cityName) else {
            return false
        }
        
        do {
            try offlineMapManager.downloadCity(city, shouldContinueWhenAppEntersBackground: true, usingNewName: nil)
            downloadStatusMap[cityCode] = OfflineMapStatus.downloading.rawValue
            return true
        } catch {
            print("下载离线地图失败: \(error)")
            return false
        }
    }
    
    /// 暂停下载
    private func pauseDownload(cityCode: String) -> Bool {
        guard let city = findCity(byCode: cityCode) else {
            return false
        }
        
        offlineMapManager.pauseItem(city)
        downloadStatusMap[cityCode] = OfflineMapStatus.pause.rawValue
        return true
    }
    
    /// 继续下载
    private func resumeDownload(cityCode: String) -> Bool {
        // iOS SDK使用相同的方法恢复下载
        return downloadOfflineMap(cityCode: cityCode, cityName: "")
    }
    
    /// 删除离线地图
    private func deleteOfflineMap(cityCode: String) -> Bool {
        guard let city = findCity(byCode: cityCode) else {
            return false
        }
        
        offlineMapManager.deleteCity(city)
        downloadProgressMap.removeValue(forKey: cityCode)
        downloadStatusMap.removeValue(forKey: cityCode)
        return true
    }
    
    /// 检查城市是否已下载
    private func isCityDownloaded(cityCode: String) -> Bool {
        guard let city = findCity(byCode: cityCode) else {
            return false
        }
        return offlineMapManager.isDownloadingItem(city)
    }
    
    /// 获取下载进度
    private func getDownloadProgress(cityCode: String) -> Int {
        return downloadProgressMap[cityCode] ?? 0
    }
    
    /// 清除所有离线地图
    private func clearAllOfflineMaps() -> Bool {
        let downloadedItems = offlineMapManager.downloadingItems ?? []
        for item in downloadedItems {
            if let city = item as? MAOfflineItemCity {
                offlineMapManager.deleteCity(city)
            }
        }
        downloadProgressMap.removeAll()
        downloadStatusMap.removeAll()
        return true
    }
    
    /// 更新离线地图
    private func updateOfflineMap(cityCode: String) -> Bool {
        // iOS SDK自动处理更新
        // 重新下载即可获取最新版本
        return downloadOfflineMap(cityCode: cityCode, cityName: "")
    }
    
    // MARK: - 辅助方法
    
    /// 根据城市编码查找城市
    private func findCity(byCode code: String) -> MAOfflineItemCity? {
        let allCities = getAllCities()
        return allCities.first { String($0.cityCode) == code }
    }
    
    /// 根据城市名称查找城市
    private func findCity(byName name: String) -> MAOfflineItemCity? {
        let allCities = getAllCities()
        return allCities.first { $0.city == name }
    }
    
    /// 获取所有城市
    private func getAllCities() -> [MAOfflineItemCity] {
        var allCities: [MAOfflineItemCity] = []
        
        let provinces = offlineMapManager.offlineMap provincesWithCities() ?? []
        for province in provinces {
            if let cities = province.cities as? [MAOfflineItemCity] {
                allCities.append(contentsOf: cities)
            }
            if let provinceCity = province as? MAOfflineItemCity {
                allCities.append(provinceCity)
            }
        }
        
        if let nationWide = offlineMapManager.nationWide as? MAOfflineItemCity {
            allCities.append(nationWide)
        }
        
        return allCities
    }
    
    /// 将城市对象转换为Map
    private func convertCityToMap(city: MAOfflineItemCity) -> [String: Any?] {
        let cityCode = String(city.cityCode)
        let isDownloaded = offlineMapManager.isDownloadingItem(city)
        
        // 获取下载状态
        var status = downloadStatusMap[cityCode]
        if status == nil {
            if isDownloaded {
                status = OfflineMapStatus.success.rawValue
            } else {
                status = OfflineMapStatus.unknown.rawValue
            }
        }
        
        return [
            "cityCode": cityCode,
            "cityName": city.city,
            "cityPinyin": city.pinyin,
            "dataSize": city.size,
            "downloadSize": city.downloadedSize,
            "ratio": downloadProgressMap[cityCode] ?? 0,
            "status": status,
            "update": city.hasNewVersion,
            "version": city.version
        ]
    }
}

// MARK: - FlutterStreamHandler

extension OfflineMapPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}

// MARK: - MAOfflineMapDelegate

extension OfflineMapPlugin: MAOfflineMapDelegate {
    
    public func offlineMap(_ map: MAOfflineMap!, didDownload item: MAOfflineItem!, downloadStatus status: MAOfflineMapDownloadStatus, result: MAOfflineMapDownloadResult) {
        
        let cityCode = String(item.cityCode)
        let cityName = item.city
        
        // 更新状态
        var flutterStatus: Int
        switch status {
        case .waiting:
            flutterStatus = OfflineMapStatus.waiting.rawValue
        case .downloading:
            flutterStatus = OfflineMapStatus.downloading.rawValue
            // 计算进度
            let progress = Int((Double(item.downloadedSize) / Double(item.size)) * 100)
            downloadProgressMap[cityCode] = progress
        case .pause:
            flutterStatus = OfflineMapStatus.pause.rawValue
        case .stop:
            flutterStatus = OfflineMapStatus.stop.rawValue
        case .completed:
            flutterStatus = OfflineMapStatus.success.rawValue
            downloadProgressMap[cityCode] = 100
        case .expired:
            flutterStatus = OfflineMapStatus.expire.rawValue
        @unknown default:
            flutterStatus = OfflineMapStatus.error.rawValue
        }
        
        downloadStatusMap[cityCode] = flutterStatus
        
        // 发送事件到Flutter
        DispatchQueue.main.async {
            self.eventSink?([
                "cityCode": cityCode,
                "cityName": cityName,
                "status": flutterStatus,
                "progress": self.downloadProgressMap[cityCode] ?? 0,
                "completeCode": result == .success ? 100 : 0,
                "result": result.rawValue
            ])
        }
    }
    
    public func offlineMap(_ map: MAOfflineMap!, didFinishCheckingWithNewVersion hasNewVersion: Bool, for item: MAOfflineItem!) {
        DispatchQueue.main.async {
            self.eventSink?([
                "type": "checkUpdate",
                "cityName": item.city,
                "cityCode": String(item.cityCode),
                "hasUpdate": hasNewVersion
            ])
        }
    }
}
