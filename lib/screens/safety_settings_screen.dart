import 'package:flutter/material.dart';
import '../../services/offline_cache_service.dart';
import '../../services/smart_eta_service.dart';
import '../../services/volume_key_service.dart';
import '../../constants/design_system.dart';

/// 安全设置页面
/// 配置SOS、Lifeline、音量键触发等安全功能
class SafetySettingsScreen extends StatefulWidget {
  const SafetySettingsScreen({super.key});

  @override
  State<SafetySettingsScreen> createState() => _SafetySettingsScreenState();
}

class _SafetySettingsScreenState extends State<SafetySettingsScreen> {
  // 服务实例
  final _offlineCacheService = OfflineCacheService();
  final _smartEtaService = SmartEtaService();
  final _volumeKeyService = VolumeKeyService();

  // 状态
  bool _isLoading = true;
  bool _volumeKeyEnabled = false;
  bool _volumeKeyAvailable = true;
  SmartEtaSettings _etaSettings = SmartEtaSettings();
  OfflineCacheStats? _cacheStats;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      await _volumeKeyService.initialize();
      await _smartEtaService.initialize();
      await _offlineCacheService.initialize();

      setState(() {
        _volumeKeyEnabled = _volumeKeyService.isEnabled;
        _volumeKeyAvailable = true; // 实际项目中检查设备兼容性
        _etaSettings = _smartEtaService.settings;
      });

