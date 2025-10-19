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
  bool _useCustomWeight = false;
  final _customWeightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with current weight
    _customWeightController.text = widget.currentWeight.toStringAsFixed(1);
    // Trigger initial weight calculation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final multiplier = widget.loadAdjustmentFunction(difficulty: _difficulty);
      final newWeight = widget.currentWeight * (1 + multiplier);
      widget.onNewWeightChange(newWeight);
    });
  }

  @override
  void dispose() {
    _customWeightController.dispose();
    super.dispose();
  }

  void _handleCustomWeightChange() {
    final customWeight = double.tryParse(_customWeightController.text);
    if (customWeight != null && customWeight > 0) {
      widget.onNewWeightChange(customWeight);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Success message
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: CrimpyTheme.bgSuccess,
            border: Border.all(color: CrimpyTheme.statusSuccess, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: CrimpyTheme.statusSuccess,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "You completed all reps!",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CrimpyTheme.statusSuccess,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Question label
        Text(
          'How did it feel?',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),

        if (!_useCustomWeight) ...[
          // Radio options
          RadioGroup<TrainingDifficulty>(
            groupValue: _difficulty,
            onChanged: (TrainingDifficulty? value) {
              setState(() => _difficulty = value);
              final multiplier = widget.loadAdjustmentFunction(
                difficulty: value,
              );
              final newWeight = widget.currentWeight * (1 + multiplier);
              widget.onNewWeightChange(newWeight);
            },
            child: Column(
              children:
                  TrainingDifficulty.values.map((difficulty) {
                    final multiplier = widget.loadAdjustmentFunction(
                      difficulty: difficulty,
                    );
                    final int variation = (multiplier * 100).round();
                    final newWeight = widget.currentWeight * (1 + multiplier);
                    final isSelected = _difficulty == difficulty;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? CrimpyTheme.bgInfo
                                : CrimpyTheme.bgSecondary,
                        border: Border.all(
                          color:
                              isSelected
                                  ? CrimpyTheme.primaryOrange
                                  : CrimpyTheme.borderDefault,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() => _difficulty = difficulty);
                          final multiplier = widget.loadAdjustmentFunction(
                            difficulty: difficulty,
                          );
                          final newWeight =
                              widget.currentWeight * (1 + multiplier);
                          widget.onNewWeightChange(newWeight);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            children: [
                              Radio<TrainingDifficulty>(value: difficulty),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      LoadAdjustmentService.getDifficultyDescription(
                                        difficulty,
                                      ),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${newWeight.toStringAsFixed(1)}kg (${variation >= 0 ? '+' : ''}$variation%)",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        color:
                                            isSelected
                                                ? CrimpyTheme.primaryOrange
                                                : CrimpyTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Switch to custom weight
          TextButton.icon(
            onPressed: () {
              setState(() {
                _useCustomWeight = true;
                // Calculate current suggested weight
                final multiplier = widget.loadAdjustmentFunction(
                  difficulty: _difficulty,
                );
                final suggestedWeight = widget.currentWeight * (1 + multiplier);
                _customWeightController.text = suggestedWeight.toStringAsFixed(
                  1,
                );
              });
            },
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Enter custom weight'),
          ),
        ] else ...[
          // Custom weight input
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: CrimpyTheme.bgSecondary,
              border: Border.all(color: CrimpyTheme.primaryOrange, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Custom Weight',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: CrimpyTheme.primaryOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customWeightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'New Weight (kg)',
                    suffixText: 'kg',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: CrimpyTheme.bgPrimary,
                  ),
                  onChanged: (_) => _handleCustomWeightChange(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Switch back to presets
          TextButton.icon(
            onPressed: () {
              setState(() {
                _useCustomWeight = false;
                // Recalculate with difficulty
                final multiplier = widget.loadAdjustmentFunction(
                  difficulty: _difficulty,
                );
                final newWeight = widget.currentWeight * (1 + multiplier);
                widget.onNewWeightChange(newWeight);
              });
            },
            icon: const Icon(Icons.list, size: 16),
            label: const Text('Use suggested weights'),
          ),
        ],
      ],
    );
  }
}
