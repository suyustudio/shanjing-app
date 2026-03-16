package com.suyustudio.shanjing

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * 离线地图插件 - 桥接高德地图离线SDK和Flutter
 * 
 * 注意：当前为模拟实现，高德 SDK 仓库在 CI 环境中无法访问
 * 如需完整功能，需要在可以访问高德仓库的环境中构建
 */
class OfflineMapPlugin private constructor(
    private val context: Context,
    flutterEngine: FlutterEngine
) : MethodChannel.MethodCallHandler, 
    EventChannel.StreamHandler {

    companion object {
        const val METHOD_CHANNEL = "com.shanjing/offline_map"
        const val EVENT_CHANNEL = "com.shanjing/offline_map_events"
        
        @Volatile
        private var instance: OfflineMapPlugin? = null
        
        fun getInstance(context: Context, flutterEngine: FlutterEngine): OfflineMapPlugin {
            return instance ?: synchronized(this) {
                instance ?: OfflineMapPlugin(context, flutterEngine).also { instance = it }
            }
        }
    }

    private val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
    private val eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    // 模拟下载状态
    private val downloadProgressMap = mutableMapOf<String, Int>()
    private val downloadStatusMap = mutableMapOf<String, Int>()
    private val downloadedCities = mutableSetOf<String>()

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getOfflineMapCityList" -> {
                // 模拟返回城市列表
                result.success(getMockCityList())
            }
            "getDownloadOfflineMapCityList" -> {
                // 模拟返回已下载城市列表
                result.success(getMockDownloadedCities())
            }
            "downloadByCityCode" -> {
                val cityCode = call.argument<String>("cityCode")
                val cityName = call.argument<String>("cityName") ?: "未知城市"
                if (cityCode != null) {
                    simulateDownload(cityCode, cityName)
                    result.success(true)
                } else {
                    result.error("INVALID_CITY_CODE", "城市代码不能为空", null)
                }
            }
            "pauseDownloadByCityCode" -> {
                val cityCode = call.argument<String>("cityCode")
                if (cityCode != null) {
                    downloadStatusMap[cityCode] = 3 // PAUSE
                    result.success(true)
                } else {
                    result.error("INVALID_CITY_CODE", "城市代码不能为空", null)
                }
            }
            "resumeDownloadByCityCode" -> {
                val cityCode = call.argument<String>("cityCode")
                val cityName = call.argument<String>("cityName") ?: "未知城市"
                if (cityCode != null) {
                    simulateDownload(cityCode, cityName)
                    result.success(true)
                } else {
                    result.error("INVALID_CITY_CODE", "城市代码不能为空", null)
                }
            }
            "stopDownloadByCityCode" -> {
                val cityCode = call.argument<String>("cityCode")
                if (cityCode != null) {
                    downloadStatusMap[cityCode] = -1 // ERROR
                    result.success(true)
                } else {
                    result.error("INVALID_CITY_CODE", "城市代码不能为空", null)
                }
            }
            "removeByCityCode" -> {
                val cityCode = call.argument<String>("cityCode")
                if (cityCode != null) {
                    downloadedCities.remove(cityCode)
                    downloadStatusMap.remove(cityCode)
                    downloadProgressMap.remove(cityCode)
                    result.success(true)
                } else {
                    result.error("INVALID_CITY_CODE", "城市代码不能为空", null)
                }
            }
            "getAvailableStorage" -> {
                // 模拟返回可用存储空间 (MB)
                result.success(2048L)
            }
            "getTotalStorage" -> {
                // 模拟返回总存储空间 (MB)
                result.success(4096L)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun simulateDownload(cityCode: String, cityName: String) {
        downloadStatusMap[cityCode] = 0 // LOADING
        downloadProgressMap[cityCode] = 0

        // 模拟下载进度
        Thread {
            for (progress in 0..100 step 10) {
                Thread.sleep(500)
                downloadProgressMap[cityCode] = progress
                downloadStatusMap[cityCode] = if (progress < 100) 0 else 4 // LOADING or SUCCESS
                
                mainHandler.post {
                    eventSink?.success(mapOf(
                        "cityCode" to cityCode,
                        "cityName" to cityName,
                        "progress" to progress,
                        "status" to downloadStatusMap[cityCode]
                    ))
                }
            }
            if (downloadProgressMap[cityCode] == 100) {
                downloadedCities.add(cityCode)
            }
        }.start()
    }

    private fun getMockCityList(): List<Map<String, Any>> {
        return listOf(
            mapOf(
                "cityCode" to "0571",
                "cityName" to "杭州市",
                "size" to 256000000L,
                "downloadStatus" to if ("0571" in downloadedCities) 4 else -1
            ),
            mapOf(
                "cityCode" to "021",
                "cityName" to "上海市",
                "size" to 512000000L,
                "downloadStatus" to if ("021" in downloadedCities) 4 else -1
            ),
            mapOf(
                "cityCode" to "010",
                "cityName" to "北京市",
                "size" to 512000000L,
                "downloadStatus" to if ("010" in downloadedCities) 4 else -1
            )
        )
    }

    private fun getMockDownloadedCities(): List<Map<String, Any>> {
        return downloadedCities.map { cityCode ->
            val cityInfo = getMockCityList().find { it["cityCode"] == cityCode }
            cityInfo ?: mapOf(
                "cityCode" to cityCode,
                "cityName" to "未知城市",
                "size" to 0L,
                "downloadStatus" to 4
            )
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}
