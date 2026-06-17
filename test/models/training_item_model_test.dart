import 'package:crimpy/models/training_item_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrainingItem.fromJson hand_positions', () {
    test('parses a flat hand_positions array', () {
      final item = TrainingItem.fromJson({
        'id': 'i1',
        'type': 'hangboard_rep',
        'position': 0,
        'hand_positions': ['FC', 'OH'],
      });
      expect(item.handPositions, ['FC', 'OH']);
    });

    test('flattens a nested (split-hand) hand_positions array', () {
      final item = TrainingItem.fromJson({
        'id': 'i2',
        'type': 'repeater',
        'position': 1,
        'hand_positions': [
          ['FC', 'FC', 'FC'],
          ['FC', 'FC', 'FC'],
        ],
        'edge_sizes_mm': [10],
        'loads': [
          {'unit': 'percent_bw', 'value': 30},
          {'unit': 'percent_bw', 'value': 100},
        ],
      });
      expect(item.handPositions, ['FC', 'FC', 'FC', 'FC', 'FC', 'FC']);
      expect(item.edgeSizesMm, [10]);
      expect(item.loads, hasLength(2));
    });
  });

  group('TrainingItem.fromJson comment', () {
    test('parses an optional coach comment', () {
      final item = TrainingItem.fromJson({
        'id': 'i3',
        'type': 'exercise',
        'position': 0,
        'comment': 'First rep in pronation, second in supination',
      });
      expect(item.comment, 'First rep in pronation, second in supination');
    });

    test('comment is null when absent and round-trips through toJson', () {
      final item = TrainingItem.fromJson({
        'id': 'i4',
        'type': 'exercise',
        'position': 0,
      });
      expect(item.comment, isNull);
      expect(item.toJson().containsKey('comment'), isFalse);

      final withComment = TrainingItem.fromJson({
        'id': 'i5',
        'type': 'exercise',
        'position': 0,
        'comment': 'Keep elbows tucked',
      });
      expect(withComment.toJson()['comment'], 'Keep elbows tucked');
    });
  });
}
