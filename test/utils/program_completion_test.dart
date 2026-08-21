import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/utils/program_completion.dart';
import 'package:flutter_test/flutter_test.dart';

Program _program() => Program(
  id: 'p',
  coachId: 'c',
  userId: 'u',
  name: 'Block',
  startDate: DateTime(2026, 6, 1),
  durationWeeks: 6,
  createdAt: DateTime(2026, 6, 1),
  updatedAt: DateTime(2026, 6, 1),
);

WeekSession _daySession({String id = 's1'}) => WeekSession(
  id: id,
  trainingId: 't1',
  trainingTitle: 'Max Hangs',
  trainingType: 'crimpy',
  dayOfWeek: 2, // Wednesday -> 2026-06-03
  position: 0,
);

WeekSession _flexSession() => const WeekSession(
  id: 's2',
  trainingId: 't2',
  trainingTitle: 'Mobility',
  trainingType: 'stretching',
  timesPerWeek: 3,
  position: 1,
);

/// A session played from the scheduled slot [scheduledId].
SessionModel _playedFrom(String scheduledId, DateTime date, {String? name}) =>
    SessionModel(
      name: name ?? 'whatever the athlete called it',
      isAssessment: false,
      origin: SessionOrigin.logged,
      programSessionId: scheduledId,
      date: date,
    );

/// A session with no link to the program: played from the user's own library,
/// or logged by hand.
SessionModel _unattached(String name, DateTime date) => SessionModel(
  name: name,
  isAssessment: false,
  origin: SessionOrigin.logged,
  date: date,
);

void main() {
  test('day-of-week session is done when it was played that day', () {
    final program = _program();
    final s = _daySession();
    final date = s.scheduledDate(program, 1)!;

    expect(isScheduledTrainingDone([], program, 1, s, date: date), isFalse);

    final sessions = [_playedFrom(s.id, date)];
    expect(
      isScheduledTrainingDone(sessions, program, 1, s, date: date),
      isTrue,
    );
  });

  test('the session name has no say in completion', () {
    final program = _program();
    final s = _daySession();
    final date = s.scheduledDate(program, 1)!;

    // Renaming the training cannot un-complete a run already played from it.
    expect(
      isScheduledTrainingDone(
        [_playedFrom(s.id, date, name: 'Renamed to something else')],
        program,
        1,
        s,
        date: date,
      ),
      isTrue,
    );

    // A session played from the user's own library, or logged by hand, does
    // not count even when it carries the training title verbatim.
    expect(
      isScheduledTrainingDone(
        [_unattached('Max Hangs', date)],
        program,
        1,
        s,
        date: date,
      ),
      isFalse,
    );

    // Nor does a longer name the title is a prefix of.
    expect(
      isScheduledTrainingDone(
        [_unattached('Max Hangs - endurance', date)],
        program,
        1,
        s,
        date: date,
      ),
      isFalse,
    );
  });

  test('two slots sharing a title are completed independently', () {
    final program = _program();
    final morning = _daySession(id: 'slot-morning');
    final evening = _daySession(id: 'slot-evening');
    final date = morning.scheduledDate(program, 1)!;

    final sessions = [_playedFrom(morning.id, date)];

    expect(
      isScheduledTrainingDone(sessions, program, 1, morning, date: date),
      isTrue,
    );
    expect(
      isScheduledTrainingDone(sessions, program, 1, evening, date: date),
      isFalse,
    );
  });

  test('times-per-week session is done once the weekly target is reached', () {
    final program = _program();
    final s = _flexSession();

    final two = [
      _playedFrom(s.id, DateTime(2026, 6, 2)),
      _playedFrom(s.id, DateTime(2026, 6, 4)),
    ];
    expect(completionsInWeek(two, program, 1, s), 2);
    expect(
      isScheduledTrainingDone(two, program, 1, s, date: DateTime(2026, 6, 4)),
      isFalse,
    );

    final three = [...two, _playedFrom(s.id, DateTime(2026, 6, 6))];
    expect(
      isScheduledTrainingDone(three, program, 1, s, date: DateTime(2026, 6, 6)),
      isTrue,
    );
  });

  test('unattached sessions never count toward the weekly target', () {
    final program = _program();
    final s = _flexSession();
    final sessions = [
      _unattached('Mobility', DateTime(2026, 6, 2)),
      _unattached('Mobility', DateTime(2026, 6, 4)),
      _unattached('Mobility', DateTime(2026, 6, 6)),
    ];

    expect(completionsInWeek(sessions, program, 1, s), 0);
  });

  test(
    'weeks always start on Monday even when the program starts mid-week',
    () {
      // Program starting on a Sunday still has Monday-anchored weeks.
      final program = Program(
        id: 'p',
        coachId: 'c',
        userId: 'u',
        name: 'Block',
        startDate: DateTime(2026, 6, 7), // Sunday
        durationWeeks: 6,
        createdAt: DateTime(2026, 6, 7),
        updatedAt: DateTime(2026, 6, 7),
      );
      expect(program.weekStart(1), DateTime(2026, 6, 1)); // Monday
      expect(program.weekStart(2), DateTime(2026, 6, 8));
      // Monday 15 Jun is the first day (offset 0) of week 3.
      expect(program.currentWeekNumber(DateTime(2026, 6, 15)), 3);
      expect(program.dayOffsetOf(3, DateTime(2026, 6, 15)), 0);
    },
  );

  test('sessions outside the week are not counted', () {
    final program = _program();
    final s = _flexSession();
    // Week 1 is 1-7 Jun; this is week 2.
    final sessions = [_playedFrom(s.id, DateTime(2026, 6, 9))];
    expect(completionsInWeek(sessions, program, 1, s), 0);
  });
}
