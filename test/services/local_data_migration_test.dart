import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/repositories/assessment_repository.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/services/local_data_migration.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// What a session create carried, so the import can be asserted on the links it
/// posted rather than on the local rows it read.
class _PostedSession {
  final SessionModel session;
  final List<RepDataModel> reps;
  final List<SessionItemResultModel> itemResults;

  _PostedSession(this.session, this.reps, this.itemResults);
}

/// Stands in for the API, minting its own ids the way the server does: nothing
/// the client sends is kept, which is the whole reason the import has to
/// rewrite the links it carries.
class _FakeRemoteTrainings implements TrainingRepository {
  final Set<String> refusedTitles;
  final Map<String, Training> stored = {};
  final List<_PostedSession> postedSessions = [];
  final List<String> calls = [];
  int _next = 0;

  _FakeRemoteTrainings({this.refusedTitles = const {}});

  String _mintId(String prefix) => '$prefix-${_next++}';

  List<TrainingItem> _mintItems(List<TrainingItem> items) => [
    for (final item in items)
      TrainingItem(
        id: _mintId('server-item'),
        type: item.type,
        position: item.position,
        items: _mintItems(item.items),
      ),
  ];

  @override
  Future<Training> saveTraining(Training training) async {
    calls.add('training');
    if (refusedTitles.contains(training.title)) {
      throw Exception('refused ${training.title}');
    }
    final id = _mintId('server-training');
    return stored[id] = Training(
      id: id,
      title: training.title,
      items: _mintItems(training.items),
    );
  }

