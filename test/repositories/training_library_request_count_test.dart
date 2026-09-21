import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves a library and counts every request the repository makes, so the round
/// trips a library read costs can be asserted rather than reasoned about.
class _CountingApiClient extends ApiClient {
  _CountingApiClient(
    this.ids, {
    this.favourites = const <String>{},
    this.empty = const <String>{},
  });

  final List<String> ids;
  final Set<String> favourites;

  /// The trainings that really hold no items. The server answers those with an
  /// empty array rather than leaving the key off, which is the distinction the
  /// fallback turns on.
  final Set<String> empty;

  int listCalls = 0;
  int detailCalls = 0;
  final List<bool> listedWithItems = [];

  Map<String, dynamic> row(String id) => {
    'id': id,
    'title': 'Training $id',
    'is_favorite': favourites.contains(id),
    'assessment': {
      'id': '$id-assessment',
      'label': 'Max pull ups',
      'unit': 'repetitions',
      'training_id': id,
    },
  };

  @override
  Future<List<Map<String, dynamic>>> getTrainings({
    bool includeItems = false,
  }) async {
    listCalls++;
    listedWithItems.add(includeItems);
    return [
      for (final id in ids)
        if (includeItems)
          {
            ...row(id),
            'referenced_assessments': [
              {
                'id': '$id-referenced',
                'label': 'Weighted hang',
                'unit': 'kilograms',
                'training_id': '$id-other',
              },
            ],
            'items': [
              if (!empty.contains(id))
                {
                  'id': '$id-item',
                  'type': 'free',
                  'position': 0,
                  'comment': 'from the list',
                },
            ],
          }
        else
          row(id),
    ];
  }

  @override
  Future<Map<String, dynamic>> getTraining(String id) async {
    detailCalls++;
    return {
      'id': id,
      'title': 'Training $id',
      'items': [
        {
          'id': '$id-item',
          'type': 'free',
          'position': 0,
          'comment': 'from the detail read',
        },
      ],
    };
  }
}

void main() {
  group('the training library read', () {
    test('costs one request whatever the library holds', () async {
      final client = _CountingApiClient([
        for (var index = 0; index < 50; index++) 't-$index',
      ]);

      final trainings = await RemoteTrainingRepository(
        client,
      ).getAllTrainings();

      expect(trainings, hasLength(50));
      // One, spelled out rather than derived: fifty trainings used to cost the
      // list plus nine more round trips, six detail reads at a time.
      expect(client.listCalls, 1);
      expect(client.detailCalls, 0);
    });

    test('asks the list for the items', () async {
      final client = _CountingApiClient(const ['t-0']);

      await RemoteTrainingRepository(client).getAllTrainings();

      expect(client.listedWithItems, [true]);
    });

    test(
      'reads the items off the list rather than off a detail read',
      () async {
        final client = _CountingApiClient(const ['t-0']);

        final training = (await RemoteTrainingRepository(
          client,
        ).getAllTrainings()).single;

        expect(training.items.single.comment, 'from the list');
      },
    );

    test('keeps the assessment fields the detail read used to carry', () async {
      final client = _CountingApiClient(const ['t-0']);

      final training = (await RemoteTrainingRepository(
        client,
      ).getAllTrainings()).single;

      // training_id is what makes an assessment the athlete's own rather than
      // one Crimpy ships, and it only reaches the app if the list row carries
      // it. This is the field that went missing the first time.
      expect(training.assessment!.trainingId, 't-0');
      expect(training.assessment!.isBuiltin, isFalse);
      expect(training.referencedAssessments.single.id, 't-0-referenced');
    });

    test('hands the library back in the order the list gave it', () async {
      final client = _CountingApiClient([
        for (var index = 0; index < 20; index++) 't-$index',
      ]);

      final trainings = await RemoteTrainingRepository(
        client,
      ).getAllTrainings();

      expect(trainings.map((training) => training.id), [
        for (var index = 0; index < 20; index++) 't-$index',
      ]);
    });

    test('carries the favourite flag the lists narrow on', () async {
      final client = _CountingApiClient(
        const ['t-0', 't-1', 't-2'],
        favourites: const {'t-1'},
      );

      final trainings = await RemoteTrainingRepository(
        client,
      ).getAllTrainings();

      // The repository has no narrower read since Krakoer/crimpy#132: the
      // favourites are filtered off this flag by the provider that holds the
      // library, so the flag has to survive the one request.
      expect(
        {for (final training in trainings) training.id: training.isFavorite},
        {'t-0': false, 't-1': true, 't-2': false},
      );
      expect(client.listCalls, 1);
      expect(client.detailCalls, 0);
    });

    test('does not refetch a training that really holds no items', () async {
      final client = _CountingApiClient(
        const ['t-0', 't-1'],
        empty: const {'t-1'},
      );

      final trainings = await RemoteTrainingRepository(
        client,
      ).getAllTrainings();

      // An empty array is not an absent key. Reading the two as the same thing
      // would send a library with one freshly created training straight back to
      // a detail read per training.
      expect(trainings.last.items, isEmpty);
      expect(trainings.first.items, hasLength(1));
      expect(client.detailCalls, 0);
    });

    test('falls back to detail reads against a server that ignores the '
        'parameter', () async {
      final client = _DeafApiClient([
        for (var index = 0; index < 8; index++) 't-$index',
      ]);

      final trainings = await RemoteTrainingRepository(
        client,
      ).getAllTrainings();

      // Today's behaviour rather than a library of trainings with no steps in
      // them, which is what reading the cheap rows straight through would give.
      expect(trainings, hasLength(8));
      expect(trainings.first.items.single.comment, 'from the detail read');
      expect(client.detailCalls, 8);
    });

    test('answers with nothing for an empty library', () async {
      final client = _CountingApiClient(const []);

      expect(await RemoteTrainingRepository(client).getAllTrainings(), isEmpty);
      expect(client.detailCalls, 0);
    });
  });
}

/// A server that predates the items on the list: it ignores the parameter and
/// answers the cheap rows, which carry no items key.
class _DeafApiClient extends _CountingApiClient {
  _DeafApiClient(super.ids);

  @override
  Future<List<Map<String, dynamic>>> getTrainings({
    bool includeItems = false,
  }) async {
    listCalls++;
    listedWithItems.add(includeItems);
    return [
      for (final id in ids)
        {
          ...row(id),
          // The cheap row a server of that vintage builds carries the shallow
          // assessment snapshot, with no training_id on it. Answering one here
          // would make the fake a better server than the one it stands for.
          'assessment': {...row(id)['assessment'] as Map<String, dynamic>}
            ..remove('training_id'),
        },
    ];
  }
}
