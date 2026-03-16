import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/offline_map_manager.dart';
import '../analytics_service.dart';
import '../constants/design_system.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_error.dart';

/// 离线地图屏幕
/// 管理离线地图的下载、查看和删除
class OfflineMapScreen extends StatefulWidget {
  const OfflineMapScreen({super.key});

  @override
  State<OfflineMapScreen> createState() => _OfflineMapScreenState();
}

class _OfflineMapScreenState extends State<OfflineMapScreen> {
  final OfflineMapManager _offlineManager = OfflineMapManager();
  final TextEditingController _searchController = TextEditingController();
  
  List<OfflineCity> _allCities = [];
  List<OfflineCity> _hotCities = [];
  List<OfflineCity> _downloadedCities = [];
  List<OfflineCity> _filteredCities = [];
  
  bool _isLoading = true;
  bool _isInitialized = false;
  String? _errorMessage;
  bool _isOfflineMode = false;
  int _totalStorageUsed = 0;
  
  // 下载中的城市进度
  final Map<String, int> _downloadProgress = {};
  final Map<String, OfflineMapDownloadStatus> _downloadStatus = {};

  @override
  void initState() {
    super.initState();
    _initialize();
    
    // 监听网络状态变化
    _offlineManager.offlineModeStream.listen((isOffline) {
      if (mounted) {
        setState(() {
          _isOfflineMode = isOffline;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _offlineManager.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 初始化离线地图管理器
      final initialized = await _offlineManager.initialize();
      if (!initialized) {
        setState(() {
          _errorMessage = '初始化离线地图失败，请检查存储权限';
          _isLoading = false;
        });
        return;
      }

      _isInitialized = true;
      _isOfflineMode = _offlineManager.isOfflineMode;

      // 并行加载数据
      await Future.wait([
        _loadCities(),
        _loadDownloadedCities(),
        _loadStorageInfo(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = '加载失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCities() async {
    try {
      final results = await Future.wait([
        _offlineManager.getOfflineCityList(),
        _offlineManager.getHotCityList(),
      ]);
      
      setState(() {
        _allCities = results[0];
        _hotCities = results[1];
        _filteredCities = _allCities;
      });
    } catch (e) {
      debugPrint('加载城市列表失败: $e');
    }
  }

  Future<void> _loadDownloadedCities() async {
    try {
      final downloaded = await _offlineManager.getDownloadedOfflineMapList();
      setState(() {
        _downloadedCities = downloaded;
      });
    } catch (e) {
      debugPrint('加载已下载列表失败: $e');
    }
  }

  Future<void> _loadStorageInfo() async {
    try {
      final size = await _offlineManager.getTotalOfflineMapSize();
      setState(() {
        _totalStorageUsed = size;
      });
    } catch (e) {
      debugPrint('加载存储信息失败: $e');
    }
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCities = _allCities;
      } else {
        _filteredCities = _allCities.where((city) =>
          city.cityName.toLowerCase().contains(query.toLowerCase()) ||
          (city.cityPinyin?.toLowerCase().contains(query.toLowerCase()) ?? false)
        ).toList();
      }
    });
  }

  Future<void> _startDownload(OfflineCity city) async {
    // 添加下载监听器
    _offlineManager.addDownloadListener(city.cityCode, (updatedCity, status, progress) {
      setState(() {
        _downloadProgress[city.cityCode] = progress;
        _downloadStatus[city.cityCode] = OfflineMapDownloadStatus.fromValue(status);
      });

      // 下载完成时刷新列表
      if (status == OfflineMapDownloadStatus.completed.value) {
        _loadDownloadedCities();
        _loadStorageInfo();
        _offlineManager.removeDownloadListener(city.cityCode);
        
        // 上报下载完成事件
        AnalyticsService().trackEvent(
          MapEvents.offlineMapDownload,
          params: {
            MapEvents.paramCityCode: city.cityCode,
            MapEvents.paramCityName: city.cityName,
            MapEvents.paramDownloadResult: 'success',
          },
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${city.cityName} 下载完成'),
              backgroundColor: DesignSystem.getSuccess(context),
            ),
          );
        }
      }
    });

    final success = await _offlineManager.downloadOfflineMap(city.cityCode, city.cityName);
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${city.cityName} 下载启动失败'),
            backgroundColor: DesignSystem.getError(context),
          ),
        );
      }
    } else {
      setState(() {
        _downloadStatus[city.cityCode] = OfflineMapDownloadStatus.downloading;
      });
    }
  }

  Future<void> _pauseDownload(OfflineCity city) async {
    final success = await _offlineManager.pauseDownload(city.cityCode);
    if (success) {
      setState(() {
        _downloadStatus[city.cityCode] = OfflineMapDownloadStatus.paused;
      });
    }
  }

  Future<void> _resumeDownload(OfflineCity city) async {
    final success = await _offlineManager.resumeDownload(city.cityCode);
    if (success) {
      setState(() {
        _downloadStatus[city.cityCode] = OfflineMapDownloadStatus.downloading;
      });
    }
  }

  Future<void> _deleteOfflineMap(OfflineCity city) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignSystem.getBackgroundElevated(context),
        title: Text(
          '确认删除',
          style: TextStyle(color: DesignSystem.getTextPrimary(context)),
        ),
        content: Text(
          '确定要删除 ${city.cityName} 的离线地图吗？\n将释放 ${city.formattedSize} 空间',
          style: TextStyle(color: DesignSystem.getTextSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: DesignSystem.getError(context)),
            child: Text(
              '删除',
              style: TextStyle(color: DesignSystem.getTextInverse(context)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _offlineManager.deleteOfflineMap(city.cityCode);
      if (success) {
        await _loadDownloadedCities();
        await _loadStorageInfo();
        
        // 上报删除事件
        AnalyticsService().trackEvent(
          MapEvents.offlineMapDelete,
          params: {
            MapEvents.paramCityCode: city.cityCode,
            MapEvents.paramCityName: city.cityName,
          },
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${city.cityName} 已删除'),
              backgroundColor: DesignSystem.getSuccess(context),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${city.cityName} 删除失败'),
              backgroundColor: DesignSystem.getError(context),
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteAllOfflineMaps() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignSystem.getBackgroundElevated(context),
        title: Text(
          '确认删除全部',
          style: TextStyle(color: DesignSystem.getTextPrimary(context)),
        ),
        content: Text(
          '确定要删除所有离线地图吗？\n共 ${_offlineManager.formatSize(_totalStorageUsed)}',
          style: TextStyle(color: DesignSystem.getTextSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: DesignSystem.getError(context)),
            child: Text(
              '全部删除',
              style: TextStyle(color: DesignSystem.getTextInverse(context)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _offlineManager.clearAllOfflineMaps();
      if (success) {
        await _loadDownloadedCities();
        await _loadStorageInfo();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('所有离线地图已删除'),
              backgroundColor: DesignSystem.getSuccess(context),
            ),
          );
        }
      }
    }
  }

  String _formatSize(int? bytes) {
    if (bytes == null) return '未知大小';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _getStatusText(OfflineMapDownloadStatus status) {
    return status.displayName;
  }

  Widget _buildNetworkStatusBanner() {
    if (!_isOfflineMode) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: DesignSystem.getWarning(context).withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off,
            color: DesignSystem.getWarning(context),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            '当前处于离线模式',
            style: TextStyle(
              color: DesignSystem.getWarning(context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignSystem.getBackgroundSecondary(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.storage,
            color: DesignSystem.getPrimary(context),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '已使用存储空间',
                  style: TextStyle(
                    color: DesignSystem.getTextSecondary(context),
                    fontSize: 12,
                  ),
                ),
                Text(
                  _offlineManager.formatSize(_totalStorageUsed),
                  style: TextStyle(
                    color: DesignSystem.getTextPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (_totalStorageUsed > 0)
            TextButton.icon(
              onPressed: _deleteAllOfflineMaps,
              icon: Icon(Icons.delete_outline, color: DesignSystem.getError(context)),
              label: Text(
                '清理',
                style: TextStyle(color: DesignSystem.getError(context)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCityList(List<OfflineCity> cities, {bool showDownloaded = false}) {
    if (cities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_city,
              size: 64,
              color: DesignSystem.getTextTertiary(context),
            ),
            const SizedBox(height: 16),
            Text(
              showDownloaded ? '暂无已下载的离线地图' : '没有找到城市',
              style: TextStyle(color: DesignSystem.getTextSecondary(context)),
            ),
            if (showDownloaded && _isOfflineMode) ...[
              const SizedBox(height: 8),
              Text(
                '离线模式下无法下载新地图',
                style: TextStyle(
                  color: DesignSystem.getWarning(context),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        final isDownloaded = _downloadedCities.any((c) => c.cityCode == city.cityCode);
        final progress = _downloadProgress[city.cityCode] ?? 0;
        final status = _downloadStatus[city.cityCode];
        final isDownloading = status == OfflineMapDownloadStatus.downloading;
        final isPaused = status == OfflineMapDownloadStatus.paused;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: DesignSystem.getBackgroundElevated(context),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDownloaded 
                    ? DesignSystem.getPrimary(context).withOpacity(0.1) 
                    : DesignSystem.getBackgroundTertiary(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isDownloaded ? Icons.map : Icons.map_outlined,
                color: isDownloaded ? DesignSystem.getPrimary(context) : DesignSystem.getTextTertiary(context),
              ),
            ),
            title: Text(
              city.cityName,
              style: TextStyle(
                color: DesignSystem.getTextPrimary(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city.formattedSize,
                  style: TextStyle(color: DesignSystem.getTextSecondary(context)),
                ),
                if (isDownloading || isPaused) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: DesignSystem.getBackgroundTertiary(context),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isPaused ? DesignSystem.getWarning(context) : DesignSystem.getPrimary(context),
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_getStatusText(status!)}: $progress%',
                    style: TextStyle(
                      fontSize: 12,
                      color: isPaused ? DesignSystem.getWarning(context) : DesignSystem.getPrimary(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            trailing: isDownloaded
                ? IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: DesignSystem.getError(context),
                    ),
                    onPressed: () => _deleteOfflineMap(city),
                  )
                : isDownloading
                    ? IconButton(
                        icon: Icon(
                          Icons.pause_circle_outline,
                          color: DesignSystem.getWarning(context),
                          size: 28,
                        ),
                        onPressed: () => _pauseDownload(city),
                      )
                    : isPaused
                        ? IconButton(
                            icon: Icon(
                              Icons.play_circle_outline,
                              color: DesignSystem.getPrimary(context),
                              size: 28,
                            ),
                            onPressed: () => _resumeDownload(city),
                          )
                        : _isOfflineMode
                            ? IconButton(
                                icon: Icon(
                                  Icons.cloud_off,
                                  color: DesignSystem.getTextTertiary(context),
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('离线模式下无法下载'),
                                      backgroundColor: DesignSystem.getWarning(context),
                                    ),
                                  );
                                },
                              )
                            : ElevatedButton(
                                onPressed: () => _startDownload(city),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: DesignSystem.getPrimary(context),
                                  foregroundColor: DesignSystem.getTextInverse(context),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('下载'),
                              ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('离线地图'),
          backgroundColor: DesignSystem.getPrimary(context),
          foregroundColor: DesignSystem.getTextInverse(context),
          bottom: TabBar(
            labelColor: DesignSystem.getTextInverse(context),
            unselectedLabelColor: DesignSystem.getTextInverse(context).withOpacity(0.7),
            indicatorColor: DesignSystem.getTextInverse(context),
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('已下载'),
                    if (_downloadedCities.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: DesignSystem.getTextInverse(context),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_downloadedCities.length}',
                          style: TextStyle(
                            fontSize: 10,
                            color: DesignSystem.getPrimary(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Tab(text: '热门城市'),
              const Tab(text: '全部城市'),
            ],
          ),
        ),
        body: _isLoading
            ? const AppLoading(message: '正在加载离线地图...')
            : _errorMessage != null
                ? AppError(
                    message: _errorMessage!,
                    onRetry: _initialize,
                  )
                : Column(
                    children: [
                      // 网络状态提示
                      _buildNetworkStatusBanner(),
                      // 搜索栏
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(color: DesignSystem.getTextPrimary(context)),
                          decoration: InputDecoration(
                            hintText: '搜索城市',
                            hintStyle: TextStyle(color: DesignSystem.getTextTertiary(context)),
                            prefixIcon: Icon(
                              Icons.search,
                              color: DesignSystem.getTextSecondary(context),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: DesignSystem.getTextSecondary(context),
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearch('');
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: DesignSystem.getBackgroundSecondary(context),
                          ),
                          onChanged: _onSearch,
                        ),
                      ),
                      // 存储空间信息
                      _buildStorageInfo(),
                      // 提示信息
                      Container(
                        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: DesignSystem.getInfo(context).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: DesignSystem.getInfo(context),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _isOfflineMode 
                                    ? '当前离线模式，只能使用已下载的离线地图'
                                    : '离线地图可在无网络环境下使用，建议在WiFi环境下下载',
                                style: TextStyle(
                                  color: DesignSystem.getInfo(context),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 城市列表
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildCityList(_downloadedCities, showDownloaded: true),
                            _buildCityList(_hotCities),
                            _buildCityList(_filteredCities),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
