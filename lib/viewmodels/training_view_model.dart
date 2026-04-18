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
  Future<void> toggleFav(String trainingId) async {
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
    String trainingId, {
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
    String trainingId, {
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
  Future<void> deleteTraining(String trainingId) async {
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

/// Represents the filters available for filtering sessions.
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

  bool matchesSession(SessionModel session) {
    if (isAssessment != null && session.isAssessment != isAssessment) {
      return false;
    }
    if (startDate != null && session.date.isBefore(startDate!)) {
      return false;
    }
    if (endDate != null && session.date.isAfter(endDate!)) {
      return false;
    }
    return true;
  }
}

/// Returns the list of all sessions, and allows the creation of new sessions.
final sessionsProvider =
    AsyncNotifierProvider<SessionsNotifier, List<SessionModel>>(
      SessionsNotifier.new,
    );

class SessionsNotifier extends AsyncNotifier<List<SessionModel>> {
  late TrainingRepository _trainingRepository;

  @override
  Future<List<SessionModel>> build() {
    _trainingRepository = ref.watch(trainingRepositoryProvider);
    return _trainingRepository.getAllSessionsWithReps(filters: null);
  }

  /// Save a session and its repetitions data.
  Future<String> saveSession(
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
      ref.invalidateSelf();
      if (ref.mounted) await future;
      return id;
    } catch (e, stackTrace) {
      if (ref.mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
      return "";
    }
  }

  /// Get a session by its ID.
  Future<SessionModel?> getSession(String id) async {
    return _trainingRepository.getSessionWithData(id);
  }

  /// Update an existing session.
  Future<void> updateSession(SessionModel session) async {
    state = const AsyncValue.loading();
    try {
      await _trainingRepository.updateSession(session);
      ref.invalidateSelf();
      if (ref.mounted) await future;
    } catch (e, stackTrace) {
      if (ref.mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
      rethrow;
    }
  }

  Future<void> deleteSession(String sessionId) async {
    state = const AsyncValue.loading();
    try {
      await _trainingRepository.deleteSession(sessionId);
      ref.invalidateSelf();
      await future;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

/// Provider for getting a single session with full data by ID.
final sessionWithDataProvider = FutureProvider.family<SessionModel?, String>((
  ref,
  sessionId,
) {
  final trainingRepository = ref.watch(trainingRepositoryProvider);
  return trainingRepository.getSessionWithData(sessionId);
});

/// Provider that returns filtered sessions based on a given filter.
/// This provider watches the base sessions provider and applies client-side filtering.
final filteredSessionsProvider =
    FutureProvider.family<List<SessionModel>, SessionFilter?>((
      ref,
      filter,
    ) async {
      final allSessions = await ref.watch(sessionsProvider.future);
      if (filter == null) {
        return allSessions;
      }
      return allSessions
          .where((session) => filter.matchesSession(session))
          .toList();
    });

/// Provider for pinned builtin trainings (with favorites).
final pinnedTrainingsProvider =
    AsyncNotifierProvider<PinnedTrainingsNotifier, List<TrainingListItem>>(
      PinnedTrainingsNotifier.new,
    );

class PinnedTrainingsNotifier extends AsyncNotifier<List<TrainingListItem>> {
  late TrainingRepository _trainingRepository;
  late BuiltinTrainingRepository _builtinTrainingRepository;

  @override
  Future<List<TrainingListItem>> build() async {
    _trainingRepository = ref.watch(trainingRepositoryProvider);
    _builtinTrainingRepository = ref.watch(builtinTrainingRepositoryProvider);

    // Get favorite regular trainings
    final favoriteTrainings = await _trainingRepository.getAllTrainings(
      onlyFavs: true,
    );
    final favoriteItems =
        favoriteTrainings.map(TrainingListItem.regular).toList();

    // Get pinned builtin training IDs
    final pinnedIds =
        await _builtinTrainingRepository.getPinnedBuiltinTrainingIds();

    // Get all builtin trainings
    final allBuiltins = await _builtinTrainingRepository.getBuiltinTrainings();

    // Filter to only pinned ones and generate them
    final pinnedBuiltinItems = <TrainingListItem>[];
    for (final builtin in allBuiltins) {
      if (pinnedIds.contains(builtin.id)) {
        final isAvailable = await _builtinTrainingRepository
            .isTrainingAvailable(builtin);
        final missingAssessments = await _builtinTrainingRepository
            .getMissingAssessments(builtin);
        final generatedTraining =
            isAvailable
                ? await _builtinTrainingRepository.generateTraining(builtin)
                : null;

        pinnedBuiltinItems.add(
          TrainingListItem.builtin(
            builtin,
            isAvailable,
            missingAssessments,
            generatedTraining,
            true, // isPinned is true since we filtered to only pinned items
          ),
        );
      }
    }

    // Combine favorite regular trainings and pinned builtin trainings
    return [...favoriteItems, ...pinnedBuiltinItems];
  }

  /// Toggle pin status for a builtin training.
  Future<void> togglePin(String builtinTrainingId) async {
    final isPinned = await _builtinTrainingRepository.isBuiltinTrainingPinned(
      builtinTrainingId,
    );

    if (isPinned) {
      await _builtinTrainingRepository.unpinBuiltinTraining(builtinTrainingId);
    } else {
      await _builtinTrainingRepository.pinBuiltinTraining(builtinTrainingId);
    }

    ref.invalidateSelf();
  }
}

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
      final isPinned = await _builtinTrainingRepository.isBuiltinTrainingPinned(
        builtin.id,
      );

      builtinItems.add(
        TrainingListItem.builtin(
          builtin,
          isAvailable,
          missingAssessments,
          generatedTraining,
          isPinned,
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
