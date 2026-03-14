package com.suyustudio.shanjing

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.amap.api.maps.offlinemap.OfflineMapCity
import com.amap.api.maps.offlinemap.OfflineMapManager
import com.amap.api.maps.offlinemap.OfflineMapStatus
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * 离线地图插件 - 桥接高德地图离线SDK和Flutter
 */
class OfflineMapPlugin private constructor(
    private val context: Context,
    flutterEngine: FlutterEngine
) : MethodChannel.MethodCallHandler, 
    EventChannel.StreamHandler,
    OfflineMapManager.OfflineMapDownloadListener {

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
    private var offlineMapManager: OfflineMapManager? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    // 下载状态映射
    private val downloadProgressMap = mutableMapOf<String, Int>()
    private val downloadStatusMap = mutableMapOf<String, Int>()

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    /**
     * 初始化离线地图管理器
     */
    private fun initialize(): Boolean {
        return try {
            if (offlineMapManager == null) {
                offlineMapManager = OfflineMapManager(context, this)
            }
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    /**
     * 获取离线地图城市列表
     */
    private fun getOfflineCityList(): List<Map<String, Any?>> {
        val cityList = offlineMapManager?.offlineMapCityList ?: return emptyList()
        return cityList.map { city -> convertCityToMap(city) }
    }

    /**
     * 获取热门城市列表
     */
    private fun getHotCityList(): List<Map<String, Any?>> {
        val hotCities = offlineMapManager?.hotCityList ?: return emptyList()
        return hotCities.map { city -> convertCityToMap(city) }
    }

    /**
     * 获取已下载的离线地图列表
     */
    private fun getDownloadedOfflineMapList(): List<Map<String, Any?>> {
        val downloadedList = offlineMapManager?.downloadOfflineMapCityList ?: return emptyList()
        return downloadedList.map { city -> convertCityToMap(city) }
    }

    /**
     * 开始下载离线地图
     */
    private fun downloadOfflineMap(cityCode: String, cityName: String): Boolean {
        return try {
            // 尝试通过城市编码下载
            val code = cityCode.toIntOrNull()
            if (code != null) {
                offlineMapManager?.downloadByCityCode(cityCode)
            } else {
                // 如果cityCode不是数字，则使用城市名称下载
                offlineMapManager?.downloadByCityName(cityName)
            }
            downloadStatusMap[cityCode] = OfflineMapStatus.LOADING
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    /**
     * 暂停下载
     */
    private fun pauseDownload(cityCode: String): Boolean {
        return try {
            offlineMapManager?.pause()
            downloadStatusMap[cityCode] = OfflineMapStatus.PAUSE
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    /**
     * 继续下载（高德SDK使用相同的start方法恢复下载）
     */
    private fun resumeDownload(cityCode: String): Boolean {
        return try {
            // 高德SDK通过重新调用download来继续下载
            val code = cityCode.toIntOrNull()
            if (code != null) {
                offlineMapManager?.downloadByCityCode(cityCode)
            }
            downloadStatusMap[cityCode] = OfflineMapStatus.LOADING
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    /**
     * 删除离线地图
     */
    private fun deleteOfflineMap(cityCode: String): Boolean {
        return try {
            val code = cityCode.toIntOrNull()
            if (code != null) {
                offlineMapManager?.remove(code)
                downloadProgressMap.remove(cityCode)
                downloadStatusMap.remove(cityCode)
                true
            } else {
                false
            }
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    /**
     * 检查城市是否已下载
     */
    private fun isCityDownloaded(cityCode: String): Boolean {
        val downloadedList = offlineMapManager?.downloadOfflineMapCityList ?: return false
        return downloadedList.any { it.code == cityCode }
    }

    /**
     * 获取下载进度
     */
    private fun getDownloadProgress(cityCode: String): Int {
        return downloadProgressMap[cityCode] ?: 0
    }

    /**
     * 清除所有离线地图
     */
    private fun clearAllOfflineMaps(): Boolean {
        return try {
            val downloadedList = offlineMapManager?.downloadOfflineMapCityList ?: emptyList()
            downloadedList.forEach { city ->
                try {
                    val code = city.code.toIntOrNull()
                    if (code != null) {
                        offlineMapManager?.remove(code)
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
            downloadProgressMap.clear()
            downloadStatusMap.clear()
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    /**
     * 更新离线地图
     */
    private fun updateOfflineMap(cityCode: String): Boolean {
        return try {
            val code = cityCode.toIntOrNull() ?: return false
            offlineMapManager?.updateOfflineCityByCode(code)
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    /**
     * 将OfflineMapCity转换为Map
     */
    private fun convertCityToMap(city: OfflineMapCity): Map<String, Any?> {
        return mapOf(
            "cityCode" to city.code,
            "cityName" to city.city,
            "cityPinyin" to city.pinyin,
            "dataSize" to city.size,
            "downloadSize" to city.downLoadSize,
            "ratio" to getDownloadProgress(city.code),
            "status" to (downloadStatusMap[city.code] ?: city.state),
            "update" to city.isUpdate,
            "version" to city.version
        )
    }

    // ==================== MethodChannel.MethodCallHandler ====================

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                result.success(initialize())
            }
            "getOfflineCityList" -> {
                result.success(getOfflineCityList())
            }
            "getHotCityList" -> {
                result.success(getHotCityList())
            }
            "getDownloadedOfflineMapList" -> {
                result.success(getDownloadedOfflineMapList())
            }
            "downloadOfflineMap" -> {
                val cityCode = call.argument<String>("cityCode") ?: ""
                val cityName = call.argument<String>("cityName") ?: ""
                result.success(downloadOfflineMap(cityCode, cityName))
            }
            "pauseDownload" -> {
                val cityCode = call.argument<String>("cityCode") ?: ""
                result.success(pauseDownload(cityCode))
            }
            "resumeDownload" -> {
                val cityCode = call.argument<String>("cityCode") ?: ""
                result.success(resumeDownload(cityCode))
            }
            "deleteOfflineMap" -> {
                val cityCode = call.argument<String>("cityCode") ?: ""
                result.success(deleteOfflineMap(cityCode))
            }
            "isCityDownloaded" -> {
                val cityCode = call.argument<String>("cityCode") ?: ""
                result.success(isCityDownloaded(cityCode))
            }
            "getDownloadProgress" -> {
                val cityCode = call.argument<String>("cityCode") ?: ""
                result.success(getDownloadProgress(cityCode))
            }
            "clearAllOfflineMaps" -> {
                result.success(clearAllOfflineMaps())
            }
            "updateOfflineMap" -> {
                val cityCode = call.argument<String>("cityCode") ?: ""
                result.success(updateOfflineMap(cityCode))
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    // ==================== EventChannel.StreamHandler ====================

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    // ==================== OfflineMapDownloadListener ====================

    override fun onDownload(status: Int, completeCode: Int, downName: String?) {
        // 通过名称查找对应的城市编码
        val cityList = offlineMapManager?.offlineMapCityList ?: emptyList()
        val city = cityList.find { it.city == downName }
        val cityCode = city?.code ?: downName ?: ""
        
        // 更新进度缓存
        downloadProgressMap[cityCode] = completeCode
        downloadStatusMap[cityCode] = status

        // 发送事件到Flutter
        mainHandler.post {
            eventSink?.success(mapOf(
                "cityCode" to cityCode,
                "cityName" to downName,
                "status" to status,
                "progress" to completeCode,
                "completeCode" to completeCode
            ))
        }
    }

    override fun onCheckUpdate(hasUpdate: Boolean, downName: String?) {
        // 检查更新回调
        mainHandler.post {
            eventSink?.success(mapOf(
                "type" to "checkUpdate",
                "cityName" to downName,
                "hasUpdate" to hasUpdate
            ))
        }
    }

    override fun onRemove(success: Boolean, downName: String?, code: String?) {
        // 删除回调
        mainHandler.post {
            eventSink?.success(mapOf(
                "type" to "remove",
                "cityName" to downName,
                "cityCode" to code,
                "success" to success
            ))
        }
    }

    /**
     * 销毁资源
     */
    fun destroy() {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSink = null
        offlineMapManager = null
        instance = null
    }
}
