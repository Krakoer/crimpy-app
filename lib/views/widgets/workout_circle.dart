import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class WorkoutCircle extends StatefulWidget {
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
        strokeWidth: 8,
        strokeCap: StrokeCap.round,
      ),
    );
  }
}
