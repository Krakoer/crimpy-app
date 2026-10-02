// ignore_for_file: avoid_public_notifier_properties
import 'package:crimpy/models/auth_models.dart' as auth_models;
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_habit.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:crimpy/viewmodels/habit_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthState extends AuthState {
  _FakeAuthState(this.user);
  final auth_models.User? user;

  @override
  Future<auth_models.User?> build() async => user;
}

class _FixedTrainings extends Trainings {
  _FixedTrainings(this.trainings);
  final List<Training> trainings;

  @override
  Future<List<Training>> build() async => trainings;
}

/// Holds a library and deletes from it, or fails to when [failing].
class _LibraryRepository implements TrainingRepository {
  _LibraryRepository(this.ids);
  List<String> ids;
  bool failing = false;

  @override
  Future<TrainingLibrary> getAllTrainings() async => (
    trainings: [for (final id in ids) Training(id: id, title: 'Training $id')],
    truncated: false,
  );

  @override
  Future<void> deleteTraining(String trainingId) async {
    if (failing) throw Exception('offline');
    ids = [...ids]..remove(trainingId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _user = auth_models.User(
  id: 'athlete',
  email: 'athlete@crimpy.app',
  firstname: 'Ada',
  lastname: 'Climber',
  emailVerified: true,
  createdAt: '2026-01-01T00:00:00Z',
);

TrainingHabit _habitOf(String trainingId) => TrainingHabit.onWeekdays(
  trainingId: trainingId,
  weekdays: const {0},
  since: DateTime(2026, 9, 28),
);

ProviderContainer _container({
  auth_models.User? user,
  List<Training> trainings = const [],
}) => ProviderContainer.test(
  overrides: [
    authStateProvider.overrideWith(() => _FakeAuthState(user)),
    trainingsProvider.overrideWith(() => _FixedTrainings(trainings)),
  ],
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('several trainings can each be a habit, one habit each', () async {
    final container = _container(user: _user);
    final habits = container.read(trainingHabitsProvider.notifier);
    await container.read(trainingHabitsProvider.future);

    await habits.setHabit(_habitOf('a'));
    await habits.setHabit(_habitOf('b'));
    await habits.setHabit(
      TrainingHabit.perWeek(
        trainingId: 'a',
        timesPerWeek: 3,
        since: DateTime(2026, 9, 30),
      ),
    );

    final stored = container.read(trainingHabitsProvider).value!;
    expect(stored.map((h) => h.trainingId), ['b', 'a']);
    expect(stored.last.timesPerWeek, 3);

    await habits.removeHabit('b');
    expect(
      container.read(trainingHabitsProvider).value!.map((h) => h.trainingId),
      ['a'],
    );
  });

  test('keeps the habits of the account they were set on', () async {
    final signedIn = _container(user: _user);
    await signedIn.read(trainingHabitsProvider.future);
    await signedIn
        .read(trainingHabitsProvider.notifier)
        .setHabit(_habitOf('a'));

    final guest = _container();
    expect(await guest.read(trainingHabitsProvider.future), isEmpty);
    final again = _container(user: _user);
    expect(await again.read(trainingHabitsProvider.future), [_habitOf('a')]);
  });

  test('drops a habit whose training is no longer in the library', () async {
    final container = _container(
      user: _user,
      trainings: const [Training(id: 'a', title: 'Hangs, renamed')],
    );
    await container.read(trainingHabitsProvider.future);
    final habits = container.read(trainingHabitsProvider.notifier);
    await habits.setHabit(_habitOf('a'));
    await habits.setHabit(_habitOf('deleted'));

    final active = await container.read(activeHabitsProvider.future);
    expect(active.map((h) => h.trainingId), ['a']);
    // Named as the library names it now.
    expect(active.single.title, 'Hangs, renamed');
  });

  group('deleting a training', () {
    Future<ProviderContainer> library(_LibraryRepository repository) async {
      final container = ProviderContainer.test(
        overrides: [
          authStateProvider.overrideWith(() => _FakeAuthState(_user)),
          trainingRepositoryProvider.overrideWithValue(repository),
        ],
      );
      await container.read(trainingsProvider.future);
      await container.read(trainingHabitsProvider.future);
      final habits = container.read(trainingHabitsProvider.notifier);
      await habits.setHabit(_habitOf('a'));
      await habits.setHabit(_habitOf('b'));
      return container;
    }

    test('drops the habit it was', () async {
      final container = await library(_LibraryRepository(['a', 'b']));

      await container.read(trainingsProvider.notifier).deleteTraining('a');

      expect(
        container.read(trainingHabitsProvider).value!.map((h) => h.trainingId),
        ['b'],
      );
    });

    test('keeps the habit when the delete fails', () async {
      final repository = _LibraryRepository(['a', 'b'])..failing = true;
      final container = await library(repository);

      await container.read(trainingsProvider.notifier).deleteTraining('a');

      expect(container.read(trainingsProvider).hasError, isTrue);
      expect(
        container.read(trainingHabitsProvider).value!.map((h) => h.trainingId),
        ['a', 'b'],
      );
    });
  });
}
