import 'package:crimpy/models/notification_preferences.dart';
import 'package:crimpy/models/week_availability.dart';
import 'package:crimpy/utils/availability_reminder_plan.dart';
import 'package:crimpy/utils/reminder_plan.dart';
import 'package:flutter_test/flutter_test.dart';

// 2026-06-01 is a Monday, so the Friday of that week is 2026-06-05 and the week
// it nudges about starts on 2026-06-08.
final _monday = DateTime(2026, 6, 1);
final _nextMonday = DateTime(2026, 6, 8);

CoachAvailabilityReminder _reminder({
  bool enabled = true,
  int dayOfWeek = 4,
  int hour = 21,
}) => CoachAvailabilityReminder(
  enabled: enabled,
  dayOfWeek: dayOfWeek,
  time: ReminderTime(hour, 0),
);

List<ReminderOccurrence> _plan({
  CoachAvailabilityReminder? reminder,
  Set<DateTime> declared = const {},
  DateTime? from,
}) => planAvailabilityReminders(
  reminder: reminder ?? _reminder(),
  declaredWeekStarts: declared,
  from: from ?? _monday,
);

void main() {
  group('availability reminder plan', () {
    test('nudges on the configured day, at the configured hour', () {
      final occurrences = _plan();

      expect(occurrences, hasLength(2));
      expect(occurrences.first.when, DateTime(2026, 6, 5, 21));
      // The horizon is 14 days, so the following Friday is planned too.
      expect(occurrences.last.when, DateTime(2026, 6, 12, 21));
    });

    test('stays quiet about a week the athlete already declared', () {
      final occurrences = _plan(declared: {_nextMonday});

      // Only the Friday nudging about 2026-06-08 goes: the one a week later is
      // about 2026-06-15, which is still undeclared.
      expect(occurrences, hasLength(1));
      expect(occurrences.single.when, DateTime(2026, 6, 12, 21));
    });

    test('a declared week is matched whatever time of day it carries', () {
      // A week start read back from the API parses at midnight, but a week
      // start built from DateTime.now() does not, and the two must still match.
      final occurrences = _plan(
        declared: {DateTime(2026, 6, 8, 17, 42), DateTime(2026, 6, 15, 3)},
      );

      expect(occurrences, isEmpty);
    });

    test('plans nothing when the coach set no reminder', () {
      expect(
        planAvailabilityReminders(
          reminder: null,
          declaredWeekStarts: const {},
          from: _monday,
        ),
        isEmpty,
      );
    });

    test('plans nothing when the reminder is off', () {
      expect(_plan(reminder: _reminder(enabled: false)), isEmpty);
    });

    test('skips an hour that has already gone today', () {
      // Asked on the Friday itself, at 22:00, an hour after the reminder.
      final occurrences = _plan(from: DateTime(2026, 6, 5, 22));

      expect(occurrences, hasLength(1));
      expect(occurrences.single.when, DateTime(2026, 6, 12, 21));
    });

    test('every id stays inside the availability block', () {
      final ids = _plan().map((o) => o.notificationId).toList();

      expect(ids, hasLength(2));
      for (final id in ids) {
        expect(id, greaterThanOrEqualTo(availabilityReminderIdBase));
        expect(
          id,
          lessThan(
            availabilityReminderIdBase + availabilityReminderIdBlockSize,
          ),
        );
      }
      // Two different weeks must not collide onto one notification.
      expect(ids.toSet(), hasLength(2));
    });

    test('never lands on the training reminder or coach reply blocks', () {
      for (final occurrence in _plan()) {
        expect(occurrence.notificationId, lessThan(reminderIdBase));
        expect(occurrence.notificationId, lessThan(800000));
      }
    });

    test('replanning the same week reuses its id', () {
      final first = _plan().first.notificationId;
      final again = _plan(from: DateTime(2026, 6, 2)).first.notificationId;

      expect(again, first);
    });
  });

  group('notification id blocks', () {
    // Cancelling one plan clears its whole block, so an overlap between two
    // blocks means writing one plan silently kills the other.
    const coachReplyIdBase = 800000;
    const coachReplyIdBlockSize = 500;

    test('the availability block holds only its own ids', () {
      expect(
        idIsInBlock(
          availabilityReminderIdBase,
          availabilityReminderIdBase,
          availabilityReminderIdBlockSize,
        ),
        isTrue,
      );
      expect(
        idIsInBlock(
          availabilityReminderIdBase + availabilityReminderIdBlockSize,
          availabilityReminderIdBase,
          availabilityReminderIdBlockSize,
        ),
        isFalse,
      );
      expect(
        idIsInBlock(
          availabilityReminderIdBase - 1,
          availabilityReminderIdBase,
          availabilityReminderIdBlockSize,
        ),
        isFalse,
      );
    });

    test('the three blocks never overlap', () {
      final blocks = [
        (availabilityReminderIdBase, availabilityReminderIdBlockSize),
        (coachReplyIdBase, coachReplyIdBlockSize),
        (reminderIdBase, reminderIdBlockSize),
      ];

      for (final (base, size) in blocks) {
        for (final (otherBase, otherSize) in blocks) {
          if (base == otherBase) continue;
          // Neither end of one block falls inside another.
          expect(idIsInBlock(base, otherBase, otherSize), isFalse);
          expect(idIsInBlock(base + size - 1, otherBase, otherSize), isFalse);
        }
      }
    });
  });
}
