import 'package:crimpy/models/training_habit.dart';
import 'package:crimpy/services/training_habit_service.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habit_view_model.g.dart';

@Riverpod(keepAlive: true)
TrainingHabitService trainingHabitService(Ref ref) => TrainingHabitService();

/// The habits stored for whoever uses the app now, and the actions that change
/// them. Several trainings can each be a habit, one habit per training.
@Riverpod(keepAlive: true)
class TrainingHabits extends _$TrainingHabits {
  late TrainingHabitService _service;
  String? _userId;

  @override
  Future<List<TrainingHabit>> build() async {
    _service = ref.watch(trainingHabitServiceProvider);
    // Awaited: on a cold start auth is still loading, and reading it then
    // would open the guest's habits for a signed in athlete.
    _userId = (await ref.watch(authStateProvider.future))?.id;
    return _service.load(_userId);
  }

  /// Sets [habit], replacing the one its training had.
  Future<void> setHabit(TrainingHabit habit) => _update(
    (current) => [
      for (final other in current)
        if (other.trainingId != habit.trainingId) other,
      habit,
    ],
  );

  /// Stops [trainingId] being a habit. Nothing happens when it was not one.
  Future<void> removeHabit(String trainingId) => _update(
    (current) => [
      for (final other in current)
        if (other.trainingId != trainingId) other,
    ],
  );

  Future<void> _update(
    List<TrainingHabit> Function(List<TrainingHabit>) change,
  ) async {
    final next = change(await future);
    await _service.save(_userId, next);
    state = AsyncData(next);
  }
}

/// The habits whose training is still in the library, with the training as it
/// is now. What everything else reads: a habit naming a training deleted on
/// another device would otherwise be reminded of and drawn as owed forever.
@Riverpod(keepAlive: true)
Future<List<ActiveHabit>> activeHabits(Ref ref) async {
  final habits = await ref.watch(trainingHabitsProvider.future);
  if (habits.isEmpty) return const [];
  final trainings = await ref.watch(trainingsProvider.future);
  final byId = {for (final training in trainings) training.id: training};
  return [
    for (final habit in habits)
      if (byId[habit.trainingId] case final training?)
        ActiveHabit(habit, training),
  ];
}
