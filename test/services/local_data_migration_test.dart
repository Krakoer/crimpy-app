import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/assessment_model.dart';
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
  final List<String> sessionIds = [];
  final List<String> calls = [];
  int _next = 0;

  /// Refuses every session create, so a run can be made to land its trainings
  /// and fail its sessions the way a dropped connection would.
  final bool refusedSessions;

  /// Stores the training with no items at all, standing in for a response whose
  /// tree does not line up with what was sent.
  final bool dropsItems;

  _FakeRemoteTrainings({
    this.refusedTitles = const {},
    this.refusedSessions = false,
    this.dropsItems = false,
  });

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
      items: dropsItems ? const [] : _mintItems(training.items),
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
    if (refusedSessions) throw Exception('refused session');
    postedSessions.add(_PostedSession(session, reps, itemResults));
    final id = _mintId('server-session');
    sessionIds.add(id);
    return id;
  }

  // The import calls nothing else, so anything that reaches here is a test that
  // drifted rather than a path worth faking.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRemoteAssessments implements AssessmentRepository {
  /// Refuses this many saves before starting to accept them, so a run that
  /// half succeeded can be retried in a test.
  int refusals;
  final List<String> savedSessionIds = [];
  int _next = 0;

  _FakeRemoteAssessments({this.refusals = 0});

  @override
  Future<String> saveAssessment(
    AssessmentResultModel assessment,
    String sessionId,
  ) async {
    if (refusals > 0) {
      refusals--;
      throw Exception('refused assessment');
    }
    savedSessionIds.add(sessionId);
    return 'server-assessment-${_next++}';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeApiClient extends ApiClient {}

/// The account the import uploads to. Written to storage in setUp, the way a
/// login does, since the marks the import leaves are kept per account.
const _userId = 'user-1';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  LocalDataMigration migrationWith(
    _FakeRemoteTrainings remote, {
    _FakeRemoteAssessments? assessments,
  }) => LocalDataMigration(
    apiClient: _FakeApiClient(),
    remoteTrainings: remote,
    remoteAssessments: assessments ?? _FakeRemoteAssessments(),
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
      final failures = await migrationWith(remote).uploadAll(_userId);

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
      await migrationWith(remote).uploadAll(_userId);

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
      await migrationWith(remote).uploadAll(_userId);

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
      final failures = await migrationWith(remote).uploadAll(_userId);

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
      final failures = await migrationWith(remote).uploadAll(_userId);

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
      final failures = await migrationWith(remote).uploadAll(_userId);

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
      final failures = await migrationWith(remote).uploadAll(_userId);

      expect(failures, 0);
      final posted = remote.postedSessions.single;
      expect(posted.session.trainingId, isNull);
      expect(posted.reps.single.trainingItemId, isNull);
    });
  });

  group('a retry after a partial import', () {
    test('does not send a training that already went up', () async {
      await saveLocalTraining();

      final remote = _FakeRemoteTrainings();
      await migrationWith(remote).uploadAll(_userId);
      await migrationWith(remote).uploadAll(_userId);

      expect(remote.calls.where((c) => c == 'training').length, 1);
      expect(remote.stored, hasLength(1));
    });

    test('does not send a session that already went up', () async {
      final local = await saveLocalTraining();
      await db.saveSession(playedSession(trainingId: local.id), [rep()]);

      final remote = _FakeRemoteTrainings();
      await migrationWith(remote).uploadAll(_userId);
      await migrationWith(remote).uploadAll(_userId);

      expect(remote.postedSessions, hasLength(1));
    });

    // The id map lives in memory for the length of one run, so without the
    // stored ids a session going up on the second attempt would name a
    // training the first attempt uploaded and find nothing to name it with.
    test(
      'links a held back session to the training of the earlier run',
      () async {
        final local = await saveLocalTraining();
        final exerciseId = local.items.single.items.single.id;
        await db.saveSession(playedSession(trainingId: local.id), [
          rep(trainingItemId: exerciseId),
        ]);

        // The training lands, the session does not.
        final firstRemote = _FakeRemoteTrainings(refusedSessions: true);
        expect(await migrationWith(firstRemote).uploadAll(_userId), 1);
        final serverTraining = firstRemote.stored.values.single;

        final secondRemote = _FakeRemoteTrainings();
        expect(await migrationWith(secondRemote).uploadAll(_userId), 0);

        expect(secondRemote.calls.where((c) => c == 'training'), isEmpty);
        final posted = secondRemote.postedSessions.single;
        expect(posted.session.trainingId, serverTraining.id);
        expect(
          posted.reps.single.trainingItemId,
          serverTraining.items.single.items.single.id,
        );
      },
    );

    test('retries an assessment without resending its session', () async {
      final sessionId = await db.saveSession(
        SessionModel(
          name: 'Critical force',
          isAssessment: true,
          origin: SessionOrigin.played,
          date: DateTime(2026, 8, 20),
        ),
        [rep()],
      );
      await db.saveAssessment(
        AssessmentResultModel(
          assessmentId: BuiltinAssessmentIds.criticalForce,
          rightValue: 31.2,
        ),
        sessionId,
      );

      final remote = _FakeRemoteTrainings();
      final refusing = _FakeRemoteAssessments(refusals: 1);
      expect(
        await migrationWith(remote, assessments: refusing).uploadAll(_userId),
        1,
      );
      expect(remote.postedSessions, hasLength(1));

      final accepting = _FakeRemoteAssessments();
      expect(
        await migrationWith(remote, assessments: accepting).uploadAll(_userId),
        0,
      );

      expect(remote.postedSessions, hasLength(1));
      // The retry has to answer the session id the first run was given, not a
      // fresh one and not an empty string.
      expect(accepting.savedSessionIds, [remote.sessionIds.single]);
    });

    test('counts only what is left when asked what is pending', () async {
      final local = await saveLocalTraining();
      await db.saveSession(playedSession(trainingId: local.id), [rep()]);

      final remote = _FakeRemoteTrainings(refusedSessions: true);
      final migration = migrationWith(remote);
      expect((await migration.pendingData()).sessionCount, 1);
      expect((await migration.pendingData()).trainingCount, 1);

      await migration.uploadAll(_userId);

      final left = await migration.pendingData();
      expect(left.trainingCount, 0);
      expect(left.sessionCount, 1);
    });
  });

  group('signing in as a different account', () {
    // A server id says where a row went. Skipping it for an account that has
    // never seen it, and then wiping the local copy because the run reported no
    // failures, takes the row off the device for good.
    test('re-imports rows the earlier account already took', () async {
      await saveLocalTraining();

      final first = _FakeRemoteTrainings();
      await migrationWith(first).uploadAll(_userId);
      expect(first.stored, hasLength(1));

      final second = _FakeRemoteTrainings();
      await migrationWith(second).uploadAll('user-2');

      expect(second.stored, hasLength(1));
    });

    test('keeps skipping them for the account that took them', () async {
      await saveLocalTraining();

      final first = _FakeRemoteTrainings();
      await migrationWith(first).uploadAll(_userId);
      await migrationWith(first).uploadAll('user-2');
      final third = _FakeRemoteTrainings();
      await migrationWith(third).uploadAll('user-2');

      expect(third.stored, isEmpty);
    });
  });

  group('what is left to import', () {
    // A run whose only failure was a pin used to report nothing pending, so the
    // dialog never came back and the pin went with the next wipe.
    test('counts a pinned builtin nothing else accounts for', () async {
      await db.pinBuiltinTraining('builtin-1');

      final status = await migrationWith(_FakeRemoteTrainings()).pendingData();

      expect(status.sessionCount, 0);
      expect(status.trainingCount, 0);
      expect(status.otherCount, 1);
      expect(status.hasData, isTrue);
    });
  });

  group('a training the server stored under a shape it was not sent', () {
    // It is on the server whichever way the pairing went, so the run has to
    // remember it or the next one makes a second copy.
    test('is still recorded, so a retry does not send it twice', () async {
      await saveLocalTraining();

      final remote = _FakeRemoteTrainings(dropsItems: true);
      expect(await migrationWith(remote).uploadAll(_userId), 1);
      expect(remote.stored, hasLength(1));

      final retry = _FakeRemoteTrainings();
      await migrationWith(retry).uploadAll(_userId);

      expect(retry.stored, isEmpty);
    });
  });
}
