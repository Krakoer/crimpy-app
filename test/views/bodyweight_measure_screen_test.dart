import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/utils/bodyweight_measurement.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/screens/bodyweight/bodyweight_measure_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBleDataStream extends BleDataStream {
  _FakeBleDataStream(this.points);

  final List<BleDataPoint> points;

  @override
  Stream<List<BleDataPoint>> build() => Stream.value(points);
}

class _FakeBleSession extends BleSession {
  @override
  BleSessionStats build() => BleSessionStats();

  @override
  void reset() {}
}

List<BleDataPoint> _steadyHold(double kilograms, {required double seconds}) {
  final start = DateTime(2026, 1, 1, 12);
  const interval = Duration(milliseconds: 50);
  return List.generate(
    (seconds * 1000 / interval.inMilliseconds).round(),
    (i) => BleDataPoint(kilograms, start.add(interval * i)),
  );
}

Future<double?> _runScreen(
  WidgetTester tester,
  List<BleDataPoint> points,
) async {
  double? popped;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        bleDataStreamProvider.overrideWith(() => _FakeBleDataStream(points)),
        bleSessionProvider.overrideWith(_FakeBleSession.new),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              popped = await showBodyweightMeasureScreen(context);
            },
            child: const Text('measure'),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('measure'));
  await tester.pumpAndSettle();
  return popped;
}

void main() {
  testWidgets('a steady hold measures the weight and leaves the screen', (
    tester,
  ) async {
    final popped = await _runScreen(tester, _steadyHold(70, seconds: 8));

    expect(popped, closeTo(70, 0.01));
    expect(find.byType(BodyweightMeasureScreen), findsNothing);
  });

  testWidgets('an unloaded sensor keeps waiting rather than measuring', (
    tester,
  ) async {
    await _runScreen(tester, _steadyHold(0.3, seconds: 10));

    expect(find.byType(BodyweightMeasureScreen), findsOneWidget);
    expect(find.textContaining('Hang with all your weight'), findsOneWidget);
  });

  testWidgets('the screen can be left without a weight', (tester) async {
    double? popped;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bleDataStreamProvider.overrideWith(
            () => _FakeBleDataStream(_steadyHold(0.3, seconds: 2)),
          ),
          bleSessionProvider.overrideWith(_FakeBleSession.new),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                popped = await showBodyweightMeasureScreen(context);
              },
              child: const Text('measure'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('measure'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(popped, isNull);
  });

  test('a typed weight outside the plausible range is refused', () {
    expect(isPlausibleBodyweight(70), isTrue);
    // The slipped decimal point: 700 instead of 70.0 put a 560 kg target on
    // the gauge for an 80 %BW rep.
    expect(isPlausibleBodyweight(700), isFalse);
    expect(isPlausibleBodyweight(0), isFalse);
    expect(isPlausibleBodyweight(-5), isFalse);
  });
}
