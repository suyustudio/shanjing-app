import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/utils/common_utils.dart';

void main() {
  group('StringExtensions', () {
    test('truncate should truncate long strings', () {
      expect('Hello World'.truncate(8), 'Hello...');
      expect('Hi'.truncate(10), 'Hi');
    });

    test('truncate should respect custom suffix', () {
      expect('Hello World'.truncate(8, suffix: '~~'), 'Hello ~~');
    });

    test('isBlank should detect empty or whitespace strings', () {
      expect(''.isBlank, true);
      expect('   '.isBlank, true);
      expect('hello'.isBlank, false);
      expect('  hello  '.isBlank, false);
    });

    test('isNotBlank should be opposite of isBlank', () {
      expect(''.isNotBlank, false);
      expect('hello'.isNotBlank, true);
    });

    test('toCamelCase should convert to camelCase', () {
      expect('hello_world'.toCamelCase(), 'helloWorld');
      expect('hello world'.toCamelCase(), 'helloWorld');
      expect('HELLO_WORLD'.toCamelCase(), 'helloWorld');
    });

    test('toSnakeCase should convert to snake_case', () {
      expect('helloWorld'.toSnakeCase(), 'hello_world');
      expect('HelloWorld'.toSnakeCase(), 'hello_world');
    });

    test('maskPhone should mask phone numbers', () {
      expect('13800138000'.maskPhone(), '138****8000');
      expect('123'.maskPhone(), '123'); // Too short
    });

    test('maskEmail should mask email addresses', () {
      expect('test@example.com'.maskEmail(), 't***t@example.com');
      expect('ab@example.com'.maskEmail(), 'a***@example.com');
    });
  });

  group('NumExtensions', () {
    test('formatDistance should format meters', () {
      expect(500.formatDistance(), '500m');
      expect(1500.formatDistance(), '1.5km');
      expect(1000.formatDistance(), '1.0km');
    });

    test('formatDuration should format minutes and hours', () {
      expect(30.formatDuration(), '30分钟');
      expect(60.formatDuration(), '1小时');
      expect(90.formatDuration(), '1小时30分钟');
    });

    test('formatElevation should format elevation', () {
      expect(100.formatElevation(), '100m');
      expect(8848.formatElevation(), '8848m');
    });

    test('formatPercent should format percentage', () {
      expect(0.123.formatPercent(), '12.3%');
      expect(0.5.formatPercent(decimalPlaces: 0), '50%');
    });

    test('clampRange should clamp value within range', () {
      expect(5.clampRange(0, 10), 5);
      expect((-5).clampRange(0, 10), 0);
      expect(15.clampRange(0, 10), 10);
      expect(3.5.clampRange(0.0, 10.0), 3.5);
    });
  });

  group('DateTimeExtensions', () {
    test('toRelativeTime should format relative time', () {
      final now = DateTime.now();
      
      expect(now.subtract(Duration(seconds: 30)).toRelativeTime(), '刚刚');
      expect(now.subtract(Duration(minutes: 5)).toRelativeTime(), '5分钟前');
      expect(now.subtract(Duration(hours: 2)).toRelativeTime(), '2小时前');
      expect(now.subtract(Duration(days: 3)).toRelativeTime(), '3天前');
    });

    test('toDateString should format date', () {
      final date = DateTime(2024, 3, 15);
      expect(date.toDateString(), '2024-03-15');
    });

    test('isToday should detect today', () {
      expect(DateTime.now().isToday, true);
      expect(DateTime.now().subtract(Duration(days: 1)).isToday, false);
    });

    test('isYesterday should detect yesterday', () {
      expect(DateTime.now().subtract(Duration(days: 1)).isYesterday, true);
      expect(DateTime.now().isYesterday, false);
    });

    test('weekdayName should return Chinese weekday', () {
      // 2024-03-18 is Monday
      expect(DateTime(2024, 3, 18).weekdayName, '周一');
      expect(DateTime(2024, 3, 24).weekdayName, '周日');
    });
  });

  group('ListExtensions', () {
    test('getOrNull should return element or null', () {
      final list = [1, 2, 3];
      
      expect(list.getOrNull(0), 1);
      expect(list.getOrNull(2), 3);
      expect(list.getOrNull(5), isNull);
      expect(list.getOrNull(-1), isNull);
    });

    test('chunk should split list into chunks', () {
      final list = [1, 2, 3, 4, 5];
      
      expect(list.chunk(2), [[1, 2], [3, 4], [5]]);
      expect(list.chunk(3), [[1, 2, 3], [4, 5]]);
    });

    test('distinct should remove duplicates', () {
      expect([1, 2, 2, 3, 3, 3].distinct(), [1, 2, 3]);
    });

    test('distinctBy should remove duplicates by key', () {
      final list = [
        {'id': 1, 'name': 'A'},
        {'id': 2, 'name': 'B'},
        {'id': 1, 'name': 'C'},
      ];
      
      final distinct = list.distinctBy((e) => e['id']);
      expect(distinct.length, 2);
    });
  });

  group('ColorExtensions', () {
    test('toHex should convert color to hex string', () {
      final color = Color(0xFF123456);
      expect(color.toHex(), 'FF123456');
    });

    test('lighten should make color lighter', () {
      final color = Color(0xFF000000);
      final lightened = color.lighten(0.3);
      expect(lightened.value, isNot(equals(color.value)));
    });

    test('darken should make color darker', () {
      final color = Color(0xFFFFFFFF);
      final darkened = color.darken(0.3);
      expect(darkened.value, isNot(equals(color.value)));
    });
  });

  group('CommonUtils', () {
    test('randomString should generate random string', () {
      final s1 = CommonUtils.randomString(10);
      final s2 = CommonUtils.randomString(10);
      
      expect(s1.length, 10);
      expect(s2.length, 10);
      expect(s1, isNot(equals(s2))); // Very unlikely to be equal
    });

    test('randomCode should generate numeric code', () {
      final code = CommonUtils.randomCode(6);
      
      expect(code.length, 6);
      expect(int.tryParse(code), isNotNull);
    });

    test('deepCopyMap should create deep copy', () {
      final original = {
        'a': 1,
        'nested': {'b': 2},
      };
      final copy = CommonUtils.deepCopyMap(original);
      
      expect(copy, equals(original));
      
      // Modify copy should not affect original
      (copy['nested'] as Map)['b'] = 3;
      expect((original['nested'] as Map)['b'], 2);
    });

    test('isValidPhone should validate Chinese phone numbers', () {
      expect(CommonUtils.isValidPhone('13800138000'), true);
      expect(CommonUtils.isValidPhone('1380013800'), false);
      expect(CommonUtils.isValidPhone('23800138000'), false);
    });

    test('isValidEmail should validate email addresses', () {
      expect(CommonUtils.isValidEmail('test@example.com'), true);
      expect(CommonUtils.isValidEmail('test@example'), false);
      expect(CommonUtils.isValidEmail('not-an-email'), false);
    });

    test('calculateDistance should calculate distance between coordinates', () {
      // Distance between Beijing and Shanghai is approximately 1067 km
      final distance = CommonUtils.calculateDistance(
        39.9042, 116.4074,  // Beijing
        31.2304, 121.4737,  // Shanghai
      );
      
      expect(distance, greaterThan(1000000)); // > 1000km in meters
      expect(distance, lessThan(1100000));    // < 1100km in meters
    });

    test('formatFileSize should format bytes', () {
      expect(CommonUtils.formatFileSize(500), '500 B');
      expect(CommonUtils.formatFileSize(1024), '1.0 KB');
      expect(CommonUtils.formatFileSize(1024 * 1024), '1.0 MB');
      expect(CommonUtils.formatFileSize(1024 * 1024 * 1024), '1.00 GB');
    });

    test('safeJsonDecode should parse JSON safely', () {
      expect(CommonUtils.safeJsonDecode('{"a":1}'), {'a': 1});
      expect(CommonUtils.safeJsonDecode('invalid json'), isNull);
      expect(CommonUtils.safeJsonDecode('invalid', defaultValue: {}), {});
    });

    test('safeToInt should convert to int safely', () {
      expect(CommonUtils.safeToInt(42), 42);
      expect(CommonUtils.safeToInt('42'), 42);
      expect(CommonUtils.safeToInt(3.14), 3);
      expect(CommonUtils.safeToInt(null, defaultValue: 0), 0);
      expect(CommonUtils.safeToInt('invalid', defaultValue: -1), -1);
    });

    test('safeToDouble should convert to double safely', () {
      expect(CommonUtils.safeToDouble(3.14), 3.14);
      expect(CommonUtils.safeToDouble('3.14'), 3.14);
      expect(CommonUtils.safeToDouble(42), 42.0);
      expect(CommonUtils.safeToDouble(null, defaultValue: 0.0), 0.0);
    });

    test('debounce should debounce function calls', () async {
      var callCount = 0;
      final debounced = CommonUtils.debounce(
        () => callCount++,
        delay: Duration(milliseconds: 50),
      );
      
      debounced();
      debounced();
      debounced();
      
      await Future.delayed(Duration(milliseconds: 100));
      expect(callCount, 1);
    });

    test('throttle should throttle function calls', () async {
      var callCount = 0;
      final throttled = CommonUtils.throttle(
        () => callCount++,
        delay: Duration(milliseconds: 50),
      );
      
      throttled();
      throttled();
      throttled();
      
      expect(callCount, 1);
      
      await Future.delayed(Duration(milliseconds: 60));
      throttled();
      expect(callCount, 2);
    });
  });
}
