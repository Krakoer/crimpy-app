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
}
