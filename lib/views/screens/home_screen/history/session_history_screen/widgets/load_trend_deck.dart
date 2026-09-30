import 'package:crimpy/logger.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/assessment_chart_axes.dart';
import 'package:crimpy/utils/load_trends.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/widgets/day_line_chart.dart';
import 'package:crimpy/views/widgets/section_widgets.dart';
import 'package:crimpy/views/widgets/series_swatch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Whether the load of each training is moving, grip by grip: one card per
/// training run at least twice with the sensor. Krakoer/crimpy#155.
///
/// Draws nothing until there is a trend to show, and nothing when the history
/// with its reps cannot be read: the sessions below are the screen, and this
/// is a reading of them rather than a part the athlete needs to go on.
class LoadTrendDeck extends ConsumerWidget {
  const LoadTrendDeck({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trends = ref.watch(trainingLoadTrendsProvider);
    if (trends case AsyncValue(:final error?, hasValue: false)) {
      AppLoggerHelper.error('Failed to load the training load trends', error);
    }
    final value = trends.value;
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return LoadTrendList(trends: value);
  }
}

/// The cards themselves, apart from where they are read from.
class LoadTrendList extends StatelessWidget {
  final List<TrainingLoadTrend> trends;

  const LoadTrendList({required this.trends, super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SectionHeading('Load per grip'),
      const SizedBox(height: CrimpyTheme.headingGap),
      for (final trend in trends)
        TrainingLoadTrendCard(key: ValueKey(trend.key), trend: trend),
      const SizedBox(height: CrimpyTheme.spaceLg),
    ],
  );
}

class TrainingLoadTrendCard extends StatefulWidget {
  final TrainingLoadTrend trend;

  const TrainingLoadTrendCard({required this.trend, super.key});

  @override
  State<TrainingLoadTrendCard> createState() => _TrainingLoadTrendCardState();
}

class _TrainingLoadTrendCardState extends State<TrainingLoadTrendCard> {
  LoadGrip? _selected;

  @override
  Widget build(BuildContext context) {
    final grips = widget.trend.grips;
    // A grip no longer in the trend, after a run was deleted, falls back to the
    // most weighed one rather than to nothing.
    final selected = grips.firstWhere(
      (entry) => entry.$1 == _selected,
      orElse: () => grips.first,
    );
    final points = selected.$2;
    final data = [for (final point in points) (point.date, point.kilograms)];

    return CrimpyCards.stats(
      margin: CrimpyTheme.cardMargin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.trend.title,
            style: CrimpyTheme.titleSmall.copyWith(
              color: CrimpyTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: CrimpyTheme.spaceSm),
          Wrap(
            spacing: CrimpyTheme.spaceSm,
            runSpacing: CrimpyTheme.spaceSm,
            children: [
              for (final (grip, _) in grips)
                ChoiceChip(
                  label: Text(loadGripLabel(grip)),
                  selected: grip == selected.$1,
                  onSelected: (_) => setState(() => _selected = grip),
                ),
            ],
          ),
          const SizedBox(height: CrimpyTheme.spaceMd),
          if (testedDays(points.map((point) => point.date)) < 2)
            _Note(
              'One day on this grip so far, at '
              '${points.last.kilograms.toStringAsFixed(1)} kg. The line starts '
              'from the second.',
            )
          else ...[
            SizedBox(
              height: _chartHeight,
              child: DayLineChart(
                color: CrimpyTheme.trainingLoadSeries,
                series: [
                  (name: 'Mean load', data: data, stroke: SeriesStroke.solid),
                ],
              ),
            ),
            const SizedBox(height: CrimpyTheme.spaceSm),
            Text(
              loadTrendNote(points, DateFormat.MMMd().format),
              style: CrimpyTheme.body.copyWith(color: CrimpyTheme.textPrimary),
            ),
          ],
          const SizedBox(height: CrimpyTheme.spaceXs),
          const _Note(
            'Mean load per session, over the pulls the sensor measured.',
          ),
        ],
      ),
    );
  }

  static const double _chartHeight = 200;
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
