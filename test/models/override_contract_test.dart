import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/utils/override_labels.dart';
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
    test('names the same keys as the backend', () {
      expect(
        overrideKeys,
        contract.map((entry) => entry.key).toSet(),
        reason:
            'a key on one side only is dropped from the prescription by whichever '
            'client does not read it',
      );
    });

    test('applies every key to the item', () {
      for (final entry in contract) {
        final overridden = baseItem().applyOverride({entry.key: entry.sample});
        expect(
          overridden.toJson()[entry.itemField],
          entry.sample,
          reason: '${entry.key} never reaches the item',
        );
      }
    });

    test('names every key on a chip, or keeps it deliberately silent', () {
      for (final entry in contract) {
        expect(
          labelledOverrideKeys,
          contains(entry.key),
          reason: '${entry.key} would reach the athlete as raw JSON',
        );
      }
    });
  });
}
