# M7 P1 收藏夹增强功能 - 测试用例扩展方案

**文档版本**: 1.0  
**制定日期**: 2026-03-22  
**制定人员**: Product Agent  
**适用范围**: 基于交叉Review发现的问题扩展测试用例，确保全面覆盖

## 概述

本文档基于M7 P1三方交叉Review发现的问题，制定了测试用例扩展方案。通过扩展测试用例覆盖，确保修复后的功能质量，防止问题回归。

## 一、扩展测试用例分类

### 1.1 按问题类型分类
1. **P1问题修复验证测试** - 验证6个P1问题的修复效果
2. **集成问题测试** - 验证组件间交互和数据一致性
3. **性能问题测试** - 验证性能改进效果
4. **用户体验测试** - 验证用户体验改进
5. **安全与可靠性测试** - 验证安全和可靠性改进

### 1.2 按测试类型分类
1. **单元测试** - 针对具体函数和方法的测试
2. **集成测试** - 组件间交互测试
3. **端到端测试** - 完整用户流程测试
4. **性能测试** - 响应时间和资源使用测试
5. **安全测试** - 权限和安全漏洞测试

## 二、P1问题修复验证测试用例

### 2.1 P1-01：批量删除使用逐个API问题

#### 新增单元测试
```dart
// 测试批量删除使用批量API
test('batchRemoveTrailsFromCollection should call batch API', () async {
  // 模拟批量API调用
  when(collectionService.batchRemoveTrailsFromCollection(
    collectionId: any(named: 'collectionId'),
    trailIds: any(named: 'trailIds'),
  )).thenAnswer((_) async => BatchOperationResult(success: 5, failed: 0));
  
  // 执行批量删除
  await enhancedService.batchRemoveTrailsFromCollection(
    collectionId: 'col1',
    trailIds: ['trail1', 'trail2', 'trail3', 'trail4', 'trail5'],
  );
  
  // 验证调用的是批量API而非逐个调用
  verify(collectionService.batchRemoveTrailsFromCollection(
    collectionId: 'col1',
    trailIds: ['trail1', 'trail2', 'trail3', 'trail4', 'trail5'],
  )).called(1);
  
  // 验证没有调用逐个删除API
  verifyNever(collectionService.removeTrailFromCollection(
    collectionId: any(named: 'collectionId'),
    trailId: any(named: 'trailId'),
  ));
});

// 测试批量删除性能
test('batchRemoveTrailsFromCollection performance for 10 items', () async {
  final stopwatch = Stopwatch()..start();
  
  await enhancedService.batchRemoveTrailsFromCollection(
    collectionId: 'col1',
    trailIds: List.generate(10, (i) => 'trail$i'),
  );
  
  stopwatch.stop();
  
  // 验证响应时间小于2秒
  expect(stopwatch.elapsedMilliseconds, lessThan(2000));
});
```

#### 新增集成测试
```dart
// 集成测试：批量删除完整流程
testWidgets('Batch delete integration test', (WidgetTester tester) async {
  // 构建测试环境
  await tester.pumpWidget(TestApp());
  
  // 进入多选模式
  await tester.longPress(find.byType(TrailCard).first);
  await tester.pumpAndSettle();
  
  // 选择多个路线
  await tester.tap(find.byType(Checkbox).first);
  await tester.tap(find.byType(Checkbox).at(1));
  await tester.tap(find.byType(Checkbox).at(2));
  await tester.pumpAndSettle();
  
  // 点击批量删除
  await tester.tap(find.text('删除'));
  await tester.pumpAndSettle();
  
  // 确认删除
  await tester.tap(find.text('确认'));
  await tester.pumpAndSettle();
  
  // 验证批量API调用
  // 验证UI更新
  expect(find.byType(TrailCard), findsNWidgets(7)); // 原来10个，删除3个剩余7个
});

// 网络监控测试
testWidgets('Batch delete network request count', (WidgetTester tester) async {
  // 使用网络监控工具验证请求数量
  final networkMonitor = NetworkRequestMonitor();
  
  await tester.pumpWidget(TestApp());
  
  // 执行批量删除5个路线
  // ... 测试步骤
  
  // 验证只有1个网络请求
  expect(networkMonitor.requestCount, equals(1));
  
  // 验证请求体包含所有路线ID
  final request = networkMonitor.requests.first;
  expect(request.body['trailIds'], hasLength(5));
});
```

