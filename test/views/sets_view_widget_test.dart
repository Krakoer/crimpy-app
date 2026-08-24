import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/rep_blocks.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/sets_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

RepDataModel _rep({
  required int index,
  double averageWeight = 28,
  double targetWeight = 30,
}) => RepDataModel(
  averageWeight: averageWeight,
  duration: 7,
  index: index,
  isRest: false,
  handSide: HandSide.right,
  targetWeight: targetWeight,
);

Future<void> _pumpSet(WidgetTester tester, List<RepDataModel> reps) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SetsViewWidget(
            sets: [RepSet(label: 'SET 1', reps: reps)],
            sessionColor: CrimpyTheme.trainingColor,
          ),
        ),
      ),
    );

void main() {
  group('set card', () {
    testWidgets('counts the reps that reached their target', (tester) async {
      await _pumpSet(tester, [
        _rep(index: 0),
        _rep(index: 1, averageWeight: 10),
      ]);

      expect(find.text('1/2'), findsOneWidget);
      expect(find.text('Target'), findsOneWidget);
      expect(find.text('30.0 kg'), findsOneWidget);
    });

    testWidgets('grades no set the sensor never measured', (tester) async {
      await _pumpSet(tester, [
        _rep(index: 0, averageWeight: 0, targetWeight: 0),
        _rep(index: 1, averageWeight: 0, targetWeight: 0),
      ]);

      expect(find.text('0/2'), findsNothing);
      expect(find.text('Target'), findsNothing);
      expect(find.text('Avg Performed'), findsNothing);
      expect(find.text('2 reps'), findsOneWidget);
    });
  });
}
