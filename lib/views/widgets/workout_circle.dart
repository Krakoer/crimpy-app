import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class WorkoutCircle extends StatefulWidget {
  /// Thickness of the ring. Anything stacked inside it, such as the force
  /// gauge, is inset by this much so the two do not paint over each other.
  static const double strokeWidth = 8;

  const WorkoutCircle({
    required this.rest,
    required this.value,
    this.size = 297,
    super.key,
  });

  final double value;
  final bool rest;
  final double size;

  @override
  State<WorkoutCircle> createState() => _WorkoutCircleState();
}

class _WorkoutCircleState extends State<WorkoutCircle> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(
        value: widget.value,
        color: widget.rest
            ? CrimpyTheme.statusSuccess
            : CrimpyTheme.primaryOrange,
        backgroundColor: CrimpyTheme.gray200,
        strokeWidth: WorkoutCircle.strokeWidth,
        // Centred, half the stroke falls outside the box and the gauge stacked
        // on top covers the other half, leaving a ring half as thick as it
        // should be. Kept inside, the whole ring stays visible.
        strokeAlign: CircularProgressIndicator.strokeAlignInside,
        strokeCap: StrokeCap.round,
      ),
    );
  }
}
