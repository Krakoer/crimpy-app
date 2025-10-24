enum HandSide { right, left }

extension HandSideExtension on HandSide {
  bool get isRightHand => switch (this) {
    HandSide.right => true,
    HandSide.left => false,
  };
}
