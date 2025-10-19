import 'package:flutter/material.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class HandLabel extends StatelessWidget {
  final HandSide handSide;

  const HandLabel({super.key, required this.handSide});

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
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        _getHandLabel(),
        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
          color: CrimpyTheme.primaryOrange,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          fontSize: 20,
        ),
      ),
    );
  }
}
