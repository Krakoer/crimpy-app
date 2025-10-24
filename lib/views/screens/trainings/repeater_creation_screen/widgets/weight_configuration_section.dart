import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class WeightConfigurationSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
            _WeightRow(
              label: 'Weight',
              controller: rightHandWeightController,
              validator: weightValidator,
            )
          else ...[
            _WeightRow(
              label: 'Right hand',
              controller: rightHandWeightController,
              validator: weightValidator,
            ),
            const SizedBox(height: 12),
            _WeightRow(
              label: 'Left hand',
              controller: leftHandWeightController,
              validator: weightValidator,
            ),
          ],
        ],
      ),
    );
  }
}

class _WeightRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?) validator;

  const _WeightRow({
    required this.label,
    required this.controller,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: TextFormField(
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            keyboardType: TextInputType.number,
            controller: controller,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: CrimpyTheme.borderDefault,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: CrimpyTheme.borderDefault,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: CrimpyTheme.primaryOrange,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            validator: validator,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'kg',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
