import 'package:flutter/material.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class HandLabel extends StatelessWidget {
  final HandSide handSide;
  final GripPosition? gripPosition;
  final int? edgeSizeMm;

  /// Colors of the hand name and of the grip details under it. They are given
  /// by the full screen gauge, which draws the label twice to invert it where
  /// the force level has covered it.
  final Color color;
  final Color detailColor;

  const HandLabel({
    super.key,
    required this.handSide,
    this.gripPosition,
    this.edgeSizeMm,
    this.color = CrimpyTheme.primaryOrange,
    this.detailColor = CrimpyTheme.gray400,
  });

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
            color: color,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 18,
          ),
        ),
        if (gripPosition != null) ...[
          const SizedBox(height: 2),
          Text(
            [
              gripPosition!.displayName,
              if (edgeSizeMm != null) '${edgeSizeMm}mm',
            ].join(' - '),
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: detailColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
