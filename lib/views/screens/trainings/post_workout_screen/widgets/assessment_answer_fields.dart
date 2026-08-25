import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The question a custom assessment ends on, and the field or fields its answer
/// is entered in. A per hand assessment asks for each arm apart, since that is
/// the point of measuring it that way.
class AssessmentAnswerFields extends StatelessWidget {
  final AssessmentDefinition definition;
  final TextEditingController rightController;
  final TextEditingController leftController;

  const AssessmentAnswerFields({
    required this.definition,
    required this.rightController,
    required this.leftController,
    super.key,
  });

  String get _suffix => switch (definition.unit) {
    AssessmentUnit.kilograms => 'kg',
    AssessmentUnit.seconds => 's',
    AssessmentUnit.repetitions => 'reps',
  };

  Widget _field(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      decoration: InputDecoration(
        labelText: label,
        suffixText: _suffix,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        final parsed = parseAnswer(value);
        if (parsed == null) return 'Enter a number';
        if (parsed < 0) return 'Cannot be negative';
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assessment,
                  color: CrimpyTheme.assessmentColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    definition.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              definition.prompt ?? 'What was your result?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (definition.perHand)
              Row(
                children: [
                  Expanded(
                    child: _field(
                      context,
                      controller: rightController,
                      label: 'Right',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      context,
                      controller: leftController,
                      label: 'Left',
                    ),
                  ),
                ],
              )
            else
              _field(context, controller: rightController, label: 'Result'),
          ],
        ),
      ),
    );
  }
}

/// Reads a typed answer, accepting a comma as the decimal separator since a
/// French keyboard offers that one. Null when there is no number to read.
double? parseAnswer(String? value) {
  final trimmed = value?.trim().replaceAll(',', '.') ?? '';
  if (trimmed.isEmpty) return null;
  return double.tryParse(trimmed);
}
