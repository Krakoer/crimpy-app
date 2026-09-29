import 'package:crimpy/models/assessment_history.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:flutter_test/flutter_test.dart';

final _maxForce = BuiltinAssessmentIds.definitionOf(AssessmentType.mvc);

AssessmentModel _result(
  DateTime date, {
  double? right,
  double? left,
  AssessmentOrigin origin = AssessmentOrigin.test,
}) => AssessmentModel(
  id: 'a-${date.millisecondsSinceEpoch}',
  date: date,
  definition: _maxForce,
  rightValue: right,
  leftValue: left,
  origin: origin,
);

void main() {
  final now = DateTime(2026, 9, 29, 12);

  test('a pull kept on one hand leaves the other at its tested value', () {
    final history = AssessedHistory(
      definition: _maxForce,
      records: [
        _result(DateTime(2026, 9, 24), right: 40.1, left: 38.4),
        _result(now, right: 42.6, origin: AssessmentOrigin.training),
      ],
    );

    expect(
      history.lastResultLine(now),
      'R: 42.6 kg (training)  L: 38.4 kg  today',
    );
  });

  test('a test reads without a marker', () {
    final history = AssessedHistory(
      definition: _maxForce,
      records: [_result(DateTime(2026, 9, 24), right: 40.1, left: 38.4)],
    );

    expect(history.lastResultLine(now), 'R: 40.1 kg  L: 38.4 kg  5d ago');
  });

  test('nothing measured reads as nothing', () {
    expect(
      AssessedHistory(
        definition: _maxForce,
        records: const [],
      ).lastResultLine(now),
      isNull,
    );
  });
}
