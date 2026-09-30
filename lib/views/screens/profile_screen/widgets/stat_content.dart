import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/assessment_chart.dart';
import 'package:crimpy/views/widgets/series_swatch.dart';
import 'package:crimpy/views/widgets/section_widgets.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class StatContent extends StatelessWidget {
  final String title;
  final double maxLeft;
  final double maxRight;
  final Color seriesColor;
  final List<(DateTime, double)> rightData;
  final List<(DateTime, double)> leftData;
  final VoidCallback onStartAssessment;
  final AssessmentUnit unit;

  /// An assessment measured on one hand at a time shows a card and a series per
  /// hand. One measured as a single number shows one of each: calling that
  /// number a hand would be a lie the legend then repeats.
  final bool perHand;

  const StatContent({
    required this.title,
    required this.maxLeft,
    required this.maxRight,
    required this.seriesColor,
    required this.leftData,
    required this.rightData,
    required this.onStartAssessment,
    this.unit = AssessmentUnit.kilograms,
    this.perHand = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(alignment: Alignment.centerLeft, child: SectionHeading(title)),
        SizedBox(height: CrimpyTheme.spaceMd),
        if (perHand)
          Row(
            children: [
              Expanded(
                child: StatCard(
                  "Left Hand",
                  maxLeft == 0 ? "--" : formatAssessmentValue(maxLeft, unit),
                  seriesColor,
                ),
              ),
              const SizedBox(width: CrimpyTheme.spaceMd),
              Expanded(
                child: StatCard(
                  "Right Hand",
                  maxRight == 0 ? "--" : formatAssessmentValue(maxRight, unit),
                  seriesColor,
                  stroke: SeriesStroke.dashed,
                ),
              ),
            ],
          )
        else
          StatCard(
            "Best",
            maxRight == 0 ? "--" : formatAssessmentValue(maxRight, unit),
            seriesColor,
          ),
        const SizedBox(height: CrimpyTheme.spaceLg),
        ForceChart(
          leftData: perHand ? leftData : const [],
          rightData: rightData,
          seriesColor: seriesColor,
          unit: unit,
          onStartAssessment: onStartAssessment,
          perHand: perHand,
        ),
      ],
    );
  }
}
