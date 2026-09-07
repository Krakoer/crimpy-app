import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/training_item_model.dart';
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
        final labels = overrideChipLabels({
          key: sample[key],
        }, results: AssessmentResults.none);
        if (silenced.contains(key)) {
          expect(labels, isEmpty, reason: '$key is meant to carry no chip');
          continue;
        }
        expect(
          labels,
          isNotEmpty,
          reason:
              '$key shows the athlete nothing: give it a label in _labels, or '
              'if it is a marker another key already says, silence it in '
              '_silentOverrideKeys and name it in silenced here',
        );
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
      }, results: AssessmentResults.none);

      expect(labels, ['LOAD MAX']);
    });

    test('spells a time the way the tile above it does', () {
      expect(
        overrideChipLabels({'duration': 90}, results: AssessmentResults.none),
        ['TIME 1mn 30s'],
      );
      expect(
        overrideChipLabels({
          'interval_seconds': 120,
        }, results: AssessmentResults.none),
        ['EVERY 2mn'],
      );
      expect(
        overrideChipLabels({
          'rest_seconds': 45,
        }, results: AssessmentResults.none),
        ['REST 45s'],
      );
    });

    test('says an open rep count and a closed one apart', () {
      expect(
        overrideChipLabels({
          'reps_is_max': true,
        }, results: AssessmentResults.none),
        ['AMRAP'],
      );
      expect(
        overrideChipLabels({
          'reps_is_max': false,
        }, results: AssessmentResults.none),
        ['FIXED REPS'],
      );
    });

    test('reads the absence of a percentage when a week clears one', () {
      expect(
        overrideChipLabels({
          'variable_targets': <String, dynamic>{},
        }, results: AssessmentResults.none),
        ['NO PERCENTAGE'],
      );
    });

    test('names the assessment a percentage is read against', () {
      // Without the catalog the chip read "REPS 75%", a percentage of nothing,
      // while the same week reads "75% Max pull ups" in the coach portal.
      final labels = overrideChipLabels({
        'variable_targets': {
          'reps': {
            'assessment_id': _maxPullUps.id,
            'percent': 75,
            'fallback': 8,
          },
        },
      }, results: AssessmentResults.none.withDefinitions(const [_maxPullUps]));

      expect(labels, ['REPS 75% Max pull ups']);
    });

    test('names the assessment a load is a percentage of', () {
      // The chip spells the load exactly as the tile above it does, kilograms
      // included: only the name of the assessment was missing from it.
      final labels = overrideChipLabels(
        {
          'loads': [
            {
              'unit': percentAssessmentUnit,
              'value': 80,
              'assessment_id': _weightedHang.id,
              'fallback': 25,
            },
          ],
        },
        results: AssessmentResults.none.withDefinitions(const [_weightedHang]),
      );

      expect(labels, ['LOAD 80% Weighted hang (25 kg)']);
    });

    test('says a percentage of an unnamed assessment is still one', () {
      // A week can name an assessment that is neither the athlete own nor
      // carried by the training, and Crimpy does not ship it either. The chip
      // then says what the tiles say, rather than an id or a bare percentage.
      final labels = overrideChipLabels({
        'variable_targets': {
          'duration': {
            'assessment_id': 'a9b8c7d6-0000-0000-0000-0000000000ff',
            'percent': 60,
            'fallback': 30,
          },
        },
      }, results: AssessmentResults.none);

      expect(labels, ['DURATION 60% assessment']);
    });
  });
}

/// A coach assessment, so the athlete can only be told its name by the catalog
/// the screen builds from the training and their own results.
const _maxPullUps = AssessmentDefinition(
  id: 'a9b8c7d6-0000-0000-0000-000000000007',
  label: 'Max pull ups',
  unit: AssessmentUnit.repetitions,
  trainingId: 't-max-pull-ups',
);

const _weightedHang = AssessmentDefinition(
  id: 'a9b8c7d6-0000-0000-0000-000000000003',
  label: 'Weighted hang',
  unit: AssessmentUnit.kilograms,
  trainingId: 't-weighted-hang',
);
