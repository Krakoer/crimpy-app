import 'dart:async';

import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/repositories/builtin_preferences_repository.dart';
import 'package:crimpy/repositories/remote_assessment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/repositories/assessment_repository.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/repositories/builtin_training_repository.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';

/// Returns the trainings repository (local Drift in guest mode, remote API when authenticated).
final trainingRepositoryProvider = Provider<TrainingRepository>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user != null) {
    return RemoteTrainingRepository(ref.read(apiClientProvider));
  }
  return LocalTrainingRepository();
});

/// Returns the assessment repository (local Drift in guest mode, remote API when authenticated).
final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user != null) {
    return RemoteAssessmentRepository(ref.read(apiClientProvider));
  }
  return LocalAssessmentRepository();
});

/// Returns the builtin preferences repository (local in guest mode, remote when authenticated).
final builtinPreferencesRepositoryProvider =
    Provider<BuiltinPreferencesRepository>((ref) {
      final user = ref.watch(authStateProvider).asData?.value;
      if (user != null) {
        return RemoteBuiltinPreferencesRepository(ref.read(apiClientProvider));
      }
      return LocalBuiltinPreferencesRepository();
    });

/// Returns the builtin trainings repository, injecting the appropriate dependencies.
final builtinTrainingRepositoryProvider = Provider<BuiltinTrainingRepository>((
  ref,
) {
  final assessmentRepo = ref.watch(assessmentRepositoryProvider);
  final preferencesRepo = ref.watch(builtinPreferencesRepositoryProvider);
  return BuiltinTrainingRepository(
    assessmentRepository: assessmentRepo,
    preferencesRepository: preferencesRepo,
  );
});

/// Returns favorite trainings.
final favTrainingsProvider =
    AsyncNotifierProvider<FavTrainingsNotifier, List<Training>>(
      FavTrainingsNotifier.new,
    );

class FavTrainingsNotifier extends AsyncNotifier<List<Training>> {
  late TrainingRepository _trainingRepository;

  @override
  FutureOr<List<Training>> build() {
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

/// Returns all trainings and allows creating, updating, and deleting them.
final trainingsProvider =
    AsyncNotifierProvider<TrainingsNotifier, List<Training>>(
      TrainingsNotifier.new,
    );

class TrainingsNotifier extends AsyncNotifier<List<Training>> {
  late TrainingRepository _trainingRepository;

  @override
  Future<List<Training>> build() {
    _trainingRepository = ref.watch(trainingRepositoryProvider);
    return _trainingRepository.getAllTrainings();
  }

  /// Runs a repository mutation and reloads the list. `invalidateSelf` re-emits
  /// the previous value as loading, so the list keeps its content on screen
  /// instead of flashing empty for the duration of the write.
  Future<void> _mutate(Future<void> Function() mutation) async {
    try {
      await mutation();
      ref.invalidateSelf();
      if (ref.mounted) await future;
    } catch (e, stackTrace) {
      if (ref.mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  /// Save a new training.
  Future<void> saveTraining(Training training) => _mutate(() async {
    await _trainingRepository.saveTraining(training);
    ref.invalidate(favTrainingsProvider);
    ref.invalidate(allTrainingsProvider);
  });

  /// Update an existing training.
  Future<void> updateTraining(Training training) => _mutate(() async {
    await _trainingRepository.updateTraining(training);
    ref.invalidate(favTrainingsProvider);
    ref.invalidate(allTrainingsProvider);
  });

  /// Delete a training.
  Future<void> deleteTraining(String trainingId) => _mutate(() async {
    await _trainingRepository.deleteTraining(trainingId);
    ref.invalidate(favTrainingsProvider);
  });
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
    try {
      await _trainingRepository.deleteSession(sessionId);
      ref.invalidateSelf();
      if (ref.mounted) await future;
    } catch (e, stackTrace) {
      if (ref.mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
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

    final favoriteTrainings = await _trainingRepository.getAllTrainings(
      onlyFavs: true,
    );
    final favoriteItems = favoriteTrainings
        .map(TrainingListItem.regular)
        .toList();

    final allBuiltins = await _builtinTrainingRepository.getBuiltinTrainings();
    final pinnedIds = await _builtinTrainingRepository
        .getPinnedBuiltinTrainingIds();
    final pinnedBuiltins = allBuiltins
        .where((b) => pinnedIds.contains(b.id))
        .toList();

    if (pinnedBuiltins.isEmpty) return favoriteItems;

    final allAssessments = await _builtinTrainingRepository
        .fetchAllAssessments();
    final allWeights = await _builtinTrainingRepository.fetchAllCustomWeights();

    final pinnedBuiltinItems = pinnedBuiltins.map((builtin) {
      final w = allWeights[builtin.id];
      final result = _builtinTrainingRepository.evaluateBuiltinSync(
        builtin,
        allAssessments,
        customWeightRight: w?.weightRight,
        customWeightLeft: w?.weightLeft,
      );
      return TrainingListItem.builtin(
        builtin,
        result.isAvailable,
        result.missing,
        result.training,
        true,
      );
    }).toList();

    return [...favoriteItems, ...pinnedBuiltinItems];
  }

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

    final regularTrainings = await _trainingRepository.getAllTrainings();
    final regularItems = regularTrainings
        .map(TrainingListItem.regular)
        .toList();

    final builtinTrainings = await _builtinTrainingRepository
        .getBuiltinTrainings();

    if (builtinTrainings.isEmpty) return regularItems;

    // Fetch all shared data once to avoid N+1 API calls.
    final allAssessments = await _builtinTrainingRepository
        .fetchAllAssessments();
    final allWeights = await _builtinTrainingRepository.fetchAllCustomWeights();
    final pinnedIds = await _builtinTrainingRepository
        .getPinnedBuiltinTrainingIds();

    final builtinItems = builtinTrainings.map((builtin) {
      final w = allWeights[builtin.id];
      final result = _builtinTrainingRepository.evaluateBuiltinSync(
        builtin,
        allAssessments,
        customWeightRight: w?.weightRight,
        customWeightLeft: w?.weightLeft,
      );
      return TrainingListItem.builtin(
        builtin,
        result.isAvailable,
        result.missing,
        result.training,
        pinnedIds.contains(builtin.id),
      );
    }).toList();

    return [...regularItems, ...builtinItems];
  }

  Future<void> refreshBuiltinAvailability() async {
    ref.invalidateSelf();
    await future;
  }
}