#### 新增端到端测试
```dart
// 端到端测试：批量删除用户流程
group('Batch Delete E2E', () {
  test('User can batch delete multiple trails', () async {
    // 启动应用
    final app = await FlutterDriver.connect();
    
    // 导航到收藏夹详情页
    await app.tap(find.byValueKey('collection_card_1'));
    await app.waitFor(find.byType('CollectionDetailScreen'));
    
    // 长按进入多选模式
    await app.longPress(find.byType('TrailCard').first);
    await app.waitFor(find.text('多选模式'));
    
    // 选择3个路线
    await app.tap(find.byType('Checkbox').first);
    await app.tap(find.byType('Checkbox').at(1));
    await app.tap(find.byType('Checkbox').at(2));
    
    // 点击批量删除
    await app.tap(find.text('删除'));
    
    // 确认删除
    await app.tap(find.text('确认'));
    
    // 验证删除成功提示
    await app.waitFor(find.text('成功删除3个路线'));
    
    // 验证路线数量减少
    final trailCount = await app.getText(find.byValueKey('trail_count'));
    expect(trailCount, equals('7条路线')); // 原来10个
    
    await app.close();
  });
});
```

### 2.2 P1-02：全选逻辑错误问题

#### 新增单元测试
```dart
// 测试搜索过滤后全选逻辑
test('selectAll should only select filtered trails', () {
  final manager = CollectionSelectionManager();
  
  // 设置测试数据：10个路线
  manager.setTrails(List.generate(10, (i) => Trail(id: 'trail$i', name: 'Trail $i')));
  
  // 模拟搜索过滤：只显示前5个
  manager.setFilteredTrails(List.generate(5, (i) => Trail(id: 'trail$i', name: 'Trail $i')));
  
  // 执行全选
  manager.selectAll();
  
  // 验证只选中了5个路线（过滤后的）
  expect(manager.selectedCount, equals(5));
  expect(manager.selectedTrailIds, equals(['trail0', 'trail1', 'trail2', 'trail3', 'trail4']));
  
  // 验证未过滤的路线未被选中
  for (int i = 5; i < 10; i++) {
    expect(manager.isSelected('trail$i'), isFalse);
  }
});

// 测试全选按钮状态
test('selectAllButtonState shows correct text for filtered results', () {
  final manager = CollectionSelectionManager();
  
  // 无过滤时
  manager.setTrails(List.generate(10, (i) => Trail(id: 'trail$i')));
  expect(manager.selectAllButtonState, equals('全选(10)'));
  
  // 有过滤时
  manager.setFilteredTrails(List.generate(5, (i) => Trail(id: 'trail$i')));
  expect(manager.selectAllButtonState, equals('全选当前结果(5)'));
  
  // 部分选中时
  manager.selectTrail('trail0');
  expect(manager.selectAllButtonState, equals('全选当前结果(5)'));
  
  // 全部选中时
  manager.selectAll();
  expect(manager.selectAllButtonState, equals('取消全选(5)'));
});
```

