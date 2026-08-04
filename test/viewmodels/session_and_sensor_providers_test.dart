import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSessions extends Sessions {
  FakeSessions(this.sessions);

  final List<SessionModel> sessions;

  @override
  Future<List<SessionModel>> build() async => sessions;
}

class FakeBleDataStream extends BleDataStream {
  FakeBleDataStream(this.points);

  final List<BleDataPoint> points;

  @override
  Stream<List<BleDataPoint>> build() => Stream.value(points);
}

SessionModel sessionOn(DateTime date, {bool isAssessment = false}) =>
    SessionModel(name: 'session', isAssessment: isAssessment, date: date);

void main() {
  group('filteredSessionsProvider', () {
    final january = sessionOn(DateTime(2026, 1, 10));
    final march = sessionOn(DateTime(2026, 3, 10));
    final assessment = sessionOn(DateTime(2026, 2, 10), isAssessment: true);

    ProviderContainer containerWithSessions() => ProviderContainer.test(
      overrides: [
        sessionsProvider.overrideWith(
          () => FakeSessions([january, assessment, march]),
        ),
      ],
    );

    test('a null filter returns every session', () async {
      final container = containerWithSessions();

      await expectLater(
        container.read(filteredSessionsProvider(null).future),
        completion(hasLength(3)),
      );
    });

    test('filters on the assessment flag', () async {
      final container = containerWithSessions();

      final sessions = await container.read(
        filteredSessionsProvider(
          const SessionFilter(isAssessment: true),
        ).future,
      );

      expect(sessions, [assessment]);
    });

    test('keeps only the sessions inside the date range', () async {
      final container = containerWithSessions();

      final sessions = await container.read(
        filteredSessionsProvider(
          SessionFilter(
            startDate: DateTime(2026, 2, 1),
            endDate: DateTime(2026, 2, 28),
          ),
        ).future,
      );

      expect(sessions, [assessment]);
    });
  });

  group('bleLastValueProvider', () {
    /// Keeps a listener on the stream so the provider is not disposed while
    /// waiting for its first value.
    Future<double?> lastValueFor(List<BleDataPoint> points) async {
      final container = ProviderContainer.test(
        overrides: [
          bleDataStreamProvider.overrideWith(() => FakeBleDataStream(points)),
        ],
      );
      container.listen(bleLastValueProvider, (previous, next) {});

      await container.read(bleDataStreamProvider.future);

      return container.read(bleLastValueProvider);
    }

    test('is null before any sample arrives', () async {
      expect(await lastValueFor([]), isNull);
    });

    test('reports the value of the most recent sample', () async {
      final value = await lastValueFor([
        BleDataPoint(12.5, DateTime(2026, 1, 1)),
        BleDataPoint(31.25, DateTime(2026, 1, 1, 0, 0, 1)),
      ]);

      expect(value, 31.25);
    });
  });
}
