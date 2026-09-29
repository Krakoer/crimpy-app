import 'dart:math';

import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/duration_format.dart';
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

/// Room kept clear at the foot of the tank, for the set and rep card when
/// there is one. The card is opaque and would otherwise hide what runs under
/// it.
double _bottomReserve({required bool hasCard, required double scale}) => hasCard
    ? _repContextCardBottom + repContextCardHeight(scale) + 12 * scale
    : 14;

/// Room around the block a step without the sensor holds in the middle of the
/// tank: its inset from the sides and the top of the tank, which is where it
/// is centred from, and its gap under the header, which it never goes above.
const double _centreBlockInset = 16;
const double _centreBlockTop = 14;
const double _centreBlockGapUnderHeader = 12;

/// Where the header, the clocks and the countdown across the top of the tank,
/// starts. Lower where the platform needs a back button in the corner.
const double _headerTop = 14;
const double _headerTopUnderBackButton = 58;

/// The countdown in the corner, at its size for a count under a minute. A
/// count of a minute or more is set smaller.
const double _countdownNumeralSize = 92;
const double _countdownNumeralHeight = 0.9;

/// Room left between the foot of the header and the highest the level rises.
const double _headerClearance = 8;

/// Whether the platform leaves the athlete no way back out of the workout on
/// its own, the app bar being gone in this design.
bool _needsBackButton(BuildContext context) =>
    Theme.of(context).platform == TargetPlatform.iOS;

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
  static final overTank = _TankPalette(
    force: CrimpyTheme.textPrimary,
    secondary: CrimpyTheme.textSecondary,
    accent: CrimpyTheme.textOn(CrimpyTheme.runPrompt),
    muted: CrimpyTheme.textMutedSmall,
    detail: CrimpyTheme.textMutedSmall,
    notch: CrimpyTheme.outline,
    goal: CrimpyTheme.goalColor,
    protocol: CrimpyTheme.protocolColor,
  );

  /// What the tank is painted in over the calm ground of a rest. The muted
  /// voice takes textSecondary there: textMutedSmall only clears the 4.5:1
  /// floor on white and reads about 4.38:1 on the calm ground.
  static final overCalm = _TankPalette(
    force: CrimpyTheme.textPrimary,
    secondary: CrimpyTheme.textSecondary,
    accent: CrimpyTheme.textOn(CrimpyTheme.runPrompt),
    muted: CrimpyTheme.textSecondary,
    detail: CrimpyTheme.textSecondary,
    notch: CrimpyTheme.outline,
    goal: CrimpyTheme.goalColor,
    protocol: CrimpyTheme.protocolColor,
  );

  static const overFill = _TankPalette(
    force: CrimpyTheme.textOnFill,
    secondary: CrimpyTheme.textOnFillSecondary,
    accent: CrimpyTheme.textOnFill,
    muted: CrimpyTheme.textOnFillSecondary,
    detail: CrimpyTheme.textOnFillSecondary,
    notch: CrimpyTheme.textOnFill,
    goal: CrimpyTheme.textOnFill,
    protocol: CrimpyTheme.textOnFill,
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

  /// Whether the load of the running hang has dropped below its target long
  /// enough to raise the alarm. The run screen decides it, from
  /// `loadDropAlarmProvider`; the layout only paints it.
  final bool loadBelowTarget;

  /// Set and rep of the running step, shown in the set and rep card.
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
    required this.loadBelowTarget,
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

    // A step that reads the sensor and has none to read raises the alarm. A
    // step that reads nothing cannot lose it.
    final sensorLost =
        sensor &&
        ref.watch(connectionStateProvider) != BleConnectionState.connected;

    // The tank only follows the sensor on a step that reads it. Watching the
    // stream on the other steps would rebuild the screen on every sample for
    // nothing. A pause mutes the stream, so the last sample it carries is stale
    // and the tank empties instead of holding the reading it stopped on. A lost
    // sensor leaves a stale sample behind the same way.
    final currentWeight = sensor && !paused && !sensorLost
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
    // The other alarm: a hang whose load dropped below its target. A paused
    // run or a lost sensor has no load to judge, so it cannot raise it.
    final loadDropped =
        loadBelowTarget && sensor && targetWeight > 0 && !paused && !sensorLost;
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

        Widget content(_TankPalette palette, _TankPart part) => _TankContent(
          layout: this,
          state: state,
          part: part,
          palette: palette,
          tankHeight: tankHeight,
          scale: scale,
          currentWeight: currentWeight,
          notchLabel: notchLabel,
        );
        final groundPalette = state == _TankState.rest
            ? _TankPalette.overCalm
            : _TankPalette.overTank;

        // The header is laid out on its own so the level can be stopped
        // under it, as it is drawn: with the text scale the phone asks for
        // and the grip lines. The notes of a hang sit under the target, not
        // in the header. See Krakoer/crimpy#161 and Krakoer/crimpy#180.
        final tank = CustomMultiChildLayout(
          delegate: _TankLayoutDelegate(
            level: fillHeight,
            levelFloor: tankHeight * targetNotchFraction,
            headerClearance: _headerClearance * scale,
            centreGapUnderHeader: _centreBlockGapUnderHeader * scale,
            bottomReserve: _bottomReserve(
              hasCard: repContext != null,
              scale: scale,
            ),
          ),
          children: [
            LayoutId(
              id: _TankSlot.ground,
              child: ColoredBox(
                color: state == _TankState.rest
                    ? CrimpyTheme.phaseCalmGround
                    : CrimpyTheme.bgPrimary,
              ),
            ),
            LayoutId(
              id: _TankSlot.body,
              child: content(groundPalette, _TankPart.body),
            ),
            LayoutId(
              id: _TankSlot.header,
              child: content(groundPalette, _TankPart.header),
            ),
            if (!sensor)
              LayoutId(
                id: _TankSlot.centre,
                child: content(groundPalette, _TankPart.centre),
              ),
            if (fillHeight > 0)
              LayoutId(
                id: _TankSlot.level,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  // The level carries the force figure in white, so it is
                  // filled with the form of its phase that carries white.
                  color: CrimpyTheme.fillOn(
                    CrimpyTheme.phaseColor(
                      loadDropped
                          ? RunPhase.alarm
                          : onTarget
                          ? RunPhase.engaged
                          : RunPhase.armed,
                    ),
                  ),
                  // The whole tank again in the colours that read on the
                  // level, laid out at the tank's size and pinned to its foot
                  // so it lands in register with the copy under it, and cut
                  // to the level.
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.bottomCenter,
                      minHeight: tankHeight,
                      maxHeight: tankHeight,
                      child: content(_TankPalette.overFill, _TankPart.whole),
                    ),
                  ),
                ),
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
              stateWord: _stateWord(
                sensorLost: sensorLost,
                loadDropped: loadDropped,
              ),
              stateColor: _stateColor(alarm: sensorLost || loadDropped),
              detail: paused ? repContext : null,
              nextStep: paused || sensorLost || loadDropped ? null : _nextStep,
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
  /// target is met better than a word could. A sensor step with no sensor to
  /// read empties the level, so that one is said. NO SENSOR rather than
  /// SENSOR LOST: the run cannot tell a connection that dropped from one that
  /// never opened. A load that dropped below the target turns the level red
  /// and says so as well, since red alone does not tell the athlete why.
  String? _stateWord({required bool sensorLost, required bool loadDropped}) {
    if (isPreparation) return 'READY';
    if (!isRunning) return 'PAUSED';
    if (sensorLost) return 'NO SENSOR';
    if (loadDropped) return 'BELOW TARGET';
    if (item is RestItem) return 'REST';
    return null;
  }

  /// The phase the state word names, in the hue [CrimpyTheme.phaseColor] gives
  /// it. The word is set in capsHeadline, 24px on the white control strip,
  /// which is large text and would pass at 3:1. It keeps the readable form of
  /// its phase anyway, which clears 4.5:1, so the word reads the same as the
  /// small labels around it. See Krakoer/crimpy#128.
  Color _stateColor({required bool alarm}) {
    final phase = isPreparation
        ? RunPhase.armed
        : !isRunning
        ? RunPhase.calm
        : alarm
        ? RunPhase.alarm
        : RunPhase.calm;
    return CrimpyTheme.textOn(CrimpyTheme.phaseColor(phase));
  }

  /// The step coming up, which a working step has the strip to itself for. A
  /// preparation and a rest fill the middle of the tank with what is next
  /// already, so their strip stays down to the one word.
  String? get _nextStep {
    if (isPreparation || item is RestItem || nextItem == null) return null;
    return describeExecutionItem(nextItem!);
  }
}

