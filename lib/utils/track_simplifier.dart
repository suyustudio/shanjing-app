import 'dart:math';
import '../models/recording_model.dart';

/// Track simplification using the Ramer-Douglas-Peucker algorithm.
///
/// Reduces the number of track points while preserving the overall shape.
/// Useful for reducing storage size and improving performance when
/// rendering long recorded tracks.
class TrackSimplifier {
  /// Simplify [points] using Douglas-Peucker with the given [epsilonMeters] tolerance.
  ///
  /// [epsilonMeters] is the maximum allowed deviation in meters.
  /// A higher value produces more aggressive simplification (fewer points).
  /// Recommended values: 3-10 meters for hiking trails.
  static List<TrackPoint> simplify(
    List<TrackPoint> points, {
    double epsilonMeters = 5.0,
  }) {
    if (points.length <= 2) return List.from(points);

    final result = _simplifyRecursive(points, 0, points.length - 1, epsilonMeters);
    return result;
  }

  /// Recursive Douglas-Peucker implementation.
  static List<TrackPoint> _simplifyRecursive(
    List<TrackPoint> points,
    int start,
    int end,
    double epsilon,
  ) {
    if (end - start <= 1) {
      if (end - start == 1) {
        return [points[start], points[end]];
      }
      return [points[start]];
    }

    // Find the point with the maximum perpendicular distance
    double maxDistance = 0;
    int maxIndex = start;

    for (int i = start + 1; i < end; i++) {
      final distance = _perpendicularDistance(
        points[i].latitude, points[i].longitude,
        points[start].latitude, points[start].longitude,
        points[end].latitude, points[end].longitude,
      );
      if (distance > maxDistance) {
        maxDistance = distance;
        maxIndex = i;
      }
    }

    // If max distance exceeds epsilon, recursively simplify both segments
    if (maxDistance > epsilon) {
      final firstSegment = _simplifyRecursive(points, start, maxIndex, epsilon);
      final secondSegment = _simplifyRecursive(points, maxIndex, end, epsilon);
      return [
        ...firstSegment.take(firstSegment.length - 1),
        ...secondSegment,
      ];
    } else {
      return [points[start], points[end]];
    }
  }

  /// Calculate the perpendicular distance from point P to the line through A and B.
  ///
  /// Uses cross-track distance formula on the sphere for geographic coordinates.
  static double _perpendicularDistance(
    double pLat, double pLng,
    double aLat, double aLng,
    double bLat, double bLng,
  ) {
    // If A and B are the same point, return great-circle distance from P to A
    if (aLat == bLat && aLng == bLng) {
      return _haversineDistance(pLat, pLng, aLat, aLng);
    }

    // Convert to radians
    final pLatRad = _toRadians(pLat);
    final pLngRad = _toRadians(pLng);
    final aLatRad = _toRadians(aLat);
    final aLngRad = _toRadians(aLng);
    final bLatRad = _toRadians(bLat);
    final bLngRad = _toRadians(bLng);

    // Calculate cross-track distance using spherical trigonometry
    // Formula: distance = asin(sin(dist_PA) * sin(bearing_AB - bearing_AP)) * R
    final d13 = _greatCircleDistance(pLatRad, pLngRad, aLatRad, aLngRad);
    final theta13 = _initialBearing(aLatRad, aLngRad, pLatRad, pLngRad);
    final theta12 = _initialBearing(aLatRad, aLngRad, bLatRad, bLngRad);

    final crossTrack = asin(sin(d13) * sin(theta12 - theta13));
    return (crossTrack * 6371000.0).abs();
  }

  static double _greatCircleDistance(double lat1, double lng1, double lat2, double lng2) {
    return 2 * asin(sqrt(
      pow(sin((lat2 - lat1) / 2), 2) +
          cos(lat1) * cos(lat2) * pow(sin((lng2 - lng1) / 2), 2),
    ));
  }

  static double _haversineDistance(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLng / 2) * sin(dLng / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _initialBearing(double lat1, double lng1, double lat2, double lng2) {
    final dLng = lng2 - lng1;
    final y = sin(dLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    return atan2(y, x);
  }

  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}
