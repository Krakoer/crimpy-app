import 'dart:math';

import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/format.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Height of the strip holding the state word and the controls, under the tank.
const double controlStripHeight = 96;

/// Tank height the type sizes below are written at. Every size scales from the
/// tank the phone actually gives, so a small screen stays legible and a tablet
/// does not overflow.
const double _referenceTankHeight = 624;

/// Height the target sits at, as a fraction of the tank. It is where the fill
/// mapping puts the target, so the level lands on the notch exactly when the
/// target is met.
const double targetNotchFraction = 0.67;

/// Weight the tank is full at the notch for, or 0 when there is nothing stable
/// to scale against. A step prescribing a load uses it. A max hang prescribes
/// none, and is scaled against the bodyweight instead: it is known before the
/// first sample and does not move during the rep, which the peak of the rep
/// does not manage, being the current value all the way up the pull.
double tankScaleWeight({
  required double targetWeight,
  required double? bodyweight,
}) => targetWeight > 0 ? targetWeight : (bodyweight ?? 0);

/// Height of the force level as a fraction of the tank. It is the mapping the
/// circular gauge already fills with, so both designs read the same. With
/// nothing to scale against the tank stays empty, as the circle does.
double tankFillFraction({
  required double currentWeight,
  required double scaleWeight,
}) {
  if (scaleWeight <= 0) return 0;
  return min(1.0, currentWeight / scaleWeight * targetNotchFraction);
}

/// What the tank draws, which is what the running step is.
enum _TankState { preparation, sensorWork, rest, timed, confirm }

/// Colors the tank content is drawn in. The content is painted twice, once in
/// the colors that read on the empty tank and once in the colors that read on
/// the force level, the second clipped to the level. A number the level is
/// halfway up is then half black and half white.
class _TankPalette {
  final Color force;
  final Color secondary;
  final Color accent;
  final Color muted;
  final Color detail;
  final Color notch;

  const _TankPalette({
    required this.force,
    required this.secondary,
    required this.accent,
    required this.muted,
    required this.detail,
    required this.notch,
  });

  static const overTank = _TankPalette(
    force: CrimpyTheme.primaryBlack,
    secondary: CrimpyTheme.textSecondary,
    accent: CrimpyTheme.primaryOrange,
    muted: CrimpyTheme.textMuted,
    detail: CrimpyTheme.gray400,
    notch: CrimpyTheme.borderDefault,
  );

  static const overFill = _TankPalette(
    force: CrimpyTheme.primaryWhite,
    secondary: CrimpyTheme.textOnFillSecondary,
    accent: CrimpyTheme.primaryWhite,
    muted: CrimpyTheme.textOnFillSecondary,
    detail: CrimpyTheme.textOnFillSecondary,
    notch: CrimpyTheme.primaryWhite,
  );
}

/// Run screen where the force gauge is the whole screen: it fills bottom-up,
/// the force is set as large as the screen allows and the countdown is plain
/// numerals in the corner. Made to be read from across the room, mid-hang.
///
/// The layout is a pure function of what the run screen already holds. Timing,
/// rep recording and the workout lifecycle stay with the screen.
class FullTankLayout extends ConsumerWidget {
  final TrainingExecutionItem item;

  /// Step the current one leads into, used by the rest block and by the line
  /// under the state word. Null on the last step.
  final TrainingExecutionItem? nextItem;

  final int secondsRemaining;
  final int elapsedMilliseconds;
  final int remainingMilliseconds;

  /// Whether the total remaining time is known, which self-paced steps make it
  /// not.
  final bool showRemaining;

  /// Whether the countdown before the first step is running.
  final bool isPreparation;

  final bool isRunning;

  /// Set and rep of the running step, shown in the pill.
  final String? repContext;

  /// Coach comments on the running and upcoming steps.
  final String? comment;
  final String? nextComment;

  final VoidCallback onPlayPause;
  final VoidCallback onSkip;
  final VoidCallback onConfirm;

  const FullTankLayout({
    required this.item,
    required this.nextItem,
    required this.secondsRemaining,
    required this.elapsedMilliseconds,
    required this.remainingMilliseconds,
    required this.showRemaining,
    required this.isPreparation,
    required this.isRunning,
    required this.repContext,
    required this.comment,
    required this.nextComment,
    required this.onPlayPause,
    required this.onSkip,
    required this.onConfirm,
    super.key,
  });