#### 新增集成测试
```dart
// 集成测试：搜索后全选行为
testWidgets('Select all after search filters correctly', (WidgetTester tester) async {
  await tester.pumpWidget(TestApp());
  
  // 输入搜索关键词
  await tester.enterText(find.byType(TextField), 'mountain');
  await tester.pumpAndSettle(const Duration(milliseconds: 350)); // 等待防抖
  
  // 验证过滤结果
  expect(find.byType(TrailCard), findsNWidgets(3)); // 假设3个匹配结果
  
  // 进入多选模式
  await tester.longPress(find.byType(TrailCard).first);
  await tester.pumpAndSettle();
  
  // 点击全选
  await tester.tap(find.text('全选当前结果(3)'));
  await tester.pumpAndSettle();
  
  // 验证只选中了3个路线
  expect(find.byType(CheckedCheckbox), findsNWidgets(3));
  
  // 执行批量删除
  await tester.tap(find.text('删除'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('确认'));
  await tester.pumpAndSettle();
  
  // 验证只删除了3个路线
  expect(find.byType(TrailCard), findsNWidgets(7)); // 原来10个
});
```

### 2.3 P1-03：批量标签功能缺失问题

#### 新增单元测试
```dart
// 测试批量标签添加
test('batchAddTagsToTrails should call batch API', () async {
  when(tagService.batchAddTagsToTrails(
    trailIds: any(named: 'trailIds'),
    tagIds: any(named: 'tagIds'),
  )).thenAnswer((_) async => BatchOperationResult(success: 5, failed: 0));
  
  await tagService.batchAddTagsToTrails(
    trailIds: ['trail1', 'trail2', 'trail3', 'trail4', 'trail5'],
    tagIds: ['tag1', 'tag2'],
  );
  
  verify(tagService.batchAddTagsToTrails(
    trailIds: ['trail1', 'trail2', 'trail3', 'trail4', 'trail5'],
    tagIds: ['tag1', 'tag2'],
  )).called(1);
});

// 测试批量标签移除
test('batchRemoveTagsFromTrails should call batch API', () async {
  when(tagService.batchRemoveTagsFromTrails(
    trailIds: any(named: 'trailIds'),
    tagIds: any(named: 'tagIds'),
  )).thenAnswer((_) async => BatchOperationResult(success: 5, failed: 0));
  
  await tagService.batchRemoveTagsFromTrails(
    trailIds: ['trail1', 'trail2', 'trail3'],
    tagIds: ['tag1'],
  );
  
  verify(tagService.batchRemoveTagsFromTrails(
    trailIds: ['trail1', 'trail2', 'trail3'],
    tagIds: ['tag1'],
  )).called(1);
});
```

#### 新增集成测试
```dart
// 集成测试：批量标签操作流程
testWidgets('Batch tag add/remove integration test', (WidgetTester tester) async {
  await tester.pumpWidget(TestApp());
  
  // 进入多选模式并选择路线
  await tester.longPress(find.byType(TrailCard).first);
  await tester.pumpAndSettle();
  await tester.tap(find.byType(Checkbox).first);
  await tester.tap(find.byType(Checkbox).at(1));
  
  // 点击标签按钮
  await tester.tap(find.text('标签'));
  await tester.pumpAndSettle();
  
  // 选择标签
  await tester.tap(find.text('户外运动'));
  await tester.tap(find.text('登山'));
  
  // 确认添加
  await tester.tap(find.text('确认'));
  await tester.pumpAndSettle();
  
  // 验证标签添加成功提示
  expect(find.text('成功为2个路线添加标签'), findsOneWidget);
  
  // 验证路线卡片显示标签
  expect(find.text('户外运动'), findsNWidgets(2));
  expect(find.text('登山'), findsNWidgets(2));
});
```

### 2.4 P1-04：防抖延迟不符合规格问题

#### 新增单元测试
```dart
// 测试防抖时间设置为300ms
test('SearchController debounce should be 300ms', () {
  final controller = SearchController();
  
  // 通过反射或公共属性获取防抖时间
  final debounceDuration = controller.debounceDuration;
  
  expect(debounceDuration, equals(const Duration(milliseconds: 300)));
});

// 测试防抖计时器重置
test('SearchController resets debounce timer on new input', () async {
  final controller = SearchController();
  bool searchExecuted = false;
  
  controller.onSearch = (query) {
    searchExecuted = true;
  };
  
  // 第一次输入
  controller.updateQuery('m');
  
  // 等待200ms后输入第二个字符（防抖计时器应重置）
  await Future.delayed(const Duration(milliseconds: 200));
  controller.updateQuery('mo');
  
  // 再等待200ms，总时间400ms，但防抖应从最后一次输入重新计时
  await Future.delayed(const Duration(milliseconds: 200));
  
  // 此时搜索不应执行（因为从最后一次输入只过了200ms）
  expect(searchExecuted, isFalse);
  
  // 再等待150ms（总350ms从最后一次输入）
  await Future.delayed(const Duration(milliseconds: 150));
  
  // 此时搜索应执行（300ms防抖已过）
  expect(searchExecuted, isTrue);
});
```

