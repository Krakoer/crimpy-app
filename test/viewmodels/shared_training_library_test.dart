import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_list_item.dart';
import 'package:crimpy/repositories/assessment_repository.dart';
import 'package:crimpy/repositories/builtin_preferences_repository.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/services/api_exception.dart';
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
  @override
  Future<List<AssessmentModel>> getAssessments({
    String? assessmentId,
    HandSide? handSide,
    GripPosition? gripPosition,
  }) async => const [];

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

  @override
  Future<List<String>> getPinnedBuiltinTrainingIds() async => _pinned.toList();

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

ProviderContainer _containerFor(
  _CountingApiClient client, {
  Iterable<String> pinnedBuiltins = const [],
}) => ProviderContainer.test(
  // A failed read is answered once here. The app retries four times with a
  // backoff, which would leave a test asserting on a failure waiting for it.
  retry: (retryCount, error) => null,
  overrides: [
    trainingRepositoryProvider.overrideWith(
      (ref) => RemoteTrainingRepository(client),
    ),
    assessmentRepositoryProvider.overrideWith((ref) => _NoAssessments()),
    builtinPreferencesRepositoryProvider.overrideWith(
      (ref) => _InMemoryPreferences(pinnedBuiltins),
    ),
  ],
);

/// What `home_screen.dart` does for the two training cards on a pull: drop the
/// library, then wait for both lists.
Future<void> _homeScreenRefresh(ProviderContainer container) {
  container.invalidate(trainingLibraryProvider);
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
      final container = _containerFor(client);
      await _homeScreenLoad(container);
      client.libraryReads = 0;

      await container
          .read(pinnedTrainingsProvider.notifier)
          .togglePin(builtinId);

      // A pin lives outside the library, so both lists rebuild from the one
      // they already hold.
      expect(client.libraryReads, 0);
      final pinned = await container.read(pinnedTrainingsProvider.future);
      expect(
        pinned.where((item) => item.isBuiltin).map((item) => item.id),
        contains(builtinId),
      );
      final all = await container.read(allTrainingsProvider.future);
      expect(all.firstWhere((item) => item.id == builtinId).isPinned, isTrue);
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
