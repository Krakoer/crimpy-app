import 'dart:typed_data';

import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/repositories/ble_repository.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crimpy/models/session_filter.dart';

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

  group('pausing the sensor stream', () {
    /// One notification as the firmware sends it: two leading bytes, then the
    /// raw force as a little-endian float32. The default tare and coefficient
    /// leave it calibrated to itself.
    List<int> sampleOf(double force) =>
        (ByteData(6)..setFloat32(2, force, Endian.little)).buffer.asUint8List();

    /// Feeds the repository and lets the broadcast stream reach the session.
    Future<void> feed(BleRepository repository, List<double> forces) async {
      for (final force in forces) {
        repository.handleRawSample(sampleOf(force));
      }
      await pumpEventQueue();
    }

    test(
      'samples taken while paused stay out of the session average',
      () async {
        final repository = BleRepository();
        final container = ProviderContainer.test(
          overrides: [bleRepositoryProvider.overrideWithValue(repository)],
        );
        container.listen(bleSessionProvider, (previous, next) {});

        await feed(repository, [20, 30]);
        expect(container.read(bleSessionProvider).avg, 25);
        expect(container.read(bleSessionProvider).nbPoints, 2);

        // The athlete is off the board for the whole pause. Averaging these in
        // is what dragged the mean force of the rep down.
        repository.pauseStreaming();
        await feed(repository, [0, 0, 0]);
        expect(container.read(bleSessionProvider).avg, 25);
        expect(container.read(bleSessionProvider).nbPoints, 2);

        repository.resumeStreaming();
        await feed(repository, [40]);
        expect(container.read(bleSessionProvider).avg, 30);
        expect(container.read(bleSessionProvider).nbPoints, 3);
      },
    );

    // Rep boundaries reset the session stats, and used to raise the streaming
    // flag with them, cancelling the pause of a suspended run from under the
    // athlete.
    test('starting a new rep leaves a paused stream paused', () async {
      final repository = BleRepository();
      final container = ProviderContainer.test(
        overrides: [bleRepositoryProvider.overrideWithValue(repository)],
      );
      container.listen(bleSessionProvider, (previous, next) {});

      await feed(repository, [20]);
      repository.pauseStreaming();
      container.read(bleSessionProvider.notifier).reset();

      expect(repository.isStreaming, isFalse);
      expect(container.read(bleSessionProvider).nbPoints, 0);
    });

    test('the peak of the rep survives a pause', () async {
      final repository = BleRepository();
      final container = ProviderContainer.test(
        overrides: [bleRepositoryProvider.overrideWithValue(repository)],
      );
      container.listen(bleSessionProvider, (previous, next) {});

      await feed(repository, [45]);
      repository.pauseStreaming();
      await feed(repository, [0]);

      expect(container.read(bleSessionProvider).max, 45);
    });
  });
}
