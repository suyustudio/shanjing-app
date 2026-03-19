import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../constants/design_system.dart';

/// 天气预警服务
/// 提供天气查询和恶劣天气预警功能
/// 支持高德天气API或和风天气API（当前为模拟实现，可替换为真实API）
class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  // 高德天气API配置（需要替换为真实API Key）
  static const String _amapWeatherUrl = 'https://restapi.amap.com/v3/weather/weatherInfo';
  static const String _amapApiKey = 'YOUR_AMAP_API_KEY'; // 替换为真实API Key

  // 缓存时间（5分钟）
  static const Duration _cacheDuration = Duration(minutes: 5);

  // 天气数据缓存
  WeatherData? _cachedWeather;
  DateTime? _lastFetchTime;
  String? _cachedLocation;

  /// 获取当前天气
  /// [latitude] 纬度
  /// [longitude] 经度
  /// [cityCode] 城市编码（可选，用于高德API）
  Future<WeatherData> getCurrentWeather({
    required double latitude,
    required double longitude,
    String? cityCode,
  }) async {
    final locationKey = '${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';
    
    // 检查缓存
    if (_cachedWeather != null && 
        _cachedLocation == locationKey &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedWeather!;
    }

    try {
      // 实际项目中调用真实API
      // final weather = await _fetchFromAmap(cityCode: cityCode);
      
      // 当前使用模拟数据（演示用途）
      final weather = await _fetchMockWeather(latitude: latitude, longitude: longitude);
      
      _cachedWeather = weather;
      _cachedLocation = locationKey;
      _lastFetchTime = DateTime.now();
      
      return weather;
    } catch (e) {
      // 返回默认天气数据
      return WeatherData.defaultWeather();
    }
  }

  /// 从高德API获取天气（实际实现）
  Future<WeatherData> _fetchFromAmap({String? cityCode}) async {
    if (cityCode == null) {
      throw Exception('City code is required for Amap weather API');
    }

    final url = Uri.parse(
      '$_amapWeatherUrl?key=$_amapApiKey&city=$cityCode&extensions=base',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == '1' && data['lives'] != null && data['lives'].isNotEmpty) {
        final live = data['lives'][0];
        return WeatherData(
          temperature: double.tryParse(live['temperature']) ?? 20,
          weather: live['weather'] ?? '晴',
          humidity: int.tryParse(live['humidity']) ?? 50,
          windDirection: live['winddirection'] ?? '北',
          windPower: live['windpower'] ?? '1',
          reportTime: DateTime.now(),
        );
      }
    }
    
    throw Exception('Failed to fetch weather from Amap');
  }

  /// 获取模拟天气数据（演示/测试用途）
  Future<WeatherData> _fetchMockWeather({
    required double latitude,
    required double longitude,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 基于位置生成不同的天气（演示不同区域的天气）
    final random = Random(latitude.hashCode + longitude.hashCode + DateTime.now().hour);
    
    // 可能的天气类型
    final weatherTypes = [
      ('晴', WeatherType.sunny),
      ('多云', WeatherType.cloudy),
      ('阴', WeatherType.overcast),
      ('小雨', WeatherType.lightRain),
      ('中雨', WeatherType.moderateRain),
      ('雷阵雨', WeatherType.thunderstorm),
      ('大风', WeatherType.windy),
    ];
    
    final selectedWeather = weatherTypes[random.nextInt(weatherTypes.length)];
    
    // 生成合理温度（根据纬度粗略估算）
    final baseTemp = 25 - (latitude - 30).abs() * 0.5;
    final temperature = baseTemp + random.nextInt(10) - 5;
    
    // 生成风力等级
    final windPower = selectedWeather.$2 == WeatherType.windy 
        ? random.nextInt(4) + 6 // 大风时 6-9级
        : random.nextInt(4) + 1; // 正常 1-4级
    
    return WeatherData(
      temperature: temperature,
      weather: selectedWeather.$1,
      weatherType: selectedWeather.$2,
      humidity: random.nextInt(60) + 30,
      windDirection: ['北', '东北', '东', '东南', '南', '西南', '西', '西北'][random.nextInt(8)],
      windPower: '$windPower级',
      windLevel: windPower,
      reportTime: DateTime.now(),
    );
  }

  /// 检查是否为恶劣天气
  /// 返回恶劣天气警告列表
  List<WeatherAlert> checkSevereWeather(WeatherData weather) {
    final alerts = <WeatherAlert>[];

    // 暴雨预警
    if (weather.weatherType == WeatherType.moderateRain ||
        weather.weatherType == WeatherType.heavyRain ||
        weather.weatherType == WeatherType.thunderstorm) {
      alerts.add(WeatherAlert(
        type: AlertType.heavyRain,
        title: '暴雨预警',
        message: '当前地区有${weather.weather}，路面湿滑，请注意防滑，避免涉水路段',
        severity: AlertSeverity.high,
        icon: Icons.water_drop,
      ));
    }

    // 雷电预警
    if (weather.weatherType == WeatherType.thunderstorm) {
      alerts.add(WeatherAlert(
        type: AlertType.thunderstorm,
        title: '雷电预警',
        message: '有雷电天气，请避免在开阔高地和树下停留，谨慎使用电子设备',
        severity: AlertSeverity.high,
        icon: Icons.flash_on,
      ));
    }

    // 大风预警
    if (weather.windLevel >= 6) {
      alerts.add(WeatherAlert(
        type: AlertType.strongWind,
        title: '大风预警',
        message: '当前风力${weather.windPower}，高空和山脊路段行走需格外小心',
        severity: weather.windLevel >= 8 ? AlertSeverity.high : AlertSeverity.medium,
        icon: Icons.air,
      ));
    }

    // 高温预警
    if (weather.temperature >= 35) {
      alerts.add(WeatherAlert(
        type: AlertType.highTemp,
        title: '高温预警',
        message: '当前气温${weather.temperature.toStringAsFixed(0)}℃，注意防暑降温，多补充水分',
        severity: weather.temperature >= 38 ? AlertSeverity.high : AlertSeverity.medium,
        icon: Icons.wb_sunny,
      ));
    }

    // 低温预警
    if (weather.temperature <= 5) {
      alerts.add(WeatherAlert(
        type: AlertType.lowTemp,
        title: '低温预警',
        message: '当前气温${weather.temperature.toStringAsFixed(0)}℃，注意保暖，防止失温',
        severity: weather.temperature <= 0 ? AlertSeverity.high : AlertSeverity.medium,
        icon: Icons.ac_unit,
      ));
    }

    return alerts;
  }

  /// 获取天气建议
  String getWeatherAdvice(WeatherData weather) {
    if (weather.weatherType == WeatherType.sunny && weather.temperature < 30) {
      return '天气晴好，适合徒步，注意防晒';
    } else if (weather.weatherType == WeatherType.cloudy) {
      return '多云天气，体感舒适，是徒步的好时机';
    } else if (weather.weatherType == WeatherType.lightRain) {
      return '有小雨，路面湿滑，建议携带雨具，穿防滑鞋';
    } else if (weather.weatherType == WeatherType.thunderstorm) {
      return '雷电天气，建议改期出行，或在安全地点躲避';
    } else if (weather.windLevel >= 6) {
      return '风力较大，注意防风，避免在高处长时间停留';
    } else if (weather.temperature >= 35) {
      return '高温炎热，建议减少户外运动，多补充水分';
    } else {
      return '天气适宜，祝徒步愉快';
    }
  }

  /// 清除缓存
  void clearCache() {
    _cachedWeather = null;
    _cachedLocation = null;
    _lastFetchTime = null;
  }
}

