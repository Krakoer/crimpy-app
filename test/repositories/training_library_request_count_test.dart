import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves a library and counts every request the repository makes, so the round
/// trips a library read costs can be asserted rather than reasoned about.
class _CountingApiClient extends ApiClient {
  _CountingApiClient(this.ids, {this.favourites = const <String>{}});

  final List<String> ids;
  final Set<String> favourites;

  int listCalls = 0;
  int detailCalls = 0;
  final List<bool> listedWithItems = [];

  Map<String, dynamic> row(String id) => {
    'id': id,
    'title': 'Training $id',
    'is_favorite': favourites.contains(id),
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
            'items': [
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

    test('narrows to the favourites without a second request', () async {
      final client = _CountingApiClient(
        const ['t-0', 't-1', 't-2'],
        favourites: const {'t-1'},
      );

      final trainings = await RemoteTrainingRepository(
        client,
      ).getAllTrainings(onlyFavs: true);

      expect(trainings.map((training) => training.id), ['t-1']);
      expect(trainings.single.items.single.comment, 'from the list');
      expect(client.listCalls, 1);
      expect(client.detailCalls, 0);
    });

    test('answers with nothing for an empty library', () async {
      final client = _CountingApiClient(const []);

      expect(await RemoteTrainingRepository(client).getAllTrainings(), isEmpty);
      expect(client.detailCalls, 0);
    });
  });
}
