import 'package:crimpy/logger.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/duration_format.dart';
import 'package:crimpy/utils/training_totals.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/widgets/section_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// The all-time totals of the profile, Krakoer/crimpy#150: what the athlete
/// has done since they started recording, which rewards turning up rather
/// than peak numbers.
class TrainingTotalsCard extends ConsumerWidget {
  const TrainingTotalsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Matched on what the state holds, so a refresh leaves the totals in place
    // while it asks again.
    return switch (ref.watch(trainingTotalsProvider)) {
      AsyncValue(:final value?) => TrainingTotalsView(totals: value),
      AsyncValue(:final error?) => () {
        AppLoggerHelper.error('Failed to load the training totals', error);
        return const _TotalsFrame(
          child: _Note('Your totals could not be loaded. Pull to try again.'),
        );
      }(),
      _ => const _TotalsFrame(
        child: Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

/// The totals themselves, apart from where they are read from.
class TrainingTotalsView extends StatelessWidget {
  final TrainingTotals totals;

  const TrainingTotalsView({required this.totals, super.key});

  @override
  Widget build(BuildContext context) {
    if (totals.isEmpty) {
      return const _TotalsFrame(
        child: _Note('Your totals start with your first session.'),
      );
    }

    final heaviest = totals.heaviestPull;
    final stats = <(String, String, String?)>[
      ('Sessions', '${totals.sessions}', null),
      ('Days trained', '${totals.daysTrained}', null),
      ('Pulls', '${totals.pulls}', null),
      (
        'Time under tension',
        formatLength(Duration(seconds: totals.timeUnderTensionSeconds)),
        null,
      ),
      ('Volume', formatVolume(totals.volumeKg), null),
      if (heaviest != null)
        (
          'Heaviest pull',
          '${heaviest.kilograms.toStringAsFixed(1)} kg',
          _longDate(heaviest.date),
        ),
    ];

    return _TotalsFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var row = 0; row * 2 < stats.length; row++) ...[
            if (row > 0) const SizedBox(height: CrimpyTheme.spaceMd),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var column = 0; column < 2; column++)
                  Expanded(
                    child: row * 2 + column < stats.length
                        ? _Stat(stats[row * 2 + column])
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ],
          const SizedBox(height: CrimpyTheme.spaceLg),
          _Note('Since ${_longDate(totals.since!)}.'),
          const SizedBox(height: CrimpyTheme.spaceXs),
          _Note(measuredNote(totals)),
        ],
      ),
    );
  }

  static String _longDate(DateTime date) => DateFormat.yMMMd().format(date);
}

/// What the loads of the card count, stated in words beside them: only the
/// pulls the sensor measured, and how many of the pulls that was when it was
/// not all of them.
String measuredNote(TrainingTotals totals) {
  const rule =
      'Volume and heaviest pull count only the pulls the sensor '
      'measured';
  if (!totals.someUnweighed) return '$rule.';
  return '$rule: ${totals.weighedPulls} of ${totals.pulls}.';
}

/// A volume in kilograms, in tonnes past ten of them, so a history of years
/// stays a number that reads at a glance.
String formatVolume(double kilograms) {
  if (kilograms >= 10000) {
    return '${(kilograms / 1000).toStringAsFixed(1)} t';
  }
  return '${NumberFormat.decimalPattern().format(kilograms.round())} kg';
}

class _TotalsFrame extends StatelessWidget {
  final Widget child;

  const _TotalsFrame({required this.child});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: CrimpyCards.stats(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading('All-time totals'),
          const SizedBox(height: CrimpyTheme.spaceLg),
          child,
        ],
      ),
    ),
  );
}

class _Stat extends StatelessWidget {
  final (String, String, String?) stat;

  const _Stat(this.stat);

  @override
  Widget build(BuildContext context) {
    final (label, value, detail) = stat;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: CrimpyTheme.bodySmall.copyWith(color: CrimpyTheme.textMedium),
        ),
        Text(value, style: CrimpyTheme.title),
        if (detail != null)
          Text(
            detail,
            style: CrimpyTheme.bodySmall.copyWith(
              color: CrimpyTheme.textSecondary,
            ),
          ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  final String text;

  const _Note(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: CrimpyTheme.bodySmall.copyWith(color: CrimpyTheme.textSecondary),
  );
}
