import 'package:crimpy/models/common.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/assessment_chart_axes.dart';
import 'package:crimpy/utils/load_trends.dart';
import 'package:crimpy/views/widgets/day_line_chart.dart';
import 'package:crimpy/views/widgets/section_widgets.dart';
import 'package:crimpy/views/widgets/series_swatch.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Whether the load of each training is moving, grip by grip: one card per
/// training run at least twice with the sensor, side by side, the next one
/// peeking in, so the section stays one card tall above the list the screen
/// is for however many trainings there are. Krakoer/crimpy#155.
class LoadTrendList extends StatefulWidget {
  final List<TrainingLoadTrend> trends;

  const LoadTrendList({required this.trends, super.key});

  /// Tall enough for a card whose grips run past the width, its chart and its
  /// two notes. A card set in a larger font scrolls inside it rather than
  /// pushing the list down.
  static const double deckHeight = 480;

  @override
  State<LoadTrendList> createState() => _LoadTrendListState();
}

class _LoadTrendListState extends State<LoadTrendList> {
  late final _pages = PageController(
    viewportFraction: widget.trends.length > 1 ? 0.9 : 1,
  );

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SectionHeading('Load per grip'),
      const SizedBox(height: CrimpyTheme.headingGap),
      SizedBox(
        height: LoadTrendList.deckHeight,
        child: PageView.builder(
          controller: _pages,
          padEnds: false,
          itemCount: widget.trends.length,
          itemBuilder: (context, index) {
            final trend = widget.trends[index];
            final card = TrainingLoadTrendCard(
              key: ValueKey(trend.key),
              trend: trend,
            );
            // A gap before the next card only: the last one ends on the edge.
            return index == widget.trends.length - 1
                ? card
                : Padding(
                    padding: const EdgeInsets.only(right: CrimpyTheme.spaceSm),
                    child: card,
                  );
          },
        ),
      ),
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
      (entry) => entry.grip == _selected,
      orElse: () => grips.first,
    );
    final hands = selected.hands;
    final namesHands = hands.length > 1;

    return CrimpyCards.stats(
      margin: CrimpyTheme.cardMargin,
      child: SingleChildScrollView(
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
            // One row that scrolls, so a training hung on many grips keeps the
            // card the height of the deck.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: CrimpyTheme.spaceSm,
                children: [
                  for (final entry in grips)
                    ChoiceChip(
                      label: Text(loadGripLabel(entry.grip)),
                      selected: entry == selected,
                      onSelected: (_) => setState(() => _selected = entry.grip),
                    ),
                ],
              ),
            ),
            const SizedBox(height: CrimpyTheme.spaceMd),
            if (testedDays(selected.points.map((point) => point.date)) < 2)
              _Note(
                'One day on this grip so far, at '
                '${_dayLoads(hands, namesHands)}. The line starts from the '
                'second.',
              )
            else ...[
              SizedBox(
                height: _chartHeight,
                child: DayLineChart(
                  color: CrimpyTheme.trainingLoadSeries,
                  series: [
                    for (final (hand, points) in hands)
                      (
                        name: hand.label,
                        data: [
                          for (final point in points)
                            (point.date, point.kilograms),
                        ],
                        stroke: _strokeOf(hand),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: CrimpyTheme.spaceSm),
              for (final (hand, points) in hands)
                Padding(
                  padding: const EdgeInsets.only(bottom: CrimpyTheme.spaceXs),
                  child: Row(
                    children: [
                      // The swatch says which line the sentence is about, the
                      // way the profile's stat cards name their hands.
                      if (namesHands) ...[
                        SeriesSwatch(
                          color: CrimpyTheme.trainingLoadSeries,
                          stroke: _strokeOf(hand),
                        ),
                        const SizedBox(width: CrimpyTheme.spaceSm),
                      ],
                      Expanded(
                        child: Text(
                          // One day is a value rather than a trend, for one
                          // hand as for the whole grip (Krakoer/crimpy#164).
                          testedDays(points.map((point) => point.date)) < 2
                              ? '${hand.label}: one day so far, at '
                                    '${_dayLoads([(hand, points)], false)}.'
                              : namesHands
                              ? '${hand.label}: '
                                    '${loadTrendNote(points, DateFormat.MMMd().format)}'
                              : loadTrendNote(points, DateFormat.MMMd().format),
                          style: CrimpyTheme.body.copyWith(
                            color: CrimpyTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: CrimpyTheme.spaceXs),
            const _Note(
              'Mean load per session, over the pulls the sensor measured.',
            ),
          ],
        ),
      ),
    );
  }

  static const double _chartHeight = 200;

  /// The left hand solid and the right dashed, as the profile draws them
  /// (Krakoer/crimpy#164); a hang on both hands at once is one solid line.
  static SeriesStroke _strokeOf(HandSide hand) =>
      hand == HandSide.right ? SeriesStroke.dashed : SeriesStroke.solid;

  /// The day's load per hand, when every session of the grip fell on one day:
  /// the mean of its sessions rather than the last of them.
  static String _dayLoads(
    List<(HandSide, List<LoadPoint>)> hands,
    bool namesHands,
  ) => [
    for (final (hand, points) in hands)
      '${(points.map((p) => p.kilograms).reduce((a, b) => a + b) / points.length).toStringAsFixed(1)} kg'
          '${namesHands ? ' (${hand.label.toLowerCase()})' : ''}',
  ].join(', ');
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
