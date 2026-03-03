package com.example.hangzhou_guide

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import com.amap.api.maps.offlinemap.OfflineMapCity
import com.amap.api.maps.offlinemap.OfflineMapManager
import com.amap.api.maps.offlinemap.OfflineMapStatus

class MainActivity: FlutterActivity() {
    private val OFFLINE_MAP_CHANNEL = "com.shanjing/offline_map"
    private val OFFLINE_MAP_EVENTS = "com.shanjing/offline_map_events"
    
    private lateinit var offlineMapManager: OfflineMapManager
    private var eventSink: EventChannel.EventSink? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 初始化离线地图管理器
        offlineMapManager = OfflineMapManager(this, object : OfflineMapManager.OfflineMapDownloadListener {
            override fun onDownload(status: Int, completeCode: Int, downName: String?) {
                // 查找城市代码
                val cityCode = findCityCodeByName(downName)
                
                val event = mapOf(
                    "cityCode" to (cityCode ?: ""),
                    "cityName" to (downName ?: ""),
                    "status" to status,
                    "progress" to completeCode,
                    "completeCode" to completeCode
                )
                
                activity?.runOnUiThread {
                    eventSink?.success(event)
                }
            }
            
            override fun onCheckUpdate(hasUpdate: Boolean, name: String?) {}
            override fun onRemove(success: Boolean, name: String?, describe: String?) {
                val cityCode = findCityCodeByName(name)
                val event = mapOf(
                    "cityCode" to (cityCode ?: ""),
                    "cityName" to (name ?: ""),
                    "status" to OfflineMapStatus.SUCCESS,
                    "progress" to 100,
                    "completeCode" to 100,
                    "action" to "removed"
                )
                
                activity?.runOnUiThread {
                    eventSink?.success(event)
                }
            }
        })
        
        // 设置MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, OFFLINE_MAP_CHANNEL)
            .setMethodCallHandler { call, result ->
                handleMethodCall(call, result)
            }
        
        // 设置EventChannel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, OFFLINE_MAP_EVENTS)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }
                
                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
    }
    
    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                result.success(true)
            }
            "getOfflineCityList" -> {
                val cities = offlineMapManager.offlineMapCityList
                result.success(cities.map { cityToMap(it) })
            }
            "getHotCityList" -> {
                val cities = offlineMapManager.hotCityList
                result.success(cities.map { cityToMap(it) })
            }
            "downloadOfflineMap" -> {
                val cityCode = call.argument<String>("cityCode")
                if (cityCode != null) {
                    offlineMapManager.downloadByCityCode(cityCode)
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
            "pauseDownload" -> {
                val cityCode = call.argument<String>("cityCode")
                if (cityCode != null) {
                    offlineMapManager.pauseByCityCode(cityCode)
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
            "resumeDownload" -> {
                val cityCode = call.argument<String>("cityCode")
                if (cityCode != null) {
                    offlineMapManager.downloadByCityCode(cityCode)
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
            "deleteOfflineMap" -> {
                val cityCode = call.argument<String>("cityCode")
                if (cityCode != null) {
                    offlineMapManager.remove(cityCode)
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
            "getDownloadedOfflineMapList" -> {
                val cities = offlineMapManager.downloadOfflineMapCityList
                result.success(cities.map { cityToMap(it) })
            }
            "isCityDownloaded" -> {
                val cityCode = call.argument<String>("cityCode")
                val cities = offlineMapManager.downloadOfflineMapCityList
                val isDownloaded = cities.any { it.code == cityCode }
                result.success(isDownloaded)
            }
            "getDownloadProgress" -> {
                val cityCode = call.argument<String>("cityCode")
                val cities = offlineMapManager.downloadOfflineMapCityList
                val city = cities.find { it.code == cityCode }
                result.success(city?.completeCode ?: 0)
            }
            "clearAllOfflineMaps" -> {
                val cities = offlineMapManager.downloadOfflineMapCityList
                cities.forEach { offlineMapManager.remove(it.code) }
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }
    
    private fun cityToMap(city: OfflineMapCity): Map<String, Any?> {
        return mapOf(
            "cityCode" to city.code,
            "cityName" to city.city,
            "cityPinyin" to city.pinyin,
            "dataSize" to city.size,
            "downloadSize" to city.downloadedSize,
            "ratio" to city.completeCode,
            "status" to city.state,
            "update" to city.isUpdate,
            "version" to city.version
        )
    }
    
    private fun findCityCodeByName(name: String?): String? {
        if (name == null) return null
        val cities = offlineMapManager.offlineMapCityList
        return cities.find { it.city == name }?.code
    }
    
    override fun onDestroy() {
        super.onDestroy()
        offlineMapManager.destroy()
    }
}
