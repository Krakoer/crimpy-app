import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/session_filter.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves a history that can be changed under it, and counts how often the
/// whole of it was downloaded with its reps.
class _FakeRepository extends TrainingRepository {
  _FakeRepository(this.sessions);

  List<SessionModel> sessions;
  bool listFails = false;
  int historyReads = 0;

  @override
  Future<List<SessionModel>> getAllSessionsWithReps({
    SessionFilter? filters,
  }) async {
    if (listFails) throw Exception('offline');
    return sessions;
  }

  @override
  Future<List<SessionModel>> getSessionHistoryWithReps() async {
    historyReads++;
    return sessions;
  }

  @override
  Future<void> markCoachReplyRead(String sessionId) async {}

  @override
  Future<void> deleteSession(String sessionId) async {
    sessions = [
      for (final s in sessions)
        if (s.id != sessionId) s,
    ];
  }

  @override
  Future<TrainingLibrary> getAllTrainings() => throw UnimplementedError();

  @override
  Future<Training?> getTraining(String trainingId) =>
      throw UnimplementedError();

  @override
  Future<Training> saveTraining(Training training) =>
      throw UnimplementedError();

  @override
  Future<Training> updateTraining(Training training) =>
      throw UnimplementedError();

  @override
  Future<void> toggleFav(String trainingId) => throw UnimplementedError();

  @override
  Future<void> deleteTraining(String trainingId) => throw UnimplementedError();

  @override
  Future<SessionModel?> getSessionWithData(String sessionId) =>
      throw UnimplementedError();

  @override
  Future<String> saveSession(
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
    List<SessionItemResultModel> itemResults = const [],
  }) => throw UnimplementedError();

  @override
  Future<void> updateSession(SessionModel session) =>
      throw UnimplementedError();
}

SessionModel _session(String id) => SessionModel(
  id: id,
  name: 'Repeaters',
  isAssessment: false,
  origin: SessionOrigin.played,
  date: DateTime(2026, 9, 20),
  reps: const [],
  coachReply: 'Nice',
);

void main() {
  late _FakeRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeRepository([_session('s-1'), _session('s-2')]);
    container = ProviderContainer.test(
      overrides: [trainingRepositoryProvider.overrideWithValue(repository)],
    );
    container.listen(sessionHistoryWithRepsProvider, (_, _) {});
  });

  test('reads the history again once a session is deleted', () async {
    await container.read(sessionsProvider.future);
    await container.read(sessionHistoryWithRepsProvider.future);
    expect(repository.historyReads, 1);

    await container.read(sessionsProvider.notifier).deleteSession('s-1');
    final history = await container.read(sessionHistoryWithRepsProvider.future);

    expect(repository.historyReads, 2);
    expect(history.map((s) => s.id), ['s-2']);
  });

  // A reply marked read and the list fetched again on resume change nothing
  // the totals count, and every rep of the history is the heaviest request the
  // app makes.
  test('leaves the history alone on a change the totals do not see', () async {
    await container.read(sessionsProvider.future);
    await container.read(sessionHistoryWithRepsProvider.future);

    await container.read(sessionsProvider.notifier).markCoachReplyRead('s-1');
    container.invalidate(sessionsProvider);
    await container.read(sessionsProvider.future);
    await container.read(sessionHistoryWithRepsProvider.future);

    expect(repository.historyReads, 1);
  });

  // The profile's pull refreshes the history alone, so a list that failed to
  // load must not hold the totals in its error.
  test('reads the history although the session list failed', () async {
    repository = _FakeRepository([_session('s-1'), _session('s-2')])
      ..listFails = true;
    container = ProviderContainer.test(
      overrides: [trainingRepositoryProvider.overrideWithValue(repository)],
    );
    container.listen(sessionHistoryWithRepsProvider, (_, _) {});
    // Riverpod keeps retrying the failed list, so it never answers here.
    container.listen(sessionsProvider, (_, _) {});

    final history = await container.read(sessionHistoryWithRepsProvider.future);

    expect(history, hasLength(2));
  });
}
