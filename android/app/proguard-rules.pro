# 高德地图 SDK ProGuard 规则
# 保留所有高德地图相关类，防止 JNI 找不到

# 保留高德地图所有类
-keep class com.amap.api.** { *; }
-keep class com.autonavi.** { *; }
-keep class com.loc.** { *; }

# 保留高德定位服务
-keep class com.amap.api.location.** { *; }

# 保留高德地图服务
-keep class com.amap.api.maps.** { *; }
-keep class com.amap.api.mapcore.** { *; }

# 保留高德搜索服务
-keep class com.amap.api.services.** { *; }

# 保留高德导航服务
-keep class com.amap.api.navi.** { *; }

# 保留 Native 方法
-keepclasseswithmembernames class * {
    native <methods>;
}
