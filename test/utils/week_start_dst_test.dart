import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/utils/datetimes.dart';
import 'package:flutter_test/flutter_test.dart';

Program _program({required DateTime startDate, int? durationWeeks}) => Program(
  id: 'p',
  coachId: 'c',
  userId: 'u',
  name: 'Block',
  startDate: startDate,
  durationWeeks: durationWeeks,
  createdAt: startDate,
  updatedAt: startDate,
);

// A week start is a map key: the declared week, the home card and the reminder
// planner all decide by comparing one against another. Built by adding a
// Duration, which is elapsed time, a week start lands an hour either side of
// midnight across a DST change and stops comparing equal to itself.
//
// These run in whatever zone the machine is in, so they cannot force a
// transition. What they pin is the property that makes the arithmetic safe
// everywhere: every result is local midnight on a Monday, and stepping a week
// lands on the next Monday rather than 168 hours later.
void main() {
  group('getStartOfWeek', () {
    test('is local midnight on the Monday of that week', () {
      for (var offset = 0; offset < 400; offset++) {
        final day = DateTime(2026, 1, 1 + offset, 13, 37);
        final monday = getStartOfWeek(day);

        expect(monday.weekday, DateTime.monday, reason: 'day $day');
        expect(monday.hour, 0, reason: 'day $day');
        expect(monday.minute, 0, reason: 'day $day');
      }
    });

    test('is idempotent, so a stored week start reads back equal', () {
      for (var offset = 0; offset < 400; offset++) {
        final monday = getStartOfWeek(DateTime(2026, 1, 1 + offset));

        expect(getStartOfWeek(monday), monday);
      }
    });
  });

  group('getStartOfNextWeek', () {
    test(
      'lands on the following Monday at midnight, every week of the year',
      () {
        for (var offset = 0; offset < 400; offset++) {
          final day = DateTime(2026, 1, 1 + offset);
          final next = getStartOfNextWeek(day);

          expect(next.weekday, DateTime.monday, reason: 'day $day');
          expect(next.hour, 0, reason: 'day $day');
          expect(next, getStartOfWeek(next), reason: 'day $day');
        }
      },
    );

    test('is exactly one week on from this one, in calendar days', () {
      for (var offset = 0; offset < 400; offset++) {
        final day = DateTime(2026, 1, 1 + offset);
        final monday = getStartOfWeek(day);
        final next = getStartOfNextWeek(day);

        expect(next.difference(monday).inDays, inInclusiveRange(6, 8));
        expect(getStartOfWeek(next.subtract(const Duration(days: 1))), monday);
      }
    });
  });

  group('addCalendarDays', () {
    // The time of day is deliberately not asserted. A zone may skip local
    // midnight outright: Santiago moves 2026-09-06 00:00 to 01:00, so the
    // start of that day is 01:00 and no arithmetic can put it at 0. What has
    // to hold is the calendar date, checked against UTC, which has no
    // transitions and so counts days exactly.
    test('lands on the right calendar date and keeps the weekday', () {
      for (var offset = 0; offset < 400; offset++) {
        final day = DateTime(2026, 1, 1 + offset);
        final moved = addCalendarDays(day, 7);
        final expected = DateTime.utc(
          day.year,
          day.month,
          day.day,
        ).add(const Duration(days: 7));

        expect(
          [moved.year, moved.month, moved.day],
          [expected.year, expected.month, expected.day],
          reason: 'day $day',
        );
        expect(moved.weekday, day.weekday, reason: 'day $day');
        expect(calendarDaysBetween(day, moved), 7, reason: 'day $day');
      }
    });

    test('steps back as well as forward', () {
      for (var offset = 0; offset < 400; offset++) {
        final day = DateTime(2026, 1, 1 + offset);

        expect(addCalendarDays(addCalendarDays(day, 7), -7), day);
      }
    });
  });

  group('calendarDaysBetween', () {
    test('counts dates, not elapsed hours', () {
      for (var offset = 0; offset < 400; offset++) {
        final from = DateTime(2026, 1, 1 + offset);
        final to = DateTime(2026, 1, 1 + offset + 6);

        expect(calendarDaysBetween(from, to), 6, reason: 'day $from');
        expect(calendarDaysBetween(to, from), -6, reason: 'day $from');
      }
    });

    test('ignores the time of day on either side', () {
      for (var offset = 0; offset < 400; offset++) {
        final from = DateTime(2026, 1, 1 + offset, 23, 30);
        final to = DateTime(2026, 1, 1 + offset + 1, 0, 15);

        expect(calendarDaysBetween(from, to), 1, reason: 'day $from');
      }
    });
  });

  group('Program.weekStart', () {
    test('is the start of a Monday, every week of a long program', () {
      for (var offset = 0; offset < 400; offset++) {
        final program = _program(startDate: DateTime(2026, 1, 1 + offset));

        for (var week = 1; week <= 52; week++) {
          final start = program.weekStart(week);

          expect(start.weekday, DateTime.monday, reason: 'week $week $start');
          expect(start, getStartOfWeek(start), reason: 'week $week $start');
        }
      }
    });

    test('steps one calendar week per week number', () {
      final program = _program(startDate: DateTime(2026, 1, 1));

      for (var week = 1; week < 52; week++) {
        expect(
          program.weekStart(week + 1),
          addCalendarDays(program.weekStart(week), 7),
          reason: 'week $week',
        );
      }
    });
  });

  group('Program.currentWeekNumber', () {
    test('reads back the week every day of it belongs to', () {
      final program = _program(startDate: DateTime(2026, 1, 1));

      for (var week = 1; week <= 52; week++) {
        final start = program.weekStart(week);

        for (var day = 0; day < 7; day++) {
          final date = addCalendarDays(start, day);

          expect(
            program.currentWeekNumber(date),
            week,
            reason: 'week $week day $date',
          );
          final lateInTheDay = DateTime(
            date.year,
            date.month,
            date.day,
            23,
            30,
          );
          expect(
            program.currentWeekNumber(lateInTheDay),
            week,
            reason: 'late in week $week day $date',
          );
        }
      }
    });

    test('holds for a program starting on any day of the year', () {
      for (var offset = 0; offset < 400; offset++) {
        final program = _program(startDate: DateTime(2026, 1, 1 + offset));

        for (var week = 1; week <= 12; week++) {
          expect(
            program.currentWeekNumber(program.weekStart(week)),
            week,
            reason: 'start ${program.startDate} week $week',
          );
        }
      }
    });
  });

  group('Program.dayOffsetOf', () {
    test('numbers the seven days of a week 0 to 6', () {
      final program = _program(startDate: DateTime(2026, 1, 1));

      for (var week = 1; week <= 52; week++) {
        final start = program.weekStart(week);

        for (var day = 0; day < 7; day++) {
          expect(
            program.dayOffsetOf(week, addCalendarDays(start, day)),
            day,
            reason: 'week $week day $day',
          );
        }
      }
    });
  });

  group('Program.endDate', () {
    test('is the Sunday closing the last week', () {
      for (var offset = 0; offset < 400; offset++) {
        final program = _program(
          startDate: DateTime(2026, 1, 1 + offset),
          durationWeeks: 12,
        );
        final end = program.endDate!;

        expect(
          end.weekday,
          DateTime.sunday,
          reason: 'start ${program.startDate}',
        );
        expect(
          end,
          addCalendarDays(program.weekStart(12), 6),
          reason: 'start ${program.startDate}',
        );
        expect(program.isActiveOn(end), isTrue);
        expect(program.isActiveOn(addCalendarDays(end, 1)), isFalse);
      }
    });
  });
}
