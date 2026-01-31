import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';
import 'waveform_visualization.dart';

/// Build a card for a single set
class RepeaterDescriptionCard extends StatelessWidget {
  final RepeaterModel repeater;

  const RepeaterDescriptionCard({super.key, required this.repeater});

  @override
  Widget build(BuildContext context) {
    return CrimpyCards.training(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Set header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CrimpyTheme.accentOrange,
                  border: Border.all(
                    color: CrimpyTheme.borderDefault,
                    width: 1,
                  ),
                ),
                child: Text(
                  'TRAINING STRUCTURE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: CrimpyTheme.primaryWhite,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SizedBox(width: 15),
              Text(
                "${repeater.sets} sets structured\nas follows.",
                style: TextStyle(
                  fontSize: 12,
                  color: CrimpyTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Set timeline
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set Timeline',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CrimpyTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              RepeaterWaveformVisualization(repeater: repeater),
            ],
          ),
        ],
      ),
    );
  }
}
