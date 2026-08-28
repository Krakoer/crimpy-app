import 'dart:async';

import 'package:crimpy/logger.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/session_filter.dart';
import 'package:crimpy/repositories/builtin_preferences_repository.dart';
import 'package:crimpy/repositories/remote_assessment_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/models/training_list_item.dart';
import 'package:crimpy/repositories/assessment_repository.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/repositories/builtin_training_repository.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';

part 'training_view_model.g.dart';

/// Returns the trainings repository (local Drift in guest mode, remote API when authenticated).
@Riverpod(keepAlive: true)
TrainingRepository trainingRepository(Ref ref) {
  if (ref.watch(isAuthenticatedProvider)) {
    return RemoteTrainingRepository(ref.watch(apiClientProvider));
  }
  return LocalTrainingRepository();
}

/// Returns the assessment repository (local Drift in guest mode, remote API when authenticated).
@Riverpod(keepAlive: true)
AssessmentRepository assessmentRepository(Ref ref) {
  if (ref.watch(isAuthenticatedProvider)) {
    return RemoteAssessmentRepository(ref.watch(apiClientProvider));
  }
  return LocalAssessmentRepository();
}

/// Returns the builtin preferences repository (local in guest mode, remote when authenticated).
@Riverpod(keepAlive: true)
BuiltinPreferencesRepository builtinPreferencesRepository(Ref ref) {
  if (ref.watch(isAuthenticatedProvider)) {
    return RemoteBuiltinPreferencesRepository(ref.watch(apiClientProvider));
  }
  return LocalBuiltinPreferencesRepository();
}

/// Returns the builtin trainings repository, injecting the appropriate dependencies.
@Riverpod(keepAlive: true)
BuiltinTrainingRepository builtinTrainingRepository(Ref ref) {
  final assessmentRepo = ref.watch(assessmentRepositoryProvider);
  final preferencesRepo = ref.watch(builtinPreferencesRepositoryProvider);
  return BuiltinTrainingRepository(
    assessmentRepository: assessmentRepo,
    preferencesRepository: preferencesRepo,
  );
}

/// Returns favorite trainings.
@Riverpod(keepAlive: true)
class FavTrainings extends _$FavTrainings {
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
@Riverpod(keepAlive: true)
class Trainings extends _$Trainings {
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

/// Returns the list of all sessions, and allows the creation of new sessions.
@Riverpod(keepAlive: true)
class Sessions extends _$Sessions {
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
    List<SessionItemResultModel> itemResults = const [],
  }) async {
    try {
      final id = await _trainingRepository.saveSession(
        session,
        reps,
        data: data,
        itemResults: itemResults,
      );
      ref.invalidateSelf();
      if (ref.mounted) await future;
      return id;
    } catch (e, stackTrace) {
      if (ref.mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
      rethrow;
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

  /// Marks the coach's answer to a session as seen, and drops the badge in
  /// place rather than refetching the whole history for one flag.
  ///
  /// Sends the receipt whether or not the history is loaded: the screen that
  /// asks is reading the answer either way, and the server keeps the first
  /// read, so asking twice costs nothing.
  Future<void> markCoachReplyRead(String sessionId) async {
    try {
      await _trainingRepository.markCoachReplyRead(sessionId);
    } catch (error) {
      // A receipt that did not land is not worth an error state: the answer is
      // on the screen either way, and the badge simply stays until the next
      // time the session is opened. Offline, and an answer the coach took back
      // since the last fetch, both come through here.
      AppLoggerHelper.warning('Coach reply receipt failed: $error');
      return;
    }
    if (!ref.mounted) return;
    final current = state.value;
    if (current == null) return;
    state = AsyncData([
      for (final s in current) s.id == sessionId ? s.withCoachReplyRead() : s,
    ]);
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
/// Auto-disposed: a loaded session carries its whole BLE sample array, so one
/// cached entry per visited session would keep growing for the whole run.
@riverpod
Future<SessionModel?> sessionWithData(Ref ref, String sessionId) {
  final trainingRepository = ref.watch(trainingRepositoryProvider);
  return trainingRepository.getSessionWithData(sessionId);
}

/// The items a played session was run from, so its reps can be read block by
/// block. Empty when the session was not played from a training, or when the
/// training has been deleted since.
///
/// The live training is what names the blocks, not a snapshot: editing a
/// training relabels the blocks of the sessions already played from it, which
/// costs a heading rather than the grouping itself.
@riverpod
Future<List<TrainingItem>> sessionTrainingItems(
  Ref ref,
  String? trainingId,
) async {
  if (trainingId == null) return const [];
  final trainingRepository = ref.watch(trainingRepositoryProvider);
  // A training the athlete does not own - a coach's, prescribed through a
  // program - is not readable here. The session carries the prescription frozen
  // from it, which is what the card reads first, so this only ever has to
  // resolve a training the athlete owns.
  final training = await trainingRepository.getTraining(trainingId);
  return training?.items ?? const [];
}

/// Provider that returns filtered sessions based on a given filter.
/// Auto-disposed: the filtered list is derived from the cached sessions, so
/// recomputing it is cheap compared to holding one list per filter used.
@riverpod
Future<List<SessionModel>> filteredSessions(
  Ref ref,
  SessionFilter? filter,
) async {
  final allSessions = await ref.watch(sessionsProvider.future);
  if (filter == null) {
    return allSessions;
  }
  return allSessions
      .where((session) => filter.matchesSession(session))
      .toList();
}

/// Builds a training list: the user's own trainings followed by the builtin
/// ones, each evaluated against the latest assessments.
///
/// The pinned list and the full list differ only in how much they keep, so they
/// share this and cannot drift apart.
Future<List<TrainingListItem>> _buildTrainingList({
  required TrainingRepository trainings,
  required BuiltinTrainingRepository builtins,
  required bool onlyPinned,
}) async {
  final regular = await trainings.getAllTrainings(onlyFavs: onlyPinned);
  final regularItems = regular.map(TrainingListItem.regular).toList();

  final allBuiltins = await builtins.getBuiltinTrainings();
  final pinnedIds = await builtins.getPinnedBuiltinTrainingIds();
  final selected = onlyPinned
      ? allBuiltins.where((b) => pinnedIds.contains(b.id)).toList()
      : allBuiltins;

  if (selected.isEmpty) return regularItems;

  // Fetch all shared data once to avoid N+1 API calls.
  final allAssessments = await builtins.fetchAllAssessments();
  final allWeights = await builtins.fetchAllCustomWeights();

  final builtinItems = selected.map((builtin) {
    final w = allWeights[builtin.id];
    final result = builtins.evaluateBuiltinSync(
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

/// Provider for pinned builtin trainings (with favorites).
@Riverpod(keepAlive: true)
class PinnedTrainings extends _$PinnedTrainings {
  late BuiltinTrainingRepository _builtinTrainingRepository;

  @override
  Future<List<TrainingListItem>> build() {
    _builtinTrainingRepository = ref.watch(builtinTrainingRepositoryProvider);
    return _buildTrainingList(
      trainings: ref.watch(trainingRepositoryProvider),
      builtins: _builtinTrainingRepository,
      onlyPinned: true,
    );
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
@Riverpod(keepAlive: true)
class AllTrainings extends _$AllTrainings {
  @override
  Future<List<TrainingListItem>> build() => _buildTrainingList(
    trainings: ref.watch(trainingRepositoryProvider),
    builtins: ref.watch(builtinTrainingRepositoryProvider),
    onlyPinned: false,
  );

  Future<void> refreshBuiltinAvailability() async {
    ref.invalidateSelf();
    await future;
  }
}
