import 'package:crimpy/models/gauge_style.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/viewmodels/gauge_style_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Picks the design the live force gauge is drawn with during a workout.
class GaugeStyleSelector extends ConsumerWidget {
  const GaugeStyleSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(gaugeStyleProvider).value ?? GaugeStyle.fallback;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Gauge design',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<GaugeStyle>(
            segments: [
              for (final style in GaugeStyle.values)
                ButtonSegment(value: style, label: Text(style.displayName)),
            ],
            selected: {selected},
            showSelectedIcon: false,
            onSelectionChanged: (selection) =>
                ref.read(gaugeStyleProvider.notifier).set(selection.first),
          ),
          const SizedBox(height: 8),
          Text(
            selected.description,
            style: const TextStyle(
              fontSize: 12,
              color: CrimpyTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
