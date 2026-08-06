import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/format.dart';
import 'package:crimpy/utils/program_completion.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/log_session_screen.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/play_training_screen.dart';
import 'package:crimpy/views/screens/trainings/programs/widgets/program_widgets.dart';
import 'package:crimpy/views/widgets/ble/connection_dialog.dart';
import 'package:crimpy/views/widgets/bodyweight_dialog.dart';
import 'package:crimpy/views/widgets/training_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:crimpy/views/widgets/section_widgets.dart';

/// Detail of a single training scheduled within a program week, with its
/// exercises (overrides merged) and a Start button into the run screen.
class ScheduledTrainingScreen extends ConsumerWidget {
  final Program program;
  final int weekNumber;
  final WeekSession session;

  const ScheduledTrainingScreen({
    required this.program,
    required this.weekNumber,
    required this.session,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingAsync = ref.watch(
      programTrainingProvider(program.id, session.trainingId),
    );

    return Scaffold(
      appBar: AppBar(title: Text(session.trainingTitle)),
      body: SafeArea(
        child: trainingAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not load this training.\n$e',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          data: (training) {
            final merged = effectiveTraining(training, session.overrides);
            final results =
                ref.watch(assessmentResultsProvider).value ??
                AssessmentResults.none;
            return _content(context, ref, merged, results);
          },
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    WidgetRef ref,
    Training training,
    AssessmentResults results,
  ) {
    final overrideByItem = {for (final o in session.overrides) o.itemId: o};
    final date = session.scheduledDate(program, weekNumber);
    final goal = training.goal?.trim() ?? '';
    final instructions = training.comment?.trim() ?? '';
    final bodyweight = ref.watch(bodyweightProvider).value;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _infoCard(context, date),
              if (session.overrides.isNotEmpty) ...[
                const SizedBox(height: 12),
                _tunedBanner(context),
              ],
              if (goal.isNotEmpty) ...[
                const SizedBox(height: 16),
                const SectionLabel('Goal'),
                const SizedBox(height: 8),
                SectionTextBlock(goal),
              ],
              if (instructions.isNotEmpty) ...[
                const SizedBox(height: 16),
                const SectionLabel('Instructions'),
                const SizedBox(height: 8),
                SectionTextBlock(instructions),
              ],
              if (training.items.isNotEmpty) ...[
                const SizedBox(height: 16),
                const SectionLabel('Exercises'),
                const SizedBox(height: 8),
                ..._buildItems(
                  training.items,
                  overrideByItem,
                  bodyweight,
                  results,
                ),
              ],
            ],
          ),
        ),
        _actionBar(context, ref, training, results),
      ],
    );
  }

  Widget _infoCard(BuildContext context, DateTime? date) {
    final type = session.sessionType;
    final color = programSessionColor(type);
    final schedule = switch (session.schedule) {
      SessionSchedule.dayOfWeek when date != null =>
        '${weekdayShort(date)} - ${formatDayMonth(date)}',
      SessionSchedule.everyday => 'EVERY DAY',
      _ => '${session.timesPerWeek ?? 1}x - ANY DAY',
    };

    return CrimpyCard.category(
      accentColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SessionTypeTile(type: type, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          programSessionLabel(type),
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ScheduleStatusTag(
                          status: scheduleStatusFor(date, DateTime.now()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.calendar,
                          size: 12,
                          color: CrimpyTheme.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          schedule,
                          style: const TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 11,
                            color: CrimpyTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if ((session.notes ?? '').isNotEmpty) ...[
            const SizedBox(height: 13),
            _coachNote(session.notes!),
          ],
        ],
      ),
    );
  }

  Widget _coachNote(String note) {
    final initials = program.name.isEmpty
        ? 'C'
        : program.name.trim()[0].toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: CrimpyTheme.bgSecondary,
        border: Border.all(color: CrimpyTheme.borderDefault, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: CrimpyTheme.primaryOrange,
              border: Border.all(color: CrimpyTheme.borderDefault, width: 1.5),
            ),
            child: Text(
              initials,
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: CrimpyTheme.bgPrimary,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              note,
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 11.5,
                height: 1.45,
                color: CrimpyTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tunedBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: CrimpyTheme.accentYellow.withValues(alpha: 0.12),
        border: Border.all(color: CrimpyTheme.accentYellow, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            FontAwesomeIcons.star,
            size: 15,
            color: CrimpyTheme.accentYellow,
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Text(
              'TUNED FOR YOU THIS WEEK. Highlighted values differ from the base training.',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 11,
                height: 1.45,
                color: CrimpyTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItems(
    List<TrainingItem> items,
    Map<String, SessionOverride> overrideByItem,
    double? bodyweightKg,
    AssessmentResults results,
  ) {
    bool tuned(TrainingItem item) {
      final override = overrideByItem[item.id];
      return override != null && override.overrides.isNotEmpty;
    }

    return buildTrainingItemTiles(
      items,
      bodyweightKg: bodyweightKg,
      results: results,
      accentColorOf: (item) => tuned(item) ? CrimpyTheme.accentYellow : null,
      extraOf: (item) => tuned(item)
          ? [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _overrideChips(overrideByItem[item.id]!.overrides),
              ),
            ]
          : const [],
    );
  }

  List<Widget> _overrideChips(Map<String, dynamic> overrides) {
    // A chip summarises the whole override, so it shows the first row only.
    String fmtLoads(dynamic raw) {
      final first = raw is List ? raw.firstOrNull : null;
      if (first is! Map<String, dynamic>) return '';
      final value = (first['value'] as num?)?.toString() ?? '';
      return '$value ${first['unit'] ?? ''}'.trim();
    }

    String fmtList(dynamic raw) => raw is List ? raw.join('/') : '';

    // Grips arrive as one array per hand, so each hand reads as its own group.
    String fmtGrips(dynamic raw) {
      final byHand = parseHandPositions(raw);
      if (byHand == null) return '';
      return byHand.map((hand) => hand.join('/')).join(' | ');
    }

    String fmtHand(dynamic raw) => switch (raw) {
      HangboardHand.both => 'BOTH HANDS',
      HangboardHand.alternate => 'ALTERNATE HANDS',
      HangboardHand.split => 'SPLIT HANDS',
      HangboardHand.left => 'LEFT HAND',
      HangboardHand.right => 'RIGHT HAND',
      _ => '$raw',
    };

    final entries = <String>[];
    overrides.forEach((key, value) {
      final label = switch (key) {
        'loads' => 'LOAD ${fmtLoads(value)}',
        'left_loads' => 'LEFT ${fmtLoads(value)}',
        'reps' => 'REPS $value',
        'cycles' => 'CYCLES $value',
        'cycle_rest_seconds' => 'CYCLE REST ${value}s',
        'rest_seconds' => 'REST ${value}s',
        'hb_worktime_seconds' => 'WORK ${value}s',
        'edge_sizes_mm' => 'EDGE ${fmtList(value)}mm',
        'hand_positions' => 'GRIP ${fmtGrips(value)}',
        'hand' => fmtHand(value),
        'granularity' => 'LAYOUT ${'$value'.toUpperCase()}',
        _ => '${key.toUpperCase()} $value',
      };
      entries.add(label);
    });

    return entries
        .map(
          (e) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: CrimpyTheme.accentYellow.withValues(alpha: 0.13),
              border: Border.all(color: CrimpyTheme.accentYellow, width: 1.5),
            ),
            child: Text(
              e,
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: CrimpyTheme.primaryOrange,
              ),
            ),
          ),
        )
        .toList();
  }

  /// Whether this session occurs today: an exact date match for day-of-week
  /// sessions, or the current week for everyday / times-per-week ones.
  bool _isScheduledToday() {
    final today = DateTime.now();
    switch (session.schedule) {
      case SessionSchedule.dayOfWeek:
        final date = session.scheduledDate(program, weekNumber);
        return date != null && isSameDay(date, today);
      case SessionSchedule.everyday:
      case SessionSchedule.timesPerWeek:
        return program.isActiveOn(today) &&
            program.currentWeekNumber(today) == weekNumber;
    }
  }

  Widget _actionBar(
    BuildContext context,
    WidgetRef ref,
    Training training,
    AssessmentResults results,
  ) {
    // Every training can be run except climbing, which is only logged.
    final logOnly = session.sessionType == SessionType.climbing;
    final sessions = ref.watch(sessionsProvider).asData?.value ?? [];
    final done = isScheduledTrainingDone(
      sessions,
      program,
      weekNumber,
      session,
      date: session.scheduledDate(program, weekNumber) ?? DateTime.now(),
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: CrimpyTheme.bgPrimary,
        border: Border(
          top: BorderSide(color: CrimpyTheme.borderDefault, width: 2),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: done
            ? _doneButton()
            : logOnly
            ? _logButton(context)
            : _startButton(context, ref, training, results),
      ),
    );
  }

  Widget _doneButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: CrimpyTheme.statusSuccess.withValues(alpha: 0.12),
        border: Border.all(color: CrimpyTheme.statusSuccess, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FontAwesomeIcons.circleCheck,
            size: 16,
            color: CrimpyTheme.statusSuccess,
          ),
          const SizedBox(width: 8),
          const Text(
            'DONE',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: CrimpyTheme.statusSuccess,
            ),
          ),
        ],
      ),
    );
  }

  Widget _startButton(
    BuildContext context,
    WidgetRef ref,
    Training training,
    AssessmentResults results,
  ) {
    return ElevatedButton.icon(
      onPressed: () => _startRun(context, ref, training, results),
      icon: const Icon(Icons.play_arrow),
      label: const Text('START TRAINING'),
      style: ElevatedButton.styleFrom(
        backgroundColor: CrimpyTheme.primaryOrange,
        foregroundColor: CrimpyTheme.bgPrimary,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  /// Starts the run. If the training can be measured with the force sensor,
  /// asks whether the user has one and lets them connect; otherwise (or if they
  /// decline) the training runs without the gauge. Loads set in percent of the
  /// body weight also need one, so it is asked for when still missing.
  Future<void> _startRun(
    BuildContext context,
    WidgetRef ref,
    Training training,
    AssessmentResults results,
  ) async {
    var useSensor = false;
    if (training.canUseSensor) {
      final hasSensor = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Force sensor'),
          content: const Text(
            'Do you have a Crimpy force sensor to measure this training?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Run without'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Yes, connect'),
            ),
          ],
        ),
      );
      if (!context.mounted) return;
      if (hasSensor == true) {
        final connected = await showDialog<bool>(
          context: context,
          builder: (_) => const ConnectionDialog(),
        );
        if (!context.mounted) return;
        useSensor = connected == true;
      }
    }
    // After the sensor, so a user who just connected one is offered the
    // measurement rather than being asked to connect all over again.
    final bodyweight = await resolveBodyweight(context, ref, training);
    if (!context.mounted) return;
    ref.read(bleSessionProvider.notifier).reset();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayTrainingScreen(
          training,
          useSensor: useSensor,
          sessionType: session.sessionType,
          bodyweightKg: bodyweight,
        ),
      ),
    );
  }

  Widget _logButton(BuildContext context) {
    final color = programSessionColor(session.sessionType);
    final canLog = _isScheduledToday();
    final date = session.scheduledDate(program, weekNumber);
    final label = canLog
        ? 'LOG AS DONE'
        : date != null
        ? 'SCHEDULED ${formatDayMonth(date)}'
        : 'NOT SCHEDULED TODAY';

    return ElevatedButton.icon(
      onPressed: canLog
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LogSessionScreen(
                    sessionType: session.sessionType,
                    name: session.trainingTitle,
                  ),
                ),
              );
            }
          : null,
      icon: const Icon(Icons.check),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: CrimpyTheme.bgPrimary,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}
