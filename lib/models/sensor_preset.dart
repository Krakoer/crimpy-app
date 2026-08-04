/// A saved sensor calibration the user can switch between: a named tare and
/// coefficient pair, ordered by [index] in the settings list.
class SensorPreset {
  final String id;
  final String name;
  final int index;
  final double tare;
  final double coef;

  const SensorPreset({
    required this.id,
    required this.name,
    required this.index,
    required this.tare,
    required this.coef,
  });
}

/// A preset the user is creating. It has no id or position yet: storage assigns
/// both, so the caller does not have to know how they are generated.
class NewSensorPreset {
  final String name;
  final double tare;
  final double coef;

  const NewSensorPreset({
    required this.name,
    required this.tare,
    required this.coef,
  });
}
