import 'package:flutter/material.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class NextRepPreview extends StatelessWidget {
  final RepModel nextRep;

  const NextRepPreview({super.key, required this.nextRep});

  String _getHandLabel(HandSide handSide) {
    switch (handSide) {
      case HandSide.left:
        return 'LEFT HAND';
      case HandSide.right:
        return 'RIGHT HAND';
      case HandSide.both:
        return 'BOTH HANDS';
    }
  }

  String _getDescription() {
    if (nextRep.isRest) {
      final duration = nextRep.durationInSeconds;
      return 'Rest ${duration}s';
    } else {
      final hand = _getHandLabel(nextRep.handSide);
      final weight = nextRep.targetWeight;
      final duration = nextRep.durationInSeconds;
      return '$hand, ${weight.toStringAsFixed(weight.truncateToDouble() == weight ? 0 : 1)}kg, ${duration}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        'Next: ${_getDescription()}',
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: CrimpyTheme.primaryBlack,
          fontSize: 17,
        ),
      ),
    );
  }
}