/// 天气数据模型
class WeatherData {
  final double temperature; // 温度（摄氏度）
  final String weather; // 天气描述
  final WeatherType weatherType; // 天气类型
  final int humidity; // 湿度（%）
  final String windDirection; // 风向
  final String windPower; // 风力描述
  final int windLevel; // 风力等级（1-12）
  final DateTime reportTime; // 报告时间

  WeatherData({
    required this.temperature,
    required this.weather,
    this.weatherType = WeatherType.unknown,
    required this.humidity,
    required this.windDirection,
    required this.windPower,
    this.windLevel = 1,
    required this.reportTime,
  });

  /// 默认天气数据
  factory WeatherData.defaultWeather() {
    return WeatherData(
      temperature: 20,
      weather: '晴',
      weatherType: WeatherType.sunny,
      humidity: 50,
      windDirection: '北',
      windPower: '1级',
      windLevel: 1,
      reportTime: DateTime.now(),
    );
  }

  /// 获取天气图标
  IconData get icon {
    switch (weatherType) {
      case WeatherType.sunny:
        return Icons.wb_sunny;
      case WeatherType.cloudy:
        return Icons.wb_cloudy;
      case WeatherType.overcast:
        return Icons.cloud;
      case WeatherType.lightRain:
      case WeatherType.moderateRain:
      case WeatherType.heavyRain:
        return Icons.water_drop;
      case WeatherType.thunderstorm:
        return Icons.flash_on;
      case WeatherType.windy:
        return Icons.air;
      case WeatherType.snowy:
        return Icons.ac_unit;
      default:
        return Icons.wb_cloudy;
    }
  }

