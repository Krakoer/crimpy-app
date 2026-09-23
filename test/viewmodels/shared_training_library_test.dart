import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_list_item.dart';
import 'package:crimpy/repositories/assessment_repository.dart';
import 'package:crimpy/repositories/builtin_preferences_repository.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/services/api_exception.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves the library and counts the requests it answers, so what a screen
/// costs can be asserted rather than reasoned about.
class _CountingApiClient extends ApiClient {
  _CountingApiClient(this.ids, {this.favourites = const <String>{}});

  List<String> ids;
  Set<String> favourites;

  /// Reads of `GET /api/trainings?include=items`, the one request the whole
  /// library costs since Krakoer/crimpy#124.
  int libraryReads = 0;

  /// Set to fail the next read, so a retry can be told from a rebuild that
  /// hands back the failure already in hand.
  bool failing = false;

  @override
  Future<List<Map<String, dynamic>>> getTrainings({
    bool includeItems = false,
  }) async {
    libraryReads++;
    if (failing) throw ApiException('offline', isOffline: true);
    return [
      for (final id in ids)
        {
          'id': id,
          'title': 'Training $id',
          'is_favorite': favourites.contains(id),
          'items': <Map<String, dynamic>>[],
        },
    ];
  }

  @override
  Future<Map<String, dynamic>> getTraining(String id) async => {
    'id': id,
    'title': 'Training $id',
    'is_favorite': favourites.contains(id),
    'items': <Map<String, dynamic>>[],
  };

  @override
  Future<Map<String, dynamic>> updateTrainingApi(
    String id,
    Map<String, dynamic> body,
  ) async {
    if (body['is_favorite'] == true) {
      favourites = {...favourites, id};
    } else {
      favourites = {...favourites}..remove(id);
    }
    return {...body, 'id': id};
  }

  @override
  Future<Map<String, dynamic>> createTraining(Map<String, dynamic> body) async {
    final id = body['id'] as String? ?? 't-new';
    ids = [...ids, id];
    return {...body, 'id': id};
  }

  @override
  Future<void> deleteTrainingApi(String id) async {
    ids = [...ids]..remove(id);
    favourites = {...favourites}..remove(id);
  }
}

/// No assessment has been recorded, which is all the builtin evaluation needs
/// to answer. It never reaches the library.
class _NoAssessments extends AssessmentRepository {
  /// Reads of the assessment history, which the builtin evaluation needs and
  /// both training lists used to ask for one each.
  int reads = 0;

  /// Fails the read, after a turn of the event loop so it settles behind a
  /// read that failed first.
  bool failing = false;

  @override
  Future<List<AssessmentModel>> getAssessments({
    String? assessmentId,
    HandSide? handSide,
    GripPosition? gripPosition,
  }) async {
    reads++;
    if (failing) {
      await Future<void>.delayed(Duration.zero);
      throw ApiException('offline', isOffline: true);
    }
    return const [];
  }

  @override
  Future<List<AssessmentDefinition>> getAssessmentDefinitions() async =>
      const [];

  @override
  Future<String> saveAssessment(
    AssessmentResultModel assessment,
    String sessionId,
  ) async => 'a-1';

  @override
  Future<void> deleteAssessment(String id) async {}
}

/// Pins held in memory, so a pin change can be made without a server and the
/// reads it costs counted against the library.
class _InMemoryPreferences extends BuiltinPreferencesRepository {
  _InMemoryPreferences([Iterable<String> pinned = const []])
    : _pinned = {...pinned};

  final Set<String> _pinned;

  /// Reads of the pinned ids, counted for the same reason as the assessments.
  int reads = 0;

  /// Fails the read straight away, so it is the first of the catalog's reads
  /// to answer.
  bool failing = false;

  @override
  Future<List<String>> getPinnedBuiltinTrainingIds() async {
    reads++;
    if (failing) throw ApiException('offline', isOffline: true);
    return _pinned.toList();
  }

  @override
  Future<void> pinBuiltinTraining(String builtinTrainingId) async =>
      _pinned.add(builtinTrainingId);

