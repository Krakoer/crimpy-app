import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/utils/format.dart';

/// The keys that carry no chip of their own because another key already says
/// what they mean. The max effort marker mirrors the load units and only ever
/// travels with the loads, whose chip names the effort.
const _silentOverrideKeys = {'load_is_max'};

/// What one override key reads as. The assessments come along because a value
/// can be a percentage of one, and naming it needs the catalog: the labels stay
/// a pure function of what the week carries, so the screen hands its catalog
/// over rather than lib/utils reaching for a provider.
typedef _ChipLabel = String Function(dynamic value, AssessmentResults results);

/// A chip summarises the whole override, so it shows the first row only.
String _loads(dynamic raw, AssessmentResults results) {
  final first = raw is List ? raw.firstOrNull : null;
  if (first is! Map<String, dynamic>) return '';
  return Load.fromJson(first).label(results: results);
}

String _list(dynamic raw) => raw is List ? raw.join('/') : '';

/// Grips arrive as one array per hand, so each hand reads as its own group.
String _grips(dynamic raw) {
  final byHand = parseHandPositions(raw);
  if (byHand == null) return '';
  return byHand.map((hand) => hand.join('/')).join(' | ');
}

String _hand(dynamic raw) => switch (raw) {
  HangboardHand.both => 'BOTH HANDS',
  HangboardHand.alternate => 'ALTERNATE HANDS',
  HangboardHand.split => 'SPLIT HANDS',
  HangboardHand.left => 'LEFT HAND',
  HangboardHand.right => 'RIGHT HAND',
  _ => '$raw',
};

/// A rep count or a duration the week set as a percentage of an assessment, or
/// the empty targets that say this week prescribes no percentage at all.
///
/// The percentage names what it is a percentage of, the way the tile above the
/// chip and the portal both do: "REPS 75% Max pull ups" rather than a
/// percentage of nothing. An assessment neither the athlete results nor the
/// training carry a definition for reads as a percentage of "assessment", the
/// word the app already uses for one it cannot name, rather than as a raw id.
String _variableTargets(dynamic raw, AssessmentResults results) {
  final targets = parseVariableTargets(raw);
  if (targets.isEmpty) return 'NO PERCENTAGE';
  return targets.entries
      .map(
        (e) =>
            '${e.key.toUpperCase()} ${e.value.percent.round()}% '
            '${results.labelOf(e.value.assessmentId)}',
      )
      .join(', ');
}

/// The label each override key reads as, in the words the item tiles above the
/// chips use. Keyed rather than switched so the set of keys this handles is a
/// value the tests can compare against contract/override-keys.json, the closed
/// key set vendored from itemOverride in
/// crimpy-backend/internal/handler/training_items.go: a key the backend adds
/// and this map forgets would otherwise reach the athlete as raw JSON, which is
/// how "REPS_IS_MAX true" nearly shipped.
final Map<String, _ChipLabel> _labels = {
  'loads': (v, results) => 'LOAD ${_loads(v, results)}',
  'left_loads': (v, results) => 'LEFT ${_loads(v, results)}',
  'reps': (v, _) => 'REPS $v',
  'reps_is_max': (v, _) => v == true ? 'AMRAP' : 'FIXED REPS',
  'duration': (v, _) => 'TIME ${formatSecondsAsLength(v as int)}',
  'cycles': (v, _) => 'CYCLES $v',
  'interval_seconds': (v, _) => 'EVERY ${formatSecondsAsLength(v as int)}',
  'cycle_rest_seconds': (v, _) =>
      'CYCLE REST ${formatSecondsAsLength(v as int)}',
  'rest_seconds': (v, _) => 'REST ${formatSecondsAsLength(v as int)}',
  'hb_worktime_seconds': (v, _) => 'WORK ${formatSecondsAsLength(v as int)}',
  'edge_sizes_mm': (v, _) => 'EDGE ${_list(v)}mm',
  'hand_positions': (v, _) => 'GRIP ${_grips(v)}',
  'hand': (v, _) => _hand(v),
  'granularity': (v, _) => 'LAYOUT ${'$v'.toUpperCase()}',
  'variable_targets': _variableTargets,
};

/// Every key [overrideChipLabels] can name, plus the ones it deliberately keeps
/// silent. Together these have to cover contract/override-keys.json, which is
/// what override_labels_test asserts.
Set<String> get labelledOverrideKeys => {
  ..._labels.keys,
  ..._silentOverrideKeys,
};

/// What one program week asks of an item, one short label per key it carries.
/// A key with no entry in [_labels] falls through to the raw key and value,
/// which is a bug rather than a format: the tests assert it cannot happen.
///
/// [results] names the assessments a percentage is read against. It is required
/// rather than defaulted: a screen that left it out would still render, just
/// saying "75% assessment" where it could name the reference, and nothing would
/// fail. Passing [AssessmentResults.none] says that was meant.
List<String> overrideChipLabels(
  Map<String, dynamic> overrides, {
  required AssessmentResults results,
}) {
  final labels = <String>[];
  overrides.forEach((key, value) {
    if (_silentOverrideKeys.contains(key)) return;
    final label = _labels[key];
    labels.add(
      label == null ? '${key.toUpperCase()} $value' : label(value, results),
    );
  });
  return labels;
}
