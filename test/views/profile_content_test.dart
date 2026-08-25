import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/auth_models.dart' as auth_models;
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/profile_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Signed out, so the bodyweight card stays away and the assessment sections are
/// what the test is left looking at.
class SignedOutAuth extends AuthState {
  @override
  Future<auth_models.User?> build() async => null;
}

const _pullUpPyramid = AssessmentDefinition(
  id: 'a9b8c7d6-0000-0000-0000-000000000001',
  label: 'Pull up pyramid',
  unit: AssessmentUnit.repetitions,
);

const _lockOff = AssessmentDefinition(
  id: 'a9b8c7d6-0000-0000-0000-000000000002',
  label: 'One arm lock off',
  unit: AssessmentUnit.seconds,
  perHand: true,
);

AssessmentModel _record(
  AssessmentDefinition definition, {
  double? right,
  double? left,
  DateTime? date,
}) => AssessmentModel(
  id: '${definition.id}-${date ?? ''}',
  date: date ?? DateTime(2026, 8, 1),
  definition: definition,
  rightValue: right,
  leftValue: left,
);

Future<void> _show(
  WidgetTester tester,
  List<AssessmentModel> assessments,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authStateProvider.overrideWith(SignedOutAuth.new)],
      child: MaterialApp(
        home: Scaffold(
          body: ProfileContent(
            assessments: assessments,
            accentLeft: Colors.green,
            accentRight: Colors.orange,
            goToAssessments: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('gives a coach assessment a section of its own', (tester) async {
    await _show(tester, [_record(_pullUpPyramid, right: 14)]);

    expect(find.text('Pull up pyramid'), findsOneWidget);
  });

  // Calling a pull up count "Right Hand" would misread the result, so a single
  // value assessment shows one card, labelled for the number rather than a hand.
  testWidgets('shows one value when the assessment is not per hand', (
    tester,
  ) async {
    await _show(tester, [_record(_pullUpPyramid, right: 14)]);

    expect(find.text('Best'), findsOneWidget);
    expect(find.text('14 reps'), findsOneWidget);
  });

  testWidgets('keeps the hands apart when the assessment is per hand', (
    tester,
  ) async {
    await _show(tester, [_record(_lockOff, right: 3, left: 6)]);

    expect(find.text('One arm lock off'), findsOneWidget);
    // Two cards, so no single "Best" number stands for the pair.
    expect(find.text('Best'), findsNothing);
    expect(find.text('6s'), findsOneWidget);
    expect(find.text('3s'), findsOneWidget);
  });

  // The section list follows what was measured, so an assessment Crimpy ships
  // and a coach one sit side by side.
  testWidgets('lists a builtin beside a coach assessment', (tester) async {
    await _show(tester, [
      _record(
        BuiltinAssessmentIds.definitionOf(AssessmentType.endurance60),
        right: 120,
        left: 110,
      ),
      _record(_pullUpPyramid, right: 14),
    ]);

    expect(find.text('60% Endurance'), findsOneWidget);
    expect(find.text('Pull up pyramid'), findsOneWidget);
  });

  testWidgets('shows no assessment section before anything is measured', (
    tester,
  ) async {
    await _show(tester, []);

    expect(find.text('Pull up pyramid'), findsNothing);
    expect(find.text('60% Endurance'), findsNothing);
  });
}
