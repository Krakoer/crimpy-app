import 'package:flutter/material.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class HandLabel extends StatelessWidget {
  final HandSide handSide;
  final GripPosition? gripPosition;
  final int? edgeSizeMm;

  const HandLabel({
    super.key,
    required this.handSide,
    this.gripPosition,
    this.edgeSizeMm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          handSide.displayName,
          // 18px bold is under the 18.66px large text threshold, so this
          // answers to 4.5:1 like the non sensor branch in
          // play_training_screen. See Krakoer/crimpy#128.
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            color: CrimpyTheme.textOn(CrimpyTheme.primaryOrange),
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
