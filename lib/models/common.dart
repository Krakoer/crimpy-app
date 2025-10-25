enum HandSide { right, left, both }

extension HandSideExtension on HandSide {
  bool get isRightHand => switch (this) {
    HandSide.right => true,
    HandSide.left || HandSide.both => false,
  };
}

enum GripPosition {
  halfCrimp,
  threeFinger,
  fullCrimp,
  openHand,
  // Add more grip positions as needed
}

extension GripPositionExtension on GripPosition {
  String get displayName => switch (this) {
    GripPosition.halfCrimp => "Half Crimp",
    GripPosition.threeFinger => "3-Finger Drag",
    GripPosition.fullCrimp => "Full Crimp",
    GripPosition.openHand => "Open Hand",
  };

  String get shortName => switch (this) {
    GripPosition.halfCrimp => "HC",
    GripPosition.threeFinger => "3FD",
    GripPosition.fullCrimp => "FC",
    GripPosition.openHand => "OH",
  };
}

enum SessionType {
  crimpy, // Crimpy training (cannot be logged manually)
  climbing, // Climbing session
  stretching, // Stretching session
  workout, // Workout session (abs, pullups, etc)
}

extension SessionTypeExtension on SessionType {
  String get displayName => switch (this) {
    SessionType.crimpy => "Crimpy Training",
    SessionType.climbing => "Climbing",
    SessionType.stretching => "Stretching",
    SessionType.workout => "Workout",
  };

  int get colorValue => switch (this) {
    SessionType.crimpy => 0xFFC6613F, // Orange
    SessionType.climbing => 0xFFD4A644, // Yellow
    SessionType.stretching => 0xFF5A8C5A, // Green
    SessionType.workout => 0xFF8B6B9E, // Purple
  };
}
