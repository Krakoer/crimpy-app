enum HandSide { right, left, both }

extension HandSideExtension on HandSide {
  bool get isRightHand => switch (this) {
    HandSide.right => true,
    HandSide.left || HandSide.both => false,
  };
}
