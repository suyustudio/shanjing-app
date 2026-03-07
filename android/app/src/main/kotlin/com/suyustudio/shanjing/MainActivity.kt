package com.suyustudio.shanjing

import android.os.Bundle
import com.amap.api.maps.MapsInitializer
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // ⚠️ 必须在 super.onCreate 之前调用隐私合规接口
        // 参数含义：context, 是否包含高德隐私政策, 是否已弹窗展示
        MapsInitializer.updatePrivacyShow(this, true, true)
        // 参数含义：context, 是否已取得用户同意
        MapsInitializer.updatePrivacyAgree(this, true)
        
        super.onCreate(savedInstanceState)
    }
}