  _TankState get _state {
    if (isPreparation) return _TankState.preparation;
    return switch (item) {
      ConfirmItem() => _TankState.confirm,
      RestItem() => _TankState.rest,
      TimedItem(:final collectSensorData) =>
        collectSensorData ? _TankState.sensorWork : _TankState.timed,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = _state;
    final sensor = state == _TankState.sensorWork;
    final rep = item is TimedItem ? item as TimedItem : null;
    final targetWeight = rep?.targetLoad ?? 0;

    // The tank only follows the sensor on a step that reads it. Watching the
    // stream on the other steps would rebuild the screen on every sample for
    // nothing.
    final currentWeight = sensor ? ref.watch(bleLastValueProvider) ?? 0 : 0.0;
    // Only a step prescribing no load needs the bodyweight to scale against.
    final bodyweight = sensor && targetWeight <= 0
        ? ref.watch(bodyweightProvider).value
        : null;

    final scaleWeight = sensor
        ? tankScaleWeight(targetWeight: targetWeight, bodyweight: bodyweight)
        : 0.0;
    final onTarget =
        sensor && targetWeight > 0 && currentWeight >= targetWeight;
    final fillFraction = tankFillFraction(
      currentWeight: currentWeight,
      scaleWeight: scaleWeight,
    );
    final notchLabel = scaleWeight <= 0
        ? null
        : targetWeight > 0
        ? 'TARGET ${formatKilograms(targetWeight)} kg'
        : 'BW ${formatKilograms(scaleWeight)} kg';
    final paused = !isRunning && !isPreparation;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tankHeight = max(0.0, constraints.maxHeight - controlStripHeight);
        final scale = tankHeight / _referenceTankHeight;
        final fillHeight = fillFraction * tankHeight;

        Widget content(_TankPalette palette) => _TankContent(
          layout: this,
          state: state,
          palette: palette,
          tankHeight: tankHeight,
          scale: scale,
          currentWeight: currentWeight,
          notchLabel: notchLabel,
        );

        final tank = Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: state == _TankState.rest
                  ? CrimpyTheme.bgSuccess
                  : CrimpyTheme.primaryWhite,
            ),
            if (fillHeight > 0)
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: fillHeight,
                  width: double.infinity,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    color: onTarget
                        ? CrimpyTheme.statusSuccess
                        : CrimpyTheme.gray600,
                  ),
                ),
              ),
            content(_TankPalette.overTank),
            if (fillHeight > 0)
              ClipRect(
                clipper: _FillClipper(fillHeight),
                child: content(_TankPalette.overFill),
              ),
          ],
        );

        return Column(
          children: [
            SizedBox(
              height: tankHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Pausing dims the tank rather than hiding it, so the athlete
                  // still sees where the run stopped.
                  if (paused) Opacity(opacity: 0.38, child: tank) else tank,
                  if (repContext != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 16,
                      child: Center(
                        child: _RepContextPill(
                          text: repContext!,
                          overFill: fillHeight > 0,
                        ),
                      ),
                    ),
                  if (paused)
                    Align(
                      alignment: const Alignment(0, -0.08),
                      child: _PausedCard(scale: scale),
                    ),
                ],
              ),
            ),
            _ControlStrip(
              stateWord: _stateWord(paused: paused, onTarget: onTarget),
              stateColor: _stateColor(paused: paused, onTarget: onTarget),
              detail: paused ? repContext : _nextStepLine(),
              isRunning: isRunning,
              showConfirm: state == _TankState.confirm,
              onPlayPause: onPlayPause,
              onSkip: onSkip,
              onConfirm: onConfirm,
            ),
          ],
        );
      },
    );
  }

  String _stateWord({required bool paused, required bool onTarget}) {
    if (isPreparation) return 'READY';
    if (paused) return 'PAUSED';
    if (item is RestItem) return 'REST';
    if (onTarget) return 'ON TARGET';
    return 'WORK';
  }

  Color _stateColor({required bool paused, required bool onTarget}) {
    if (isPreparation) return CrimpyTheme.primaryOrange;
    if (paused) return CrimpyTheme.textMuted;
    if (item is RestItem || onTarget) return CrimpyTheme.statusSuccess;
    return CrimpyTheme.primaryOrange;
  }

  /// The step coming up, under the state word. A preparation and a rest fill
  /// the middle of the tank with what is next already, so their strip stays
  /// down to the one word.
  String? _nextStepLine() {
    if (isPreparation || item is RestItem || nextItem == null) return null;
    return 'Next: ${describeExecutionItem(nextItem!)}';
  }
}

