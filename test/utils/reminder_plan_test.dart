import 'package:crimpy/models/cached_program_schedule.dart';
import 'package:crimpy/models/notification_preferences.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/utils/reminder_plan.dart';
import 'package:flutter_test/flutter_test.dart';

// 2026-06-01 is a Monday, so week 1 runs 2026-06-01 to 2026-06-07.
Program _program({int? durationWeeks = 6}) => Program(
  id: 'p',
  coachId: 'c',
  userId: 'u',
  name: 'Block',
  startDate: DateTime(2026, 6, 1),
  durationWeeks: durationWeeks,
  createdAt: DateTime(2026, 6, 1),
  updatedAt: DateTime(2026, 6, 1),
);

WeekSession _daySession({int dayOfWeek = 2}) => WeekSession(
  id: 's1',
  trainingId: 't1',
  trainingTitle: 'Max Hangs',
  trainingType: 'crimpy',
  dayOfWeek: dayOfWeek,
  position: 0,
);

const _everydaySession = WeekSession(
  id: 's2',
  trainingId: 't2',
  trainingTitle: 'Mobility',
  trainingType: 'stretching',
  isEveryday: true,
  position: 1,
);

const _flexSession = WeekSession(
  id: 's3',
  trainingId: 't3',
  trainingTitle: 'Core',
  trainingType: 'workout',
  timesPerWeek: 3,
  position: 2,
);

Week _week(int weekNumber, List<WeekSession> sessions) => Week(
  id: 'w$weekNumber',
  programId: 'p',
  weekNumber: weekNumber,
  sessions: sessions,
);

CachedProgramSchedule _schedule(
  List<WeekSession> sessions, {
  Program? program,
  List<int> weekNumbers = const [1, 2, 3],
}) => CachedProgramSchedule(
  program: program ?? _program(),
  weeks: [for (final n in weekNumbers) _week(n, sessions)],
  cachedAt: DateTime(2026, 6, 1),
);

SessionModel _logged(String name, DateTime date) =>
    SessionModel(name: name, isAssessment: false, date: date);

const _enabled = NotificationPreferences(enabled: true);

/// Monday of week 1, 06:00, before the default 08:00 reminder.
final _mondayMorning = DateTime(2026, 6, 1, 6);