      await _loadCacheStats();
    } catch (e) {
      // 错误处理
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCacheStats() async {
    final stats = await _offlineCacheService.getStats();
    setState(() => _cacheStats = stats);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        title: const Text('安全设置'),
        backgroundColor: Colors.white,
        foregroundColor: DesignSystem.textPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SOS快捷触发
                  _buildSectionHeader('SOS 快捷触发'),
                  _buildVolumeKeyCard(),
                  
                  const SizedBox(height: 8),
                  
                  // 智能ETA设置
                  _buildSectionHeader('智能ETA设置'),
                  _buildEtaSettingsCard(),
                  
                  const SizedBox(height: 8),
                  
                  // 离线缓存管理
                  _buildSectionHeader('离线缓存管理'),
                  _buildOfflineCacheCard(),
                  
                  const SizedBox(height: 32),
                  
                  // 提示信息
                  _buildInfoCard(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: DesignSystem.textSecondary,
        ),
      ),
    );
  }

  // ========== 音量键触发卡片 ==========
  Widget _buildVolumeKeyCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 主开关
          SwitchListTile(
            title: const Text(
              '音量键快捷触发',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              '连按音量下键3次触发SOS',
              style: TextStyle(
                fontSize: 13,
                color: DesignSystem.textSecondary,
              ),
            ),
            value: _volumeKeyEnabled,
            onChanged: _volumeKeyAvailable
                ? (value) => _toggleVolumeKey(value)
                : null,
            activeColor: DesignSystem.primary,
          ),
          
          if (_volumeKeyEnabled) ...[
            const Divider(height: 1),
            
            // 测试按钮
            ListTile(
              title: const Text('测试触发'),
              subtitle: const Text('模拟连按3次音量下键'),
              trailing: ElevatedButton(
                onPressed: _testVolumeKeyTrigger,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('测试'),
              ),
            ),
            
            // 说明
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '注意：此功能会消耗更多电量，且在某些设备上可能无法正常工作',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          if (!_volumeKeyAvailable)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.grey.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '您的设备不支持此功能',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ========== 智能ETA设置卡片 ==========
  Widget _buildEtaSettingsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 安全系数滑块
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '安全缓冲时间',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(_etaSettings.safetyBuffer * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: DesignSystem.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '在估算时间上增加的缓冲时间',
                  style: TextStyle(
                    fontSize: 13,
                    color: DesignSystem.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _etaSettings.safetyBuffer,
                  min: 0.0,
                  max: 0.5,
                  divisions: 10,
                  label: '${(_etaSettings.safetyBuffer * 100).toInt()}%',
                  onChanged: (value) => _updateSafetyBuffer(value),
                  activeColor: DesignSystem.primary,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('无缓冲', style: TextStyle(fontSize: 12, color: DesignSystem.textSecondary)),
                    Text('50%缓冲', style: TextStyle(fontSize: 12, color: DesignSystem.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // 个人速度调整
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '个人速度偏好',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _getPaceText(_etaSettings.paceAdjustment),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: DesignSystem.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '根据您的徒步习惯调整估算',
                  style: TextStyle(
                    fontSize: 13,
                    color: DesignSystem.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _etaSettings.paceAdjustment,
                  min: -0.3,
                  max: 0.3,
                  divisions: 6,
                  label: _getPaceText(_etaSettings.paceAdjustment),
                  onChanged: (value) => _updatePaceAdjustment(value),
                  activeColor: DesignSystem.primary,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('偏快', style: TextStyle(fontSize: 12, color: DesignSystem.textSecondary)),
                    Text('标准', style: TextStyle(fontSize: 12, color: DesignSystem.textSecondary)),
                    Text('偏慢', style: TextStyle(fontSize: 12, color: DesignSystem.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // 开关选项
          SwitchListTile(
            title: const Text('动态ETA调整'),
            subtitle: const Text('根据当前速度实时调整预计到达时间'),
            value: _etaSettings.enableDynamicAdjustment,
            onChanged: (value) => _updateEtaSettings(
              _etaSettings.copyWith(enableDynamicAdjustment: value),
            ),
            activeColor: DesignSystem.primary,
          ),
          
          SwitchListTile(
            title: const Text('考虑天气因素'),
            subtitle: const Text('根据天气条件调整估算时间'),
            value: _etaSettings.enableWeatherFactor,
            onChanged: (value) => _updateEtaSettings(
              _etaSettings.copyWith(enableWeatherFactor: value),
            ),
            activeColor: DesignSystem.primary,
          ),
          
          const Divider(height: 1),
          
          // 清除历史记录
          ListTile(
            title: Text(
              '清除历史记录',
              style: TextStyle(color: Colors.red.shade600),
            ),
            subtitle: const Text('删除所有ETA历史数据'),
            trailing: Icon(Icons.delete_outline, color: Colors.red.shade400),
            onTap: _showClearHistoryDialog,
          ),
        ],
      ),
    );
  }

  // ========== 离线缓存卡片 ==========
  Widget _buildOfflineCacheCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 统计信息
          if (_cacheStats != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatRow('待发送', _cacheStats!.pendingCount.toString(), Colors.orange),
                  const SizedBox(height: 8),
                  _buildStatRow('已发送', _cacheStats!.sentCount.toString(), Colors.green),
                  const SizedBox(height: 8),
                  _buildStatRow('发送失败', _cacheStats!.failedCount.toString(), Colors.red),
                  const SizedBox(height: 8),
                  _buildStatRow('已过期', _cacheStats!.expiredCount.toString(), Colors.grey),
                ],
              ),
            ),
          
          const Divider(height: 1),
          
          // 立即补发按钮
          ListTile(
            leading: Icon(Icons.send_outlined, color: DesignSystem.primary),
            title: const Text('立即补发'),
            subtitle: const Text('尝试发送所有待发送的SOS事件'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _retryFailedEvents,
          ),
          
          const Divider(height: 1),
          
          // 清理缓存按钮
          ListTile(
            leading: Icon(Icons.cleaning_services_outlined, color: Colors.orange),
            title: const Text('清理过期缓存'),
            subtitle: const Text('删除超过7天的缓存数据'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _cleanupExpiredCache,
          ),
          
          const Divider(height: 1),
          
          // 清除所有缓存
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: Colors.red),
            title: Text(
              '清除所有缓存',
              style: TextStyle(color: Colors.red.shade600),
            ),
            subtitle: const Text('删除所有离线缓存数据'),
            trailing: Icon(Icons.chevron_right, color: Colors.red.shade400),
            onTap: _showClearAllCacheDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // ========== 信息卡片 ==========
  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                '安全提示',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• SOS功能仅在真正紧急时使用\n'
            '• 建议提前设置好紧急联系人\n'
            '• 离线缓存数据会在网络恢复后自动补发\n'
            '• 如遇生命危险，请直接拨打 110/120',
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }

  // ========== 操作处理 ==========
  
  Future<void> _toggleVolumeKey(bool enabled) async {
    final success = await _volumeKeyService.setEnabled(enabled);
    if (success) {
      setState(() => _volumeKeyEnabled = enabled);
    } else {
      _showSnackBar('设置失败，请检查权限');
    }
  }

  void _testVolumeKeyTrigger() {
    // 模拟3次按键
    _volumeKeyService.simulateKeyPress();
    Future.delayed(const Duration(milliseconds: 500), () {
      _volumeKeyService.simulateKeyPress();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      _volumeKeyService.simulateKeyPress();
    });
    
    _showSnackBar('已模拟3次按键，如果功能正常会触发SOS');
  }

  Future<void> _updateSafetyBuffer(double value) async {
    final newSettings = _etaSettings.copyWith(safetyBuffer: value);
    await _updateEtaSettings(newSettings);
  }

  Future<void> _updatePaceAdjustment(double value) async {
    final newSettings = _etaSettings.copyWith(paceAdjustment: value);
    await _updateEtaSettings(newSettings);
  }

  Future<void> _updateEtaSettings(SmartEtaSettings settings) async {
    final success = await _smartEtaService.saveSettings(settings);
    if (success) {
      setState(() => _etaSettings = settings);
    }
  }

  String _getPaceText(double adjustment) {
    if (adjustment < -0.15) return '较快';
    if (adjustment < -0.05) return '稍快';
    if (adjustment > 0.15) return '较慢';
    if (adjustment > 0.05) return '稍慢';
    return '标准';
  }

  Future<void> _retryFailedEvents() async {
    _showLoadingDialog('正在补发...');
    
    final result = await _offlineCacheService.retryFailedEvents();
    
    Navigator.pop(context); // 关闭loading
    await _loadCacheStats();
    
    _showSnackBar(result.message);
  }

  Future<void> _cleanupExpiredCache() async {
    _showLoadingDialog('正在清理...');
    
    final cleanedCount = await _offlineCacheService.cleanupExpiredCache();
    
    Navigator.pop(context); // 关闭loading
    await _loadCacheStats();
    
    _showSnackBar('已清理 $cleanedCount 条过期数据');
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除历史记录'),
        content: const Text('确定要删除所有ETA历史数据吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _smartEtaService.clearHistory();
              _showSnackBar(success ? '历史记录已清除' : '清除失败');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }

  void _showClearAllCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除所有缓存'),
        content: const Text('确定要删除所有离线缓存数据吗？包括待发送的SOS事件。此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _offlineCacheService.clearAllCache();
              await _loadCacheStats();
              _showSnackBar(success ? '缓存已清除' : '清除失败');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
