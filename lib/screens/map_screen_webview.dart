import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../constants/design_system.dart';

// 使用 WebView 加载高德地图 - 绕过 SDK 崩溃问题
class MapScreenSimple extends StatefulWidget {
  const MapScreenSimple({super.key});

  @override
  State<MapScreenSimple> createState() => _MapScreenSimpleState();
}

class _MapScreenSimpleState extends State<MapScreenSimple> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadHtmlString(_getMapHtml());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: DesignSystem.getPrimary(context),
              ),
            ),
          // 顶部提示
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: DesignSystem.getPrimary(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '地图测试版 - WebView',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMapHtml() {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>杭州地图</title>
      <style>
        body { margin: 0; padding: 0; }
        #container { width: 100%; height: 100vh; }
      </style>
      <script src="https://webapi.amap.com/maps?v=2.0&key=e17f8ae117d84e2d2d394a2124866603"></script>
    </head>
    <body>
      <div id="container"></div>
      <script>
        var map = new AMap.Map('container', {
          zoom: 14,
          center: [120.15, 30.25]
        });
      </script>
    </body>
    </html>
    ''';
  }
}
