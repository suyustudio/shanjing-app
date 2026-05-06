plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.suyustudio.shanjing"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.suyustudio.shanjing"
        minSdk = 24
        targetSdk = 34  // 使用 API 34 避免 Android 16 对 Runtime.nativeLoad 的限制
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndk {
            abiFilters += listOf("arm64-v8a", "armeabi-v7a", "x86_64")
        }
    }

    // 签名配置
    // 调试版 SHA1: 57:E4:95:83:7A:4D:C8:A9:BE:A9:F1:A2:A9:03:11:57:93:28:4F:6C
    // 发布版 SHA1: 1E:FA:63:18:EC:48:1D:11:12:3F:FA:25:9A:80:D8:E3:8B:DC:A8:7F
    val debugKeystore = file("keystores/debug.keystore")
    val releaseKeystore = file("keystores/release.keystore")

    buildTypes {
        debug {
            signingConfig = if (debugKeystore.exists()) {
                signingConfigs.create("debug_custom") {
                    storeFile = debugKeystore
                    storePassword = "android"
                    keyAlias = "androiddebugkey"
                    keyPassword = "android"
                }
            } else {
                signingConfigs.getByName("debug")
            }
        }
        release {
            signingConfig = if (releaseKeystore.exists()) {
                signingConfigs.create("release") {
                    storeFile = releaseKeystore
                    storePassword = System.getenv("KEYSTORE_PASSWORD") ?: "shanjing"
                    keyAlias = System.getenv("KEY_ALIAS") ?: "shanjing"
                    keyPassword = System.getenv("KEY_PASSWORD") ?: "shanjing"
                }
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.amap.api:3dmap:10.0.600")
}