/// One line naming a step, e.g. "rest 3s" or "hang 7s".
String describeExecutionItem(TrainingExecutionItem item) => switch (item) {
  RestItem(:final durationSeconds) => 'rest ${durationSeconds}s',
  ConfirmItem(:final label) => label.toLowerCase(),
  TimedItem(:final label, :final durationSeconds) =>
    '${label.toLowerCase()} ${durationSeconds}s',
};

/// Everything drawn inside the tank. It is built twice in the two palettes and
/// both copies share this layout exactly, so the clipped one lands in register
/// with the one under it.
class _TankContent extends StatelessWidget {
  final FullTankLayout layout;
  final _TankState state;
  final _TankPalette palette;
  final double tankHeight;
  final double scale;
  final double currentWeight;

  /// What the notch stands for, e.g. "TARGET 42 kg", or null when there is
  /// nothing to scale against and no notch is drawn.
  final String? notchLabel;

  const _TankContent({
    required this.layout,
    required this.state,
    required this.palette,
    required this.tankHeight,
    required this.scale,
    required this.currentWeight,
    required this.notchLabel,
  });

  double _s(double size) => size * scale;

  /// Whether the platform leaves the athlete no way back out of the workout
  /// on its own, the app bar being gone in this design.
  bool _needsBackButton(BuildContext context) =>
      Theme.of(context).platform == TargetPlatform.iOS;

