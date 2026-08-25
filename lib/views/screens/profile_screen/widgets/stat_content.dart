import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/assessment_chart.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/section_tile.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/stat_card.dart';
import 'package:flutter/material.dart';

class StatContent extends StatelessWidget {
  final String title;
  final double maxLeft;
  final double maxRight;
  final Color accentLeft;
  final Color accentRight;
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
    required this.accentLeft,
    required this.accentRight,
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
        SectionTitle(title),
        SizedBox(height: 12),
        if (perHand)
          Row(
            children: [
              Expanded(
                child: StatCard(
                  "Left Hand",
                  maxLeft == 0 ? "--" : formatAssessmentValue(maxLeft, unit),
                  accentLeft,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  "Right Hand",
                  maxRight == 0 ? "--" : formatAssessmentValue(maxRight, unit),
                  accentRight,
                ),
              ),
            ],
          )
        else
          StatCard(
            "Best",
            maxRight == 0 ? "--" : formatAssessmentValue(maxRight, unit),
            accentRight,
          ),
        const SizedBox(height: 16),
        ForceChart(
          leftData: perHand ? leftData : const [],
          rightData: rightData,
          accentLeft: accentLeft,
          accentRight: accentRight,
          onStartAssessment: onStartAssessment,
          showLegend: perHand,
        ),
      ],
    );
  }
}
