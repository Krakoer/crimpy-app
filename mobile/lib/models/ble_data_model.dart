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