  /// A type size, scaled from the tank the phone gave. Display numbers clamp
  /// so they stay readable on a small screen without overflowing a large one.
  TextStyle _style(
    double size, {
    required Color color,
    FontWeight weight = FontWeight.w500,
    double letterSpacing = 0,
    double height = 1,
    double? min,
    double? max,
  }) => TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: (min == null || max == null)
        ? _s(size)
        : _s(size).clamp(min, max),
    fontWeight: weight,
    letterSpacing: _s(letterSpacing),
    height: height,
    color: color,
  );

  @override
  Widget build(BuildContext context) {
    // A step with no sensor puts its countdown in the middle of the screen, so
    // the corner is free for the total time left.
    final cornerCountdown =
        state != _TankState.timed && state != _TankState.confirm;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (notchLabel != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: tankHeight * targetNotchFraction,
            height: 2,
            child: ColoredBox(color: palette.notch),
          ),
        // Without an app bar, a platform with no hardware back button needs
        // something to leave the workout with. It goes through the same
        // confirmation the back gesture does.
        if (_needsBackButton(context))
          Positioned(
            left: 0,
            top: 0,
            width: 44,
            height: 44,
            child: IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back),
              iconSize: 18,
              color: palette.force,
              padding: EdgeInsets.zero,
            ),
          ),
        Positioned(
          left: 16,
          top: _needsBackButton(context) ? 58 : 14,
          right: 16 + _s(140),
          child: _topLeftBlock(),
        ),
        if (cornerCountdown)
          Positioned(right: 16, top: 14, child: _countdown())
        else if (layout.showRemaining)
          Positioned(
            right: 16,
            top: 14,
            child: _timeBlock(
              'LEFT',
              layout.remainingMilliseconds,
              alignEnd: true,
            ),
          ),
        if (state == _TankState.sensorWork)
          ..._forceReadout()
        else
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Center(child: _centerBlock()),
            ),
          ),
      ],
    );
  }

  Widget _topLeftBlock() {
    final rep = layout.item is TimedItem ? layout.item as TimedItem : null;
    final namesTheGrip = state == _TankState.sensorWork;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _timeBlock('ELAPSED', layout.elapsedMilliseconds),
        if (namesTheGrip) ...[
          SizedBox(height: _s(10)),
          Text(
            rep!.handSide.displayName,
            style: _style(
              16,
              color: palette.accent,
              weight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          Text(
            gripLine(rep.gripPosition, rep.edgeSizeMm),
            style: _style(12, color: palette.detail),
          ),
        ],
        // Only a sensor step has its middle taken by the force. Every other
        // state carries the comment in the block it centers there.
        if (layout.comment != null && state == _TankState.sensorWork) ...[
          SizedBox(height: _s(6)),
          Text(
            layout.comment!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _style(11, color: palette.secondary, height: 1.4),
          ),
        ],
      ],
    );
  }

  Widget _timeBlock(String label, int milliseconds, {bool alignEnd = false}) =>
      Column(
        crossAxisAlignment: alignEnd
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: _style(
              9,
              color: palette.muted,
              weight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          Text(
            formatMillisMinutesSeconds(milliseconds),
            style: _style(20, color: palette.force),
          ),
        ],
      );

  /// Seconds left, without minutes or colon under a minute. A hang is counted
  /// in seconds and a bare numeral is the fastest thing to read.
  Widget _countdown() {
    final seconds = layout.secondsRemaining;
    final resting = state == _TankState.rest;
    final color = resting ? CrimpyTheme.statusSuccess : palette.force;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          seconds < 60
              ? '$seconds'
              : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
          style: _style(
            seconds < 60 ? 92 : 64,
            color: color,
            weight: FontWeight.w900,
            letterSpacing: -2,
            height: 0.9,
          ),
        ),
        Text(
          resting ? 'SEC REST' : 'SEC',
          style: _style(
            11,
            color: resting ? CrimpyTheme.statusSuccess : palette.secondary,
            weight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  /// The force, as large as the tank allows, over the level that measures it.
  List<Widget> _forceReadout() {
    final formatted = formatKilograms(currentWeight);
    final dot = formatted.indexOf('.');

    Widget line(double top, Widget child) =>
        Positioned(left: 0, right: 0, top: tankHeight * top, child: child);

    return [
      line(
        0.330,
        Text(
          dot == -1 ? formatted : formatted.substring(0, dot),
          textAlign: TextAlign.center,
          style: _style(
            116,
            color: palette.force,
            weight: FontWeight.w900,
            letterSpacing: -4,
            min: 96,
            max: 160,
          ),
        ),
      ),
      line(
        0.516,
        Text(
          '${dot == -1 ? '' : formatted.substring(dot)} kg',
          textAlign: TextAlign.center,
          style: _style(40, color: palette.force, weight: FontWeight.w900),
        ),
      ),
      if (notchLabel != null)
        line(
          0.606,
          Text(
            notchLabel!,
            textAlign: TextAlign.center,
            style: _style(
              16,
              color: palette.secondary,
              weight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ),
    ];
  }

  Widget _centerBlock() => switch (state) {
    _TankState.preparation => _preparationBlock(),
    _TankState.rest => _nextStepBlock(),
    _TankState.timed => _timedBlock(),
    _TankState.confirm => _confirmBlock(),
    _TankState.sensorWork => const SizedBox.shrink(),
  };

  Widget _column(List<Widget> children) =>
      Column(mainAxisSize: MainAxisSize.min, children: children);

  Widget _preparationBlock() {
    final next = layout.nextItem;
    final rep = next is TimedItem ? next : null;

    return _column([
      Text(
        'PREPARATION',
        style: _style(
          22,
          color: CrimpyTheme.primaryOrange,
          weight: FontWeight.w700,
          letterSpacing: 4,
        ),
      ),
      SizedBox(height: _s(14)),
      Text(
        _preparationInstruction(rep),
        textAlign: TextAlign.center,
        style: _style(14, color: palette.secondary, height: 1.6),
      ),
      if (rep != null && rep.targetLoad > 0) ...[
        SizedBox(height: _s(16)),
        Text(
          'FIRST TARGET ${formatKilograms(rep.targetLoad)} kg',
          style: _style(
            15,
            color: palette.force,
            weight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    ]);
  }

  String _preparationInstruction(TimedItem? rep) {
    if (rep == null) return 'Get ready.';
    if (!rep.collectSensorData) {
      return 'Get ready. First up: ${rep.label.toLowerCase()}.';
    }
    final hands = rep.handSide.displayName.toLowerCase();
    return 'Get on the edge. '
        '${hands[0].toUpperCase()}${hands.substring(1)}, '
        '${rep.gripPosition.displayName.toLowerCase()}'
        '${rep.edgeSizeMm == null ? '' : ', ${rep.edgeSizeMm}mm'}.';
  }

  Widget _nextStepBlock() {
    final next = layout.nextItem;
    if (next == null) {
      return Text(
        'LAST REST',
        style: _style(
          22,
          color: CrimpyTheme.statusSuccess,
          weight: FontWeight.w700,
          letterSpacing: 4,
        ),
      );
    }
    final rep = next is TimedItem ? next : null;
    final sensor = rep?.collectSensorData ?? false;

    return _column([
      Text(
        'NEXT',
        style: _style(
          12,
          color: palette.secondary,
          weight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
      SizedBox(height: _s(14)),
      Text(
        sensor
            ? rep!.handSide.displayName
            : describeExecutionItem(next).toUpperCase(),
        textAlign: TextAlign.center,
        style: _style(30, color: palette.force, weight: FontWeight.w900),
      ),
      if (rep != null) ...[
        SizedBox(height: _s(14)),
        Text(
          [
            if (rep.targetLoad > 0) '${formatKilograms(rep.targetLoad)} kg',
            '${rep.durationSeconds}s',
          ].join(' - '),
          style: _style(
            20,
            color: CrimpyTheme.primaryOrange,
            weight: FontWeight.w700,
          ),
        ),
        if (sensor) ...[
          SizedBox(height: _s(14)),
          Text(
            gripLine(rep.gripPosition, rep.edgeSizeMm),
            style: _style(13, color: palette.secondary),
          ),
        ],
      ],
      if (layout.nextComment != null) ...[
        SizedBox(height: _s(14)),
        Text(
          layout.nextComment!,
          textAlign: TextAlign.center,
          style: _style(13, color: palette.secondary, height: 1.4),
        ),
      ],
    ]);
  }

  Widget _timedBlock() {
    final rep = layout.item as TimedItem;

    return _column([
      Text(
        rep.label.toUpperCase(),
        textAlign: TextAlign.center,
        style: _style(
          18,
          color: CrimpyTheme.primaryOrange,
          weight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
      if (layout.comment != null) ...[
        SizedBox(height: _s(8)),
        Text(
          layout.comment!,
          textAlign: TextAlign.center,
          style: _style(13, color: palette.secondary, height: 1.4),
        ),
      ],
      SizedBox(height: _s(8)),
      Text(
        '${layout.secondsRemaining}',
        style: _style(
          150,
          color: palette.force,
          weight: FontWeight.w900,
          letterSpacing: -6,
          height: 0.9,
          min: 120,
          max: 190,
        ),
      ),
      SizedBox(height: _s(8)),
      Text(
        'SEC LEFT',
        style: _style(
          14,
          color: palette.secondary,
          weight: FontWeight.w700,
          letterSpacing: 4,
        ),
      ),
      if (rep.targetLoad > 0) ...[
        SizedBox(height: _s(12)),
        Text(
          'TARGET ${formatKilograms(rep.targetLoad)} kg',
          style: _style(15, color: palette.muted, weight: FontWeight.w700),
        ),
      ],
    ]);
  }

  Widget _confirmBlock() {
    final rep = layout.item as ConfirmItem;
    final details = [
      if (rep.reps != null) '${rep.reps} reps',
      if (rep.load != null) rep.load!,
    ].join('  -  ');

    return _column([
      Text(
        rep.label.toUpperCase(),
        textAlign: TextAlign.center,
        style: _style(
          18,
          color: CrimpyTheme.primaryOrange,
          weight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
      if (layout.comment != null) ...[
        SizedBox(height: _s(8)),
        Text(
          layout.comment!,
          textAlign: TextAlign.center,
          style: _style(13, color: palette.secondary, height: 1.4),
        ),
      ],
      if (details.isNotEmpty) ...[
        SizedBox(height: _s(14)),
        Text(
          details,
          textAlign: TextAlign.center,
          style: _style(30, color: palette.force, weight: FontWeight.w900),
        ),
      ],
      SizedBox(height: _s(14)),
      Text(
        'Tap DONE when finished',
        style: _style(13, color: palette.secondary),
      ),
    ]);
  }
}

String gripLine(GripPosition gripPosition, int? edgeSizeMm) => [
  gripPosition.shortName,
  if (edgeSizeMm != null) '${edgeSizeMm}mm',
].join(' - ');

/// Keeps the inverted copy of the tank content to the part of the screen the
/// force level covers.
class _FillClipper extends CustomClipper<Rect> {
  final double fillHeight;

  const _FillClipper(this.fillHeight);

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, size.height - fillHeight, size.width, size.height);

  @override
  bool shouldReclip(_FillClipper oldClipper) =>
      oldClipper.fillHeight != fillHeight;
}

/// Set and rep of the running step. Its background is opaque over the level so
/// it never ends up unreadable half way through an inversion.
class _RepContextPill extends StatelessWidget {
  final String text;
  final bool overFill;

  const _RepContextPill({required this.text, required this.overFill});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: overFill
          ? CrimpyTheme.primaryWhite
          : CrimpyTheme.primaryOrange.withValues(alpha: 0.12),
      border: Border.all(color: CrimpyTheme.primaryOrange, width: 1.5),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: CrimpyTheme.primaryOrange,
      ),
    ),
  );
}

class _PausedCard extends StatelessWidget {
  final double scale;

  const _PausedCard({required this.scale});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: CrimpyTheme.primaryWhite,
      border: Border.fromBorderSide(
        BorderSide(color: CrimpyTheme.borderDefault, width: 2),
      ),
      boxShadow: [
        BoxShadow(color: CrimpyTheme.borderDefault, offset: Offset(3, 3)),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'PAUSED',
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 24 * scale,
            fontWeight: FontWeight.w900,
            letterSpacing: 4 * scale,
            color: CrimpyTheme.primaryBlack,
          ),
        ),
        SizedBox(height: 8 * scale),
        Text(
          'Tap play to resume',
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 12 * scale,
            height: 1.6,
            color: CrimpyTheme.textSecondary,
          ),
        ),
      ],
    ),
  );
}

/// The strip under the tank: what the run is doing on the left, the controls
/// on the right.
class _ControlStrip extends StatelessWidget {
  final String stateWord;
  final Color stateColor;
  final String? detail;
  final bool isRunning;
  final bool showConfirm;
  final VoidCallback onPlayPause;
  final VoidCallback onSkip;
  final VoidCallback onConfirm;

  const _ControlStrip({
    required this.stateWord,
    required this.stateColor,
    required this.detail,
    required this.isRunning,
    required this.showConfirm,
    required this.onPlayPause,
    required this.onSkip,
    required this.onConfirm,
  });

  Widget _icon(IconData icon, Color color, VoidCallback onPressed) =>
      IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: color,
        iconSize: 44,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      );

  @override
  Widget build(BuildContext context) => Container(
    height: controlStripHeight,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: const BoxDecoration(
      color: CrimpyTheme.primaryWhite,
      border: Border(
        top: BorderSide(color: CrimpyTheme.borderDefault, width: 2),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                stateWord,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                  color: stateColor,
                ),
              ),
              if (detail != null) ...[
                const SizedBox(height: 4),
                Text(
                  detail!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11,
                    color: CrimpyTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (showConfirm)
          ElevatedButton.icon(
            onPressed: onConfirm,
            icon: const Icon(Icons.check),
            label: const Text('DONE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: CrimpyTheme.primaryOrange,
              foregroundColor: CrimpyTheme.primaryWhite,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          )
        else ...[
          _icon(
            isRunning ? Icons.pause : Icons.play_arrow,
            CrimpyTheme.primaryOrange,
            onPlayPause,
          ),
          const SizedBox(width: 28),
          _icon(Icons.skip_next, CrimpyTheme.primaryBlack, onSkip),
        ],
      ],
    ),
  );
}
