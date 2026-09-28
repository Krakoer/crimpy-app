import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/training_intensity.dart';
import 'package:flutter/material.dart';

/// How hard a training is, on its card: the heaviest prescribed load as a
/// percentage of the athlete's max, spelled out, in a box that grows heavier
/// with the tier. A plain box rather than a chip, so the filled near max one
/// cannot pass for a selected control. See Krakoer/crimpy#166.
class IntensityBadge extends StatelessWidget {
  final TrainingIntensity intensity;

  const IntensityBadge(this.intensity, {super.key});

  @override
  Widget build(BuildContext context) {
    final (line, ground, figure) = switch (intensity.tier) {
      IntensityTier.light => (
        CrimpyTheme.intensityLight,
        CrimpyTheme.bgPrimary,
        CrimpyTheme.intensityLight,
      ),
      IntensityTier.moderate => (
        CrimpyTheme.intensityModerate,
        CrimpyTheme.bgPrimary,
        CrimpyTheme.intensityModerate,
      ),
      IntensityTier.nearMax => (
        CrimpyTheme.intensityNearMax,
        CrimpyTheme.intensityNearMax,
        CrimpyTheme.textOnFill,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: CrimpyTheme.spaceXs),
      decoration: BoxDecoration(
        color: ground,
        border: Border.all(color: line),
        borderRadius: CrimpyTheme.corners,
      ),
      child: Text(
        intensity.label,
        style: CrimpyTheme.tabular(CrimpyTheme.labelSmall).copyWith(
          color: figure,
          fontWeight: intensity.tier == IntensityTier.light
              ? FontWeight.w500
              : FontWeight.w700,
        ),
      ),
    );
  }
}