#### 新增性能测试
```dart
// 性能测试：搜索响应时间
test('Search response time should be under 600ms', () async {
  final controller = SearchController();
  final stopwatch = Stopwatch();
  
  controller.onSearch = (query) {
    stopwatch.stop();
  };
  
  stopwatch.start();
  controller.updateQuery('test query');
  
  // 等待防抖+搜索执行
  await Future.delayed(const Duration(milliseconds: 650));
  
  expect(stopwatch.isRunning, isFalse);
  expect(stopwatch.elapsedMilliseconds, lessThan(600));
});
```

### 2.5 P1-05：网络错误处理不完善问题

#### 新增单元测试
```dart
// 测试网络错误处理
test('batchDelete should handle network errors gracefully', () async {
  // 模拟网络异常
  when(collectionService.batchRemoveTrailsFromCollection(
    collectionId: any(named: 'collectionId'),
    trailIds: any(named: 'trailIds'),
  )).thenThrow(SocketException('Network is unreachable'));
  
  try {
    await enhancedService.batchRemoveTrailsFromCollection(
      collectionId: 'col1',
      trailIds: ['trail1', 'trail2'],
    );
    fail('Should throw an exception');
  } catch (e) {
    // 验证错误类型和消息
    expect(e, isA<NetworkException>());
    expect(e.message, contains('网络连接失败'));
  }
});

// 测试部分失败处理
test('batchDelete should handle partial failures', () async {
  // 模拟部分成功
  when(collectionService.batchRemoveTrailsFromCollection(
    collectionId: any(named: 'collectionId'),
    trailIds: any(named: 'trailIds'),
  )).thenAnswer((_) async => BatchOperationResult(
    success: 3,
    failed: 2,
    failures: [
      FailedOperation(trailId: 'trail4', reason: 'Not found'),
      FailedOperation(trailId: 'trail5', reason: 'Permission denied'),
    ],
  ));
  
  final result = await enhancedService.batchRemoveTrailsFromCollection(
    collectionId: 'col1',
    trailIds: ['trail1', 'trail2', 'trail3', 'trail4', 'trail5'],
  );
  
  expect(result.success, equals(3));
  expect(result.failed, equals(2));
  expect(result.failures, hasLength(2));
});
```

#### 新增集成测试
```dart
// 集成测试：网络错误场景
testWidgets('Network error handling in batch operations', (WidgetTester tester) async {
  // 设置网络错误模拟
  NetworkSimulator.setNetworkState(NetworkState.disconnected);
  
  await tester.pumpWidget(TestApp());
  
  // 执行批量删除
  await tester.longPress(find.byType(TrailCard).first);
  await tester.pumpAndSettle();
  await tester.tap(find.byType(Checkbox).first);
  await tester.tap(find.text('删除'));
  await tester.tap(find.text('确认'));
  await tester.pumpAndSettle();
  
  // 验证网络错误提示
  expect(find.text('网络连接失败，请检查网络设置'), findsOneWidget);
  expect(find.text('重试'), findsOneWidget);
  
  // 恢复网络并重试
  NetworkSimulator.setNetworkState(NetworkState.connected);
  await tester.tap(find.text('重试'));
  await tester.pumpAndSettle();
  
  // 验证操作成功
  expect(find.text('成功删除1个路线'), findsOneWidget);
});
```

### 2.6 P1-06：权限检查未实现问题

