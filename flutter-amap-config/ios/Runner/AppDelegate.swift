import Flutter
import UIKit
import AMapFoundationKit
import MAMapKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  private var offlineManager: MAOfflineMap?
  private var eventSink: FlutterEventSink?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // 配置高德地图
    AMapServices.shared().enableHTTPS = true
    AMapServices.shared().apiKey = Bundle.main.object(forInfoDictionaryKey: "AMAP_KEY") as? String ?? ""
    
    // 初始化离线地图管理器
    offlineManager = MAOfflineMap.shared()
    
    // 设置MethodChannel
    let controller = window?.rootViewController as! FlutterViewController
    let methodChannel = FlutterMethodChannel(
      name: "com.shanjing/offline_map",
      binaryMessenger: controller.binaryMessenger
    )
    
    methodChannel.setMethodCallHandler { [weak self] (call, result) in
      self?.handleMethodCall(call, result: result)
    }
    
    // 设置EventChannel
    let eventChannel = FlutterEventChannel(
      name: "com.shanjing/offline_map_events",
      binaryMessenger: controller.binaryMessenger
    )
    eventChannel.setStreamHandler(self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      result(true)
      
    case "getOfflineCityList":
      let cities = offlineManager?.offlineCities ?? []
      result(cities.map { cityToMap($0) })
      
    case "getHotCityList":
      let cities = offlineManager?.hotCities ?? []
      result(cities.map { cityToMap($0) })
      
    case "downloadOfflineMap":
      if let args = call.arguments as? [String: Any],
         let cityCode = args["cityCode"] as? String {
        if let city = findCity(byCode: cityCode) {
          offlineManager?.downloadCity(city, shouldContinueWhenAppEntersBackground: true, downloadBlock: { [weak self] (item, error) in
            if let item = item {
              self?.sendDownloadEvent(item: item, status: item.status.rawValue)
            }
          })
          result(true)
        } else {
          result(false)
        }
      } else {
        result(false)
      }
      
    case "pauseDownload":
      offlineManager?.pause()
      result(true)
      
    case "resumeDownload":
      if let args = call.arguments as? [String: Any],
         let cityCode = args["cityCode"] as? String {
        if let city = findCity(byCode: cityCode) {
          offlineManager?.downloadCity(city, shouldContinueWhenAppEntersBackground: true, downloadBlock: { [weak self] (item, error) in
            if let item = item {
              self?.sendDownloadEvent(item: item, status: item.status.rawValue)
            }
          })
          result(true)
        } else {
          result(false)
        }
      } else {
        result(false)
      }
      
    case "deleteOfflineMap":
      if let args = call.arguments as? [String: Any],
         let cityCode = args["cityCode"] as? String {
        if let city = findCity(byCode: cityCode) {
          offlineManager?.deleteOfflineItem(city)
          result(true)
        } else {
          result(false)
        }
      } else {
        result(false)
      }
      
    case "getDownloadedOfflineMapList":
      let cities = offlineManager?.offlineCities?.filter { $0.status == .downloaded } ?? []
      result(cities.map { cityToMap($0) })
      
    case "isCityDownloaded":
      if let args = call.arguments as? [String: Any],
         let cityCode = args["cityCode"] as? String {
        let isDownloaded = offlineManager?.offlineCities?.contains(where: { $0.code == cityCode && $0.status == .downloaded }) ?? false
        result(isDownloaded)
      } else {
        result(false)
      }
      
    case "getDownloadProgress":
      if let args = call.arguments as? [String: Any],
         let cityCode = args["cityCode"] as? String {
        let progress = offlineManager?.offlineCities?.first(where: { $0.code == cityCode })?.downloadRatio ?? 0
        result(progress)
      } else {
        result(0)
      }
      
    case "clearAllOfflineMaps":
      offlineManager?.offlineCities?.forEach { city in
        offlineManager?.deleteOfflineItem(city)
      }
      result(true)
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func cityToMap(_ city: MAOfflineItemCity) -> [String: Any?] {
    return [
      "cityCode": city.code,
      "cityName": city.name,
      "cityPinyin": city.pinyin,
      "dataSize": city.size,
      "downloadSize": city.downloadedSize,
      "ratio": city.downloadRatio,
      "status": city.status.rawValue,
      "update": city.needUpdate,
      "version": city.version
    ]
  }
  
  private func findCity(byCode code: String) -> MAOfflineItemCity? {
    return offlineManager?.offlineCities?.first { $0.code == code }
  }
  
  private func sendDownloadEvent(item: MAOfflineItem, status: Int) {
    let event: [String: Any] = [
      "cityCode": item.code ?? "",
      "cityName": item.name ?? "",
      "status": status,
      "progress": item.downloadRatio,
      "completeCode": item.downloadRatio
    ]
    eventSink?(event)
  }
}

// MARK: - FlutterStreamHandler
extension AppDelegate: FlutterStreamHandler {
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    return nil
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }
}
