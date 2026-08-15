import 'package:crimpy/views/widgets/workout_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A centred stroke puts half the ring outside its box, where the gauge
  // stacked on top covers the half that is left, so the run screen showed a
  // ring half as thick as it should be.
  testWidgets('the ring is drawn inside its own box', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: WorkoutCircle(value: 0.5, rest: false, size: 200),
          ),
        ),
      ),
    );

    final indicator = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(indicator.strokeAlign, CircularProgressIndicator.strokeAlignInside);
    expect(indicator.strokeWidth, WorkoutCircle.strokeWidth);
  });
}