#### 新增单元测试
```dart
// 测试权限检查
test('checkPermission should validate user permissions', () {
  final permissionManager = PermissionManager();
  
  // 设置用户权限
  permissionManager.setUserPermissions({
    'collection:col1': ['view', 'edit'],
    'collection:col2': ['view'],
  });
  
  // 验证有权限的操作
  expect(permissionManager.checkPermission('collection:col1', 'edit'), isTrue);
  expect(permissionManager.checkPermission('collection:col1', 'delete'), isFalse);
  
  // 验证无权限的操作
  expect(permissionManager.checkPermission('collection:col2', 'edit'), isFalse);
  expect(permissionManager.checkPermission('collection:col2', 'delete'), isFalse);
  
  // 验证不存在的资源
  expect(permissionManager.checkPermission('collection:col3', 'view'), isFalse);
});

// 测试权限不足的错误
test('batchDelete should throw PermissionDeniedException when no permission', () async {
  // 模拟权限检查失败
  when(permissionService.checkPermission(
    resourceId: any(named: 'resourceId'),
    action: any(named: 'action'),
  )).thenReturn(false);
  
  try {
    await enhancedService.batchRemoveTrailsFromCollection(
      collectionId: 'col1',
      trailIds: ['trail1', 'trail2'],
    );
    fail('Should throw PermissionDeniedException');
  } catch (e) {
    expect(e, isA<PermissionDeniedException>());
    expect(e.message, contains('没有删除权限'));
  }
});
```

#### 新增安全测试
```dart
// 安全测试：越权访问
testWidgets('Prevent unauthorized access to collections', (WidgetTester tester) async {
  // 使用无权限用户登录
  await tester.pumpWidget(TestApp(userType: UserType.guest));
  
  // 尝试访问需要权限的收藏夹
  await tester.tap(find.byValueKey('restricted_collection'));
  await tester.pumpAndSettle();
  
  // 验证权限错误提示
  expect(find.text('您没有权限查看此收藏夹'), findsOneWidget);
  
  // 验证无法进入多选模式
  await tester.longPress(find.byType(TrailCard).first);
  await tester.pumpAndSettle();
  
  expect(find.text('多选模式'), findsNothing);
  expect(find.text('您没有编辑权限'), findsOneWidget);
});
```

## 三、集成问题测试用例扩展

### 3.1 组件间交互测试

#### 新增集成测试
```dart
// 测试搜索、多选、批量操作完整流程
testWidgets('Full flow: Search -> Multi-select -> Batch operation', (WidgetTester tester) async {
  await tester.pumpWidget(TestApp());
  
  // 步骤1: 搜索过滤
  await tester.enterText(find.byType(TextField), 'lake');
  await tester.pumpAndSettle(const Duration(milliseconds: 350));
  
  // 步骤2: 进入多选模式
  await tester.longPress(find.byType(TrailCard).first);
  await tester.pumpAndSettle();
  
  // 步骤3: 全选当前结果
  await tester.tap(find.text('全选当前结果(3)'));
  await tester.pumpAndSettle();
  
  // 步骤4: 批量添加标签
  await tester.tap(find.text('标签'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('湖泊'));
  await tester.tap(find.text('确认'));
  await tester.pumpAndSettle();
  
  // 步骤5: 验证结果
  expect(find.text('成功为3个路线添加标签'), findsOneWidget);
  expect(find.text('湖泊'), findsNWidgets(3));
  
  // 步骤6: 批量删除
  await tester.tap(find.text('删除'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('确认'));
  await tester.pumpAndSettle();
  
  // 步骤7: 验证删除结果
  expect(find.text('成功删除3个路线'), findsOneWidget);
  expect(find.byType(TrailCard), findsNWidgets(7)); // 原来10个
});
```

### 3.2 数据一致性测试

