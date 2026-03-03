import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/offline_map_manager.dart';
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
  
  // 下载中的城市进度
  final Map<String, int> _downloadProgress = {};
  final Map<String, OfflineMapDownloadStatus> _downloadStatus = {};

  @override
  void initState() {
    super.initState();
    _initialize();
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

      // 并行加载数据
      await Future.wait([
        _loadCities(),
        _loadDownloadedCities(),
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
      final cities = await _offlineManager.getOfflineCityList();
      final hotCities = await _offlineManager.getHotCityList();
      
      setState(() {
        _allCities = cities;
        _hotCities = hotCities;
        _filteredCities = cities;
      });
    } catch (e) {
      print('加载城市列表失败: $e');
    }
  }

  Future<void> _loadDownloadedCities() async {
    try {
      final downloaded = await _offlineManager.getDownloadedOfflineMapList();
      setState(() {
        _downloadedCities = downloaded;
      });
    } catch (e) {
      print('加载已下载列表失败: $e');
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
        _offlineManager.removeDownloadListener(city.cityCode);
      }
    });

    final success = await _offlineManager.downloadOfflineMap(city.cityCode, city.cityName);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${city.cityName} 下载启动失败'),
          backgroundColor: DesignSystem.getError(context),
        ),
      );
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
          '确定要删除 ${city.cityName} 的离线地图吗？',
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
        _loadDownloadedCities();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${city.cityName} 已删除'),
            backgroundColor: DesignSystem.getSuccess(context),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${city.cityName} 删除失败'),
            backgroundColor: DesignSystem.getError(context),
          ),
        );
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
    switch (status) {
      case OfflineMapDownloadStatus.waiting:
        return '等待中';
      case OfflineMapDownloadStatus.downloading:
        return '下载中';
      case OfflineMapDownloadStatus.paused:
        return '已暂停';
      case OfflineMapDownloadStatus.completed:
        return '已完成';
      case OfflineMapDownloadStatus.error:
        return '下载错误';
      case OfflineMapDownloadStatus.networkError:
        return '网络错误';
      case OfflineMapDownloadStatus.ioError:
        return '存储错误';
      case OfflineMapDownloadStatus.wifiError:
        return 'WiFi错误';
      case OfflineMapDownloadStatus.noSpaceError:
        return '空间不足';
      default:
        return '未知状态';
    }
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
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: DesignSystem.getBackgroundElevated(context),
          child: ListTile(
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
              style: TextStyle(color: DesignSystem.getTextPrimary(context)),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatSize(city.dataSize),
                  style: TextStyle(color: DesignSystem.getTextSecondary(context)),
                ),
                if (isDownloading || isPaused) ...[
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: DesignSystem.getBackgroundTertiary(context),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isPaused ? DesignSystem.getWarning(context) : DesignSystem.getPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_getStatusText(status!)}: $progress%',
                    style: TextStyle(
                      fontSize: 12,
                      color: DesignSystem.getTextSecondary(context),
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
                          Icons.pause,
                          color: DesignSystem.getWarning(context),
                        ),
                        onPressed: () => _pauseDownload(city),
                      )
                    : isPaused
                        ? IconButton(
                            icon: Icon(
                              Icons.play_arrow,
                              color: DesignSystem.getPrimary(context),
                            ),
                            onPressed: () => _resumeDownload(city),
                          )
                        : ElevatedButton(
                            onPressed: () => _startDownload(city),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignSystem.getPrimary(context),
                              foregroundColor: DesignSystem.getTextInverse(context),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
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
            tabs: const [
              Tab(text: '已下载'),
              Tab(text: '热门城市'),
              Tab(text: '全部城市'),
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
                      // 存储空间提示
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
                                '离线地图可在无网络环境下使用，建议在WiFi环境下下载',
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
