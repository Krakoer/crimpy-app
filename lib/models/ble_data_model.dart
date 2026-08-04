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
