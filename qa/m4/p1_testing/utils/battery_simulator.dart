// qa/m4/p1_testing/utils/battery_simulator.dart
// 电池模拟器 - 用于模拟各种电量场景

/// 电池状态枚举
enum BatteryState {
  charging,     // 充电中
  discharging,  // 放电中
  full,         // 充满
  low,          // 低电量
  critical,     // 极低电量
}

/// 电池模拟器
class BatterySimulator {
  int _batteryLevel = 100;
  BatteryState _batteryState = BatteryState.full;
  bool _powerSaveMode = false;

  /// 获取当前电量
  int get batteryLevel => _batteryLevel;

  /// 获取电池状态
  BatteryState get batteryState => _batteryState;

  /// 是否启用省电模式
  bool get powerSaveModeEnabled => _powerSaveMode;

  /// 设置电量水平
  Future<void> setBatteryLevel(int level) async {
    if (level < 0) level = 0;
    if (level > 100) level = 100;
    
    _batteryLevel = level;
    _updateBatteryState();
    _updatePowerSaveMode();
    
    // 模拟设置延迟
    await Future.delayed(Duration(milliseconds: 50));
  }

  /// 启用/禁用省电模式
  Future<void> enablePowerSaveMode(bool enabled) async {
    _powerSaveMode = enabled;
    await Future.delayed(Duration(milliseconds: 50));
  }

  /// 恢复默认状态
  Future<void> restore() async {
    _batteryLevel = 100;
    _batteryState = BatteryState.full;
    _powerSaveMode = false;
    await Future.delayed(Duration(milliseconds: 50));
  }

  /// 更新电池状态
  void _updateBatteryState() {
    if (_batteryLevel >= 100) {
      _batteryState = BatteryState.full;
    } else if (_batteryLevel <= 5) {
      _batteryState = BatteryState.critical;
    } else if (_batteryLevel <= 20) {
      _batteryState = BatteryState.low;
    } else {
      _batteryState = BatteryState.discharging;
    }
  }

  /// 更新省电模式状态
  void _updatePowerSaveMode() {
    // 电量低于20%自动启用省电模式
    if (_batteryLevel <= 20 && !_powerSaveMode) {
      _powerSaveMode = true;
    }
  }

  /// 模拟电量消耗
  Future<void> simulateDischarge(int amount) async {
    await setBatteryLevel(_batteryLevel - amount);
  }

  /// 模拟电量增加（充电）
  Future<void> simulateCharge(int amount) async {
    await setBatteryLevel(_batteryLevel + amount);
  }

  /// 检查是否为低电量
  bool get isLowBattery => _batteryLevel <= 20;

  /// 检查是否为极低电量
  bool get isCriticalBattery => _batteryLevel <= 5;

  /// 获取电量状态描述
  String get batteryStatusDescription {
    if (_batteryLevel >= 80) return '充足';
    if (_batteryLevel >= 50) return '良好';
    if (_batteryLevel >= 20) return '一般';
    if (_batteryLevel >= 10) return '低电量';
    return '极低电量';
  }

  /// 获取预估可用时间（分钟）
  int get estimatedRemainingMinutes {
    // 基于电量水平和使用模式的简单估算
    final baseMinutes = _batteryLevel * 3; // 假设1%电量约3分钟
    
    if (_powerSaveMode) {
      return (baseMinutes * 1.5).toInt(); // 省电模式延长50%
    }
    
    return baseMinutes;
  }
}
