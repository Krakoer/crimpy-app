import 'package:crimpy/models/training_feedback_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';

class SuccessFeedbackForm extends StatefulWidget {
  final LoadAdjustmentFunction loadAdjustmentFunction;
  final double currentWeight;
  final void Function(double) onNewWeightChange;

  const SuccessFeedbackForm({
    required this.currentWeight,
    required this.loadAdjustmentFunction,
    required this.onNewWeightChange,
    super.key,
  });

  @override
  State<SuccessFeedbackForm> createState() => _SuccessFeedbackFormState();
}

class _SuccessFeedbackFormState extends State<SuccessFeedbackForm> {
  TrainingDifficulty? _difficulty = TrainingDifficulty.moderate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "You managed to do all the reps",
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: CrimpyTheme.gray500),
        ),
        SizedBox(height: 24),
        Text(
          'How did it feel?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        RadioGroup<TrainingDifficulty>(
          groupValue: _difficulty,
          onChanged: (TrainingDifficulty? value) {
            setState(() => _difficulty = value);
            final multiplier = widget.loadAdjustmentFunction(difficulty: value);
            final newWeight = widget.currentWeight * (1 + multiplier);
            widget.onNewWeightChange(newWeight);
          },
          child: Column(
            children:
                TrainingDifficulty.values.map((difficulty) {
                  final multiplier = widget.loadAdjustmentFunction(difficulty: difficulty);
                  final int variation = (multiplier * 100).round();
                  final newWeight = widget.currentWeight * (1 + multiplier);
                  return ListTile(
                    title: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                LoadAdjustmentService.getDifficultyDescription(
                                  difficulty,
                                ),
                          ),
                          TextSpan(
                            text:
                                " (${newWeight.toStringAsFixed(1)}kg, ${variation >= 0 ? '+' : ''}$variation%)",
                          ),
                        ],
                      ),
                    ),
                    leading: Radio<TrainingDifficulty>(value: difficulty),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
