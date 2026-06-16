import 'package:flutter/material.dart';

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
  final greenColor = Color.fromARGB(255, 93, 133, 1);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(
        value: widget.value,
        color: widget.rest
            ? greenColor
            : const Color.fromARGB(255, 149, 21, 12),
        strokeWidth: 8,
        strokeCap: StrokeCap.round,
      ),
    );
  }
}