  @override
  Future<void> unpinBuiltinTraining(String builtinTrainingId) async =>
      _pinned.remove(builtinTrainingId);

  @override
  Future<Map<String, ({double? weightRight, double? weightLeft})>>
  getAllCustomWeights() async => const {};

  @override
  Future<void> saveCustomWeights({
    required String builtinTrainingId,
    required double weightRight,
    required double weightLeft,
  }) async {}
}

({
  ProviderContainer container,
  _NoAssessments assessments,
  _InMemoryPreferences preferences,
})
_setUp(
  _CountingApiClient client, {
  Iterable<String> pinnedBuiltins = const [],
}) {
  final assessments = _NoAssessments();
  final preferences = _InMemoryPreferences(pinnedBuiltins);
  return (
    container: ProviderContainer.test(
      // A failed read is answered once here. The app retries four times with a
      // backoff, which would leave a test asserting on a failure waiting for
      // it.
      retry: (retryCount, error) => null,
      overrides: [
        trainingRepositoryProvider.overrideWith(
          (ref) => RemoteTrainingRepository(client),
        ),
        assessmentRepositoryProvider.overrideWith((ref) => assessments),
        builtinPreferencesRepositoryProvider.overrideWith((ref) => preferences),
        // Only the assessment save path reaches this, and it writes nowhere.
        sessionsProvider.overrideWith(_CapturingSessions.new),
      ],
    ),
    assessments: assessments,
    preferences: preferences,
  );
}

/// Saves without a store behind it, so recording a result can be driven
/// without a session repository.
class _CapturingSessions extends Sessions {
  @override
  Future<List<SessionModel>> build() async => const [];

  @override
  Future<String> saveSession(
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
    List<SessionItemResultModel> itemResults = const [],
  }) async => 's-1';
}

ProviderContainer _containerFor(
  _CountingApiClient client, {
  Iterable<String> pinnedBuiltins = const [],
}) => _setUp(client, pinnedBuiltins: pinnedBuiltins).container;

/// What `home_screen.dart` does for the two training cards on a pull: drop the
/// reads behind them, then wait for both lists.
Future<void> _homeScreenRefresh(ProviderContainer container) {
  container.invalidate(trainingLibraryProvider);
  container.invalidate(builtinTrainingCatalogProvider);
  // The history is its own root since Krakoer/crimpy#135, and the catalog
  // derives it rather than reading it, so this is what makes a pull ask the
  // server for the assessments again. The screen drops all three.
  container.invalidate(assessmentHistoryProvider);
  return Future.wait([
    container.read(allTrainingsProvider.future),
    container.read(pinnedTrainingsProvider.future),
  ]);
}

Future<void> _homeScreenLoad(ProviderContainer container) => Future.wait([
  container.read(allTrainingsProvider.future),
  container.read(pinnedTrainingsProvider.future),
]);

Iterable<String> _regularIds(List<TrainingListItem> items) =>
    items.where((item) => item.isRegular).map((item) => item.id);

Training _training(String id) => Training(id: id, title: 'Training $id');

