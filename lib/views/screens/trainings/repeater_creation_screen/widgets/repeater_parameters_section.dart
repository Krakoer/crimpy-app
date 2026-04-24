import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/format.dart';

class RepeaterParametersSection extends StatelessWidget {
  final TextEditingController setNumberController;
  final TextEditingController repsNumberController;
  final Duration worktime;
  final Duration rest;
  final Duration setRest;
  final Function(Duration) onWorktimeChanged;
  final Function(Duration) onRestChanged;
  final Function(Duration) onSetRestChanged;
  final Function(BuildContext, Function(Duration), Duration) showDurationPicker;

  const RepeaterParametersSection({
    super.key,
    required this.setNumberController,
    required this.repsNumberController,
    required this.worktime,
    required this.rest,
    required this.setRest,
    required this.onWorktimeChanged,
    required this.onRestChanged,
    required this.onSetRestChanged,
    required this.showDurationPicker,
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
            'WORKOUT STRUCTURE',
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: CrimpyTheme.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _ParameterRow(
            label: 'Sets',
            controller: setNumberController,
            unit: '',
          ),
          const SizedBox(height: 12),
          _ParameterRow(
            label: 'Reps per set',
            controller: repsNumberController,
            unit: '',
          ),
          const SizedBox(height: 12),
          _DurationRow(
            label: 'Work time',
            duration: worktime,
            onTap: () =>
                showDurationPicker(context, onWorktimeChanged, worktime),
          ),
          const SizedBox(height: 12),
          _DurationRow(
            label: 'Rest time',
            duration: rest,
            onTap: () => showDurationPicker(context, onRestChanged, rest),
          ),
          const SizedBox(height: 12),
          _DurationRow(
            label: 'Set rest',
            duration: setRest,
            onTap: () => showDurationPicker(context, onSetRestChanged, setRest),
          ),
        ],
      ),
    );
  }
}

class _ParameterRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String unit;

  const _ParameterRow({
    required this.label,
    required this.controller,
    required this.unit,
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                return 'Invalid';
              }
              return null;
            },
          ),
        ),
        if (unit.isNotEmpty) ...[
          const SizedBox(width: 8),
          Text(
            unit,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _DurationRow extends StatelessWidget {
  final String label;
  final Duration duration;
  final VoidCallback onTap;

  const _DurationRow({
    required this.label,
    required this.duration,
    required this.onTap,
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
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: CrimpyTheme.borderDefault, width: 2),
                color: CrimpyTheme.bgPrimary,
              ),
              child: Text(
                formatDurationMinSec(duration),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: CrimpyTheme.primaryOrange,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
