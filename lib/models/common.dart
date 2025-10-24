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
