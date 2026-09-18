import 'package:crimpy/repositories/bodyweight_repository.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/services/bodyweight_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records what the repository sends, and can refuse, so the offline path can
/// be exercised without a network.
class _FakeApiClient extends ApiClient {
  /// Flipped by the tests rather than set at construction, since the point of
  /// the offline cases is a network that comes and goes during one run.
  bool offline = false;
  final List<({double weightKg, DateTime measuredAt})> created = [];

  @override
  Future<Map<String, dynamic>> createBodyweight(
    double weightKg,
    DateTime measuredAt,
  ) async {
    if (offline) throw Exception('no network');
    created.add((weightKg: weightKg, measuredAt: measuredAt));
    return {
      'id': 'bw-${created.length}',
      'user_id': 'u-1',
      'weight_kg': weightKg,
      'measured_at': measuredAt.toUtc().toIso8601String(),
      'created_at': measuredAt.toUtc().toIso8601String(),
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getMyBodyweights() async => [
    {
      'id': 'bw-1',
      'user_id': 'u-1',
      'weight_kg': 70.5,
      'measured_at': '2026-09-01T08:00:00Z',
      'created_at': '2026-09-01T08:00:00Z',
    },
  ];
}

void main() {
  late _FakeApiClient api;
  late BodyweightRepository repository;
  late BodyweightService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    api = _FakeApiClient();
    service = BodyweightService();
    repository = BodyweightRepository(api, service: service);
  });

  // A run must not wait on a network round trip, so recording is a device
  // write and nothing else. The send is a separate step.
  test('records on the device without touching the network', () async {
    await repository.record(71.4);

    expect(await repository.cached(), 71.4);
    expect(api.created, isEmpty);
    expect(await repository.hasPending(), isTrue);
  });

  test('sends what is pending and stops calling it pending', () async {
    await repository.record(71.4);

    await repository.flushPending();

    expect(api.created.single.weightKg, 71.4);
    expect(await repository.hasPending(), isFalse);
  });

  test('keeps the measurement pending when the send fails', () async {
    api.offline = true;
    await repository.record(69.2);

    await repository.flushPending();

    expect(api.created, isEmpty);
    expect(await repository.cached(), 69.2);
    expect(await repository.hasPending(), isTrue);
  });

  // The coach would otherwise read a series with an entry on the wrong day.
  test('files an offline measurement under the day it was taken', () async {
    api.offline = true;
    final measuredAt = DateTime.now().subtract(const Duration(days: 2));
    await repository.record(69.2, measuredAt: measuredAt);

    api.offline = false;
    await repository.flushPending();

    expect(api.created.single.weightKg, 69.2);
    expect(
      api.created.single.measuredAt.toUtc().toIso8601String(),
      measuredAt.toUtc().toIso8601String(),
    );
  });

  // The pending record carries its own weight, so a later weigh-in cannot
  // replace the number an earlier unsent one was about. Without that, day 1's
  // measurement would go up carrying day 3's weight.
  test('sends the weight it was recorded with, not the one since', () async {
    api.offline = true;
    final dayOne = DateTime.now().subtract(const Duration(days: 2));
    await repository.record(69.2, measuredAt: dayOne);

    await repository.record(70.4);
    api.offline = false;
    await repository.flushPending();

    expect(api.created.single.weightKg, 70.4);
    expect(await repository.cached(), 70.4);
  });

  test('sends nothing when there is nothing pending', () async {
    await repository.record(70);
    await repository.flushPending();
    api.created.clear();

    await repository.flushPending();

    expect(api.created, isEmpty);
  });

  // The bodyweight describes an athlete, not a device: a sign out must not
  // leave the next user resolving their loads against it, nor leave a pending
  // measurement to be filed under the wrong account.
  test('clears the weight and anything pending', () async {
    api.offline = true;
    await repository.record(69.2);

    await repository.clear();

    expect(await repository.cached(), isNull);
    expect(await repository.hasPending(), isFalse);
  });

  // Several things ask for a flush at once, so two attempts must not both read
  // the same pending record and file it twice.
  test('files a pending measurement once when flushed twice at once', () async {
    await repository.record(71.4);

    await Future.wait([repository.flushPending(), repository.flushPending()]);

    expect(api.created, hasLength(1));
  });

  test('reads the series back newest first', () async {
    final series = await repository.series();

    expect(series.single.weightKg, 70.5);
    expect(series.single.id, 'bw-1');
  });
}
