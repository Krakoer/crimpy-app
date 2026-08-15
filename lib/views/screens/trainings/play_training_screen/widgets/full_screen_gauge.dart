import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/format.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/hand_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Height the target sits at, as a fraction of the gauge. The room left above
/// it is what an overshoot climbs into, so pulling past the target still reads
/// as pulling harder instead of pinning to the top edge.
const double targetHeightFraction = 0.72;

/// Height of the force level as a fraction of the gauge. With a target, the
/// scale is fixed so the level lands on the target line exactly when the target
/// is met. Without one, it is scaled against the peak of the rep, so pulling
/// still reads as a level rising rather than an empty screen.
double gaugeLevelFraction({
  required double currentWeight,
  required double targetWeight,
  required double peakWeight,
}) {
  final scaleMax = targetWeight > 0 ? targetWeight : peakWeight;
  if (scaleMax <= 0) return 0;
  return (currentWeight / scaleMax * targetHeightFraction).clamp(0.0, 1.0);
}

/// Live force gauge filling the whole run area: the level rises with the pull,
/// the target is a line across the screen, and the readouts sit on top of the
/// level, inverting to white wherever it has swallowed them.
class FullScreenGauge extends ConsumerWidget {
  /// Load the athlete is asked to hold. Zero when the step prescribes none, in
  /// which case the level is scaled against the peak of the rep instead.
  final double targetWeight;

  final int secondsRemaining;

  /// How far through the current rep, from 0 to 1, drawn as the bar closing
  /// along the top edge.
  final double repProgress;

  final HandSide handSide;
  final GripPosition gripPosition;
  final int? edgeSizeMm;
  final String? comment;

  const FullScreenGauge({
    required this.targetWeight,
    required this.secondsRemaining,
    required this.repProgress,
    required this.handSide,
    required this.gripPosition,
    this.edgeSizeMm,
    this.comment,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeight = ref.watch(bleLastValueProvider) ?? 0;
    final stats = ref.watch(bleSessionProvider);
    final onTarget = targetWeight > 0 && currentWeight >= targetWeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final levelHeight =
            height *
            gaugeLevelFraction(
              currentWeight: currentWeight,
              targetWeight: targetWeight,
              peakWeight: stats.max,
            );

        return Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: levelHeight,
                width: double.infinity,
                child: ColoredBox(
                  color: onTarget
                      ? CrimpyTheme.statusSuccess
                      : CrimpyTheme.gray600,
                ),
              ),
            ),
            _readouts(
              height: height,
              currentWeight: currentWeight,
              stats: stats,
              onTarget: onTarget,
              foreground: CrimpyTheme.primaryBlack,
              secondary: CrimpyTheme.textSecondary,
              accent: CrimpyTheme.primaryOrange,
            ),
            // The same readouts in the colors that read against the level,
            // clipped to it. Both copies are laid out identically, so the one
            // on top only ever repaints the part the level has reached.
            if (levelHeight > 0)
              ClipRect(
                clipper: _LevelClipper(levelHeight),
                child: _readouts(
                  height: height,
                  currentWeight: currentWeight,
                  stats: stats,
                  onTarget: onTarget,
                  foreground: CrimpyTheme.primaryWhite,
                  secondary: CrimpyTheme.primaryWhite,
                  accent: CrimpyTheme.primaryWhite,
                ),
              ),
            Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(
                value: repProgress,
                minHeight: 6,
                backgroundColor: CrimpyTheme.gray200,
                color: CrimpyTheme.primaryOrange,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _readouts({
    required double height,
    required double currentWeight,
    required BleSessionStats stats,
    required bool onTarget,
    required Color foreground,
    required Color secondary,
    required Color accent,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (targetWeight > 0)
          Positioned(
            left: 20,
            right: 20,
            top: height * (1 - targetHeightFraction) - 9,
            height: 18,
            child: _targetLine(accent),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            children: [
              // The step name takes the band above the target line, so a long
              // coach comment stops short of it instead of crossing it. A step
              // with no target keeps the same band, so the name does not jump
              // between steps.
              SizedBox(
                height: (height * (1 - targetHeightFraction) - 36).clamp(
                  0.0,
                  height,
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HandLabel(
                          handSide: handSide,
                          gripPosition: gripPosition,
                          edgeSizeMm: edgeSizeMm,
                          color: accent,
                          detailColor: secondary,
                        ),
                        if (comment != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            comment!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 13,
                              height: 1.4,
                              color: secondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              // Clears the target line, so the force readout starts under it
              // rather than sitting across it.
              const SizedBox(height: 36),
              _slot(
                flex: 3,
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sized off the screen rather than fixed, so the readout
                    // is as big as a tablet allows and still fits a phone.
                    _weight(
                      currentWeight,
                      foreground,
                      secondary,
                      (height * 0.17).clamp(48.0, 120.0),
                    ),
                    const SizedBox(height: 4),
                    _onTargetCue(onTarget, accent),
                    const SizedBox(height: 12),
                    _countdown(foreground, (height * 0.08).clamp(24.0, 52.0)),
                  ],
                ),
              ),
              _slot(flex: 2, _repStats(stats, foreground, secondary)),
            ],
          ),
        ),
      ],
    );
  }

