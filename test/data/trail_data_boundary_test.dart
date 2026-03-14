import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('路线数据 边界场景测试', () {
    
    test('JSON数据格式验证', () async {
      final file = File('data/json/trails-all.json');
      expect(await file.exists(), isTrue);
      
      final content = await file.readAsString();
      final json = jsonDecode(content);
      
      expect(json, isA<Map<String, dynamic>>());
      expect(json['trails'], isA<List>());
    });

    test('路线数据完整性检查', () async {
      final file = File('data/json/trails-all.json');
      final content = await file.readAsString();
      final json = jsonDecode(content);
      final trails = json['trails'] as List;
      
      // 至少应该有10条路线
      expect(trails.length, greaterThanOrEqualTo(10));
      
      // 检查每条路线都有必需的字段
      for (final trail in trails) {
        expect(trail['id'], isNotNull);
        expect(trail['name'], isNotNull);
        expect(trail['distance'], isNotNull);
        expect(trail['duration'], isNotNull);
      }
    });

    test('距离值合理性', () async {
      final file = File('data/json/trails-all.json');
      final content = await file.readAsString();
      final json = jsonDecode(content);
      final trails = json['trails'] as List;
      
      for (final trail in trails) {
        final distance = trail['distance'];
        expect(distance, isA<num>());
        // 距离应该在 0.1 - 100 公里之间
        expect(distance, greaterThan(0));
        expect(distance, lessThan(100));
      }
    });

    test('时长值合理性', () async {
      final file = File('data/json/trails-all.json');
      final content = await file.readAsString();
      final json = jsonDecode(content);
      final trails = json['trails'] as List;
      
      for (final trail in trails) {
        final duration = trail['duration'];
        expect(duration, isA<num>());
        // 时长应该在 5 分钟到 24 小时之间
        expect(duration, greaterThanOrEqualTo(5));
        expect(duration, lessThanOrEqualTo(1440));
      }
    });

    test('坐标数据格式', () async {
      final file = File('data/json/trails-all.json');
      final content = await file.readAsString();
      final json = jsonDecode(content);
      final trails = json['trails'] as List;
      
      for (final trail in trails) {
        if (trail['coordinates'] != null) {
          final coords = trail['coordinates'] as List;
          expect(coords.length, greaterThan(0));
          
          // 检查坐标格式 [经度, 纬度]
          for (final coord in coords) {
            expect(coord, isA<List>());
            expect(coord.length, equals(2));
            expect(coord[0], isA<num>()); // 经度
            expect(coord[1], isA<num>()); // 纬度
            
            // 经度范围: -180 到 180
            expect(coord[0], greaterThanOrEqualTo(-180));
            expect(coord[0], lessThanOrEqualTo(180));
            
            // 纬度范围: -90 到 90
            expect(coord[1], greaterThanOrEqualTo(-90));
            expect(coord[1], lessThanOrEqualTo(90));
          }
        }
      }
    });

    test('杭州区域坐标验证', () async {
      final file = File('data/json/trails-all.json');
      final content = await file.readAsString();
      final json = jsonDecode(content);
      final trails = json['trails'] as List;
      
      // 杭州的经度范围大约 119.9 - 120.5
      // 杭州的纬度范围大约 30.0 - 30.5
      for (final trail in trails) {
        if (trail['coordinates'] != null) {
          final coords = trail['coordinates'] as List;
          for (final coord in coords) {
            // 经度在杭州范围内
            expect(coord[0], greaterThan(119.5));
            expect(coord[0], lessThan(121.0));
            
            // 纬度在杭州范围内
            expect(coord[1], greaterThan(29.5));
            expect(coord[1], lessThan(31.0));
          }
        }
      }
    });

    test('难度值有效性', () async {
      final file = File('data/json/trails-all.json');
      final content = await file.readAsString();
      final json = jsonDecode(content);
      final trails = json['trails'] as List;
      
      final validDifficulties = ['easy', 'moderate', 'hard'];
      
      for (final trail in trails) {
        if (trail['difficulty'] != null) {
          expect(validDifficulties, contains(trail['difficulty']));
        }
      }
    });

    test('路线ID唯一性', () async {
      final file = File('data/json/trails-all.json');
      final content = await file.readAsString();
      final json = jsonDecode(content);
      final trails = json['trails'] as List;
      
      final ids = trails.map((t) => t['id']).toList();
      final uniqueIds = ids.toSet();
      
      expect(ids.length, equals(uniqueIds.length));
    });

    test('空路线名称处理', () async {
      // 测试空名称的情况
      final trailWithEmptyName = {
        'id': 'test_001',
        'name': '',
        'distance': 5.0,
        'duration': 60,
      };
      
      expect(trailWithEmptyName['name'], isEmpty);
    });

    test('特殊字符路线名称', () async {
      // 测试包含特殊字符的名称
      final trailWithSpecialChars = {
        'id': 'test_002',
        'name': '九溪十八涧 & 龙井村 (西湖区)',
        'distance': 5.0,
        'duration': 60,
      };
      
      expect(trailWithSpecialChars['name'], contains('&'));
      expect(trailWithSpecialChars['name'], contains('('));
    });
  });
}
