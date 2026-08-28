import 'package:crimpy/utils/datetimes.dart';

class BleDataPoint {
  final double value;
  final DateTime timestamp;

  BleDataPoint(this.value, this.timestamp);

  BleDataPoint.fromJson(Map<String, dynamic> json)
    : value = json['value'] as double,
      timestamp = DateTime.parse(json['timestamp'] as String);

  Map<String, dynamic> toJson() => {
    'value': value,
    'timestamp': timestamp.toString(),
  };
}

/// A force curve as the API carries it: one start instant, then a millisecond
/// offset and a kilogram reading per sample.
///
/// Two parallel arrays rather than an object per point with its own timestamp,
/// which is roughly a fifth of the bytes for the same curve. A four minute
/// critical force run is a couple of thousand samples, so the shape is what
/// decides whether the curve is worth sending at all.
abstract final class ForceCurve {
  /// Kilograms are sent to the hundredth. A reading is a raw
  /// (measurement - tare) * calibration double, so it serialises to seventeen
  /// significant figures, and the API keeps it as a float32: everything past
  /// the seventh is dropped on arrival. Two decimals is already finer than the
  /// sensor resolves, and it roughly halves the body of a four minute run.
  static const _sentDecimals = 2;

  /// The curve as the API takes it, or null when there is nothing to send.
  static Map<String, dynamic>? toJson(List<BleDataPoint> points) {
    if (points.isEmpty) return null;
    final t0 = points.first.timestamp;
    return {
      't0': t0.toUtc().toIso8601String(),
      'ms': [
        for (final point in points)
          point.timestamp.difference(t0).inMilliseconds,
      ],
      'kg': [
        for (final point in points)
          double.parse(point.value.toStringAsFixed(_sentDecimals)),
      ],
    };
  }

  /// The curve read back off the API. Empty when the session carries none, and
  /// when the two arrays disagree or the start instant does not parse: the API
  /// refuses to store either, so this is not a case that is expected to arise,
  /// but half a curve plotted as though it were whole is worse than no curve.
  static List<BleDataPoint> fromJson(Map<String, dynamic>? json) {
    if (json == null) return [];
    final offsets = (json['ms'] as List<dynamic>? ?? []).cast<num>();
    final values = (json['kg'] as List<dynamic>? ?? []).cast<num>();
    if (offsets.length != values.length) return [];
    final t0 = tryParseApiInstant(json['t0'] as String?);
    if (t0 == null) return [];
    return [
      for (var i = 0; i < offsets.length; i++)
        BleDataPoint(
          values[i].toDouble(),
          t0.add(Duration(milliseconds: offsets[i].toInt())),
        ),
    ];
  }
}

/// Connection state enum
enum BleConnectionState { disconnected, connecting, connected, failed }

/// Class to hold the current BLE session statistics.
class BleSessionStats {
  final Duration elapsed;
  final double avg;
  final double max;
  final int nbPoints;

  BleSessionStats({
    this.avg = 0,
    this.elapsed = Duration.zero,
    this.max = 0,
    this.nbPoints = 0,
  });
}
