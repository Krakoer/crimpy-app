import 'package:crimpy/utils/override_labels.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/override_contract.dart';

void main() {
  group('overrideChipLabels', () {
    test('names every key a week may carry, and never falls through', () {
      // The fallthrough prints the raw key and value, which is how
      // Krakoer/crimpy#51 nearly shipped "REPS_IS_MAX true" to an athlete. A key
      // added to itemOverride on the backend and forgotten here fails this.
      final sample = {
        for (final entry in readOverrideContract()) entry.key: entry.sample,
      };
      final contractKeys = sample.keys.toSet();

      // The assertions below all read the contract, so an empty or truncated one
      // would satisfy them saying nothing. CI diffs the file against the backend
      // and would catch that first, but a local run should not go quietly green.
      expect(contractKeys, isNotEmpty);
      expect(
        contractKeys.difference(labelledOverrideKeys),
        isEmpty,
        reason:
            'these keys of contract/override-keys.json carry no label, so they '
            'would reach the athlete as raw JSON',
      );
      // Every key still has to produce something, on a realistic value. A
      // silenced key produces no chip at all, so it is named here rather than
      // passing on an empty list: a key silenced by mistake would otherwise
      // reach the athlete as a blank where the week asked for something.
      const silenced = {'load_is_max'};
      for (final key in contractKeys) {
        final labels = overrideChipLabels({key: sample[key]});
        if (silenced.contains(key)) {
          expect(labels, isEmpty, reason: '$key is meant to carry no chip');
          continue;
        }
        expect(labels, isNotEmpty, reason: '$key shows the athlete nothing');
        expect(labels.every((label) => label.trim().isNotEmpty), isTrue);
      }
    });

    test('reads a max effort as MAX rather than as a load of nothing', () {
      // The marker itself carries no chip, so the load chip is the only thing
      // that says the week asks for a max effort.
      final labels = overrideChipLabels({
        'load_is_max': true,
        'loads': [
          {'unit': 'max', 'value': 0},
        ],
      });

      expect(labels, ['LOAD MAX']);
    });

    test('spells a time the way the tile above it does', () {
      expect(overrideChipLabels({'duration': 90}), ['TIME 1mn 30s']);
      expect(overrideChipLabels({'interval_seconds': 120}), ['EVERY 2mn']);
      expect(overrideChipLabels({'rest_seconds': 45}), ['REST 45s']);
    });

    test('says an open rep count and a closed one apart', () {
      expect(overrideChipLabels({'reps_is_max': true}), ['AMRAP']);
      expect(overrideChipLabels({'reps_is_max': false}), ['FIXED REPS']);
    });

    test('names a percentage, and its absence when a week clears one', () {
      expect(
        overrideChipLabels({
          'variable_targets': {
            'reps': {'assessment_id': 'a1', 'percent': 75, 'fallback': 8},
          },
        }),
        ['REPS 75%'],
      );
      expect(overrideChipLabels({'variable_targets': <String, dynamic>{}}), [
        'NO PERCENTAGE',
      ]);
    });
  });
}