  @override
  Future<String> saveSession(
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
    List<SessionItemResultModel> itemResults = const [],
  }) async {
    calls.add('session');
    postedSessions.add(_PostedSession(session, reps, itemResults));
    return _mintId('server-session');
  }

  // The import calls nothing else, so anything that reaches here is a test that
  // drifted rather than a path worth faking.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRemoteAssessments implements AssessmentRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeApiClient extends ApiClient {}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  LocalDataMigration migrationWith(_FakeRemoteTrainings remote) =>
      LocalDataMigration(
        apiClient: _FakeApiClient(),
        remoteTrainings: remote,
        remoteAssessments: _FakeRemoteAssessments(),
        database: db,
      );

  RepDataModel rep({String? trainingItemId}) => RepDataModel(
    averageWeight: 25,
    duration: 7,
    index: 0,
    isRest: false,
    handSide: HandSide.right,
    targetWeight: 30,
    trainingItemId: trainingItemId,
  );

  SessionModel playedSession({String? trainingId}) => SessionModel(
    name: 'Repeaters',
    isAssessment: false,
    origin: SessionOrigin.played,
    date: DateTime(2026, 8, 20),
    trainingId: trainingId,
  );

  /// Saves a training holding one group with one exercise under it, and hands
  /// back the ids the local database minted for them.
  Future<Training> saveLocalTraining({String title = 'Repeaters'}) async {
    final id = await db.saveTraining(
      Training(
        id: '',
        title: title,
        items: [
          TrainingItem(
            id: '',
            type: TrainingItemType.group,
            position: 0,
            groupTitle: 'Main',
            items: [
              TrainingItem(
                id: '',
                type: TrainingItemType.exercise,
                position: 0,
                repsIsMax: true,
              ),
            ],
          ),
        ],
      ),
    );
    return (await db.getTraining(id))!;
  }

  group('a guest session played from a training', () {
    test('is imported under the training id the server minted', () async {
      final local = await saveLocalTraining();
      await db.saveSession(playedSession(trainingId: local.id), [
        rep(trainingItemId: local.items.single.items.single.id),
      ]);

      final remote = _FakeRemoteTrainings();
      final failures = await migrationWith(remote).uploadAll();

      expect(failures, 0);
      final posted = remote.postedSessions.single;
      final serverTraining = remote.stored.values.single;
      expect(posted.session.trainingId, serverTraining.id);
      expect(
        posted.reps.single.trainingItemId,
        serverTraining.items.single.items.single.id,
      );
    });

    test('goes up after the training it names', () async {
      final local = await saveLocalTraining();
      await db.saveSession(playedSession(trainingId: local.id), [rep()]);

      final remote = _FakeRemoteTrainings();
      await migrationWith(remote).uploadAll();

      expect(remote.calls, ['training', 'session']);
    });

    test('carries the counts its open items were answered with', () async {
      final local = await saveLocalTraining();
      final exerciseId = local.items.single.items.single.id;
      await db.saveSession(
        playedSession(trainingId: local.id),
        [rep(trainingItemId: exerciseId)],
        itemResults: [
          SessionItemResultModel(
            trainingItemId: exerciseId,
            occurrence: 0,
            field: SessionItemField.reps,
            value: 12,
          ),
        ],
      );

      final remote = _FakeRemoteTrainings();
      await migrationWith(remote).uploadAll();

      final posted = remote.postedSessions.single;
      final serverExerciseId =
          remote.stored.values.single.items.single.items.single.id;
      expect(posted.itemResults.single.trainingItemId, serverExerciseId);
      expect(posted.itemResults.single.value, 12);
    });

    // The training stays editable while a played session keeps the prescription
    // it was run from, so a rep can name an item the training no longer holds.
    // The server refuses a link its snapshot does not carry, and the session
    // matters more than the link.
    test('drops a rep link to an item the training no longer holds', () async {
      final local = await saveLocalTraining();
      await db.saveSession(playedSession(trainingId: local.id), [
        rep(trainingItemId: 'deleted-item'),
      ]);

      final remote = _FakeRemoteTrainings();
      final failures = await migrationWith(remote).uploadAll();

      expect(failures, 0);
      expect(remote.postedSessions.single.reps.single.trainingItemId, isNull);
    });

    // Dropped rather than nulled the way a rep link is: the count exists only
    // to answer an item, so one that answers nothing has nothing left to say.
    test('drops an open count answering an item that is gone', () async {
      final local = await saveLocalTraining();
      await db.saveSession(
        playedSession(trainingId: local.id),
        [rep(trainingItemId: local.items.single.items.single.id)],
        itemResults: [
          SessionItemResultModel(
            trainingItemId: 'deleted-item',
            occurrence: 0,
            field: SessionItemField.reps,
            value: 12,
          ),
        ],
      );

      final remote = _FakeRemoteTrainings();
      final failures = await migrationWith(remote).uploadAll();

      expect(failures, 0);
      expect(remote.postedSessions.single.itemResults, isEmpty);
      expect(
        remote.postedSessions.single.reps.single.trainingItemId,
        isNotNull,
      );
    });
  });

  group('a guest session whose training is not on the server', () {
    test('is held back when the training failed to import', () async {
      final local = await saveLocalTraining(title: 'Refused');
      await db.saveSession(playedSession(trainingId: local.id), [rep()]);

      final remote = _FakeRemoteTrainings(refusedTitles: {'Refused'});
      final failures = await migrationWith(remote).uploadAll();

      expect(remote.postedSessions, isEmpty);
      expect(failures, 2);
    });

    // The athlete deleted the training after playing it, so there is nothing
    // left to import and nothing to wait for. Holding the session back would
    // leave the import failing on every attempt from here on.
    test('is imported unlinked when the training is gone', () async {
      await db.saveSession(playedSession(trainingId: 'deleted-training'), [
        rep(trainingItemId: 'deleted-item'),
      ]);

      final remote = _FakeRemoteTrainings();
      final failures = await migrationWith(remote).uploadAll();

      expect(failures, 0);
      final posted = remote.postedSessions.single;
      expect(posted.session.trainingId, isNull);
      expect(posted.reps.single.trainingItemId, isNull);
    });
  });
}