  /// 获取天气对应颜色
  Color getColor(BuildContext context) {
    switch (weatherType) {
      case WeatherType.sunny:
        return Colors.orange;
      case WeatherType.cloudy:
        return DesignSystem.getInfo(context);
      case WeatherType.overcast:
        return DesignSystem.getTextSecondary(context);
      case WeatherType.lightRain:
      case WeatherType.moderateRain:
      case WeatherType.heavyRain:
        return DesignSystem.getInfo(context);
      case WeatherType.thunderstorm:
        return DesignSystem.getError(context);
      case WeatherType.windy:
        return DesignSystem.getWarning(context);
      case WeatherType.snowy:
        return Colors.lightBlue;
      default:
        return DesignSystem.getTextSecondary(context);
    }
  }

  /// 是否为恶劣天气
  bool get isSevere {
    return weatherType == WeatherType.thunderstorm ||
           weatherType == WeatherType.heavyRain ||
           windLevel >= 6 ||
           temperature >= 35 ||
           temperature <= 0;
  }
}

/// 天气类型枚举
enum WeatherType {
  sunny, // 晴
  cloudy, // 多云
  overcast, // 阴
  lightRain, // 小雨
  moderateRain, // 中雨
  heavyRain, // 大雨/暴雨
  thunderstorm, // 雷阵雨
  windy, // 大风
  snowy, // 雪
  unknown, // 未知
}

/// 天气预警
class WeatherAlert {
  final AlertType type;
  final String title;
  final String message;
  final AlertSeverity severity;
  final IconData icon;

  WeatherAlert({
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
    required this.icon,
  });

  /// 获取严重度颜色
  Color getSeverityColor(BuildContext context) {
    switch (severity) {
      case AlertSeverity.low:
        return DesignSystem.getInfo(context);
      case AlertSeverity.medium:
        return DesignSystem.getWarning(context);
      case AlertSeverity.high:
        return DesignSystem.getError(context);
      default:
        return DesignSystem.getInfo(context);
    }
  }
}

/// 预警类型
enum AlertType {
  heavyRain, // 暴雨
  thunderstorm, // 雷电
  strongWind, // 大风
  highTemp, // 高温
  lowTemp, // 低温
  airQuality, // 空气质量
  other, // 其他
}

/// 严重度等级
enum AlertSeverity {
  low, // 低
  medium, // 中
  high, // 高
}

// 引入图标
import 'package:flutter/material.dart';