#### 新增集成测试
```dart
// 测试数据一致性：本地状态与服务器同步
testWidgets('Data consistency after batch operations', (WidgetTester tester) async {
  final localDatabase = LocalDatabase();
  final serverApi = ServerApi();
  
  await tester.pumpWidget(TestApp());
  
  // 获取初始数据
  final initialLocalData = await localDatabase.getTrails('col1');
  final initialServerData = await serverApi.getTrails('col1');
  
  // 验证初始一致性
  expect(initialLocalData.length, equals(initialServerData.length));
  
  // 执行批量删除
  await tester.longPress(find.byType(TrailCard).first);
  await tester.pumpAndSettle();
  await tester.tap(find.byType(Checkbox).first);
  await tester.tap(find.byType(Checkbox).at(1));
  await tester.tap(find.text('删除'));
  await tester.tap(find.text('确认'));
  await tester.pumpAndSettle();
  
  // 等待同步
  await Future.delayed(const Duration(seconds: 2));
  
  // 验证数据一致性
  final updatedLocalData = await localDatabase.getTrails('col1');
  final updatedServerData = await serverApi.getTrails('col1');
  
  expect(updatedLocalData.length, equals(updatedServerData.length));
  expect(updatedLocalData.length, equals(initialLocalData.length - 2));
});
```

## 四、性能测试用例扩展

### 4.1 批量操作性能测试

#### 新增性能测试
```dart
// 性能测试：批量删除不同数量路线
group('Batch delete performance', () {
  test('Performance for 5 trails', () async {
    final stopwatch = Stopwatch()..start();
    
    await enhancedService.batchRemoveTrailsFromCollection(
      collectionId: 'col1',
      trailIds: List.generate(5, (i) => 'trail$i'),
    );
    
    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(1500));
  });
  
  test('Performance for 20 trails', () async {
    final stopwatch = Stopwatch()..start();
    
    await enhancedService.batchRemoveTrailsFromCollection(
      collectionId: 'col1',
      trailIds: List.generate(20, (i) => 'trail$i'),
    );
    
    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(3000));
  });
  
  test('Performance for 50 trails', () async {
    final stopwatch = Stopwatch()..start();
    
    await enhancedService.batchRemoveTrailsFromCollection(
      collectionId: 'col1',
      trailIds: List.generate(50, (i) => 'trail$i'),
    );
    
    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(5000));
  });
});
```

### 4.2 搜索性能测试

#### 新增性能测试
```dart
// 性能测试：搜索响应时间
test('Search response time with 1000 items', () async {
  // 准备1000个测试数据
  final testData = List.generate(1000, (i) => Trail(
    id: 'trail$i',
    name: 'Trail $i ${i % 5 == 0 ? 'mountain' : 'valley'}',
  ));
  
  final controller = SearchController();
  controller.setData(testData);
  
  final stopwatch = Stopwatch()..start();
  controller.updateQuery('mountain');
  
  // 等待防抖+搜索执行
  await Future.delayed(const Duration(milliseconds: 600));
  
  stopwatch.stop();
  
  // 验证响应时间
  expect(stopwatch.elapsedMilliseconds, lessThan(600));
  
  // 验证搜索结果正确性
  expect(controller.filteredTrails.length, equals(200)); // 1000/5=200个包含mountain
});
```

## 五、用户体验测试用例扩展

### 5.1 用户流程测试

#### 新增端到端测试
```dart
// 端到端测试：新用户首次使用批量操作
test('First-time user batch operation flow', () async {
  final app = await FlutterDriver.connect();
  
  // 作为新用户登录
  await app.tap(find.byValueKey('login_button'));
  await app.enterText(find.byType('TextField'), 'newuser@example.com');
  await app.enterText(find.byType('PasswordField'), 'password123');
  await app.tap(find.text('登录'));
  
  // 首次使用引导
  await app.waitFor(find.text('欢迎使用收藏夹增强功能'));
  await app.tap(find.text('下一步'));
  
  // 多选模式引导
  await app.waitFor(find.text('长按路线卡片进入多选模式'));
  await app.tap(find.text('我知道了'));
  
  // 尝试长按
  await app.longPress(find.byType('TrailCard').first);
  await app.waitFor(find.text('多选模式'));
  
  // 批量操作引导
  await app.waitFor(find.text('选择多个路线后可以批量操作'));
  await app.tap(find.text('下一步'));
  
  // 完成引导
  await app.tap(find.text('开始使用'));
  
  // 验证可以正常使用批量功能
  await app.tap(find.byType('Checkbox').first);
  await app.tap(find.byType('Checkbox').at(1));
  await app.tap(find.text('删除'));
  await app.waitFor(find.text('确认删除2个路线吗？'));
  
  await app.close();
});
```

