import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/views/widgets/mvc_weight_input_field.dart';

class WeightConfigurationSection extends ConsumerWidget {
  final bool splitHand;
  final TextEditingController rightHandWeightController;
  final TextEditingController leftHandWeightController;
  final String? Function(String?) weightValidator;

  const WeightConfigurationSection({
    super.key,
    required this.splitHand,
    required this.rightHandWeightController,
    required this.leftHandWeightController,
    required this.weightValidator,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CrimpyTheme.bgSecondary,
        border: Border.all(color: CrimpyTheme.borderDefault, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TARGET WEIGHT',
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: CrimpyTheme.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          if (!splitHand)
            MvcWeightInputField(
              label: 'Weight',
              controller: rightHandWeightController,
              validator: weightValidator,
              handSide: HandSide.right,
            )
          else ...[
            MvcWeightInputField(
              label: 'Right hand',
              controller: rightHandWeightController,
              validator: weightValidator,
              handSide: HandSide.right,
            ),
            const SizedBox(height: 12),
            MvcWeightInputField(
              label: 'Left hand',
              controller: leftHandWeightController,
              validator: weightValidator,
              handSide: HandSide.left,
            ),
          ],
        ],
      ),
    );
  }
}
