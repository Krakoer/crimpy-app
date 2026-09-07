import 'package:crimpy/models/training_item_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/override_contract.dart';

/// A base whose every field differs from the sample the contract carries, so a
/// merged field that still reads the base value means the key was dropped.
TrainingItem baseItem() => TrainingItem.fromJson({
  'id': 'a',
  'type': 'repeater',
  'position': 0,
  'cycles': 1,
  'cycle_rest_seconds': 30,
  'interval_seconds': 60,
  'reps': 2,
  'reps_is_max': false,
  'duration': 30,
  'rest_seconds': 10,
  'worktime_seconds': 5,
  'hand': 'split',
  'granularity': 'uniform',
  'load_is_max': false,
  'loads': [
    {'unit': 'kg', 'value': 1},
  ],
  'left_loads': [
    {'unit': 'kg', 'value': 2},
  ],
  'hand_positions': [
    ['OC'],
  ],
  'edge_sizes_mm': [10],
});

void main() {
  final contract = readOverrideContract();

  group('the override key contract', () {
    test('applies every key to the item', () {
      for (final entry in contract) {
        // Without this the assertion below can pass on a key nothing merges,
        // where the base happens to already hold the sample.
        expect(
          baseItem().toJson()[entry.itemField],
          isNot(entry.sample),
          reason:
              '${entry.key}: the base has to differ from the contract sample '
              'or the merge proves nothing',
        );
        final overridden = baseItem().applyOverride({entry.key: entry.sample});
        expect(
          overridden.toJson()[entry.itemField],
          entry.sample,
          reason: '${entry.key} never reaches the item',
        );
      }
    });
  });
}
