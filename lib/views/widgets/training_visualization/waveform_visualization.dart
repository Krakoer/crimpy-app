import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/views/widgets/training_visualization/waveform/mixed_hand_painter.dart';
import 'package:crimpy/views/widgets/training_visualization/waveform/split_hand_painter.dart';
import 'package:flutter/material.dart';

/// Waveform visualization for split-hand repeater training
/// Shows work/rest pattern with annotations for timing and weights
class RepeaterWaveformVisualization extends StatelessWidget {
  final RepeaterModel repeater;

  const RepeaterWaveformVisualization({super.key, required this.repeater});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: CustomPaint(
        painter: repeater.splitHand
            ? SplitHandRepeaterWaveformPainter(repeater: repeater)
            : MixedHandRepeaterWaveformPainter(repeater: repeater),
        size: const Size(double.infinity, 180),
      ),
    );
  }
}