void main() {
  group('the home screen', () {
    test('reads the library once on a cold load', () async {
      final client = _CountingApiClient(const ['t-0', 't-1', 't-2']);
      final container = _containerFor(client);

      await _homeScreenLoad(container);

      // One, spelled out rather than derived: the full list and the pinned
      // list are two views of the same read, and the screen used to put that
      // read on the wire twice at once.
      expect(client.libraryReads, 1);
    });

    test('reads the library once on a pull to refresh', () async {
      final client = _CountingApiClient(const ['t-0', 't-1', 't-2']);
      final container = _containerFor(client);
      await _homeScreenLoad(container);
      client.libraryReads = 0;

      await _homeScreenRefresh(container);

      expect(client.libraryReads, 1);
    });

    test('reads the builtin catalog once on a pull to refresh', () async {
      final client = _CountingApiClient(const ['t-0']);
      final setUp = _setUp(client);
      await _homeScreenLoad(setUp.container);
      setUp.assessments.reads = 0;
      setUp.preferences.reads = 0;

      await _homeScreenRefresh(setUp.container);

      // One each, spelled out: the full list and the pinned list evaluate the
      // same builtins against the same pins and the same assessments, and used
      // to ask for all of it once per list.
      expect(setUp.assessments.reads, 1);
      expect(setUp.preferences.reads, 1);
    });

    // The point of Krakoer/crimpy#135. The dashboard reads the history through
    // assessmentResults and the builtin catalog reads it for availability, and
    // both used to ask the repository themselves: one home screen load sent the
    // byte identical request twice, at the same time. Spelled out as one rather
    // than derived, since the number is the whole assertion.
    test('reads the assessment history once on a cold load', () async {
      final client = _CountingApiClient(const ['t-0']);
      final setUp = _setUp(client);

      await _homeScreenLoad(setUp.container);
      await setUp.container.read(assessmentResultsProvider.future);

      expect(setUp.assessments.reads, 1);
    });

    test('reads the assessment history once on a pull to refresh', () async {
      final client = _CountingApiClient(const ['t-0']);
      final setUp = _setUp(client);
      await _homeScreenLoad(setUp.container);
      await setUp.container.read(assessmentResultsProvider.future);
      setUp.assessments.reads = 0;

      await _homeScreenRefresh(setUp.container);
      await setUp.container.read(assessmentResultsProvider.future);

      expect(setUp.assessments.reads, 1);
    });

    // The two sides of the duplication, asserted against each other rather than
    // against a count: a dashboard reading a different history from the one the
    // builtin availability was evaluated against is the bug the single read
    // exists to make impossible.
    test(
      'evaluates builtins against the history the dashboard shows',
      () async {
        final client = _CountingApiClient(const ['t-0']);
        final setUp = _setUp(client);

        final catalog = await setUp.container.read(
          builtinTrainingCatalogProvider.future,
        );
        final history = await setUp.container.read(
          assessmentHistoryProvider.future,
        );

        expect(identical(catalog.assessments, history), isTrue);
        expect(setUp.assessments.reads, 1);
      },
    );

    test('shows what a pull fetched rather than what it held', () async {
      final client = _CountingApiClient(const ['t-0']);
      final container = _containerFor(client);
      await _homeScreenLoad(container);

      client.ids = const ['t-0', 't-added'];
      await _homeScreenRefresh(container);

      expect(_regularIds(await container.read(allTrainingsProvider.future)), [
        't-0',
        't-added',
      ]);
    });
  });

  group('the lists derived from the library', () {
    test('keep the favourites out of each other', () async {
      final client = _CountingApiClient(
        const ['t-0', 't-1', 't-2'],
        favourites: const {'t-1'},
      );
      final container = _containerFor(client);

      final favourites = await container.read(favTrainingsProvider.future);
      final pinned = await container.read(pinnedTrainingsProvider.future);
      final all = await container.read(allTrainingsProvider.future);

      expect(favourites.map((training) => training.id), ['t-1']);
      expect(_regularIds(pinned), ['t-1']);
      expect(_regularIds(all), ['t-0', 't-1', 't-2']);
      expect(client.libraryReads, 1);
    });

    test('hand the library back in the order the server gave it', () async {
      final client = _CountingApiClient(const ['t-2', 't-0', 't-1']);
      final container = _containerFor(client);

      final all = await container.read(allTrainingsProvider.future);

      expect(_regularIds(all), ['t-2', 't-0', 't-1']);
    });

    test('carry the same trainings the library itself does', () async {
      final client = _CountingApiClient(
        const ['t-0', 't-1'],
        favourites: const {'t-0'},
      );
      final container = _containerFor(client);

      final library = await container.read(trainingLibraryProvider.future);
      final trainings = await container.read(trainingsProvider.future);

      expect(trainings.map((training) => training.id), ['t-0', 't-1']);
      expect(library.map((training) => training.id), ['t-0', 't-1']);
      expect(client.libraryReads, 1);
    });

    test('are pinned to the favourite flag, not to the request', () async {
      final client = _CountingApiClient(
        const ['t-0', 't-1', 't-2'],
        favourites: const {'t-0', 't-2'},
      );
      final container = _containerFor(client);

      final favourites = await container.read(favTrainingsProvider.future);

      expect(favourites.map((training) => training.id), ['t-0', 't-2']);
      expect(favourites.every((training) => training.isFavorite), isTrue);
    });
  });

  group('invalidation', () {
    test('a favourite toggle costs one library read and reaches every '
        'list', () async {
      final client = _CountingApiClient(const ['t-0', 't-1']);
      final container = _containerFor(client);
      await _homeScreenLoad(container);
      await container.read(favTrainingsProvider.future);
      client.libraryReads = 0;

      await container.read(favTrainingsProvider.notifier).toggleFav('t-1');

      expect(
        (await container.read(favTrainingsProvider.future)).map((t) => t.id),
        ['t-1'],
      );
      expect(
        _regularIds(await container.read(pinnedTrainingsProvider.future)),
        ['t-1'],
      );
      expect(_regularIds(await container.read(allTrainingsProvider.future)), [
        't-0',
        't-1',
      ]);
      // Three lists rebuilt off one read. Counted after they were read, since
      // an invalidation on its own fetches nothing until someone asks.
      expect(client.libraryReads, 1);
    });

    test('a pin change costs no library read at all', () async {
      final builtinId = builtinTrainings.first.id;
      final client = _CountingApiClient(const ['t-0']);
      final setUp = _setUp(client);
      await _homeScreenLoad(setUp.container);
      client.libraryReads = 0;
      setUp.assessments.reads = 0;

      await setUp.container
          .read(pinnedTrainingsProvider.notifier)
          .togglePin(builtinId);

      final pinned = await setUp.container.read(pinnedTrainingsProvider.future);
      final all = await setUp.container.read(allTrainingsProvider.future);

      // A pin belongs to the catalog, so the library is never asked for, and
      // the catalog is asked for once for both lists rather than once each.
      //
      // The assessments are not asked for at all. They used to be, because the
      // catalog read them itself and a pin change dropped the catalog. They are
      // a root of their own now, so a pin refreshes the pins and leaves the
      // history alone: a heart tap says nothing about what the athlete has
      // measured. This assertion moved from 1 to 0 because the behaviour got
      // better, not because the test was relaxed.
      expect(client.libraryReads, 0);
      expect(setUp.assessments.reads, 0);
      expect(
        pinned.where((item) => item.isBuiltin).map((item) => item.id),
        contains(builtinId),
      );
      expect(all.firstWhere((item) => item.id == builtinId).isPinned, isTrue);
    });

    test('a library refresh leaves the builtin catalog alone', () async {
      final client = _CountingApiClient(const ['t-0']);
      final setUp = _setUp(client);
      await _homeScreenLoad(setUp.container);
      client.libraryReads = 0;
      setUp.assessments.reads = 0;
      setUp.preferences.reads = 0;

      // What the assessments tab pull does: it shows the athlete's own
      // trainings and nothing builtin, so it drops the library only.
      setUp.container.invalidate(trainingLibraryProvider);
      await _homeScreenLoad(setUp.container);

      expect(client.libraryReads, 1);
      expect(setUp.assessments.reads, 0);
      expect(setUp.preferences.reads, 0);
    });

    test('recording a result re-evaluates the builtins', () async {
      final client = _CountingApiClient(const ['t-0']);
      final setUp = _setUp(client);
      await _homeScreenLoad(setUp.container);
      client.libraryReads = 0;
      setUp.preferences.reads = 0;
      setUp.assessments.reads = 0;

      await setUp.container
          .read(assessmentsProvider('a-1').notifier)
          .saveAssessment(
            AssessmentResultModel(assessmentId: 'a-1', rightValue: 12),
            SessionModel(
              name: 'Max pull ups',
              date: DateTime(2026, 9, 21),
              isAssessment: true,
              activity: SessionActivity.hangboard,
              origin: SessionOrigin.played,
            ),
            const [],
          );
      await _homeScreenLoad(setUp.container);

      // A builtin's availability is read off the assessments, so the catalog
      // is what the write made stale. Invalidating a list instead would fetch
      // nothing and leave both showing the old evaluation, and the library is
      // not involved either way.
      //
      // The pinned ids are the literal here because the catalog is the only
      // reader of them. Three providers re-read the assessments on this path
      // and only one of them is the catalog, so that count says the history
      // was refreshed rather than which reader refreshed it.
      expect(setUp.assessments.reads, greaterThanOrEqualTo(1));
      expect(setUp.preferences.reads, 1);
      expect(client.libraryReads, 0);
    });

    test('a failed catalog read does not orphan the reads beside it', () async {
      final client = _CountingApiClient(const ['t-0']);
      final setUp = _setUp(client);
      setUp.preferences.failing = true;
      setUp.assessments.failing = true;

      await expectLater(
        setUp.container.read(pinnedTrainingsProvider.future),
        throwsA(isA<ApiException>()),
      );
      // Long enough for the slower read to answer. Awaited one after another,
      // its failure would land with nobody listening and reach the zone as an
      // unhandled error, which is a crash under Sentry and three more of them
      // once the provider retries. What fails this test is that error, which
      // the test zone reports whatever the assertions say: the count below is
      // only here so the test cannot pass by never issuing the read at all.
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(setUp.assessments.reads, 1);
    });

    test('an update costs one library read', () async {
      final client = _CountingApiClient(const ['t-0']);
      final container = _containerFor(client);
      await _homeScreenLoad(container);
      client.libraryReads = 0;

      await container
          .read(trainingsProvider.notifier)
          .updateTraining(_training('t-0'));

      expect(client.libraryReads, 1);
      expect(_regularIds(await container.read(allTrainingsProvider.future)), [
        't-0',
      ]);
    });

    test('a save costs one library read', () async {
      final client = _CountingApiClient(const ['t-0']);
      final container = _containerFor(client);
      await _homeScreenLoad(container);
      client.libraryReads = 0;

      await container
          .read(trainingsProvider.notifier)
          .saveTraining(_training('t-new'));

      expect(client.libraryReads, 1);
      expect(_regularIds(await container.read(allTrainingsProvider.future)), [
        't-0',
        't-new',
      ]);
    });

    test('a delete costs one library read', () async {
      final client = _CountingApiClient(const ['t-0', 't-1']);
      final container = _containerFor(client);
      await _homeScreenLoad(container);
      client.libraryReads = 0;

      await container.read(trainingsProvider.notifier).deleteTraining('t-0');

      expect(client.libraryReads, 1);
      expect(_regularIds(await container.read(allTrainingsProvider.future)), [
        't-1',
      ]);
    });

    test('a retry after a failed read asks the server again', () async {
      final client = _CountingApiClient(const ['t-0'])..failing = true;
      final container = _containerFor(client);
      await expectLater(
        container.read(pinnedTrainingsProvider.future),
        throwsA(isA<ApiException>()),
      );
      client.failing = false;
      client.libraryReads = 0;

      // What the retry button on the home screen card does. Invalidating the
      // list instead would rebuild it from the failed library read and hand
      // back the same error forever.
      container.invalidate(trainingLibraryProvider);

      expect(await container.read(pinnedTrainingsProvider.future), isNotNull);
      expect(client.libraryReads, 1);
    });

    test('invalidating a derived list does not reach the server', () async {
      final client = _CountingApiClient(const ['t-0']);
      final container = _containerFor(client);
      await _homeScreenLoad(container);
      client.libraryReads = 0;

      container.invalidate(allTrainingsProvider);
      await container.read(allTrainingsProvider.future);

      // The rule the rest of the app is written against: the library is the
      // only thing whose invalidation fetches.
      expect(client.libraryReads, 0);
    });
  });
}