void main() {
  group('planReminders', () {
    test('schedules a day-of-week session on its calendar day only', () {
      final plan = planReminders(
        preferences: _enabled,
        schedule: _schedule([_daySession()]),
        sessions: [],
        from: _mondayMorning,
      );

      expect(plan, hasLength(2)); // weeks 1 and 2 of the 14 day horizon
      expect(plan.first.when, DateTime(2026, 6, 3, 8));
      expect(plan.first.title, '1 training today');
      expect(plan.first.body, 'Max Hangs');
      expect(plan.last.when, DateTime(2026, 6, 10, 8));
    });

    test('schedules an everyday session on every active weekday', () {
      final plan = planReminders(
        preferences: _enabled,
        schedule: _schedule([_everydaySession]),
        sessions: [],
        from: _mondayMorning,
      );

      expect(plan, hasLength(14));
      expect(plan.every((o) => o.body == 'Mobility'), isTrue);
    });

    test('honours the active weekdays', () {
      final plan = planReminders(
        preferences: _enabled.copyWith(activeWeekdays: {0, 2}),
        schedule: _schedule([_everydaySession]),
        sessions: [],
        from: _mondayMorning,
      );

      expect(plan, hasLength(4)); // two Mondays and two Wednesdays
      expect(plan.map((o) => o.when.weekday).toSet(), {
        DateTime.monday,
        DateTime.wednesday,
      });
    });

    test('schedules a flexible session on its default spread of days', () {
      final plan = planReminders(
        preferences: _enabled,
        schedule: _schedule([_flexSession], weekNumbers: [1]),
        sessions: [],
        from: _mondayMorning,
      );

      // defaultFlexibleDays(3) is Mon, Wed, Sat.
      expect(plan.map((o) => o.when.day), [1, 3, 6]);
      expect(plan.first.body, 'Core 0/3 this week');
    });

    test('schedules a flexible session on the days the user picked', () {
      final plan = planReminders(
        preferences: _enabled.copyWith(
          flexibleTrainingDays: {
            't3': {1, 4},
          },
        ),
        schedule: _schedule([_flexSession], weekNumbers: [1]),
        sessions: [],
        from: _mondayMorning,
      );

      expect(plan.map((o) => o.when.day), [2, 5]); // Tuesday and Friday
    });

    test('drops a training already logged that day but keeps later days', () {
      final plan = planReminders(
        preferences: _enabled,
        schedule: _schedule([_everydaySession]),
        sessions: [_logged('Mobility - 01/06/2026', DateTime(2026, 6, 1, 7))],
        from: _mondayMorning,
      );

      expect(plan, hasLength(13));
      expect(plan.first.when, DateTime(2026, 6, 2, 8));
    });

    test(
      'stops reminding a flexible session once its weekly target is met',
      () {
        final done = [
          _logged('Core - 01/06/2026', DateTime(2026, 6, 1)),
          _logged('Core - 02/06/2026', DateTime(2026, 6, 2)),
          _logged('Core - 03/06/2026', DateTime(2026, 6, 3)),
        ];

        final plan = planReminders(
          preferences: _enabled,
          schedule: _schedule([_flexSession], weekNumbers: [1, 2]),
          sessions: done,
          from: _mondayMorning,
        );

        // Week 1 is satisfied, so only week 2 still reminds.
        expect(plan.every((o) => o.when.isAfter(DateTime(2026, 6, 7))), isTrue);
        expect(plan.map((o) => o.when.day), [8, 10, 13]);
      },
    );

    test('combines the trainings due on the same day into one reminder', () {
      final plan = planReminders(
        preferences: _enabled,
        schedule: _schedule(
          [_daySession(dayOfWeek: 0), _everydaySession, _flexSession],
          weekNumbers: [1],
        ),
        sessions: [],
        from: _mondayMorning,
      );

      expect(plan.first.when, DateTime(2026, 6, 1, 8));
      expect(plan.first.title, '3 trainings today');
      expect(plan.first.body, 'Max Hangs, Mobility, Core 0/3 this week');
    });

    test('emits one occurrence per configured time', () {
      final plan = planReminders(
        preferences: _enabled.copyWith(
          secondaryTime: const ReminderTime(19, 30),
        ),
        schedule: _schedule([_daySession()], weekNumbers: [1]),
        sessions: [],
        from: _mondayMorning,
      );

      expect(plan.map((o) => o.when), [
        DateTime(2026, 6, 3, 8),
        DateTime(2026, 6, 3, 19, 30),
      ]);
      expect(plan.map((o) => o.slot), [0, 1]);
    });

    test('discards times that already passed', () {
      final plan = planReminders(
        preferences: _enabled,
        schedule: _schedule([_everydaySession], weekNumbers: [1]),
        sessions: [],
        from: DateTime(2026, 6, 1, 9), // after the 08:00 reminder
      );

      expect(plan.first.when, DateTime(2026, 6, 2, 8));
    });

    test('stops at the end of the program', () {
      final plan = planReminders(
        preferences: _enabled,
        schedule: _schedule(
          [_everydaySession],
          program: _program(durationWeeks: 1),
          weekNumbers: [1, 2],
        ),
        sessions: [],
        from: _mondayMorning,
      );

      expect(plan, hasLength(7));
      expect(plan.last.when, DateTime(2026, 6, 7, 8));
    });

    test('produces nothing without a schedule, a week or the opt-in', () {
      expect(
        planReminders(
          preferences: _enabled,
          schedule: null,
          sessions: [],
          from: _mondayMorning,
        ),
        isEmpty,
      );
      expect(
        planReminders(
          preferences: const NotificationPreferences(),
          schedule: _schedule([_everydaySession]),
          sessions: [],
          from: _mondayMorning,
        ),
        isEmpty,
      );
      expect(
        planReminders(
          preferences: _enabled,
          schedule: _schedule([_everydaySession], weekNumbers: []),
          sessions: [],
          from: _mondayMorning,
        ),
        isEmpty,
      );
    });

    test('produces nothing on a rest day', () {
      final plan = planReminders(
        preferences: _enabled,
        schedule: _schedule([_daySession()], weekNumbers: [1]),
        sessions: [],
        from: _mondayMorning,
      );

      expect(plan, hasLength(1));
    });
  });

  group('notificationId', () {
    test('is stable per day and slot, and distinct across the horizon', () {
      final plan = planReminders(
        preferences: _enabled.copyWith(
          secondaryTime: const ReminderTime(19, 0),
        ),
        schedule: _schedule([_everydaySession]),
        sessions: [],
        from: _mondayMorning,
      );

      final ids = plan.map((o) => o.notificationId).toList();
      expect(ids.toSet(), hasLength(ids.length));
      expect(
        ids.every(
          (id) =>
              id >= reminderIdBase && id < reminderIdBase + reminderIdBlockSize,
        ),
        isTrue,
      );
    });
  });

  group('defaultFlexibleDays', () {
    test('spreads the requested count evenly over the week', () {
      expect(defaultFlexibleDays(1), {0});
      expect(defaultFlexibleDays(2), {0, 4});
      expect(defaultFlexibleDays(3), {0, 2, 5});
      expect(defaultFlexibleDays(7), {0, 1, 2, 3, 4, 5, 6});
    });

    test('clamps out of range counts', () {
      expect(defaultFlexibleDays(0), {0});
      expect(defaultFlexibleDays(12), allWeekdays);
    });
  });

  group('NotificationPreferences', () {
    test('round-trips through JSON', () {
      const preferences = NotificationPreferences(
        enabled: true,
        primaryTime: ReminderTime(7, 15),
        secondaryTime: ReminderTime(20, 45),
        activeWeekdays: {0, 3, 6},
        flexibleTrainingDays: {
          't3': {1, 4},
        },
      );

      final restored = NotificationPreferences.fromJson(preferences.toJson());

      expect(restored.enabled, isTrue);
      expect(restored.primaryTime, const ReminderTime(7, 15));
      expect(restored.secondaryTime, const ReminderTime(20, 45));
      expect(restored.activeWeekdays, {0, 3, 6});
      expect(restored.flexibleTrainingDays, {
        't3': {1, 4},
      });
    });

    test('falls back to the defaults on an empty payload', () {
      final restored = NotificationPreferences.fromJson({});

      expect(restored.enabled, isFalse);
      expect(restored.primaryTime, const ReminderTime(8, 0));
      expect(restored.secondaryTime, isNull);
      expect(restored.activeWeekdays, allWeekdays);
      expect(restored.times, hasLength(1));
      expect(restored.snoozedUntil, isNull);
    });

    test('a snooze survives the round trip', () {
      final preferences = _enabled.copyWith(
        snoozedUntil: DateTime(2026, 6, 1, 19, 30),
      );

      final restored = NotificationPreferences.fromJson(preferences.toJson());

      expect(restored.snoozedUntil, DateTime(2026, 6, 1, 19, 30));
    });
  });

  group('snoozed reminders', () {
    test('adds one occurrence at the chosen hour', () {
      final plan = planReminders(
        preferences: _enabled.copyWith(
          snoozedUntil: DateTime(2026, 6, 1, 19, 30),
        ),
        schedule: _schedule([_everydaySession]),
        sessions: [],
        from: _mondayMorning,
      );

      final snoozed = plan.where((o) => o.isSnoozed).toList();
      expect(snoozed, hasLength(1));
      expect(snoozed.single.when, DateTime(2026, 6, 1, 19, 30));
      expect(snoozed.single.body, 'Mobility');
    });

    test('keeps an id of its own so it never overwrites a scheduled slot', () {
      final plan = planReminders(
        preferences: _enabled.copyWith(
          snoozedUntil: DateTime(2026, 6, 1, 19, 30),
        ),
        schedule: _schedule([_everydaySession]),
        sessions: [],
        from: _mondayMorning,
      );

      final ids = plan.map((o) => o.notificationId).toList();
      expect(ids.toSet(), hasLength(ids.length));
      expect(
        plan.firstWhere((o) => o.isSnoozed).notificationId,
        snoozeNotificationId,
      );
      expect(
        ids.every(
          (id) =>
              id >= reminderIdBase && id < reminderIdBase + reminderIdBlockSize,
        ),
        isTrue,
      );
    });

    test('fires on a day the reminder is normally silent', () {
      // The user asked for this hour by hand, so the active weekdays that gate
      // a scheduled reminder do not apply to it.
      final plan = planReminders(
        preferences: _enabled.copyWith(
          activeWeekdays: {2},
          snoozedUntil: DateTime(2026, 6, 1, 19, 30),
        ),
        schedule: _schedule([_everydaySession]),
        sessions: [],
        from: _mondayMorning,
      );

      expect(plan.where((o) => o.isSnoozed), hasLength(1));
    });

    test('stays quiet once the training it postponed is logged', () {
      final plan = planReminders(
        preferences: _enabled.copyWith(
          snoozedUntil: DateTime(2026, 6, 1, 19, 30),
        ),
        schedule: _schedule([_everydaySession]),
        sessions: [_logged('Mobility', DateTime(2026, 6, 1, 12))],
        from: _mondayMorning,
      );

      expect(plan.where((o) => o.isSnoozed), isEmpty);
    });

    test('a snooze already gone is not planned', () {
      final plan = planReminders(
        preferences: _enabled.copyWith(snoozedUntil: DateTime(2026, 6, 1, 5)),
        schedule: _schedule([_everydaySession]),
        sessions: [],
        from: _mondayMorning,
      );

      expect(plan.where((o) => o.isSnoozed), isEmpty);
    });

    test('a spent snooze is forgotten rather than carried around', () {
      final preferences = _enabled.copyWith(
        snoozedUntil: DateTime(2026, 6, 1, 5),
      );

      expect(
        preferences.withoutStaleSnooze(_mondayMorning).snoozedUntil,
        isNull,
      );
      expect(
        _enabled
            .copyWith(snoozedUntil: DateTime(2026, 6, 1, 19))
            .withoutStaleSnooze(_mondayMorning)
            .snoozedUntil,
        DateTime(2026, 6, 1, 19),
      );
    });
  });
}
