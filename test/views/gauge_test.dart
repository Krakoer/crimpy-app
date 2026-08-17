import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/widgets/gauge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBleDataStream extends BleDataStream {
  _FakeBleDataStream(this.points);

  final List<BleDataPoint> points;

  @override
  Stream<List<BleDataPoint>> build() => Stream.value(points);
}

Future<WeightGaugePainter> _pumpGauge(
  WidgetTester tester, {
  required double lastValue,
  required bool paused,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        bleDataStreamProvider.overrideWith(
          () => _FakeBleDataStream([BleDataPoint(lastValue, DateTime(2026))]),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(body: Gauge(42, paused: paused)),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final customPaint = tester.widget<CustomPaint>(
    find.descendant(of: find.byType(Gauge), matching: find.byType(CustomPaint)),
  );
  return customPaint.painter! as WeightGaugePainter;
}

void main() {
  testWidgets('a running gauge reads the latest sample', (tester) async {
    final painter = await _pumpGauge(tester, lastValue: 34.2, paused: false);

    expect(painter.currentWeight, 34.2);
  });

  // The sensor stream is muted for the whole pause, so the sample the gauge
  // stopped on is stale. Keeping it on the dial reads as a hold the athlete
  // let go of to take the pause.
  testWidgets('a paused gauge empties instead of holding a stale sample', (
    tester,
  ) async {
    final painter = await _pumpGauge(tester, lastValue: 34.2, paused: true);

    expect(painter.currentWeight, 0);
    expect(painter.fillPercentage, 0);
  });
}
