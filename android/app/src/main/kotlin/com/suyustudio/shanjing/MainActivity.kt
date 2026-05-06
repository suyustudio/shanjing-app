package com.suyustudio.shanjing

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        // 预加载高德地图原生库，解决 Android 16+ 上 Runtime.nativeLoad 限制
        AmapNativePreloader.preload()
        super.onCreate(savedInstanceState)
    }
}
