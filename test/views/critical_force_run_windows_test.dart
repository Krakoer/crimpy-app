import 'package:clock/clock.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/repositories/ble_repository.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/screens/assessments/critical_force/critical_force_result_screen.dart';
import 'package:crimpy/views/screens/assessments/critical_force/critical_force_run_screen.dart';
import 'package:crimpy/views/widgets/workout_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Connected extends BleConnection {
  @override
  BleConnectionState build() => BleConnectionState.connected;
}

/// The samples the run reads, added by hand with the fake clock's time.
class _HandFedSamples extends BleDataStream {
  final List<BleDataPoint> points = [];

  @override
  Stream<List<BleDataPoint>> build() => const Stream.empty();

  @override
  double? lastValue() => points.lastOrNull?.value;

  @override
  List<BleDataPoint> getData() => points;
}

class _NoHistory extends Assessments {
  @override
  Future<List<AssessmentModel>> build(String? assessmentId) async => const [];

  @override
  Future<double?> getLastValueForHand(
    HandSide handSide, {
    GripPosition? gripPosition,
  }) async => null;
}

const _pull = TimedItem(
  label: 'Pull',
  durationSeconds: 2,
  targetLoad: 0,
  handSide: HandSide.right,
  gripPosition: GripPosition.halfCrimp,
  collectSensorData: true,
);

const _rest = RestItem(durationSeconds: 1);

/// A 1 s lead-in, then four 2 s pulls with 1 s between them.
const _reps = [_rest, _pull, _rest, _pull, _rest, _pull, _rest, _pull];

void main() {
  testWidgets('the pull windows sit on the bells and the force in them is '
      'the result', (tester) async {
    final watch = ManualCrimpyWatch();
    final samples = _HandFedSamples();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bleRepositoryProvider.overrideWithValue(BleRepository()),
          connectionStateProvider.overrideWith(_Connected.new),
          bleDataStreamProvider.overrideWith(() => samples),
          assessmentsProvider.overrideWith(_NoHistory.new),
        ],
        child: MaterialApp(
          home: CriticalForceRunScreen(
            reps: [..._reps],
            hand: HandSide.right,
            watch: watch,
          ),
        ),
      ),
    );
    final state = tester.state(find.byType(CriticalForceRunScreen));

    // The run clock and the wall clock move together, 100 ms at a time. The
    // athlete pulls 10 kg in every pull and holds 30 kg in the rests, which
    // must not reach the result.
    for (var ms = 0; ms < 12000; ms += 100) {
      final inPull = ms >= 1000 && (ms - 1000) % 3000 <= 2000;
      samples.points.add(BleDataPoint(inPull ? 10 : 30, clock.now()));
      if (ms == 4000) {
        // ignore: avoid_dynamic_calls
        expect((state as dynamic).pullWindows, [(start: 1000, end: 3000)]);
      }
      watch.advance(100);
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // ignore: avoid_dynamic_calls
    expect((state as dynamic).pullWindows, [
      (start: 1000, end: 3000),
      (start: 4000, end: 6000),
      (start: 7000, end: 9000),
      (start: 10000, end: 12000),
    ]);
    expect(find.byType(CriticalForceResultScreen), findsOneWidget);
    expect(find.text('10.00 kg'), findsOneWidget);
    expect(find.text('Mean of pulls 1-4'), findsOneWidget);
  });
}
