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
  bool targetUnmeasured = false,
}) => RepDataModel(
  averageWeight: averageWeight,
  duration: 7,
  index: index,
  isRest: false,
  handSide: HandSide.right,
  targetWeight: targetWeight,
  targetUnmeasured: targetUnmeasured,
);

Future<void> _pumpSet(
  WidgetTester tester,
  List<RepDataModel> reps, {
  String label = 'SET 1',
}) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: SetsViewWidget(
        sets: [RepSet(label: label, reps: reps)],
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

    testWidgets('leaves a rep the sensor never measured out of the ratio', (
      tester,
    ) async {
      await _pumpSet(tester, [
        _rep(index: 0),
        _rep(index: 1),
        _rep(
          index: 2,
          averageWeight: 0,
          targetWeight: 0,
          targetUnmeasured: true,
        ),
        _rep(
          index: 3,
          averageWeight: 0,
          targetWeight: 0,
          targetUnmeasured: true,
        ),
      ]);

      expect(find.text('2/2'), findsOneWidget);
      expect(find.text('2/4'), findsNothing);
      // The set was four reps long whatever the sensor caught of it.
      expect(find.textContaining('4 reps'), findsOneWidget);
      expect(find.textContaining('2 unmeasured'), findsOneWidget);
    });

    // The note lengthens the header line the badge shares, and a set of a split
    // repeater is named with its hand, so the longest form of both is checked on
    // the narrowest screen the app runs on.
    testWidgets('fits the unmeasured note in at phone width', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await _pumpSet(tester, [
        _rep(index: 0),
        _rep(index: 1),
        _rep(
          index: 2,
          averageWeight: 0,
          targetWeight: 0,
          targetUnmeasured: true,
        ),
      ], label: 'SET 1 - Right');

      expect(tester.takeException(), isNull);
      expect(find.textContaining('1 unmeasured'), findsOneWidget);
    });

    testWidgets('states the zero a graded set really pulled', (tester) async {
      await _pumpSet(tester, [
        _rep(index: 0, averageWeight: 0),
        _rep(index: 1, averageWeight: 0),
      ]);

      expect(find.text('0/2'), findsOneWidget);
      expect(find.text('Avg Performed'), findsOneWidget);
      expect(find.text('0.0 kg'), findsOneWidget);
    });
  });
}
