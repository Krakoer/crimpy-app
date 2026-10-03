import 'package:crimpy/models/training_habit.dart';
import 'package:crimpy/services/training_habit_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _onDays = TrainingHabit.onWeekdays(
  trainingId: 't1',
  weekdays: const {0, 2, 4},
  since: DateTime(2026, 9, 21),
);
final _perWeek = TrainingHabit.perWeek(
  trainingId: 't2',
  timesPerWeek: 3,
  since: DateTime(2026, 9, 28),
);

void main() {
  group('TrainingHabit', () {
    test('a weekday habit survives the round trip', () {
      expect(TrainingHabit.fromJson(_onDays.toJson()), _onDays);
    });

    test('a per week habit survives the round trip', () {
      expect(TrainingHabit.fromJson(_perWeek.toJson()), _perWeek);
    });

    test('is due on its weekdays only', () {
      expect(_onDays.isDueOn(DateTime(2026, 9, 28)), isTrue); // Monday
      expect(_onDays.isDueOn(DateTime(2026, 9, 29)), isFalse);
      // A habit counted per week is due on no day in particular.
      expect(_perWeek.isDueOn(DateTime(2026, 9, 28)), isFalse);
    });
  });

  group('TrainingHabitService', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('keeps one list per account, and one for the guest', () async {
      final service = TrainingHabitService();
      await service.save('user-a', [_onDays]);
      await service.save(null, [_perWeek]);

      expect(await service.load('user-a'), [_onDays]);
      expect(await service.load(null), [_perWeek]);
      expect(await service.load('user-b'), isEmpty);
    });

    test('reads an unreadable list as no habits', () async {
      SharedPreferences.setMockInitialValues({
        TrainingHabitService.keyFor('user-a'): 'not json',
      });
      expect(await TrainingHabitService().load('user-a'), isEmpty);
    });
  });
}