### 5.2 错误场景用户体验测试

#### 新增集成测试
```dart
// 测试错误场景的用户体验
testWidgets('User experience in error scenarios', (WidgetTester tester) async {
  await tester.pumpWidget(TestApp());
  
  // 场景1: 网络断开
  NetworkSimulator.setNetworkState(NetworkState.disconnected);
  
  await tester.longPress(find.byType(TrailCard).first);
  await tester.pumpAndSettle();
  await tester.tap(find.byType(Checkbox).first);
  await tester.tap(find.text('删除'));
  await tester.tap(find.text('确认'));
  await tester.pumpAndSettle();
  
  // 验证友好错误提示
  expect(find.text('网络连接失败'), findsOneWidget);
  expect(find.text('重试'), findsOneWidget);
  expect(find.text('检查网络设置'), findsOneWidget);
  
  // 场景2: 权限不足
  NetworkSimulator.setNetworkState(NetworkState.connected);
  PermissionSimulator.setPermission(false);
  
  await tester.tap(find.text('重试'));
  await tester.pumpAndSettle();
  
  // 验证权限错误提示
  expect(find.text('您没有删除权限'), findsOneWidget);
  expect(find.text('联系管理员'), findsOneWidget);
  
  // 场景3: 部分成功
  PermissionSimulator.setPermission(true);
  ServerSimulator.setPartialSuccess(3, 2); // 3成功，2失败
  
  await tester.tap(find.text('重试'));
  await tester.pumpAndSettle();
  
  // 验证部分成功提示
  expect(find.text('3个路线删除成功，2个失败'), findsOneWidget);
  expect(find.text('查看失败详情'), findsOneWidget);
  
  await tester.tap(find.text('查看失败详情'));
  await tester.pumpAndSettle();
  
  expect(find.text('失败原因'), findsOneWidget);
  expect(find.text('重试失败项'), findsOneWidget);
});
```

## 六、测试用例管理

### 6.1 测试用例优先级

| 优先级 | 测试类型 | 执行频率 | 自动化程度 |
|--------|----------|----------|------------|
| **P1** | 核心功能验证、安全测试 | 每次提交 | 100%自动化 |
| **P2** | 集成测试、性能测试 | 每日构建 | 80%自动化 |
| **P3** | 用户体验测试、边界测试 | 发布前 | 50%自动化 |

### 6.2 测试执行计划

#### 每日构建测试 (30分钟)
- 所有P1优先级单元测试
- 核心集成测试
- 快速性能测试

#### 每周完整测试 (2小时)
- 所有单元测试
- 所有集成测试
- 完整性能测试
- 安全扫描测试

#### 发布前测试 (1天)
- 所有测试用例（单元、集成、端到端、性能、安全）
- 用户体验测试
- 兼容性测试
- 压力测试

### 6.3 测试报告模板

