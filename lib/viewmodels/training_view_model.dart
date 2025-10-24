import 'dart:async';

import 'package:crimpy/models/ble_data_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/repositories/builtin_training_repository.dart';

/// Returns the trainings repository.
final trainingRepositoryProvider = Provider<TrainingRepository>((ref) {
  final repository = TrainingRepository();
  return repository;
});

/// Returns the builtin trainings repository.
final builtinTrainingRepositoryProvider = Provider<BuiltinTrainingRepository>((
  ref,
) {
  return BuiltinTrainingRepository();
});

/// Returns favorite trainings.
final favTrainingsProvider =
    AsyncNotifierProvider<FavTrainingsNotifier, List<TrainingWithReps>>(
      FavTrainingsNotifier.new,
    );

class FavTrainingsNotifier extends AsyncNotifier<List<TrainingWithReps>> {
  late TrainingRepository _trainingRepository;

  @override
  FutureOr<List<TrainingWithReps>> build() {
    _trainingRepository = ref.watch(trainingRepositoryProvider);
    return _trainingRepository.getAllTrainings(onlyFavs: true);
  }

  /// Toggle the favorite status for a given training.
  Future<void> toggleFav(int trainingId) async {
    await _trainingRepository.toggleFav(trainingId);
    ref.invalidate(trainingsProvider);
    ref.invalidateSelf();
  }
}

/// Returns all trainings (except for assessments), and allow to edit, create and delete them.
final trainingsProvider =
    AsyncNotifierProvider<TrainingsNotifier, List<TrainingWithReps>>(
      TrainingsNotifier.new,
    );

class TrainingsNotifier extends AsyncNotifier<List<TrainingWithReps>> {
  late TrainingRepository _trainingRepository;

  @override
  Future<List<TrainingWithReps>> build() {
    _trainingRepository = ref.watch(trainingRepositoryProvider);
    return _trainingRepository.getAllTrainings();
  }

  /// Edit a training's name and/or reps.
  Future<void> editTraining(
    int trainingId, {
    String? newName,
    List<RepModel>? newReps,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _trainingRepository.editTraining(
        trainingId,
        name: newName,
        reps: newReps,
      );
      ref.invalidate(favTrainingsProvider);
      ref.invalidate(allTrainingsProvider);
      ref.invalidateSelf();
      await future;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Edit a repeater training's name and/or model.
  Future<void> editRepeaterTraining(
    int trainingId, {
    String? newName,
    RepeaterModel? model,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _trainingRepository.editRepeaterTraining(
        trainingId,
        name: newName,
        model: model,
      );
      ref.invalidate(favTrainingsProvider);
      ref.invalidate(allTrainingsProvider);
      ref.invalidateSelf();
      await future;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Save a new training into the DB given a name and a set of reps.
  Future<void> saveTraining(String name, List<RepModel> reps) async {
    state = const AsyncValue.loading();
    try {
      await _trainingRepository.saveTraining(name, reps);
      ref.invalidate(allTrainingsProvider);
      ref.invalidateSelf();
      await future;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Save a new repeater training given a name and a repeater model.
  Future<void> saveRepeaterTraining(String name, RepeaterModel model) async {
    state = const AsyncValue.loading();
    try {
      await _trainingRepository.saveRepeaterTraining(name, model);
      ref.invalidate(allTrainingsProvider);
      ref.invalidateSelf();
      await future;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Delete a training.
  Future<void> deleteTraining(int trainingId) async {
    state = const AsyncValue.loading();
    try {
      await _trainingRepository.deleteTraining(trainingId);
      ref.invalidate(favTrainingsProvider);
      ref.invalidateSelf();
      await future;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

/// Represents the filters available for the `sessionsProvider` family.
class SessionFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isAssessment;

  const SessionFilter({this.startDate, this.endDate, this.isAssessment});

  @override
  bool operator ==(Object other) {
    return other is SessionFilter &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.isAssessment == isAssessment;
  }

  @override
  int get hashCode => Object.hash(startDate, endDate, isAssessment);
}

/// Returns the list of sessions, and allows the creation of new sessions.
final sessionsProvider = AsyncNotifierProvider.family<
  SessionsNotifier,
  List<SessionModel>,
  SessionFilter?
>(SessionsNotifier.new);

class SessionsNotifier
    extends FamilyAsyncNotifier<List<SessionModel>, SessionFilter?> {
  late TrainingRepository _trainingRepository;

  @override
  Future<List<SessionModel>> build(SessionFilter? filters) {
    _trainingRepository = ref.watch(trainingRepositoryProvider);
    return _trainingRepository.getAllSessionsWithReps(filters: filters);
  }

  /// Save a session and its repetitions data.
  Future<int> saveSession(
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
  }) async {
    state = const AsyncValue.loading();
    try {
      final id = await _trainingRepository.saveSession(
        session,
        reps,
        data: data,
      );
      ref.invalidate(sessionsProvider);
      await future;
      return id;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return -1;
    }
  }

  /// Get a session by its ID.
  Future<SessionModel?> getSession(int id) async {
    return _trainingRepository.getSessionWithData(id);
  }
}

/// Provider for getting a single session with full data by ID.
final sessionWithDataProvider = FutureProvider.family<SessionModel?, int>((
  ref,
  sessionId,
) {
  final trainingRepository = ref.watch(trainingRepositoryProvider);
  return trainingRepository.getSessionWithData(sessionId);
});

/// Provider for combined training list (regular + builtin trainings).
final allTrainingsProvider =
    AsyncNotifierProvider<AllTrainingsNotifier, List<TrainingListItem>>(
      AllTrainingsNotifier.new,
    );

class AllTrainingsNotifier extends AsyncNotifier<List<TrainingListItem>> {
  late TrainingRepository _trainingRepository;
  late BuiltinTrainingRepository _builtinTrainingRepository;

  @override
  Future<List<TrainingListItem>> build() async {
    _trainingRepository = ref.watch(trainingRepositoryProvider);
    _builtinTrainingRepository = ref.watch(builtinTrainingRepositoryProvider);

    // Get regular trainings
    final regularTrainings = await _trainingRepository.getAllTrainings();
    final regularItems =
        regularTrainings.map(TrainingListItem.regular).toList();

    // Get builtin trainings
    final builtinTrainings =
        await _builtinTrainingRepository.getBuiltinTrainings();
    final builtinItems = <TrainingListItem>[];

    for (final builtin in builtinTrainings) {
      final isAvailable = await _builtinTrainingRepository.isTrainingAvailable(
        builtin,
      );
      final missingAssessments = await _builtinTrainingRepository
          .getMissingAssessments(builtin);
      final generatedTraining =
          isAvailable
              ? await _builtinTrainingRepository.generateTraining(builtin)
              : null;

      builtinItems.add(
        TrainingListItem.builtin(
          builtin,
          isAvailable,
          missingAssessments,
          generatedTraining,
        ),
      );
    }

    // Combine regular and builtin trainings
    return [...regularItems, ...builtinItems];
  }

  /// Refresh builtin trainings availability (call after new assessments).
  Future<void> refreshBuiltinAvailability() async {
    ref.invalidateSelf();
    await future;
  }
}
