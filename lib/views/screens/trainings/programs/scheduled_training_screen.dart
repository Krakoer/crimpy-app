import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/views/screens/home_screen/log_session_screen.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/play_training_screen.dart';
import 'package:crimpy/views/screens/trainings/programs/widgets/program_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const _dowLong = [
  'MONDAY',
  'TUESDAY',
  'WEDNESDAY',
  'THURSDAY',
  'FRIDAY',
  'SATURDAY',
  'SUNDAY',
];
const _months = [
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MAY',
  'JUN',
  'JUL',
  'AUG',
  'SEP',
  'OCT',
  'NOV',
  'DEC',
];

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
      programTrainingProvider((program.id, session.trainingId)),
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
            return _content(context, ref, merged);
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, Training training) {
    final overrideByItem = {for (final o in session.overrides) o.itemId: o};
    final date = session.scheduledDate(program, weekNumber);

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
              if (training.goal != null) ...[
                const SizedBox(height: 16),
                const ProgramSectionLabel('Goal'),
                const SizedBox(height: 8),
                _textBlock(training.goal!),
              ],
              if (training.comment != null) ...[
                const SizedBox(height: 16),
                const ProgramSectionLabel('Instructions'),
                const SizedBox(height: 8),
                _textBlock(training.comment!),
              ],
              if (training.items.isNotEmpty) ...[
                const SizedBox(height: 16),
                const ProgramSectionLabel('Exercises'),
                const SizedBox(height: 8),
                ..._buildItems(context, training.items, overrideByItem, 0),
              ],
            ],
          ),
        ),
        _actionBar(context, ref, training),
      ],
    );
  }

  Widget _textBlock(String text) {
    return CrimpyCard.simple(
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 12,
          height: 1.5,
          color: CrimpyTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _infoCard(BuildContext context, DateTime? date) {
    final type = session.sessionType;
    final color = programSessionColor(type);
    final schedule = switch (session.schedule) {
      SessionSchedule.dayOfWeek when date != null =>
        '${_dowLong[session.dayOfWeek!]} - ${date.day} ${_months[date.month - 1]}',
      SessionSchedule.everyday => 'EVERY DAY',
      _ => '${session.timesPerWeek ?? 0}x - ANY DAY',
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
    BuildContext context,
    List<TrainingItem> items,
    Map<String, SessionOverride> overrideByItem,
    int depth,
  ) {
    final widgets = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final override = overrideByItem[item.id];
      widgets.add(
        Padding(
          padding: EdgeInsets.only(left: depth * 14.0, bottom: 10),
          child: _itemTile(context, item, i + 1, override),
        ),
      );
      if (item.items.isNotEmpty) {
        widgets.addAll(
          _buildItems(context, item.items, overrideByItem, depth + 1),
        );
      }
    }
    return widgets;
  }

  Widget _itemTile(
    BuildContext context,
    TrainingItem item,
    int number,
    SessionOverride? override,
  ) {
    final tuned = override != null && override.overrides.isNotEmpty;
    final accent = tuned ? CrimpyTheme.accentYellow : null;
    final child = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: CrimpyTheme.bgSecondary,
            border: Border.all(color: CrimpyTheme.borderDefault, width: 1.5),
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _itemTitle(item),
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: CrimpyTheme.textPrimary,
                ),
              ),
              if (_itemDetail(item).isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  _itemDetail(item),
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11,
                    color: CrimpyTheme.textSecondary,
                  ),
                ),
              ],
              if (tuned) ...[
                const SizedBox(height: 9),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _overrideChips(override.overrides),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    return accent == null
        ? CrimpyCard.simple(child: child)
        : CrimpyCard.category(accentColor: accent, child: child);
  }

  String _itemTitle(TrainingItem item) => switch (item.type) {
    TrainingItemType.section => item.sectionTitle ?? 'Section',
    TrainingItemType.circuit => 'Circuit',
    TrainingItemType.repeater => 'Repeater',
    TrainingItemType.hangboardRep => 'Hangboard',
    TrainingItemType.exercise => 'Exercise',
    TrainingItemType.free => item.freeText ?? 'Note',
  };

  String _itemDetail(TrainingItem item) {
    String load() {
      final l = item.loads;
      if (l == null || l.isEmpty) return '';
      final first = l.first;
      return first.isBodyweight
          ? 'BW'
          : '${first.value.toStringAsFixed(first.value.truncateToDouble() == first.value ? 0 : 1)} ${first.unit}';
    }

    switch (item.type) {
      case TrainingItemType.repeater:
        return '${item.cycles ?? 1}x${item.reps ?? 1} - ${item.worktimeSeconds ?? 7}s on / ${item.restSeconds ?? 3}s off';
      case TrainingItemType.hangboardRep:
        final parts = [
          '${item.reps ?? 1} reps',
          '${item.worktimeSeconds ?? 7}s on / ${item.restSeconds ?? 3}s off',
          if (load().isNotEmpty) load(),
        ];
        return parts.join(' - ');
      case TrainingItemType.exercise:
        final parts = [
          if (item.reps != null) '${item.reps} reps',
          if (item.duration != null) '${item.duration}s',
          if (load().isNotEmpty) load(),
        ];
        return parts.join(' - ');
      case TrainingItemType.circuit:
        return '${item.cycles ?? 1} cycles';
      case TrainingItemType.section:
        return '';
      case TrainingItemType.free:
        return '';
    }
  }

  List<Widget> _overrideChips(Map<String, dynamic> overrides) {
    String fmtLoads(dynamic raw) {
      final list = (raw as List<dynamic>?) ?? [];
      if (list.isEmpty) return '';
      final first = list.first as Map<String, dynamic>;
      final value = (first['value'] as num?)?.toString() ?? '';
      return '$value ${first['unit'] ?? ''}'.trim();
    }

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
        'edge_sizes_mm' => 'EDGE ${(value as List).join('/')}mm',
        'hand_positions' => 'GRIP ${(value as List).join('/')}',
        'both_hands' => value == true ? 'BOTH HANDS' : 'SPLIT HANDS',
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
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    switch (session.schedule) {
      case SessionSchedule.dayOfWeek:
        final date = session.scheduledDate(program, weekNumber);
        return date != null && sameDay(date, today);
      case SessionSchedule.everyday:
      case SessionSchedule.timesPerWeek:
        return program.isActiveOn(today) &&
            program.currentWeekNumber(today) == weekNumber;
    }
  }

  Widget _actionBar(BuildContext context, WidgetRef ref, Training training) {
    // Only sensor (hangboard) trainings are run live; the others
    // (climbing, mobility, workout) are logged as completed sessions.
    final isSensorTraining = session.sessionType == SessionType.crimpy;
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
        child: isSensorTraining
            ? _startButton(context, ref, training)
            : _logButton(context),
      ),
    );
  }

  Widget _startButton(BuildContext context, WidgetRef ref, Training training) {
    final connected =
        ref.watch(connectionStateProvider) == BleConnectionState.connected;
    return ElevatedButton.icon(
      onPressed: connected
          ? () {
              ref.read(bleSessionProvider.notifier).reset();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (ctx) => PlayTrainingScreen(training),
                ),
              );
            }
          : null,
      icon: const Icon(Icons.play_arrow),
      label: Text(connected ? 'START TRAINING' : 'CONNECT SENSOR TO START'),
      style: ElevatedButton.styleFrom(
        backgroundColor: CrimpyTheme.primaryOrange,
        foregroundColor: CrimpyTheme.bgPrimary,
        padding: const EdgeInsets.symmetric(vertical: 14),
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
        ? 'SCHEDULED ${date.day} ${_months[date.month - 1]}'
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
