import 'dart:async';

import 'package:crimpy/logger.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/builtin_training.dart';
import 'package:crimpy/models/session_filter.dart';
import 'package:crimpy/repositories/builtin_preferences_repository.dart';
import 'package:crimpy/repositories/remote_assessment_repository.dart';
import 'package:crimpy/viewmodels/habit_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/models/training_list_item.dart';
import 'package:crimpy/repositories/assessment_repository.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:crimpy/repositories/builtin_training_repository.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:crimpy/utils/training_intensity.dart';
import 'package:crimpy/utils/training_totals.dart';

part 'training_view_model.g.dart';

/// Returns the trainings repository (local Drift in guest mode, remote API when authenticated).
@Riverpod(keepAlive: true)
TrainingRepository trainingRepository(Ref ref) {
  if (ref.watch(isAuthenticatedProvider)) {
    return RemoteTrainingRepository(
      ref.watch(apiClientProvider),
      bodyweight: ref.watch(bodyweightRepositoryProvider),
    );
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
  final preferencesRepo = ref.watch(builtinPreferencesRepositoryProvider);
  return BuiltinTrainingRepository(preferencesRepository: preferencesRepo);
}

/// The athlete's training library, read once and shared by everything that
/// lists trainings.
///
/// The library comes back in a single request carrying every training in full,
/// so the favourites are a filter over what is already in hand rather than a
/// narrower read. Four providers used to call the repository themselves and
/// each one put the byte identical request on the wire: a home screen pull sent
/// two at the same time. They all derive from this now, and the fetch happens
/// once.
///
/// This is the provider to invalidate to fetch the library again. Invalidating
/// one of the lists below rebuilds it from the library already held and never
/// reaches the server, which is what makes a pinned or builtin change free.
@Riverpod(keepAlive: true)
Future<TrainingLibrary> trainingLibrary(Ref ref) =>
    ref.watch(trainingRepositoryProvider).getAllTrainings();

/// Whether the library on screen is the start of the athlete's library rather
/// than all of it.
///
/// Its own provider so a banner can watch the one fact it needs without
/// rebuilding on every change to the trainings themselves, and so the screens
/// that show the library do not each have to unpack the record.
@Riverpod(keepAlive: true)
Future<bool> trainingLibraryTruncated(Ref ref) async =>
    (await ref.watch(trainingLibraryProvider.future)).truncated;

typedef BuiltinTrainingCatalog = ({
  List<BuiltinTrainingModel> trainings,
  List<String> pinnedIds,
  List<AssessmentModel> assessments,
  Map<String, ({double? weightRight, double? weightLeft})> customWeights,
});

/// Everything the builtin half of a training list is built from, read once and
/// shared the way the library is.
///
/// The pinned list and the full list show the same builtins against the same
/// pins, assessments and custom weights. Reading those per list put the same
/// three requests on the wire twice, which is the library duplication one layer
/// down. None of it belongs to the library, so a pin change drops this and
/// leaves the library alone, and a pull drops both.
///
/// The reads are independent and go out together, so the catalog costs one
/// round trip rather than three. It reads the assessments and the weights even
/// when the athlete has pinned nothing, where the pinned list alone used to
/// stop at the pins: making them conditional would mean a list that watches
/// them only sometimes, which is the staleness the shared provider exists to
/// remove. It is two small requests on a cold start, against a list that
/// evaluates a builtin the moment one is pinned.
@Riverpod(keepAlive: true)
Future<BuiltinTrainingCatalog> builtinTrainingCatalog(Ref ref) async {
  final builtins = ref.watch(builtinTrainingRepositoryProvider);
  final trainings = builtins.getBuiltinTrainings();
  final pinnedIds = builtins.getPinnedBuiltinTrainingIds();
  // Off the shared history rather than a read of its own. The endpoint behind
  // it takes no parameters and always answers everything, so the catalog asking
  // the repository directly put the same request on the wire as the dashboard,
  // at the same time, on every cold load and every pull.
  final assessments = ref.watch(assessmentHistoryProvider.future);
  final customWeights = builtins.fetchAllCustomWeights();

  // Waited on together rather than awaited one after another. Awaiting them in
  // order means the first failure leaves the reads behind it running with
  // nobody listening, and an offline device answers each of those with an error
  // that reaches the zone as a crash instead of the one error the screen shows.
  // Future.wait listens to all four and rethrows the first, which keeps the
  // ApiException the offline handling reads.
  await Future.wait([trainings, pinnedIds, assessments, customWeights]);

  return (
    trainings: await trainings,
    pinnedIds: await pinnedIds,
    assessments: await assessments,
    customWeights: await customWeights,
  );
}

/// Returns favorite trainings.
@Riverpod(keepAlive: true)
class FavTrainings extends _$FavTrainings {
  @override
  Future<List<Training>> build() async {
    final library = await ref.watch(trainingLibraryProvider.future);
    return library.trainings.where((training) => training.isFavorite).toList();
  }

  /// Toggle the favorite status for a given training.
  ///
  /// The flag lives on the training, so the library is what went out of date:
  /// invalidating it refreshes this list and every other view of the library
  /// with one read.
  Future<void> toggleFav(String trainingId) async {
    await ref.read(trainingRepositoryProvider).toggleFav(trainingId);
    ref.invalidate(trainingLibraryProvider);
  }
}

/// Returns all trainings and allows creating, updating, and deleting them.
@Riverpod(keepAlive: true)
class Trainings extends _$Trainings {
  late TrainingRepository _trainingRepository;

  @override
  Future<List<Training>> build() async {
    _trainingRepository = ref.watch(trainingRepositoryProvider);
    final library = await ref.watch(trainingLibraryProvider.future);
    return library.trainings;
  }

  /// Runs a repository mutation and reloads the library. Invalidating it
  /// re-emits the previous value as loading here, so the list keeps its content
  /// on screen instead of flashing empty for the duration of the write, and the
  /// favourites and the home screen lists pick the write up from the same read.
  Future<void> _mutate(Future<void> Function() mutation) async {
    try {
      await mutation();
      ref.invalidate(trainingLibraryProvider);
      if (ref.mounted) await future;
    } catch (e, stackTrace) {
      if (ref.mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  /// Save a new training.
  Future<void> saveTraining(Training training) =>
      _mutate(() => _trainingRepository.saveTraining(training));

  /// Update an existing training.
  Future<void> updateTraining(Training training) =>
      _mutate(() => _trainingRepository.updateTraining(training));

  /// Delete a training, and the habit it was, if any.
  Future<void> deleteTraining(String trainingId) async {
    await _mutate(() => _trainingRepository.deleteTraining(trainingId));
    // A delete that failed leaves the training, and its habit with it.
    if (!ref.mounted || state.hasError) return;
    // After the delete and apart from it: the habit is device-local, and a
    // failure to drop it must not read as the delete failing. One left behind
    // is harmless, since the habits are joined against the library before use.
    try {
      await ref.read(trainingHabitsProvider.notifier).removeHabit(trainingId);
    } catch (error) {
      AppLoggerHelper.warning(
        'Could not drop the habit of $trainingId: $error',
      );
    }
  }
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

/// Every session the athlete has, each carrying all of its reps: the whole
/// history, for the readers that add it up rather than list it.
///
/// Read on its own rather than after the session list, so a list that failed
/// to load does not fail this with it, and a pull on the profile asks again for
/// real. Read again whenever the list answers with a history other than the one
/// read here, told apart by its sessions, their dates and their rep counts, so
/// a run saved, edited or deleted anywhere reaches the totals without each of
/// those paths having to know they exist. The list is compared with what was
/// read rather than with its own previous answer, so a change made while it had
/// no answer is still caught by its first one. A change that leaves the history
/// alone, a coach reply marked read or the list fetched again on resume, does
/// not download every rep again: it is the heaviest request the app makes.
///
/// Auto-disposed, although the profile that reads it is kept alive in the main
/// pager, so in practice it lives from the first visit to the profile on.
@riverpod
Future<List<SessionModel>> sessionHistoryWithReps(Ref ref) async {
  final repository = ref.watch(trainingRepositoryProvider);
  String? readKey;
  ref.listen(sessionsProvider, (_, next) {
    final listedKey = _historyKey(next.value);
    if (readKey != null && listedKey != null && listedKey != readKey) {
      ref.invalidateSelf();
    }
  });
  final history = await repository.getSessionHistoryWithReps();
  readKey = _historyKey(history);
  return history;
}

/// What the session list says about the history the totals are made of, null
/// while it has no answer.
String? _historyKey(List<SessionModel>? sessions) => sessions
    ?.map((s) => '${s.id}@${s.date.microsecondsSinceEpoch}#${s.repCount}')
    .join(',');

/// The all-time totals of the profile, Krakoer/crimpy#150.
@riverpod
Future<TrainingTotals> trainingTotals(Ref ref) async =>
    TrainingTotals.of(await ref.watch(sessionHistoryWithRepsProvider.future));

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
///
/// Takes the library and the catalog rather than the repositories: both lists
/// are built from the same two reads, and the pinned one narrows them here
/// instead of asking the server for narrower answers it does not have.
List<TrainingListItem> _buildTrainingList({
  required List<Training> library,
  required BuiltinTrainingCatalog catalog,
  required bool onlyPinned,
  required TrainingIntensityRater rater,
}) {
  TrainingIntensity? intensityOf(Training? training) =>
      training == null ? null : rater.rate(training);

  final regular = onlyPinned
      ? library.where((training) => training.isFavorite).toList()
      : library;
  final regularItems = regular
      .map(
        (training) => TrainingListItem.regular(
          training,
          intensity: intensityOf(training),
          results: rater.resultsFor(training),
        ),
      )
      .toList();

  final selected = onlyPinned
      ? catalog.trainings
            .where((builtin) => catalog.pinnedIds.contains(builtin.id))
            .toList()
      : catalog.trainings;

  final builtinItems = selected.map((builtin) {
    final weights = catalog.customWeights[builtin.id];
    final result = BuiltinTrainingRepository.evaluateBuiltinSync(
      builtin,
      catalog.assessments,
      customWeightRight: weights?.weightRight,
      customWeightLeft: weights?.weightLeft,
    );
    return TrainingListItem.builtin(
      builtin,
      result.isAvailable,
      result.missing,
      result.training,
      catalog.pinnedIds.contains(builtin.id),
      intensity: intensityOf(result.training),
      results: result.training == null
          ? AssessmentResults.none
          : rater.resultsFor(result.training!),
    );
  }).toList();

  return [...regularItems, ...builtinItems];
}

/// The bodyweight a %BW hang is rated against, or none when it is not known or
/// cannot be read: an intensity it cannot resolve is left off the card, which
/// is no reason to fail the list.
Future<double?> _bodyweightOrNone(Ref ref) => ref
    .watch(bodyweightProvider.future)
    .then<double?>((kilograms) => kilograms, onError: (_) => null);

/// What every card rates a training's intensity against: the athlete's max
/// force per grip, their other results and their bodyweight. See
/// Krakoer/crimpy#166.
@Riverpod(keepAlive: true)
Future<TrainingIntensityRater> trainingIntensityRater(Ref ref) async {
  final history = ref.watch(assessmentHistoryProvider.future);
  final bodyweightKg = _bodyweightOrNone(ref);
  return TrainingIntensityRater.fromHistory(
    await history,
    bodyweightKg: await bodyweightKg,
  );
}

/// Provider for pinned builtin trainings (with favorites).
@Riverpod(keepAlive: true)
class PinnedTrainings extends _$PinnedTrainings {
  @override
  Future<List<TrainingListItem>> build() async {
    final library = ref.watch(trainingLibraryProvider.future);
    final catalog = ref.watch(builtinTrainingCatalogProvider.future);
    final rater = ref.watch(trainingIntensityRaterProvider.future);
    return _buildTrainingList(
      library: (await library).trainings,
      catalog: await catalog,
      onlyPinned: true,
      rater: await rater,
    );
  }

  /// Pins or unpins a builtin training.
  ///
  /// A pin belongs to the builtin catalog and not to the library, so dropping
  /// the catalog refreshes both lists, which show the same heart against the
  /// same builtins, without asking for the library again.
  Future<void> togglePin(String builtinTrainingId) async {
    final builtins = ref.read(builtinTrainingRepositoryProvider);
    if (await builtins.isBuiltinTrainingPinned(builtinTrainingId)) {
      await builtins.unpinBuiltinTraining(builtinTrainingId);
    } else {
      await builtins.pinBuiltinTraining(builtinTrainingId);
    }
    ref.invalidate(builtinTrainingCatalogProvider);
  }
}

/// Every training the athlete can start: their own library followed by the
/// builtins, each evaluated against the latest assessments.
@Riverpod(keepAlive: true)
Future<List<TrainingListItem>> allTrainings(Ref ref) async {
  final library = ref.watch(trainingLibraryProvider.future);
  final catalog = ref.watch(builtinTrainingCatalogProvider.future);
  final rater = ref.watch(trainingIntensityRaterProvider.future);
  return _buildTrainingList(
    library: (await library).trainings,
    catalog: await catalog,
    onlyPinned: false,
    rater: await rater,
  );
}
