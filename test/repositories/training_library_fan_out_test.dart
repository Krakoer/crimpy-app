import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves a library of trainings, counting how many detail reads were on the
/// wire at the same moment so the fan-out can be checked for its bound.
class _FakeApiClient extends ApiClient {
  _FakeApiClient(this.ids);

  final List<String> ids;

  int inFlight = 0;
  int peakInFlight = 0;
  final List<String> fetched = [];

  @override
  Future<List<Map<String, dynamic>>> getTrainings() async => [
    for (final id in ids) {'id': id, 'title': 'Training $id'},
  ];

  @override
  Future<Map<String, dynamic>> getTraining(String id) async {
    fetched.add(id);
    inFlight++;
    if (inFlight > peakInFlight) peakInFlight = inFlight;
    try {
      // A detail read takes several event loop turns, which is what gives an
      // unbounded fan-out the chance to put the whole library on the wire. The
      // later trainings answer first, so a fan-out that kept the answers in the
      // order they landed would hand the library back scrambled.
      final turns = ids.length - ids.indexOf(id);
      for (var turn = 0; turn < turns; turn++) {
        await Future<void>.delayed(Duration.zero);
      }
      return {'id': id, 'title': 'Training $id', 'items': <dynamic>[]};
    } finally {
      inFlight--;
    }
  }
}

void main() {
  group('the training library fan-out', () {
    test('keeps at most six detail reads on the wire', () async {
      final client = _FakeApiClient([
        for (var index = 0; index < 50; index++) 't-$index',
      ]);

      final trainings = await RemoteTrainingRepository(
        client,
      ).getAllTrainings();

      expect(trainings, hasLength(50));
      expect(client.peakInFlight, lessThanOrEqualTo(6));
    });

    test('hands the library back in the order the list gave it', () async {
      final client = _FakeApiClient([
        for (var index = 0; index < 20; index++) 't-$index',
      ]);

      final trainings = await RemoteTrainingRepository(
        client,
      ).getAllTrainings();

      expect(trainings.map((training) => training.id), [
        for (var index = 0; index < 20; index++) 't-$index',
      ]);
    });

    test('reads the details of the favourites only when asked', () async {
      final client = _FavouriteApiClient();

      final trainings = await RemoteTrainingRepository(
        client,
      ).getAllTrainings(onlyFavs: true);

      expect(trainings.map((training) => training.id), ['t-1']);
      expect(client.fetched, ['t-1']);
    });
  });
}

/// A library where a single training is a favourite.
class _FavouriteApiClient extends _FakeApiClient {
  _FavouriteApiClient() : super(const ['t-0', 't-1', 't-2']);

  @override
  Future<List<Map<String, dynamic>>> getTrainings() async => [
    for (final id in ids)
      {'id': id, 'title': 'Training $id', 'is_favorite': id == 't-1'},
  ];
}
