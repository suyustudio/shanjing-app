package com.suyustudio.shanjing

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    
    private var offlineMapPlugin: OfflineMapPlugin? = null
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 注册离线地图插件
        offlineMapPlugin = OfflineMapPlugin.getInstance(this, flutterEngine)
    }
    
    override fun onDestroy() {
        // 清理离线地图插件资源
        offlineMapPlugin?.destroy()
        super.onDestroy()
    }
}
