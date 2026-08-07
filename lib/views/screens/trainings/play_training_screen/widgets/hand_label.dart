import 'package:flutter/material.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class HandLabel extends StatelessWidget {
  final HandSide handSide;
  final GripPosition? gripPosition;

  const HandLabel({super.key, required this.handSide, this.gripPosition});

  String _getHandLabel() {
    switch (handSide) {
      case HandSide.left:
        return 'LEFT HAND';
      case HandSide.right:
        return 'RIGHT HAND';
      case HandSide.both:
        return 'BOTH HANDS';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _getHandLabel(),
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            color: CrimpyTheme.primaryOrange,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 18,
          ),
        ),
        if (gripPosition != null) ...[
          const SizedBox(height: 2),
          Text(
            gripPosition!.displayName,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: CrimpyTheme.gray400,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
