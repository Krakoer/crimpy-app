import 'package:flutter/material.dart';

class WorkoutCircle extends StatefulWidget {
  const WorkoutCircle({required this.rest, required this.value, super.key});

  final double value;
  final bool rest;

  @override
  State<WorkoutCircle> createState() => _WorkoutCircleState();
}

class _WorkoutCircleState extends State<WorkoutCircle> {
  final greenColor = Color.fromARGB(255, 93, 133, 1);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 297,
      height: 297,
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
