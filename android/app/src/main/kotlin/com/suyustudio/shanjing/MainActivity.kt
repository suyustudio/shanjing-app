package com.suyustudio.shanjing

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    
    private var offlineMapPlugin: OfflineMapPlugin? = null
    private val TAG = "MainActivity"
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 保持启动背景直到 Flutter 渲染第一帧
        Handler(Looper.getMainLooper()).postDelayed({
            flutterEngine?.let { engine ->
                try {
                    engine.renderer.startRenderingToSurface(null)
                } catch (e: Exception) {
                    Log.w(TAG, "Renderer start warning: ${e.message}")
                }
            }
        }, 100)
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 注册离线地图插件（带错误处理，防止插件失败导致黑屏）
        try {
            offlineMapPlugin = OfflineMapPlugin.getInstance(this, flutterEngine)
            Log.d(TAG, "OfflineMapPlugin registered successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to register OfflineMapPlugin: ${e.message}")
            // 插件注册失败不影响主应用运行
        }
    }
    
    override fun onDestroy() {
        try {
            offlineMapPlugin?.destroy()
        } catch (e: Exception) {
            Log.w(TAG, "Error destroying plugin: ${e.message}")
        }
        super.onDestroy()
    }
}