```markdown
## 测试报告 - [日期]

### 测试概况
- 测试周期: [开始时间] - [结束时间]
- 测试范围: [模块/功能]
- 测试人员: [姓名]
- 测试环境: [环境描述]

### 测试结果摘要
- 总测试用例数: X
- 通过数: Y
- 失败数: Z
- 跳过数: W
- 通过率: Y/X*100%

### 详细结果
#### P1测试用例
| 测试用例ID | 描述 | 结果 | 备注 |
|------------|------|------|------|
| TC-P1-01-01 | 批量删除使用批量API | ✅ 通过 | - |
| TC-P1-02-01 | 搜索过滤后全选逻辑 | ✅ 通过 | - |

#### P2测试用例
| 测试用例ID | 描述 | 结果 | 备注 |
|------------|------|------|------|
| TC-P2-01-01 | 批量标签添加性能 | ⚠️ 警告 | 响应时间略超标准 |

#### P3测试用例
| 测试用例ID | 描述 | 结果 | 备注 |
|------------|------|------|------|
| TC-P3-01-01 | 大量数据搜索性能 | ✅ 通过 | - |

### 发现的问题
1. **问题1**: [问题描述]
   - 严重程度: [P1/P2/P3]
   - 重现步骤: [步骤]
   - 影响范围: [影响]
   - 建议修复: [建议]

2. **问题2**: [问题描述]
   - ...

### 质量评估
- 功能完整性: X/10
- 性能指标: Y/10  
- 用户体验: Z/10
- 安全性: W/10
- **总体评分**: [分数]/10

### 发布建议
- [ ] 建议发布
- [ ] 需要修复关键问题
- [ ] 需要重新测试

### 附件
- 详细测试日志
- 性能测试报告
- 安全扫描报告
```

## 七、测试环境配置

### 7.1 测试数据准备
```dart
// 测试数据生成工具
class TestDataGenerator {
  static List<Trail> generateTrails(int count) {
    return List.generate(count, (i) => Trail(
      id: 'trail$i',
      name: 'Trail $i',
      tags: i % 3 == 0 ? ['mountain'] : i % 3 == 1 ? ['lake'] : ['forest'],
    ));
  }
  
  static List<Tag> generateTags(int count) {
    return List.generate(count, (i) => Tag(
      id: 'tag$i',
      name: ['户外运动', '登山', '湖泊', '森林', '徒步'][i % 5],
      color: Colors.primaries[i % Colors.primaries.length],
    ));
  }
}
```

### 7.2 模拟服务配置
```dart
// 模拟服务配置
void setupMockServices() {
  // 模拟网络服务
  final mockNetworkService = MockNetworkService();
  when(mockNetworkService.isConnected).thenReturn(true);
  
  // 模拟权限服务
  final mockPermissionService = MockPermissionService();
  when(mockPermissionService.checkPermission(
    resourceId: any(named: 'resourceId'),
    action: any(named: 'action'),
  )).thenReturn(true);
  
  // 模拟API服务
  final mockApiService = MockApiService();
  when(mockApiService.batchRemoveTrailsFromCollection(
    collectionId: any(named: 'collectionId'),
    trailIds: any(named: 'trailIds'),
  )).thenAnswer((_) async => BatchOperationResult(success: 5, failed: 0));
  
  // 注册服务
  ServiceLocator.register<NetworkService>(mockNetworkService);
  ServiceLocator.register<PermissionService>(mockPermissionService);
  ServiceLocator.register<ApiService>(mockApiService);
}
```

## 八、下一步行动

### 8.1 立即行动 (3月23日)
1. **评审测试用例扩展方案** - 提交给Dev Agent评审
2. **准备测试环境** - 配置测试数据和模拟服务
3. **创建测试文件** - 根据方案创建具体的测试文件

### 8.2 短期行动 (3月24日-25日)
1. **实现测试用例** - 开发团队实现新增测试用例
2. **执行测试** - QA团队执行扩展的测试用例
3. **修复测试发现的问题** - 开发团队修复测试发现的问题

### 8.3 长期行动 (3月26日后)
1. **测试自动化集成** - 将测试用例集成到CI/CD流水线
2. **测试覆盖率监控** - 监控测试覆盖率并持续改进
3. **测试用例维护** - 定期评审和更新测试用例

---

**文档状态**: 待评审  
**下一步**: 提交给Dev Agent和QA Agent评审，确认测试用例扩展方案  
**预计更新时间**: 2026-03-23 11:00 GMT+8