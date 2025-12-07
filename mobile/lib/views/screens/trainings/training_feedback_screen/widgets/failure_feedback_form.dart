import 'package:crimpy/models/training_feedback_model.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';

class FailureFeedbackForm extends StatefulWidget {
  final List<RepDataModel> reps;
  final LoadAdjustmentFunction? loadAdjustmentFunction;
  final double currentWeight;
  final void Function(double) onNewWeightChange;

  const FailureFeedbackForm({
    required this.reps,
    required this.loadAdjustmentFunction,
    required this.currentWeight,
    required this.onNewWeightChange,
    super.key,
  });

  @override
  State<FailureFeedbackForm> createState() => _FailureFeedbackFormState();
}

class _FailureFeedbackFormState extends State<FailureFeedbackForm> {
  bool _useCustomWeight = false;
  final _customWeightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with current weight
    _customWeightController.text = widget.currentWeight.toStringAsFixed(1);
    // Calculate and set the new weight based on failure rate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.loadAdjustmentFunction != null) {
        final workingReps = widget.reps.where((r) => !r.isRest).toList();
        final percentageSuccess =
            (workingReps
                    .where((r) => r.averageWeight >= r.targetWeight)
                    .length /
                workingReps.length *
                100);
        final failureRate = 100 - percentageSuccess;

        final multiplier = widget.loadAdjustmentFunction!(
          failureRate: failureRate,
        );
        final newWeight = widget.currentWeight * (1 + multiplier);
        widget.onNewWeightChange(newWeight);
      }
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
    final workingReps = widget.reps.where((r) => !r.isRest).toList();
    final percentageSuccess =
        (workingReps.where((r) => r.averageWeight >= r.targetWeight).length /
                workingReps.length *
                100)
            .round();

    final failureRate = 100 - percentageSuccess;

    double newWeight = widget.currentWeight;
    int variation = 0;
    if (widget.loadAdjustmentFunction != null) {
      final multiplier = widget.loadAdjustmentFunction!(
        failureRate: failureRate.toDouble(),
      );
      newWeight = widget.currentWeight * (1 + multiplier);
      variation = (multiplier * 100).round();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Partial success message
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: CrimpyTheme.bgWarning,
            border: Border.all(color: CrimpyTheme.statusWarning, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: CrimpyTheme.statusWarning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "You completed $percentageSuccess% of the reps",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CrimpyTheme.statusWarning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (widget.loadAdjustmentFunction != null) ...[
          const SizedBox(height: 24),

          // Recommendation label
          Text(
            'Recommended Adjustment',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          if (!_useCustomWeight) ...[
            // Adjustment display
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: CrimpyTheme.bgInfo,
                border: Border.all(color: CrimpyTheme.primaryOrange, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'New Weight:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: CrimpyTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '${newWeight.toStringAsFixed(1)}kg',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          color: CrimpyTheme.primaryOrange,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Change:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: CrimpyTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '${variation >= 0 ? '+' : ''}$variation%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              variation >= 0
                                  ? CrimpyTheme.statusSuccess
                                  : CrimpyTheme.statusError,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: CrimpyTheme.bgSecondary,
                border: Border.all(color: CrimpyTheme.borderDefault, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: CrimpyTheme.textMuted,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This weight will be automatically applied to your next session',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: CrimpyTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Switch to custom weight
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _useCustomWeight = true;
                  _customWeightController.text = newWeight.toStringAsFixed(1);
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

            // Switch back to recommendation
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _useCustomWeight = false;
                  // Recalculate recommended weight
                  if (widget.loadAdjustmentFunction != null) {
                    final workingReps =
                        widget.reps.where((r) => !r.isRest).toList();
                    final percentageSuccess =
                        (workingReps
                                .where((r) => r.averageWeight >= r.targetWeight)
                                .length /
                            workingReps.length *
                            100);
                    final failureRate = 100 - percentageSuccess;
                    final multiplier = widget.loadAdjustmentFunction!(
                      failureRate: failureRate,
                    );
                    final recommendedWeight =
                        widget.currentWeight * (1 + multiplier);
                    widget.onNewWeightChange(recommendedWeight);
                  }
                });
              },
              icon: const Icon(Icons.auto_fix_high, size: 16),
              label: const Text('Use recommended weight'),
            ),
          ],
        ],
      ],
    );
  }
}