/// One line naming a step, e.g. "rest 0:03" or "hang 0:07". The run screen
/// reads every length as a clock, the way its countdowns run.
String describeExecutionItem(TrainingExecutionItem item) => switch (item) {
  RestItem(:final durationSeconds) =>
    'rest ${formatClock(Duration(seconds: durationSeconds))}',
  ConfirmItem(:final label) => label.toLowerCase(),
  TimedItem(:final label, :final durationSeconds) =>
    '${label.toLowerCase()} ${formatClock(Duration(seconds: durationSeconds))}',
};

/// Everything drawn inside the tank. It is built twice in the two palettes and
/// both copies share this layout exactly, so the clipped one lands in register
/// with the one under it.
class _TankContent extends StatelessWidget {
  final FullTankLayout layout;
  final _TankState state;

  /// Which part of the tank content this copy draws.
  final _TankPart part;
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
    required this.part,
    required this.palette,
    required this.tankHeight,
    required this.scale,
    required this.currentWeight,
    required this.notchLabel,
  });

  double _s(double size) => size * scale;

  /// A style of the scale, grown or shrunk with the tank the phone gave.
  TextStyle _scaledStyle(
    TextStyle style, {
    required Color color,
    double? height,
  }) => style
      .apply(fontSizeFactor: scale, letterSpacingFactor: scale, color: color)
      .copyWith(height: height);

  /// A display number, scaled from the tank the phone gave and clamped so it
  /// stays readable on a small screen without overflowing a large one.
  TextStyle _numeralStyle(
    double size, {
    required Color color,
    double height = 1,
    double? min,
    double? max,
  }) => CrimpyTheme.numerals(
    (min == null || max == null) ? _s(size) : _s(size).clamp(min, max),
    height: height,
  ).copyWith(color: color);

  @override
  Widget build(BuildContext context) => switch (part) {
    _TankPart.header => _header(context),
    _TankPart.centre => _fittedCentreBlock(context),
    _TankPart.body => Stack(fit: StackFit.expand, children: _body(context)),
    _TankPart.whole => Stack(
      fit: StackFit.expand,
      children: [
        ..._body(context),
        Positioned(left: 0, top: 0, right: 0, child: _header(context)),
      ],
    ),
  };

  /// The clocks, the countdown in the corner and what sits under the clocks,
  /// across the top of the tank. Sized to what it draws, which is what the
  /// level is stopped under.
  Widget _header(BuildContext context) {
    // A step with no sensor puts its countdown in the middle of the screen, and
    // a self paced one has none.
    final cornerCountdown =
        state != _TankState.timed && state != _TankState.confirm;
    final backButton = _needsBackButton(context);
    final countdownRoom = 16 + _s(140);

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: 16,
            top: backButton ? _headerTopUnderBackButton : _headerTop,
            right: countdownRoom,
          ),
          child: _topLeftBlock(),
        ),
        if (cornerCountdown)
          Align(
            alignment: Alignment.topRight,
            heightFactor: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: _headerTop, right: 16),
              child: _countdown(),
            ),
          ),
        // Without an app bar, a platform with no hardware back button needs
        // something to leave the workout with. It goes through the same
        // confirmation the back gesture does.
        if (backButton)
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
      ],
    );
  }

  /// The block in the middle of the tank at the width it is given, shrunk
  /// whole to the height it is given when it is taller: at a large text size
  /// the room between the header and the set and rep card can be less than
  /// the block needs, and it is scaled down rather than run under either. See
  /// Krakoer/crimpy#181.
  Widget _fittedCentreBlock(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: constraints.maxWidth,
        child: Center(child: _centerBlock(context)),
      ),
    ),
  );

  /// Everything in the tank under the header on a sensor step: the notch and
  /// the force. Every other step holds a block in the middle instead, laid
  /// out under the header.
  List<Widget> _body(BuildContext context) => [
    if (notchLabel != null)
      Positioned(
        left: 0,
        right: 0,
        bottom: tankHeight * targetNotchFraction,
        height: 2,
        child: ColoredBox(color: palette.notch),
      ),
    if (state == _TankState.sensorWork) ..._forceReadout(),
  ];

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
            style: _scaledStyle(CrimpyTheme.title, color: palette.accent),
          ),
          Text(
            gripLine(rep.gripPosition, rep.edgeSizeMm),
            style: _scaledStyle(CrimpyTheme.bodySmall, color: palette.detail),
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
  Widget _goalLine(String goal) => Text(
    goal.toUpperCase(),
    textAlign: TextAlign.center,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: _scaledStyle(CrimpyTheme.capsLabel, color: palette.goal),
  );

  /// The rule the step is resolved by, under the step it belongs to. Labelled
  /// and line capped, since the tank draws its content twice and cannot scroll:
  /// a coach with more to say than fits writes it where the athlete reads it
  /// before starting, on the training breakdown, and reports against it after.
  ///
  /// [maxLines] is the room the block it sits in has.
  ///
  /// The colour comes from the palette for the reason the goal's does: the copy
  /// drawn over the fill would otherwise paint gold on gold and disappear.
  Widget _protocolBlock(String protocol, {required int maxLines}) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'PROTOCOL',
        style: _scaledStyle(CrimpyTheme.capsLabel, color: palette.protocol),
      ),
      SizedBox(height: _s(3)),
      Text(
        protocol,
        textAlign: TextAlign.center,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: _scaledStyle(CrimpyTheme.body, color: palette.secondary),
      ),
    ],
  );

  Widget _timeBlock(String label, int milliseconds) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: _scaledStyle(CrimpyTheme.capsLabel, color: palette.muted),
      ),
      Text(
        formatClock(Duration(milliseconds: milliseconds)),
        style: _scaledStyle(
          CrimpyTheme.tabular(CrimpyTheme.titleLarge),
          color: palette.force,
        ),
      ),
    ],
  );

  /// Seconds left, without minutes or colon under a minute. A hang is counted
  /// in seconds and a bare numeral is the fastest thing to read.
  Widget _countdown() {
    final seconds = layout.secondsRemaining;
    final resting = state == _TankState.rest;
    final calm = CrimpyTheme.textOn(CrimpyTheme.phaseColor(RunPhase.calm));
    final color = resting ? calm : palette.force;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          seconds < 60
              ? '$seconds'
              : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
          style: _numeralStyle(
            seconds < 60 ? _countdownNumeralSize : 64,
            color: color,
            height: _countdownNumeralHeight,
          ),
        ),
        Text(
          resting ? 'SEC REST' : 'SEC',
          style: _scaledStyle(
            CrimpyTheme.capsLabel,
            color: resting ? calm : palette.secondary,
          ),
        ),
      ],
    );
  }

  /// The force, as large as the tank allows, over the level that measures it.
  /// The whole reading sits on one line with its unit beside it, and shrinks
  /// rather than wraps when a reading runs to three figures on a narrow phone.
  List<Widget> _forceReadout() {
    Widget line(double top, Widget child) =>
        Positioned(left: 16, right: 16, top: tankHeight * top, child: child);

    return [
      line(
        0.345,
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formatKilograms(currentWeight),
                style: _numeralStyle(
                  104,
                  color: palette.force,
                  min: 80,
                  max: 140,
                ),
              ),
              SizedBox(width: _s(6)),
              Text(
                'kg',
                style: _scaledStyle(
                  CrimpyTheme.titleLarge,
                  color: palette.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
      // The lower tank is empty during a hang, and the level only ever
      // crosses it in the colours that read on it, so the notes of the step
      // sit there, under the target they are read against, rather than
      // growing the header down into the notch and the force. See
      // Krakoer/crimpy#180.
      Positioned(
        left: 16,
        right: 16,
        top: tankHeight * 0.56,
        bottom: _bottomReserve(
          hasCard: layout.repContext != null,
          scale: scale,
        ),
        child: ClipRect(
          child: CustomMultiChildLayout(
            delegate: _HangNotesLayoutDelegate(
              gapBeforeGoal: _s(12),
              gapBeforeNote: _s(8),
            ),
            children: [
              if (notchLabel != null)
                LayoutId(
                  id: _HangNoteSlot.target,
                  child: Text(
                    notchLabel!,
                    textAlign: TextAlign.center,
                    style: _scaledStyle(
                      CrimpyTheme.title,
                      color: palette.secondary,
                    ),
                  ),
                ),
              ..._hangNotes(),
            ],
          ),
        ),
      ),
    ];
  }

  /// The goal, the protocol and the comment of a hang, under the target. The
  /// rule takes two lines, being what the hang is resolved by; the goal and
  /// the comment take one each. That is what the lower tank has room for at
  /// text scale 1.3 on a small phone; past it the notes are dropped rather
  /// than run under the set and rep card, see _HangNotesLayoutDelegate. The
  /// whole of each is on the training breakdown, read before the run.
  List<Widget> _hangNotes() => [
    if (layout.goal != null)
      LayoutId(id: _HangNoteSlot.goal, child: _goalLine(layout.goal!)),
    // A hang is the step a stop rule is written for ("to failure or 40s"),
    // so the rule is on screen while it runs.
    if (layout.protocol != null)
      LayoutId(
        id: _HangNoteSlot.protocol,
        child: _protocolBlock(layout.protocol!, maxLines: 2),
      ),
    if (layout.comment != null)
      LayoutId(
        id: _HangNoteSlot.comment,
        child: Text(
          layout.comment!,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _scaledStyle(CrimpyTheme.bodySmall, color: palette.secondary),
        ),
      ),
  ];

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
      // Only drawn over the empty tank: a preparation reads no sensor, so there
      // is no level for a second copy to be clipped to.
      Text(
        'PREPARATION',
        style: _scaledStyle(
          CrimpyTheme.capsHeadline,
          color: CrimpyTheme.textOn(CrimpyTheme.phaseColor(RunPhase.armed)),
        ),
      ),
      SizedBox(height: _s(14)),
      Text(
        _preparationInstruction(rep),
        textAlign: TextAlign.center,
        maxLines: _stepTitleMaxLines,
        overflow: TextOverflow.ellipsis,
        style: _scaledStyle(CrimpyTheme.body, color: palette.secondary),
      ),
      if (rep != null && rep.targetLoad > 0) ...[
        SizedBox(height: _s(16)),
        Text(
          'FIRST TARGET ${formatKilograms(rep.targetLoad)} kg',
          style: _scaledStyle(CrimpyTheme.titleSmall, color: palette.force),
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
        style: _scaledStyle(
          CrimpyTheme.capsHeadline,
          color: CrimpyTheme.textOn(CrimpyTheme.phaseColor(RunPhase.calm)),
        ),
      );
    }
    final rep = next is TimedItem ? next : null;
    final hang = rep?.isHang ?? false;

    return _column([
      Text(
        'NEXT',
        style: _scaledStyle(CrimpyTheme.capsLabel, color: palette.secondary),
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
        // bounding most: a long exercise name wraps at the capsHeadline size and
        // would otherwise push the block past the tank.
        maxLines: _stepTitleMaxLines,
        overflow: TextOverflow.ellipsis,
        style: _scaledStyle(CrimpyTheme.capsHeadline, color: palette.force),
      ),
      if (rep != null) ...[
        SizedBox(height: _s(14)),
        Text(
          [
            if (rep.targetLoad > 0) '${formatKilograms(rep.targetLoad)} kg',
            formatClock(Duration(seconds: rep.durationSeconds)),
          ].join(' - '),
          style: _scaledStyle(CrimpyTheme.titleLarge, color: palette.accent),
        ),
        if (hang) ...[
          SizedBox(height: _s(14)),
          Text(
            gripLine(rep.gripPosition, rep.edgeSizeMm),
            style: _scaledStyle(CrimpyTheme.body, color: palette.secondary),
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
          style: _scaledStyle(CrimpyTheme.body, color: palette.secondary),
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
        style: _scaledStyle(CrimpyTheme.title, color: palette.accent),
      ),
      // A hang on both hands runs without the sensor, so this is where the
      // athlete reads how to take the edge.
      if (rep.isHang) ...[
        SizedBox(height: _s(8)),
        Text(
          rep.handSide.displayName,
          style: _scaledStyle(CrimpyTheme.capsHeadline, color: palette.force),
        ),
        SizedBox(height: _s(4)),
        Text(
          gripLine(rep.gripPosition, rep.edgeSizeMm),
          style: _scaledStyle(CrimpyTheme.titleSmall, color: palette.secondary),
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
          style: _scaledStyle(CrimpyTheme.body, color: palette.secondary),
        ),
      ],
      SizedBox(height: _s(8)),
      Text(
        '${layout.secondsRemaining}',
        // Display sized already, and the one thing in the block that does not
        // need to grow to be read: the room it would take at a large text size
        // goes to the notes instead. See Krakoer/crimpy#181.
        textScaler: TextScaler.noScaling,
        style: _numeralStyle(
          150,
          color: palette.force,
          height: 0.9,
          min: 120,
          max: 190,
        ),
      ),
      SizedBox(height: _s(8)),
      Text(
        'SEC LEFT',
        style: _scaledStyle(CrimpyTheme.capsLabel, color: palette.secondary),
      ),
      if (rep.targetLoad > 0) ...[
        SizedBox(height: _s(12)),
        Text(
          'TARGET ${formatKilograms(rep.targetLoad)} kg',
          style: _scaledStyle(CrimpyTheme.titleSmall, color: palette.muted),
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
        style: _scaledStyle(CrimpyTheme.title, color: palette.accent),
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
                  style: _scaledStyle(CrimpyTheme.body, color: palette.force),
                ),
                SizedBox(height: _s(6)),
                // Says what the tap does and nothing about what is on screen:
                // whether the prose above was cut short is not measured here,
                // so promising the rest of it would be a lie on every note the
                // tank had room for.
                Text(
                  'Tap the note to open it',
                  style: _scaledStyle(
                    CrimpyTheme.bodySmall,
                    color: palette.secondary,
                  ),
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
          style: _scaledStyle(CrimpyTheme.body, color: palette.secondary),
        ),
      ],
      if (details.isNotEmpty) ...[
        SizedBox(height: _s(14)),
        Text(
          details,
          textAlign: TextAlign.center,
          style: _scaledStyle(CrimpyTheme.headline, color: palette.force),
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
        style: _scaledStyle(CrimpyTheme.body, color: palette.secondary),
      ),
    ]);
  }
}

String gripLine(GripPosition gripPosition, int? edgeSizeMm) => [
  gripPosition.shortName,
  if (edgeSizeMm != null) '${edgeSizeMm}mm',
].join(' - ');

/// What a copy of the tank content draws. The copy over the level draws the
/// whole of it, since a level stopped at the notch under a deep header can
/// still reach the foot of the header. Only a sensor step has a level, and it
/// has no centre block, so the whole of it is the body and the header.
enum _TankPart { header, body, centre, whole }

/// The children the tank is laid out in.
enum _TankSlot { ground, body, header, centre, level }

/// Lays the tank out: the ground and the body across the whole of it, the
/// header across the top at the height it draws, and the level up from the
/// foot. The level stops [headerClearance] under the header, so no figure the
/// header holds is ever cut in two by its edge, but never under [levelFloor],
/// so a header too deep for the tank still lets the level reach the notch.
///
/// The centre block of a step without the sensor is centred between the top
/// of the tank and the set and rep card, as it always was, but never above
/// [centreGapUnderHeader] under the header: where the two would meet it is
/// pushed down, and where it is taller than the room between them it is
/// shrunk to it.
class _TankLayoutDelegate extends MultiChildLayoutDelegate {
  final double level;
  final double levelFloor;
  final double headerClearance;
  final double centreGapUnderHeader;
  final double bottomReserve;

  _TankLayoutDelegate({
    required this.level,
    required this.levelFloor,
    required this.headerClearance,
    required this.centreGapUnderHeader,
    required this.bottomReserve,
  });

  @override
  void performLayout(Size size) {
    for (final slot in [_TankSlot.ground, _TankSlot.body]) {
      layoutChild(slot, BoxConstraints.tight(size));
      positionChild(slot, Offset.zero);
    }
    final header = layoutChild(_TankSlot.header, BoxConstraints.loose(size));
    positionChild(_TankSlot.header, Offset.zero);

    if (hasChild(_TankSlot.centre)) {
      final roomTop = header.height + centreGapUnderHeader;
      final roomBottom = max(roomTop, size.height - bottomReserve);
      final block = layoutChild(
        _TankSlot.centre,
        BoxConstraints(
          maxWidth: max(0.0, size.width - 2 * _centreBlockInset),
          maxHeight: roomBottom - roomTop,
        ),
      );
      final centred = (_centreBlockTop + roomBottom - block.height) / 2;
      positionChild(
        _TankSlot.centre,
        Offset(
          (size.width - block.width) / 2,
          centred.clamp(roomTop, max(roomTop, roomBottom - block.height)),
        ),
      );
    }

    if (!hasChild(_TankSlot.level)) return;
    final ceiling = max(
      size.height - header.height - headerClearance,
      levelFloor,
    );
    final height = min(level, ceiling).clamp(0.0, size.height);
    layoutChild(
      _TankSlot.level,
      BoxConstraints.tight(Size(size.width, height)),
    );
    positionChild(_TankSlot.level, Offset(0, size.height - height));
  }

  @override
  bool shouldRelayout(_TankLayoutDelegate oldDelegate) =>
      oldDelegate.level != level ||
      oldDelegate.levelFloor != levelFloor ||
      oldDelegate.headerClearance != headerClearance ||
      oldDelegate.centreGapUnderHeader != centreGapUnderHeader ||
      oldDelegate.bottomReserve != bottomReserve;
}

/// What sits under the target on a hang, top to bottom.
enum _HangNoteSlot { target, goal, protocol, comment }

/// Lays the target and the notes of a hang out down the lower tank, centred.
/// Where a large text size leaves too little room for all of them, notes are
/// dropped rather than run under the set and rep card: the comment first,
/// then the goal. The protocol is the stop rule the hang is resolved by, so it
/// goes last; a note the lower tank cannot hold even on its own is clipped.
class _HangNotesLayoutDelegate extends MultiChildLayoutDelegate {
  /// Room above the goal, which heads the notes and sits apart from the
  /// target, and above each of the others.
  final double gapBeforeGoal;
  final double gapBeforeNote;

  _HangNotesLayoutDelegate({
    required this.gapBeforeGoal,
    required this.gapBeforeNote,
  });

  static const _notes = [
    _HangNoteSlot.goal,
    _HangNoteSlot.protocol,
    _HangNoteSlot.comment,
  ];

  static const _keptLongest = [
    _HangNoteSlot.protocol,
    _HangNoteSlot.goal,
    _HangNoteSlot.comment,
  ];

  @override
  void performLayout(Size size) {
    final loose = BoxConstraints(maxWidth: size.width);
    final sizes = <_HangNoteSlot, Size>{
      for (final slot in _HangNoteSlot.values)
        if (hasChild(slot)) slot: layoutChild(slot, loose),
    };
    final targetHeight = sizes[_HangNoteSlot.target]?.height ?? 0;

    double gapBefore(_HangNoteSlot slot) =>
        slot == _HangNoteSlot.goal ? gapBeforeGoal : gapBeforeNote;
    double heightOf(Set<_HangNoteSlot> notes) => notes.fold(
      targetHeight,
      (sum, slot) => sum + gapBefore(slot) + sizes[slot]!.height,
    );

    final shown = <_HangNoteSlot>{};
    for (final slot in _keptLongest.where(sizes.containsKey)) {
      if (shown.isNotEmpty && heightOf({...shown, slot}) > size.height) break;
      shown.add(slot);
    }

    void centre(_HangNoteSlot slot, double top) =>
        positionChild(slot, Offset((size.width - sizes[slot]!.width) / 2, top));

    var top = 0.0;
    if (sizes.containsKey(_HangNoteSlot.target)) {
      centre(_HangNoteSlot.target, top);
      top += targetHeight;
    }
    for (final slot in _notes.where(sizes.containsKey)) {
      if (!shown.contains(slot)) {
        // Laid out all the same, as every child has to be, and put past the
        // foot of the clip.
        positionChild(slot, Offset(0, size.height));
        continue;
      }
      top += gapBefore(slot);
      centre(slot, top);
      top += sizes[slot]!.height;
    }
  }

  @override
  bool shouldRelayout(_HangNotesLayoutDelegate oldDelegate) =>
      oldDelegate.gapBeforeGoal != gapBeforeGoal ||
      oldDelegate.gapBeforeNote != gapBeforeNote;
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
    // Flat: it tells the athlete where they are, and the level and the prompt
    // are what matter on this screen.
    decoration: CrimpyTheme.flat,
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
          style: CrimpyTheme.tabular(CrimpyTheme.titleLarge).apply(
            fontSizeFactor: scale.clamp(16 / 22, 28 / 22),
            fontWeightDelta: 1,
            color: CrimpyTheme.textPrimary,
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
    decoration: CrimpyTheme.raised,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'PAUSED',
          style: CrimpyTheme.capsHeadline.apply(
            fontSizeFactor: scale,
            letterSpacingFactor: scale,
            color: CrimpyTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8 * scale),
        Text(
          'Tap play to resume',
          style: CrimpyTheme.bodySmall.apply(
            fontSizeFactor: scale,
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
      color: CrimpyTheme.bgPrimary,
      border: Border(top: BorderSide(color: CrimpyTheme.outline, width: 2)),
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
                  style: CrimpyTheme.capsHeadline.copyWith(color: stateColor),
                ),
              if (nextStep != null) ...[
                Text(
                  'NEXT',
                  style: CrimpyTheme.capsLabel.copyWith(
                    color: CrimpyTheme.textMutedSmall,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nextStep!.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CrimpyTheme.title.copyWith(
                    color: CrimpyTheme.textPrimary,
                  ),
                ),
              ],
              if (detail != null) ...[
                const SizedBox(height: 4),
                Text(
                  detail!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CrimpyTheme.bodySmall.copyWith(
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
            // A choice the athlete makes, not an alarm, so it is not red. Red
            // on the run screen is the alarm's alone. See Krakoer/crimpy#158.
            color: CrimpyTheme.control,
            iconSize: 30,
            tooltip: 'I cannot make the next round',
          ),
        if (showConfirm)
          ElevatedButton.icon(
            onPressed: onConfirm,
            icon: const Icon(Icons.check),
            label: const Text('DONE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: CrimpyTheme.fillOn(CrimpyTheme.action),
              foregroundColor: CrimpyTheme.textOnFill,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          )
        else ...[
          _icon(
            isRunning ? Icons.pause : Icons.play_arrow,
            // Playing is the screen's primary action; pausing is a control.
            isRunning ? CrimpyTheme.control : CrimpyTheme.action,
            onPlayPause,
          ),
          const SizedBox(width: 28),
          _icon(Icons.skip_next, CrimpyTheme.textPrimary, onSkip),
        ],
      ],
    ),
  );
}
