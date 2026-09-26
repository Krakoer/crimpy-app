import 'dart:math';

import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/format.dart';
import 'package:crimpy/utils/video_link.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/note_dialog.dart';
import 'package:crimpy/views/widgets/exercise_video_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Height of the strip holding the state word and the controls, under the tank.
const double controlStripHeight = 96;

/// Tank height the type sizes below are written at. Every size scales from the
/// tank the phone actually gives, so a small screen stays legible and a tablet
/// does not overflow.
const double _referenceTankHeight = 624;

/// Height of the set and rep card at the foot of the tank, scaled like the
/// rest of it. Fixed rather than sized by its text, so the block centred above
/// it can keep clear of it.
double repContextCardHeight(double scale) => (56 * scale).clamp(44.0, 72.0);

/// Gap between the foot of the tank and the set and rep card.
const double _repContextCardBottom = 16;

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

/// Height of the force level as a fraction of the tank. With nothing to scale
/// against the tank stays empty.
double tankFillFraction({
  required double currentWeight,
  required double scaleWeight,
}) {
  if (scaleWeight <= 0) return 0;
  return min(1.0, currentWeight / scaleWeight * targetNotchFraction);
}

/// What the tank draws, which is what the running step is.
enum _TankState { preparation, sensorWork, rest, timed, confirm }

/// Lines a step title may take before it is cut short. Generous on purpose:
/// the cap is there to stop a pathological title growing the middle of the
/// tank past the room the screen has for it, not to shorten a long exercise
/// name, which has nothing to open the rest of it with the way a note's prose
/// does. Four lines of title, five of a note's prose and four of a comment
/// still leave well over half the tank free.
const _stepTitleMaxLines = 4;