  /// A band of the screen given a share of what the step name leaves. Sharing
  /// the height out rather than stacking natural sizes keeps the force readout
  /// in the same place all workout long, and lets a band scale itself down
  /// instead of overflowing on a screen too short to hold it at full size.
  Widget _slot(Widget child, {int flex = 1}) => Expanded(
    flex: flex,
    child: Center(
      child: FittedBox(fit: BoxFit.scaleDown, child: child),
    ),
  );

  Widget _targetLine(Color accent) => Row(
    children: [
      Expanded(child: Container(height: 2, color: accent)),
      const SizedBox(width: 8),
      Text(
        'TARGET ${formatKilograms(targetWeight)} kg',
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: accent,
        ),
      ),
    ],
  );

  Widget _weight(
    double currentWeight,
    Color foreground,
    Color secondary,
    double fontSize,
  ) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          formatKilograms(currentWeight),
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            height: 1,
            color: foreground,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'kg',
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: fontSize * 0.25,
            fontWeight: FontWeight.w500,
            color: secondary,
          ),
        ),
      ],
    ),
  );

  Widget _onTargetCue(bool onTarget, Color accent) => SizedBox(
    height: 20,
    child: onTarget
        ? Center(
            child: Text(
              'ON TARGET',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: accent,
              ),
            ),
          )
        : null,
  );

  Widget _countdown(Color foreground, double fontSize) => Text(
    '${(secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(secondsRemaining % 60).toString().padLeft(2, '0')}',
    style: TextStyle(
      fontFamily: 'JetBrainsMono',
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      height: 1,
      color: foreground,
    ),
  );

  /// What the rep has amounted to so far. The screen has the room for it now,
  /// and it is the pair of numbers the athlete otherwise waits until the end of
  /// the workout to see.
  Widget _repStats(BleSessionStats stats, Color foreground, Color secondary) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stat('PEAK', stats.max, foreground, secondary),
          const SizedBox(width: 56),
          _stat('AVERAGE', stats.avg, foreground, secondary),
        ],
      );

  Widget _stat(String label, double value, Color foreground, Color secondary) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: secondary,
            ),
          ),
          Text(
            '${formatKilograms(value)} kg',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      );
}

/// Keeps only what the level has reached, measured from the bottom edge.
class _LevelClipper extends CustomClipper<Rect> {
  const _LevelClipper(this.levelHeight);

  final double levelHeight;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, size.height - levelHeight, size.width, size.height);

  @override
  bool shouldReclip(_LevelClipper oldClipper) =>
      oldClipper.levelHeight != levelHeight;
}
