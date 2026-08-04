import 'package:flutter/material.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/workout_protocol.dart';
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
    final r = nextRep;
    if (r.isRest) return 'Rest ${r.durationInSeconds}s';
    if (r.isConfirm) {
      return [
        r.label ?? 'Exercise',
        if (r.reps != null) '${r.reps} reps',
        if (r.load != null) r.load!,
      ].join(' - ');
    }
    if (r.showGauge) {
      final w = r.targetWeight;
      return [
        _getHandLabel(r.handSide),
        r.gripPosition.shortName,
        if (w > 0) '${w.toStringAsFixed(w.truncateToDouble() == w ? 0 : 1)}kg',
        '${r.durationInSeconds}s',
      ].join(' - ');
    }
    // Timed work without a sensor (e.g. a duration exercise).
    return '${r.label ?? 'Work'} - ${r.durationInSeconds}s';
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