/// Lines of a note's prose the running screen shows. Past this the athlete
/// reads the rest from the reader a tap on the note opens.
const noteProseMaxLines = 5;

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
  final Color goal;
  final Color protocol;

  const _TankPalette({
    required this.force,
    required this.secondary,
    required this.accent,
    required this.muted,
    required this.detail,
    required this.notch,
    required this.goal,
    required this.protocol,
  });

  /// What the tank is painted in over the unfilled part, which is plain white.
  /// The accent is written as 16px bold text there, so it takes the text form:
  /// the bare accent reads 4.05:1, under the 4.5:1 floor. Krakoer/crimpy#128.
  static const overTank = _TankPalette(
    force: CrimpyTheme.primaryBlack,
    secondary: CrimpyTheme.textSecondary,
    accent: CrimpyTheme.accentOrangeText,
    muted: CrimpyTheme.textMutedSmall,
    detail: CrimpyTheme.gray400,
    notch: CrimpyTheme.borderDefault,
    goal: CrimpyTheme.goalColor,
    protocol: CrimpyTheme.protocolColor,
  );

  static const overFill = _TankPalette(
    force: CrimpyTheme.primaryWhite,
    secondary: CrimpyTheme.textOnFillSecondary,
    accent: CrimpyTheme.primaryWhite,
    muted: CrimpyTheme.textOnFillSecondary,
    detail: CrimpyTheme.textOnFillSecondary,
    notch: CrimpyTheme.primaryWhite,
    goal: CrimpyTheme.primaryWhite,
    protocol: CrimpyTheme.primaryWhite,
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

  /// Step the current one leads into, used by the rest block and by the strip
  /// under a working step. Null on the last step.
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

  /// What the blocks the running and upcoming steps belong to are for. Set
  /// above the step name, small and in the accent green, so it heads the step
  /// instead of competing with the numbers the athlete is acting on.
  final String? goal;
  final String? nextGoal;

  /// Coach comments on the running and upcoming steps.
  final String? comment;
  final String? nextComment;

  /// The rules the running and upcoming steps are resolved by, e.g. "to
  /// failure or 40s; past 40s add 5kg". Read by the athlete and by nothing
  /// else: the run neither evaluates one nor adjusts the next step from it.
  final String? protocol;
  final String? nextProtocol;

  /// Demo videos of the running and upcoming steps. Only offered where the
  /// athlete is not mid set: the upcoming one during a rest, the running one on
  /// a self paced step they end themselves. A timed step shows neither, so
  /// nothing is tappable while they are hanging.
  final String? videoLink;
  final String? nextVideoLink;

  final VoidCallback onPlayPause;
  final VoidCallback onSkip;
  final VoidCallback onConfirm;

  /// Whether the run is inside an emom the athlete can drop out of, and what to
  /// do when they say they cannot make the next round.
  final bool showDropOut;
  final VoidCallback onDropOut;

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
    required this.goal,
    required this.nextGoal,
    required this.comment,
    required this.nextComment,
    required this.protocol,
    required this.nextProtocol,
    required this.videoLink,
    required this.nextVideoLink,
    required this.onPlayPause,
    required this.onSkip,
    required this.onConfirm,
    required this.showDropOut,
    required this.onDropOut,
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
    final paused = !isRunning && !isPreparation;

    // The tank only follows the sensor on a step that reads it. Watching the
    // stream on the other steps would rebuild the screen on every sample for
    // nothing. A pause mutes the stream, so the last sample it carries is stale
    // and the tank empties instead of holding the reading it stopped on.
    final currentWeight = sensor && !paused
        ? ref.watch(bleLastValueProvider) ?? 0
        : 0.0;
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
                      left: 16,
                      right: 16,
                      bottom: _repContextCardBottom,
                      child: Center(
                        child: _RepContextCard(text: repContext!, scale: scale),
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
              stateWord: _stateWord,
              stateColor: _stateColor,
              detail: paused ? repContext : null,
              nextStep: paused ? null : _nextStep,
              isRunning: isRunning,
              showConfirm: state == _TankState.confirm,
              onPlayPause: onPlayPause,
              onSkip: onSkip,
              onConfirm: onConfirm,
              showDropOut: showDropOut,
              onDropOut: onDropOut,
            ),
          ],
        );
      },
    );
  }

  /// What the run is doing, when the tank does not already say it. A working
  /// step has none: the level and the notch show the effort and whether the
  /// target is met better than a word could.
  String? get _stateWord {
    if (isPreparation) return 'READY';
    if (!isRunning) return 'PAUSED';
    if (item is RestItem) return 'REST';
    return null;
  }

  /// The state word is 18px bold on the white control strip, under the
  /// 18.66px large text threshold, so it answers to 4.5:1 and the accent's
  /// 4.05:1 does not reach it. See Krakoer/crimpy#128.
  Color get _stateColor {
    if (isPreparation) return CrimpyTheme.textOn(CrimpyTheme.primaryOrange);
    if (!isRunning) return CrimpyTheme.textMutedSmall;
    return CrimpyTheme.statusSuccess;
  }

  /// The step coming up, which a working step has the strip to itself for. A
  /// preparation and a rest fill the middle of the tank with what is next
  /// already, so their strip stays down to the one word.
  String? get _nextStep {
    if (isPreparation || item is RestItem || nextItem == null) return null;
    return describeExecutionItem(nextItem!);
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
    // A step with no sensor puts its countdown in the middle of the screen, and
    // a self paced one has none.
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
          Positioned(right: 16, top: 14, child: _countdown()),
        if (state == _TankState.sensorWork)
          ..._forceReadout()
        else
          Positioned.fill(
            child: Padding(
              // Kept clear of the set and rep card, which is opaque and would
              // otherwise hide the foot of a tall block.
              padding: EdgeInsets.fromLTRB(
                16,
                14,
                16,
                layout.repContext == null
                    ? 14
                    : _repContextCardBottom +
                          repContextCardHeight(scale) +
                          _s(12),
              ),
              child: Center(child: _centerBlock(context)),
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
        // The total time left sits beside the time spent on every step, rather
        // than in the corner the countdown of the running step takes.
        Wrap(
          spacing: _s(20),
          runSpacing: _s(6),
          children: [
            _timeBlock('ELAPSED', layout.elapsedMilliseconds),
            if (layout.showRemaining)
              _timeBlock('LEFT', layout.remainingMilliseconds),
          ],
        ),
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
        // state carries the goal and the comment in the block it centers there.
        // The hang is the step the goal matters most on, since a finger block
        // is what the coach wrote one for, so it is not dropped here.
        if (layout.goal != null && state == _TankState.sensorWork) ...[
          SizedBox(height: _s(8)),
          _goalLine(layout.goal!, align: TextAlign.start),
        ],
        // A hang is the step a stop rule is written for ("to failure or 40s"),
        // so the rule is on screen while it runs. Two lines here, where the
        // force has the middle of the tank.
        if (layout.protocol != null && state == _TankState.sensorWork) ...[
          SizedBox(height: _s(6)),
          _protocolBlock(layout.protocol!, maxLines: 2, align: TextAlign.start),
        ],
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

  /// What the block is for, heading a step. One line, since a goal is a label
  /// and the tank cannot scroll: it draws its content twice, clipped to the
  /// force level, so anything in it has to be bounded. The colour comes from
  /// the palette for that same reason, or the copy drawn over the fill would
  /// paint green on the dark green and disappear.
  ///
  /// [align] only decides where a goal that had to be cut short sits in the
  /// leftover pixels. It does not place the line: a goal short enough to fit
  /// shrink-wraps to its glyphs, so the block it sits in is what puts it left
  /// or centre.
  Widget _goalLine(String goal, {TextAlign align = TextAlign.center}) => Text(
    goal.toUpperCase(),
    textAlign: align,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: _style(
      12,
      color: palette.goal,
      weight: FontWeight.w700,
      letterSpacing: 1,
    ),
  );

  /// The rule the step is resolved by, under the step it belongs to. Labelled
  /// and line capped, since the tank draws its content twice and cannot scroll:
  /// a coach with more to say than fits writes it where the athlete reads it
  /// before starting, on the training breakdown, and reports against it after.
  ///
  /// [maxLines] is the room the block it sits in has. [align] follows the block
  /// it sits in, the way _goalLine's does: the corner block sets its content
  /// from the left, and a rule long enough to wrap would otherwise centre its
  /// label and its last line against left aligned copy above it.
  ///
  /// The colour comes from the palette for the reason the goal's does: the copy
  /// drawn over the fill would otherwise paint gold on gold and disappear.
  Widget _protocolBlock(
    String protocol, {
    required int maxLines,
    TextAlign align = TextAlign.center,
  }) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: align == TextAlign.start
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center,
    children: [
      Text(
        'PROTOCOL',
        style: _style(
          9,
          color: palette.protocol,
          weight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
      SizedBox(height: _s(3)),
      Text(
        protocol,
        textAlign: align,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: _style(13, color: palette.secondary, height: 1.4),
      ),
    ],
  );

  Widget _timeBlock(String label, int milliseconds) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _centerBlock(BuildContext context) => switch (state) {
    _TankState.preparation => _preparationBlock(),
    _TankState.rest => _nextStepBlock(),
    _TankState.timed => _timedBlock(),
    _TankState.confirm => _confirmBlock(context),
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
          color: palette.accent,
          weight: FontWeight.w700,
          letterSpacing: 4,
        ),
      ),
      SizedBox(height: _s(14)),
      Text(
        _preparationInstruction(rep),
        textAlign: TextAlign.center,
        maxLines: _stepTitleMaxLines,
        overflow: TextOverflow.ellipsis,
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
      // The safest moment there is to look the movement up, and the only one a
      // run of a single timed set offers at all.
      if (isPlayableVideoLink(layout.nextVideoLink)) ...[
        SizedBox(height: _s(10)),
        ExerciseVideoButton(layout.nextVideoLink, compact: true),
      ],
    ]);
  }

  String _preparationInstruction(TimedItem? rep) {
    if (rep == null) return 'Get ready.';
    if (!rep.isHang) {
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
    final hang = rep?.isHang ?? false;

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
      if (layout.nextGoal != null) ...[
        SizedBox(height: _s(8)),
        _goalLine(layout.nextGoal!),
      ],
      SizedBox(height: _s(14)),
      Text(
        hang
            ? rep!.handSide.displayName
            : describeExecutionItem(next).toUpperCase(),
        textAlign: TextAlign.center,
        // The largest type in the block, so the step it names is what needs
        // bounding most: a long exercise name wraps into it at 30px and would
        // otherwise push the block past the tank.
        maxLines: _stepTitleMaxLines,
        overflow: TextOverflow.ellipsis,
        style: _style(30, color: palette.force, weight: FontWeight.w900),
      ),
      if (rep != null) ...[
        SizedBox(height: _s(14)),
        Text(
          [
            if (rep.targetLoad > 0) '${formatKilograms(rep.targetLoad)} kg',
            '${rep.durationSeconds}s',
          ].join(' - '),
          style: _style(20, color: palette.accent, weight: FontWeight.w700),
        ),
        if (hang) ...[
          SizedBox(height: _s(14)),
          Text(
            gripLine(rep.gripPosition, rep.edgeSizeMm),
            style: _style(13, color: palette.secondary),
          ),
        ],
      ],
      // The rest is where the rule is acted on: it says what to do about the
      // set just finished before the next one starts, so it is read here and
      // not only once the step is already running.
      if (layout.nextProtocol != null) ...[
        SizedBox(height: _s(14)),
        _protocolBlock(layout.nextProtocol!, maxLines: 4),
      ],
      if (layout.nextComment != null) ...[
        SizedBox(height: _s(14)),
        Text(
          layout.nextComment!,
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: _style(13, color: palette.secondary, height: 1.4),
        ),
      ],
      if (isPlayableVideoLink(layout.nextVideoLink)) ...[
        SizedBox(height: _s(10)),
        ExerciseVideoButton(layout.nextVideoLink, compact: true),
      ],
    ]);
  }

  Widget _timedBlock() {
    final rep = layout.item as TimedItem;

    return _column([
      if (layout.goal != null) ...[
        _goalLine(layout.goal!),
        SizedBox(height: _s(6)),
      ],
      Text(
        rep.label.toUpperCase(),
        textAlign: TextAlign.center,
        maxLines: _stepTitleMaxLines,
        overflow: TextOverflow.ellipsis,
        style: _style(
          18,
          color: palette.accent,
          weight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
      // A hang on both hands runs without the sensor, so this is where the
      // athlete reads how to take the edge.
      if (rep.isHang) ...[
        SizedBox(height: _s(8)),
        Text(
          rep.handSide.displayName,
          style: _style(
            22,
            color: palette.force,
            weight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: _s(4)),
        Text(
          gripLine(rep.gripPosition, rep.edgeSizeMm),
          style: _style(15, color: palette.secondary, weight: FontWeight.w700),
        ),
      ],
      if (layout.protocol != null) ...[
        SizedBox(height: _s(8)),
        _protocolBlock(layout.protocol!, maxLines: 4),
      ],
      if (layout.comment != null) ...[
        SizedBox(height: _s(8)),
        Text(
          layout.comment!,
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
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

  Widget _confirmBlock(BuildContext context) {
    final rep = layout.item as ConfirmItem;
    final details = [
      if (rep.repsAreOpen)
        'AMRAP'
      else if (rep.reps != null)
        '${rep.reps} reps',
      if (rep.load != null) rep.load!,
    ].join('  -  ');

    return _column([
      if (layout.goal != null) ...[
        _goalLine(layout.goal!),
        SizedBox(height: _s(6)),
      ],
      Text(
        rep.label.toUpperCase(),
        textAlign: TextAlign.center,
        maxLines: _stepTitleMaxLines,
        overflow: TextOverflow.ellipsis,
        style: _style(
          18,
          color: palette.accent,
          weight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
      // A whole prescription rather than a name, so it is set as prose: mixed
      // case, a reading size, and line capped so the tank cannot be overflowed
      // by it. A tap opens the whole of it, which is what the ellipsis is for.
      if (rep.instructions != null) ...[
        SizedBox(height: _s(10)),
        GestureDetector(
          onTap: () => showNoteDialog(context, rep.instructions!),
          // The whole block answers the tap, gaps included, rather than the
          // glyph boxes the column would hit test on its own: the hint line is
          // a few millimetres of text and the finger aiming at it is sweaty.
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: _s(6)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  rep.instructions!,
                  textAlign: TextAlign.center,
                  maxLines: noteProseMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: _style(14, color: palette.force, height: 1.45),
                ),
                SizedBox(height: _s(6)),
                // Says what the tap does and nothing about what is on screen:
                // whether the prose above was cut short is not measured here,
                // so promising the rest of it would be a lie on every note the
                // tank had room for.
                Text(
                  'Tap the note to open it',
                  style: _style(11, color: palette.secondary),
                ),
              ],
            ),
          ),
        ),
      ],
      if (layout.protocol != null) ...[
        SizedBox(height: _s(8)),
        _protocolBlock(layout.protocol!, maxLines: 4),
      ],
      if (layout.comment != null) ...[
        SizedBox(height: _s(8)),
        Text(
          layout.comment!,
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
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
      if (isPlayableVideoLink(layout.videoLink)) ...[
        SizedBox(height: _s(10)),
        ExerciseVideoButton(layout.videoLink, compact: true),
      ],
      SizedBox(height: _s(14)),
      Text(
        rep.repsAreOpen
            ? 'Tap DONE and say how many'
            : 'Tap DONE when finished',
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

/// Set and rep of the running step, drawn as the paused card is so it belongs
/// to the same screen. Its background is opaque over the level so it never
/// ends up unreadable half way through an inversion.
class _RepContextCard extends StatelessWidget {
  final String text;
  final double scale;

  const _RepContextCard({required this.text, required this.scale});

  @override
  Widget build(BuildContext context) => Container(
    height: repContextCardHeight(scale),
    padding: EdgeInsets.symmetric(horizontal: 18 * scale),
    decoration: const BoxDecoration(
      color: CrimpyTheme.primaryWhite,
      border: Border.fromBorderSide(
        BorderSide(color: CrimpyTheme.borderDefault, width: 2),
      ),
      boxShadow: [
        BoxShadow(color: CrimpyTheme.borderDefault, offset: Offset(3, 3)),
      ],
    ),
    // Sized to its text across, so a short context stays a card rather than a
    // banner over the fill. A long one such as "SET 10/10 - REP 12/12" shrinks
    // to one line on a narrow phone instead of wrapping out of the fixed
    // height.
    child: Center(
      widthFactor: 1,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          maxLines: 1,
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: (22 * scale).clamp(16.0, 28.0),
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: CrimpyTheme.primaryBlack,
          ),
        ),
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
  final String? stateWord;
  final Color stateColor;

  /// Small print under the state word.
  final String? detail;

  /// The step coming up, set large where there is no state word to read.
  final String? nextStep;
  final bool isRunning;
  final bool showConfirm;
  final VoidCallback onPlayPause;
  final VoidCallback onSkip;
  final VoidCallback onConfirm;

  /// Whether the run is inside an emom the athlete can drop out of.
  final bool showDropOut;
  final VoidCallback onDropOut;

  const _ControlStrip({
    required this.stateWord,
    required this.stateColor,
    required this.detail,
    required this.nextStep,
    required this.isRunning,
    required this.showConfirm,
    required this.onPlayPause,
    required this.onSkip,
    required this.onConfirm,
    required this.showDropOut,
    required this.onDropOut,
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
              if (stateWord != null)
                Text(
                  stateWord!,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                    color: stateColor,
                  ),
                ),
              if (nextStep != null) ...[
                const Text(
                  'NEXT',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: CrimpyTheme.textMutedSmall,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nextStep!.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 20,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    color: CrimpyTheme.primaryBlack,
                  ),
                ),
              ],
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
        if (showDropOut)
          IconButton(
            onPressed: onDropOut,
            icon: const Icon(Icons.flag_outlined),
            color: CrimpyTheme.statusError,
            iconSize: 30,
            tooltip: 'I cannot make the next round',
          ),
        if (showConfirm)
          ElevatedButton.icon(
            onPressed: onConfirm,
            icon: const Icon(Icons.check),
            label: const Text('DONE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: CrimpyTheme.fillOn(CrimpyTheme.primaryOrange),
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
