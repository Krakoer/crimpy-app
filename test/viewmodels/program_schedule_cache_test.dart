import 'package:clock/clock.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/viewmodels/notification_view_model.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 2026-06-01 is a Monday, so week 1 runs 2026-06-01 to 2026-06-07.
final _program = Program(
  id: 'p',
  coachId: 'c',
  userId: 'u',
  name: 'Block',
  startDate: DateTime(2026, 6, 1),
  durationWeeks: 6,
  createdAt: DateTime(2026, 6, 1),
  updatedAt: DateTime(2026, 6, 1),
);

Week _week(int number) =>
    Week(id: 'w$number', programId: 'p', weekNumber: number, sessions: []);

Future<List<int>> _cachedWeeksAt(DateTime now) => withClock(
  Clock.fixed(now),
  () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer.test(
      overrides: [
        activeProgramProvider.overrideWith((ref) async => _program),
        for (var number = 1; number <= 6; number++)
          weekDetailProvider(
            'p',
            number,
          ).overrideWith((ref) async => _week(number)),
      ],
    );
    final schedule = await container.read(programScheduleCacheProvider.future);
    return [for (final week in schedule!.weeks) week.weekNumber];
  },
);

void main() {
  test('starts at the week the training day is in', () async {
    expect(await _cachedWeeksAt(DateTime(2026, 6, 3, 18)), [1, 2, 3]);
  });

  // A reminder put off from Sunday 23:30 to 00:30 is asked of Sunday. Rebuilt
  // after midnight from the calendar week, the cache held no Sunday to ask,
  // and the reminder was dropped with the training still owed.
  test('still holds the closing week on a Monday before 04:00', () async {
    expect(await _cachedWeeksAt(DateTime(2026, 6, 8, 0, 10)), [1, 2, 3]);
    expect(await _cachedWeeksAt(DateTime(2026, 6, 8, 4)), [2, 3, 4]);
  });
}
