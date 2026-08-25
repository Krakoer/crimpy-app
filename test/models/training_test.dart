import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:flutter_test/flutter_test.dart';

/// The assessment context the server sends with a training detail, which is the
/// only way an athlete learns what a coach's assessment is: it is not in the
/// catalog they can fetch, since they do not own it.
void main() {
  group('Training.fromJson', () {
    test('reads the assessments the items are prescribed against', () {
      final training = Training.fromJson({
        'id': 't1',
        'title': 'Board work',
        'items': <dynamic>[],
        'referenced_assessments': [
          {
            'id': 'a9b8c7d6-0000-0000-0000-000000000001',
            'label': 'One arm lock off',
            'unit': 'seconds',
            'per_hand': true,
            'training_id': 't-lock-off',
          },
        ],
      });

      final referenced = training.referencedAssessments.single;
      expect(referenced.label, 'One arm lock off');
      expect(referenced.unit, AssessmentUnit.seconds);
      expect(referenced.perHand, isTrue);
    });

    test('reads none when the training references no assessment', () {
      final training = Training.fromJson({
        'id': 't1',
        'title': 'Board work',
        'items': <dynamic>[],
      });

      expect(training.referencedAssessments, isEmpty);
    });

    // The server derives them from the items, so writing them back would only
    // restate what the items already say.
    test('does not send them back', () {
      final training = Training.fromJson({
        'id': 't1',
        'title': 'Board work',
        'items': <dynamic>[],
        'referenced_assessments': [
          {
            'id': 'a9b8c7d6-0000-0000-0000-000000000001',
            'label': 'One arm lock off',
            'unit': 'seconds',
          },
        ],
      });

      expect(training.toJson().containsKey('referenced_assessments'), isFalse);
    });
  });
}
