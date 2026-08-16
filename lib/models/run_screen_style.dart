/// Layout the training run screen is drawn with.
enum RunScreenStyle {
  ringAndTank,
  fullTank;

  /// Name written to storage. Kept apart from the enum name so reordering or
  /// renaming a design does not strand the value stored on a device.
  String get storageKey => switch (this) {
    RunScreenStyle.ringAndTank => 'ring_and_tank',
    RunScreenStyle.fullTank => 'full_tank',
  };

  String get displayName => switch (this) {
    RunScreenStyle.ringAndTank => 'Ring plus tank',
    RunScreenStyle.fullTank => 'Full tank',
  };

  String get description => switch (this) {
    RunScreenStyle.ringAndTank =>
      'The original. Timer ring around a circular force tank.',
    RunScreenStyle.fullTank =>
      'Force fills the whole screen. Readable from across the room.',
  };

  /// Design a run opens in until one is picked, and whenever a stored key
  /// names none. Trying the full tank is the point of the change, so it is
  /// what a workout starts in.
  static const RunScreenStyle fallback = fullTank;

  static RunScreenStyle fromStorageKey(String? key) => values.firstWhere(
    (style) => style.storageKey == key,
    orElse: () => fallback,
  );
}
