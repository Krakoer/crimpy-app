import 'package:crimpy/models/training_model.dart';
import 'package:flutter/material.dart';
import 'basic_list.dart';
import 'repeater_overview_header.dart';
import 'set_card.dart';

/// Visualizes a repeater training in a set-based layout
class RepeaterVisualization extends StatelessWidget {
  final TrainingWithReps training;

  const RepeaterVisualization({super.key, required this.training});

  @override
  Widget build(BuildContext context) {
    if (training.repeater == null) {
      // Fallback to basic list if not a repeater
      return BasicRepList(reps: training.reps);
    }

    final repeater = training.repeater!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RepeaterOverviewHeader(repeater: repeater),
        const SizedBox(height: 16),
        RepeaterDescriptionCard(repeater: repeater),
      ],
    );
  }
}
