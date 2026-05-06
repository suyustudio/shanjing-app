package com.suyustudio.shanjing;

import android.os.Build;

/**
 * 高德地图原生库预加载器
 * 解决 Android 16+ 上 libAMapOpenMap.so 无法通过 Runtime.nativeLoad() 动态加载
 * 其他原生库的问题。
 *
 * 原理：在 AMap Flutter 插件尝试加载原生库之前，先使用 System.loadLibrary()
 * 显式加载所有高德原生库。这样当 libAMapOpenMap.so 尝试通过 Runtime.nativeLoad()
 * 加载它们时，它们已经存在于进程中，不会触发 Android 16 的访问限制。
 */
public class AmapNativePreloader {

    private static final String[] AMAP_LIBRARIES = {
        "AMapSDK_MAP_v10_0_600",
        "AMapOpenMap",
        "AMap"
    };

    private static boolean sLoaded = false;

    /**
     * 预加载所有高德地图原生库
     * 应在 Application.onCreate() 或 Activity.onCreate() 中尽早调用
     */
    public static void preload() {
        if (sLoaded) return;
        sLoaded = true;

        for (String libName : AMAP_LIBRARIES) {
            try {
                System.loadLibrary(libName);
            } catch (UnsatisfiedLinkError e) {
            }
        }
    }
}
